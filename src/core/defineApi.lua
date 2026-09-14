--==================================================
-- core/defineApi.lua
--==================================================
-- Generic bridge between an API definition:
--
--   Nebula.defineApi({
--       struct  = "EventDefinition",
--       resolve = function() ... return address, err end,
--   })
--
-- and Nebula's existing struct/field/memory machinery. This is NOT
-- a second parallel API architecture — every get()/set() below
-- routes through the same core/Type.lua, core/Repeated.lua and
-- core/Struct.lua modules the hand-written api/*.lua files always
-- used. What used to be copy-pasted into every event module
-- (resolvePath, readFieldById, writeFieldById, walkFields, the
-- String/Array ABI shadowing) now lives here once.
--
-- Metadata is never version-pinned by the caller: defineApi()
-- resolves the struct's metadata automatically through
-- metadata/manifest.lua, keyed on the struct name and the running
-- game's two-component version. See that file for the resolution
-- rules.
--
-- No field filtering: every field present in the resolved struct
-- metadata is reachable through get()/set()/fields()/meta() —
-- there is no whitelist/blacklist concept here, by design (see
-- metadata/1.73/structs/EventDefinition.lua's header comment).

local Memory   = loadModule("core/Memory.lua")
local Struct   = loadModule("core/Struct.lua")
local Type     = loadModule("core/Type.lua")
local Repeated = loadModule("core/Repeated.lua")
local Path     = loadModule("core/Path.lua")
local Manifest = loadModule("metadata/manifest.lua")
local Trace = loadModule("core/Trace.lua")

local M = {}

-- Per-API log label (config.name, e.g. "PublicEvent") so trace lines
-- read "[PublicEvent] ..." / "[TeamEvent] ..." / "[CommunityEvent] ..."
-- — defaults to the struct name when no label is configured.
local Logfile = loadModule("core/Logfile.lua")

local function log(label, ...)
    if Nebula ~= nil and Nebula.log then
        Logfile.log("[" .. label .. "]", ...)
    end
end

-- Same cooldown convention as every hand-written api/*.lua module:
-- when no struct instance is currently resolvable, don't re-run an
-- expensive scan on every single get()/set() call.
local FAIL_RETRY_SECONDS = 5

local function nowSec()
    if os.clock then return os.clock() end
    return os.time()
end

---A field is a leaf (readable) entry iff its own `type` is a
---string. Pure namespace containers (sessionEntry, gameMode) have
---no `type` of their own — only typed children.
local function isLeafField(node)
    return type(node) == "table" and type(node.type) == "string"
end

local function isOffsetKnown(field)
    return field.offset ~= nil and field.offset ~= 0xBAAD
end

---Resolve the child-field template of a `type = "Object"` field —
---the pattern that makes PlayerInfo.gameStatus.vipStatus work:
---the Object field's own table carries
---the nested struct's fields injected next to `offset`/`type`.
---Also accepted (1.73 EventDefinition.specialFeatures shape): an
---`elements` template table on the Object field. Both are the same
---read: QWORD at base+offset -> nested object base -> fields there.
---Returns nil for genuinely childless Object fields (still rejected).
---The returned template preserves the parent field's `stringDirect`
---property so the subtree uses the correct string ABI. We shallow-copy
---the elements table so `pairs()` iteration (used by Struct.get) sees
---all fields; `stringDirect` is stored directly on the copy.
local function objectChildTemplate(field)
    if type(field) ~= "table" then return nil end
    for _, v in pairs(field) do
        if type(v) == "table" and type(v.offset) == "number" then
            return field        -- vipStatus pattern: injected children
        end
    end
    if type(field.elements) == "table" then
        local tpl = {}
        for k, v in pairs(field.elements) do
            tpl[k] = v
        end
        -- Preserve stringDirect on the template for ABI propagation
        if field.stringDirect ~= nil then
            tpl.stringDirect = field.stringDirect
        end
        return tpl
    end
    return nil
end

---Shadow a String field with indirect=false when the ABI inlines
---strings (every EventDefinition-backed API does). Does NOT
---mutate the shared metadata — returns a shadow table.
local function shadowStringDirect(field, direct)
    if direct and field.type == "String" and field.indirect == nil then
        return setmetatable({ indirect = false }, { __index = field })
    end
    return field
end

---Shadow an Array-with-elements field to add stringDirect +
---container ABI hints without mutating the shared metadata.
local function shadowStringDirectArray(field, direct, container)
    if field.stringDirect == nil and direct then
        return setmetatable({ stringDirect = true, container = container or "vector" }, { __index = field })
    end
    return field
end

---Build the API module for one defineApi() config. Kept as a
---factory (not exposed directly) so multiple calls with different
---configs never share state.
---@param config table @ { struct = string, resolve = function, stringDirect = boolean|nil, container = string|nil }
---A type = "Object" field in the struct metadata may declare its own
---`stringDirect` key: the subtree behind that pointer then uses THAT
---ABI (e.g. PlayerInfo.gameStatus is `stringDirect = false` — the
---proto2 GameStatus family with indirect strings and protobuf array
---headers — instead of PlayerInfo's inline/vector ABI).
function M.create(config)
    assert(type(config) == "table", "defineApi requires a config table")
    assert(type(config.struct) == "string" and config.struct ~= "", "defineApi requires config.struct")
    assert(type(config.resolve) == "function", "defineApi requires config.resolve")

    -- Every event struct currently migrated to this system inlines
    -- its strings and uses std::vector arrays — same default every
    -- hand-written event api module hardcoded. A future struct with
    -- a different ABI can override either via config.
    local opts = {
        stringDirect = config.stringDirect ~= false,
        container    = config.container or "vector",
    }

    local label = config.name or config.struct
    local function apilog(...)
        log(label, ...)
    end

    ---Standardized address-trace record — see core/Trace.lua. Every
    ---defineApi-backed module (current and future) emits the same
    ---record format automatically from here.
    local function rec(tag, kv)
        Trace.rec(label, tag, kv)
    end

    local mod = {}
    mod.struct = config.struct
    mod.name = label
    -- Exposed for tests only (see test/defineApi_spec.lua) — lets a
    -- test confirm the real resolver function was wired in, without
    -- needing to execute it against a live device.
    mod._resolve = config.resolve

    --==================================================
    -- Metadata resolution (automatic, per metadata/manifest.lua)
    --==================================================

    local resolvedMetadata, resolvedVersion = nil, nil

    local function resolveMetadata()
        if resolvedMetadata ~= nil then
            return resolvedMetadata
        end
        local metadata, version, err = Manifest.resolve(config.struct)
        if not metadata then
            rec("null", { STRUCT = config.struct, ERR = "metadata_resolution_failed: " .. tostring(err) })
            error("defineApi(" .. config.struct .. "): metadata resolution failed: " .. tostring(err))
        end
        rec("meta", { STRUCT = config.struct, VER = version,
            INFO = "top_level_keys=" .. (function()
                local n = 0
                for _ in pairs(metadata) do n = n + 1 end
                return n
            end)() })
        resolvedMetadata, resolvedVersion = metadata, version
        return resolvedMetadata
    end

    -- Lazily resolved so constructing the module never fails just
    -- because the game/device isn't attached yet.
    mod.metadata = setmetatable({}, {
        __index = function(_, k) return resolveMetadata()[k] end,
    })

    ---@return string|nil version @ the metadata version currently in use (e.g. "1.73")
    function mod.metadataVersion()
        resolveMetadata()
        return resolvedVersion
    end

    --==================================================
    -- Base address resolution
    --==================================================

    local baseAddress = nil
    local lastFailErr, lastFailClock = nil, nil

    local function resolveBase(forceRescan)
        if baseAddress ~= nil and not forceRescan then
            rec("resolve", { MODE = "warm", ADDR = baseAddress, STRUCT = config.struct })
            return baseAddress
        end

        if lastFailErr ~= nil and not forceRescan
            and (nowSec() - lastFailClock) < FAIL_RETRY_SECONDS then
            apilog(string.format("resolveBase: still in fail-cooldown (%.1fs left): %s",
                FAIL_RETRY_SECONDS - (nowSec() - lastFailClock), tostring(lastFailErr)))
            return nil, lastFailErr
        end

        local address, err = config.resolve()
        if not address then
            lastFailErr = err or "base_not_found"
            lastFailClock = nowSec()
            rec("null", { ADDR = "NULL/INVALID", ERR = "resolveBase_failed: " .. tostring(lastFailErr) })
            return nil, lastFailErr
        end

        baseAddress = address
        lastFailErr, lastFailClock = nil, nil
        rec("resolve", { MODE = "cold", ADDR = address, STRUCT = config.struct,
            VER = resolvedVersion, INFO = forceRescan and "forced_rescan" or nil })
        return baseAddress
    end
    mod.resolveBase = resolveBase

    --==================================================
    -- Field lookup (dotted id, with optional array indices)
    --==================================================

    local function resolvePath(id)
        local segments = Path.parse(id)
        if #segments == 0 then
            apilog("resolvePath: empty path")
            return nil, "empty_path"
        end

        local base, baseErr = resolveBase()
        if not base then
            apilog("resolvePath '" .. tostring(id) .. "': base resolution failed: " .. tostring(baseErr))
            return nil, baseErr
        end

        local metadata = resolveMetadata()
        local currentBase = base
        local currentMeta = metadata
        local finalField = nil

        -- ABI state threading. opts.stringDirect describes THIS
        -- struct's string/array ABI (inline vs pointer-deref'd
        -- strings, vector vs protobuf arrays). Struct families with
        -- a DIFFERENT ABI are entered through a type = "Object"
        -- field that declares its own `stringDirect` key (e.g.
        -- PlayerInfo.gameStatus -> the proto2 GameStatus subtree
        -- is `stringDirect = false`: indirect strings + protobuf
        -- array headers, exactly as raw metadata declares them).
        -- The state is inherited downward and used for the final
        -- field's dispatch — a leaf never re-applies the root ABI
        -- to a subtree that declared its own.
        local currentDirect = opts.stringDirect

        rec("path", { PATH = tostring(id), ADDR = base, SEG = #segments })

        for i, seg in ipairs(segments) do
            local node = currentMeta[seg.name]
            if node == nil then
                apilog(string.format("resolvePath: seg[%d] '%s' NOT FOUND in metadata", i, seg.name))
                return nil, "unknown_field: " .. tostring(id)
            end

            if seg.index ~= nil then
                if node.type ~= "Array" then
                    apilog(string.format("resolvePath: seg[%d] '%s[%d]' indexed but type=%s is not Array", i, seg.name, seg.index, tostring(node.type)))
                    return nil, "not_an_array: " .. seg.name
                end
                if not isOffsetKnown(node) then
                    apilog(string.format("resolvePath: seg[%d] '%s[%d]': offset_unknown", i, seg.name, seg.index))
                    return nil, "offset_unknown: " .. seg.name
                end
                local arr, arrErr = Repeated.get(currentBase, shadowStringDirectArray(node, currentDirect, opts.container))
                if not arr then
                    apilog(string.format("resolvePath: '%s[%d]' array read FAILED: %s", seg.name, seg.index, tostring(arrErr)))
                    return nil, arrErr
                end
                local luaIdx = seg.index
                if luaIdx < 1 or luaIdx > #arr then
                    apilog(string.format("resolvePath: '%s[%d]' REJECTED: index out of bounds (size=%d)", seg.name, seg.index, #arr))
                    return nil, string.format("index_out_of_bounds: %s[%d] (size=%d)", seg.name, seg.index, #arr)
                end
                if i == #segments then
                    local elemStride = node.elementStride or 0x8
                    local header, _ = Repeated.readHeaderForSet(currentBase, shadowStringDirectArray(node, currentDirect, opts.container))
                    local writeAddr = nil
                    local writeErr = nil
                    if header and header.arrayPtr and header.arrayPtr ~= 0 then
                        if elemStride > 0x8 then
                            writeAddr = header.arrayPtr + (seg.index - 1) * elemStride
                        else
                            local slots, _ = Memory.readBatchChunked({
                                { address = header.arrayPtr + (seg.index - 1) * 0x8, flags = Memory.FLAGS.INT64 }
                            })
                            if slots and slots[1] and slots[1].value ~= 0 then
                                writeAddr = slots[1].value
                            else
                                writeErr = "null_element_ptr"
                            end
                        end
                    else
                        writeErr = "null_array_ptr"
                    end
                    return { value = arr[luaIdx], resolved = true, writeAddr = writeAddr, writeErr = writeErr, elementType = node.elementType, elements = node.elements, direct = currentDirect }
                end
                if node.elements then
                    local stride = node.elementStride or 0x8
                    if stride > 0x8 then
                        local header, hErr = Repeated.readHeaderForSet(currentBase, shadowStringDirectArray(node, currentDirect, opts.container))
                        if not header then return nil, hErr end
                        currentBase = header.arrayPtr + (seg.index - 1) * stride
                        rec("elem", { PATH = tostring(id), FIELD = seg.name,
                            IDX = seg.index - 1, PTR = header.arrayPtr,
                            ELEM = currentBase, NESTED = currentBase, STRIDE = stride })
                    else
                        local h, he = Repeated.readHeaderForSet(currentBase, shadowStringDirectArray(node, currentDirect, opts.container))
                        if not h then return nil, he end
                        local slotAddr = h.arrayPtr + (seg.index - 1) * 0x8
                        local slots, sErr = Memory.readBatchChunked({
                            { address = slotAddr, flags = Memory.FLAGS.INT64 }
                        })
                        if not slots or not slots[1] or slots[1].value == 0 then
                            rec("null", { PATH = tostring(id), FIELD = seg.name,
                                IDX = seg.index - 1, SLOT = slotAddr,
                                ADDR = "NULL/INVALID", ERR = "null_element_ptr" })
                            return nil, "null_element_ptr"
                        end
                        currentBase = slots[1].value
                        rec("elem", { PATH = tostring(id), FIELD = seg.name,
                            IDX = seg.index - 1, SLOT = slotAddr, PTR = h.arrayPtr,
                            ELEM = currentBase, NESTED = currentBase })
                    end
                    currentMeta = node.elements
                else
                    return nil, "array_has_no_elements: " .. seg.name
                end
            elseif isLeafField(node) and i == #segments then
                rec("path", { PATH = tostring(id), FIELD = seg.name, SEG = i,
                    TYPE = tostring(node.type), OFF = node.offset or 0,
                    ADDR = currentBase + (node.offset or 0) })
                finalField = node
                break
            elseif type(node) == "table" and node.type == "Object" and i < #segments then
                -- mid-path Object: descend via the field QWORD —
                -- same chain as GameStatus (e.g. "vipStatus.isVip").
                if not isOffsetKnown(node) then
                    return nil, "offset_unknown: " .. seg.name
                end
                local template = objectChildTemplate(node)
                if not template then
                    return nil, "object_has_no_children: " .. seg.name
                end
                rec("path", { PATH = tostring(id), FIELD = seg.name, SEG = i,
                    TYPE = "Object", OFF = node.offset or 0,
                    ADDR = currentBase + (node.offset or 0) })
                local ptr = Memory.deref(currentBase, node.offset)
                if not ptr or ptr == 0 then
                    rec("null", { PATH = tostring(id), FIELD = seg.name,
                        OFF = node.offset or 0, PTR = "NULL/INVALID",
                        ERR = "null_pointer" })
                    return nil, "null_pointer: " .. seg.name
                end
                rec("nested", { PATH = tostring(id), FIELD = seg.name,
                    OFF = node.offset or 0, QWORD = ptr, PTR = ptr,
                    NESTED = ptr, INFO = "mid_path_object" })
                currentBase = ptr
                currentMeta = template
                if node.stringDirect ~= nil then
                    currentDirect = node.stringDirect
                    rec("meta", { PATH = tostring(id), FIELD = seg.name,
                        INFO = "abi_override stringDirect="
                            .. tostring(currentDirect) })
                end
            elseif type(node) == "table" and not isLeafField(node) and i < #segments then
                apilog(string.format("resolvePath: seg[%d] '%s' namespace container (descending)", i, seg.name))
                currentMeta = node
            else
                apilog(string.format("resolvePath: seg[%d] '%s' unresolvable node shape", i, seg.name))
                return nil, "unknown_field: " .. tostring(id)
            end
        end

        if finalField then
            return { field = finalField, base = currentBase, direct = currentDirect }
        end
        return nil, "unknown_field: " .. tostring(id)
    end
    -- Exposed for focused tests (see test/defineApi_spec.lua) — not
    -- part of the documented public surface.
    mod._resolvePath = resolvePath

    local function readFieldById(id)
        local result, err = resolvePath(id)
        if not result then
            return nil, err
        end

        if result.resolved then
            return result.value
        end

        local field = result.field
        local base = result.base

        if field.type == "Object" then
            -- vipStatus pattern (see objectChildTemplate): an
            -- Object field is read by taking the QWORD at
            -- base+offset — the nested object's runtime base (e.g. a
            -- std::list's START QWORD) — and reading the nested
            -- fields AT that base. No extra offsets. NULL/0 is
            -- recorded and rejected, never blindly dereferenced.
            local template = objectChildTemplate(field)
            if template and isOffsetKnown(field) then
                local fieldAddr = base + field.offset
                rec("get", { PATH = tostring(id), TYPE = "Object",
                    OFF = field.offset, ADDR = fieldAddr,
                    INFO = "qword-read" })
                local ptr = Memory.deref(base, field.offset)
                if not ptr or ptr == 0 then
                    rec("null", { PATH = tostring(id), TYPE = "Object",
                        OFF = field.offset, ADDR = fieldAddr,
                        PTR = "NULL/INVALID", ERR = "null_pointer" })
                    return nil, "null_pointer: " .. tostring(id)
                end
                rec("nested", { PATH = tostring(id), FIELD = tostring(id),
                    OFF = field.offset, ADDR = fieldAddr, QWORD = ptr,
                    PTR = ptr, NESTED = ptr, INFO = "object_base" })
                -- field.stringDirect may be FALSE (a proto2 subtree
                -- boundary like gameStatus). A plain `a and b or c`
                -- chain falls through to result.direct when the
                -- override is false — leaking the root ABI past
                -- the boundary — so pick it explicitly.
                local leafDirect = result.direct
                if field.stringDirect ~= nil then
                    leafDirect = field.stringDirect
                end
                return Struct.get(ptr, template, leafDirect, tostring(id))
            end
            apilog("get '" .. tostring(id) .. "': Object type — not readable, rejected (no nested metadata)")
            return nil, "unsupported_type: Object fields are not yet readable (missing nested metadata)"
        end

        if not isOffsetKnown(field) then
            apilog(string.format("get '%s': offset_unknown (0x%X placeholder)", tostring(id), field.offset or 0))
            return nil, "offset_unknown: " .. id
        end

        if field.type == "Array" then
            rec("get", { PATH = tostring(id), TYPE = "Array",
                OFF = field.offset or 0, ADDR = base + (field.offset or 0),
                ELEM_TYPE = field.elementType, STRIDE = field.elementStride or 0x8 })
            return Repeated.get(base, shadowStringDirectArray(field, result.direct, opts.container), nil, tostring(id))
        end

        if field.repeated then
            apilog(string.format("get '%s': dispatching repeated read (base=0x%X + offset=0x%X)",
                tostring(id), base, field.offset or 0))
            return Repeated.get(base, field)
        end

        local impl = Type.resolve(field.type)
        if not impl then
            apilog("get '" .. tostring(id) .. "': no_type_impl '" .. tostring(field.type) .. "'")
            return nil, "no_type_impl: " .. tostring(field.type)
        end

        rec("get", { PATH = tostring(id), TYPE = tostring(field.type),
            OFF = field.offset or 0, ADDR = base + (field.offset or 0) })
        return impl.get(base, shadowStringDirect(field, result.direct))
    end

    local function writeFieldById(id, value)
        local result, err = resolvePath(id)
        if not result then
            return false, err
        end

        if result.resolved then
            if not result.writeAddr then
                local werr = result.writeErr or "cannot_set_array_element_value_directly"
                apilog(string.format("set '%s': element not writable (%s) — rejected", tostring(id), tostring(werr)))
                return false, werr
            end
            -- Whole element-struct write (elements-template array):
            -- Struct.set AT the element address with the template,
            -- mirroring the whole-Object write semantics — partial
            -- values are allowed, only the provided keys are
            -- written, and the existing instance is edited in
            -- place, never re-allocated.
            if result.elements then
                if type(value) ~= "table" then
                    apilog("set '" .. tostring(id) .. "': element struct write REJECTED — value is not a table")
                    return false, "value_not_table"
                end
                rec("set", { PATH = tostring(id), TYPE = "Element",
                    OFF = 0, ADDR = result.writeAddr,
                    INFO = "element_template" })
                local ok = Struct.set(result.writeAddr, result.elements, value, result.direct)
                if not ok then
                    apilog("set '" .. tostring(id) .. "': element struct write FAILED")
                    return false, "write_failed"
                end
                return true, nil
            end
            local elemType = result.elementType
            if not elemType then
                return false, "unknown_element_type"
            end
            local impl = Type.resolve(elemType)
            if not impl then
                return false, "no_type_impl: " .. tostring(elemType)
            end
            local f = { offset = 0, type = elemType }
            if elemType == "String" then
                -- vector/stringDirect arrays inline their string
                -- elements; proto2 subtrees (direct=false) keep the
                -- String impl's indirect default
                f = shadowStringDirect(f, result.direct)
            end
            local ok = impl.set(result.writeAddr, f, value)
            if not ok then
                return false, "write_failed"
            end
            return true, nil
        end

        local field = result.field
        local base = result.base

        if field.type == "Object" then
            -- Write twin of readFieldById's Object branch: QWORD at
            -- base+offset is the nested object's runtime base;
            -- Struct.set writes the provided fields AT that base.
            -- NULL/0 is recorded and rejected, never blindly
            -- dereferenced. Never allocates a new object — a whole
            -- Object set only edits the existing instance.
            local template = objectChildTemplate(field)
            if template and isOffsetKnown(field) then
                local fieldAddr = base + field.offset
                rec("set", { PATH = tostring(id), TYPE = "Object",
                    OFF = field.offset, ADDR = fieldAddr,
                    INFO = "qword-write" })
                local ptr = Memory.deref(base, field.offset)
                if not ptr or ptr == 0 then
                    rec("null", { PATH = tostring(id), TYPE = "Object",
                        OFF = field.offset, ADDR = fieldAddr,
                        PTR = "NULL/INVALID", ERR = "null_pointer" })
                    return false, "null_pointer: " .. tostring(id)
                end
                rec("nested", { PATH = tostring(id), FIELD = tostring(id),
                    OFF = field.offset, ADDR = fieldAddr, QWORD = ptr,
                    PTR = ptr, NESTED = ptr, INFO = "object_base" })
                -- field.stringDirect may be FALSE (a proto2 subtree boundary).
                -- Explicit pick: `a and b or c` falls through to
                -- result.direct on a false override.
                local leafDirect = result.direct
                if field.stringDirect ~= nil then
                    leafDirect = field.stringDirect
                end
                local ok = Struct.set(ptr, template, value, leafDirect)
                if not ok then
                    apilog("set '" .. tostring(id) .. "': Object write FAILED")
                    return false, "write_failed"
                end
                return true, nil
            end
            return false, "unsupported_type: Object fields are not yet writable (missing nested metadata)"
        end

        if not isOffsetKnown(field) then
            return false, "offset_unknown: " .. id
        end

        if field.type == "Array" then
            return Repeated.set(base, shadowStringDirectArray(field, result.direct, opts.container), value)
        end

        if field.repeated then
            return Repeated.set(base, field, value)
        end

        local impl = Type.resolve(field.type)
        if not impl then
            apilog("set '" .. tostring(id) .. "': no_type_impl '" .. tostring(field.type) .. "'")
            return false, "no_type_impl: " .. tostring(field.type)
        end

        rec("set", { PATH = tostring(id), TYPE = tostring(field.type),
            OFF = field.offset or 0, ADDR = base + (field.offset or 0) })
        local ok = impl.set(base, shadowStringDirect(field, result.direct), value)
        if not ok then
            apilog("set '" .. tostring(id) .. "': write FAILED")
            return false, "write_failed"
        end
        return true, nil
    end

    --==================================================
    -- get()
    --==================================================

    ---@param id string|nil @ omit to get an accessor bound to the currently-resolved struct instance
    ---@return any|nil value, string|nil error
    function mod.get(id)
        local base, baseErr = resolveBase()
        if not base then
            apilog("get: base unresolved (" .. tostring(baseErr) .. ")")
            return nil, baseErr
        end

        if id == nil then
            apilog(string.format("get(): accessor bound to base=0x%X", base))
            return {
                base = base,
                get = function(fieldId) return readFieldById(fieldId) end,
            }
        end

        local op = Trace.beginOp(label, "get", { ADDR = base, STRUCT = config.struct })
        local value, err = readFieldById(id)
        Trace.fieldDone(op, tostring(id), value ~= nil or err == nil)
        Trace.endOp(op)
        return value, err
    end

    --==================================================
    -- set() — chainable operation object supporting :dry()
    --==================================================

    local SetOperation = {}
    SetOperation.__index = SetOperation

    local function performWrite(op)
        if op._dry then
            local result, dryErr = resolvePath(op.id)
            if not result then
                apilog("set(dry) '" .. tostring(op.id) .. "': path resolution failed — " .. tostring(dryErr))
                return false, dryErr
            end
            if result.resolved then
                apilog(string.format("set(dry) '%s': element path resolvable (writable=%s, template=%s) — no write performed",
                    tostring(op.id), tostring(result.writeAddr ~= nil),
                    tostring(result.elements ~= nil or result.elementType ~= nil)))
            else
                apilog("set(dry) '" .. tostring(op.id) .. "': path resolvable, no write performed")
            end
            return true, nil
        end
        return writeFieldById(op.id, op.value)
    end

    function SetOperation:dry()
        self._dry = true
        return performWrite(self)
    end

    --==================================================
    -- :verify() — read-back verification. Compares the value
    -- actually in memory against the one this operation wrote
    -- (or intended to write). Numbers compare with a small
    -- float32 tolerance; tables compare recursively over the
    -- EXPECTED keys only, so a partial element-struct write
    -- verifies against a full read-back cleanly.
    --==================================================

    local function valuesMatch(expected, actual)
        if type(expected) == "number" and type(actual) == "number" then
            return math.abs(expected - actual) <= 1e-4
        end
        if type(expected) ~= type(actual) then
            return false
        end
        if type(expected) == "table" then
            for k, v in pairs(expected) do
                if not valuesMatch(v, actual[k]) then
                    return false
                end
            end
            return true
        end
        return expected == actual
    end

    function SetOperation:verify()
        if self._dry then
            return self
        end
        if not self._ok then
            self._verified = false
            self._actual = nil
            return self
        end
        local actual = readFieldById(self.id)
        self._actual = actual
        self._verified = valuesMatch(self.value, actual)
        if not self._verified then
            apilog(string.format("verify '%s': READ-BACK MISMATCH — expected=%s actual=%s",
                tostring(self.id), tostring(self.value), tostring(actual)))
        end
        return self
    end

    setmetatable(SetOperation, {
        __call = function(cls, id, value)
            local self = setmetatable({ id = id, value = value, _dry = false }, cls)
            local op = Trace.beginOp(label, "set", { STRUCT = config.struct })
            Trace.fieldDone(op, tostring(id), true) -- marked below by outcome
            local ok, err = performWrite(self)
            op.slow[#op.slow].ok = ok
            if not ok then
                op.ok, op.fail = op.ok - 1, op.fail + 1
                rec("null", { PATH = tostring(id), ERR = "set_failed: " .. tostring(err) })
            end
            Trace.endOp(op)
            self._ok, self._err = ok, err
            return self
        end
    })

    ---@param id string @ dotted field id
    ---@param value any
    ---@return table operation @ chainable; already executed
    function mod.set(id, value)
        return SetOperation(id, value)
    end

    --==================================================
    -- fields() / meta() — read-only introspection
    --==================================================

    local function walkFields(node, prefix, results)
        for key, child in pairs(node) do
            if type(child) == "table" then
                local id = prefix and (prefix .. "." .. key) or key
                if isLeafField(child) then
                    if isOffsetKnown(child) then
                        results[#results + 1] = id
                    end
                else
                    walkFields(child, id, results)
                end
            end
        end
    end

    ---List every offset-verified field's dotted id — every field
    ---the resolved struct metadata defines, with no filtering.
    ---@return string[] ids
    function mod.fields()
        local results = {}
        walkFields(resolveMetadata(), nil, results)
        table.sort(results)
        return results
    end

    ---@param id string
    ---@return table|nil metaView, string|nil error
    function mod.meta(id)
        local result, err = resolvePath(id)
        local field = result and result.field
        if not field then
            return nil, err
        end

        local view = {
            name     = id,
            type     = field.type,
            offset   = field.offset,
            repeated = field.repeated == true or field.type == "Array",
            known    = isOffsetKnown(field),
        }

        if baseAddress ~= nil and view.known then
            view.address = baseAddress + field.offset
        end

        return view
    end

    return mod
end

return M
