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
local Type     = loadModule("core/Type.lua")
local Repeated = loadModule("core/Repeated.lua")
local Path     = loadModule("core/Path.lua")
local Manifest = loadModule("metadata/manifest.lua")

local M = {}

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

---Shadow a String field with indirect=false when the struct's ABI
---inlines strings (every current EventDefinition-backed API does).
---Does NOT mutate the shared metadata — returns a shadow table.
local function shadowStringDirect(field, opts)
    if opts.stringDirect and field.type == "String" and field.indirect == nil then
        return setmetatable({ indirect = false }, { __index = field })
    end
    return field
end

---Shadow an Array-with-elements field to add stringDirect +
---container ABI hints without mutating the shared metadata.
local function shadowStringDirectArray(field, opts)
    if field.stringDirect == nil and opts.stringDirect then
        return setmetatable({ stringDirect = true, container = opts.container or "vector" }, { __index = field })
    end
    return field
end

---Build the API module for one defineApi() config. Kept as a
---factory (not exposed directly) so multiple calls with different
---configs never share state.
---@param config table @ { struct = string, resolve = function, stringDirect = boolean|nil, container = string|nil }
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

    local mod = {}
    mod.struct = config.struct
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
            error("defineApi(" .. config.struct .. "): metadata resolution failed: " .. tostring(err))
        end
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
            return baseAddress
        end

        if lastFailErr ~= nil and not forceRescan
            and (nowSec() - lastFailClock) < FAIL_RETRY_SECONDS then
            return nil, lastFailErr
        end

        local address, err = config.resolve()
        if not address then
            lastFailErr = err or "base_not_found"
            lastFailClock = nowSec()
            return nil, lastFailErr
        end

        baseAddress = address
        lastFailErr, lastFailClock = nil, nil
        return baseAddress
    end
    mod.resolveBase = resolveBase

    --==================================================
    -- Field lookup (dotted id, with optional array indices)
    --==================================================

    local function resolvePath(id)
        local segments = Path.parse(id)
        if #segments == 0 then
            return nil, "empty_path"
        end

        local base, baseErr = resolveBase()
        if not base then
            return nil, baseErr
        end

        local metadata = resolveMetadata()
        local currentBase = base
        local currentMeta = metadata
        local finalField = nil

        for i, seg in ipairs(segments) do
            local node = currentMeta[seg.name]
            if node == nil then
                return nil, "unknown_field: " .. tostring(id)
            end

            if seg.index ~= nil then
                if node.type ~= "Array" then
                    return nil, "not_an_array: " .. seg.name
                end
                if not isOffsetKnown(node) then
                    return nil, "offset_unknown: " .. seg.name
                end
                local arr, arrErr = Repeated.get(currentBase, shadowStringDirectArray(node, opts))
                if not arr then
                    return nil, arrErr
                end
                local luaIdx = seg.index
                if luaIdx < 1 or luaIdx > #arr then
                    return nil, string.format("index_out_of_bounds: %s[%d] (size=%d)", seg.name, seg.index, #arr)
                end
                if i == #segments then
                    local elemStride = node.elementStride or 0x8
                    local header, _ = Repeated.readHeaderForSet(currentBase, node)
                    local writeAddr = nil
                    if header and header.arrayPtr and header.arrayPtr ~= 0 then
                        if elemStride > 0x8 then
                            writeAddr = header.arrayPtr + (seg.index - 1) * elemStride
                        else
                            local slots, _ = Memory.readBatchChunked({
                                { address = header.arrayPtr + (seg.index - 1) * 0x8, flags = Memory.FLAGS.INT64 }
                            })
                            if slots and slots[1] and slots[1].value ~= 0 then
                                writeAddr = slots[1].value
                            end
                        end
                    end
                    return { value = arr[luaIdx], resolved = true, writeAddr = writeAddr, elementType = node.elementType }
                end
                if node.elements then
                    local stride = node.elementStride or 0x8
                    if stride > 0x8 then
                        local header, hErr = Repeated.readHeaderForSet(currentBase, node)
                        if not header then return nil, hErr end
                        currentBase = header.arrayPtr + (seg.index - 1) * stride
                    else
                        local h, he = Repeated.readHeaderForSet(currentBase, node)
                        if not h then return nil, he end
                        local slots, sErr = Memory.readBatchChunked({
                            { address = h.arrayPtr + (seg.index - 1) * 0x8, flags = Memory.FLAGS.INT64 }
                        })
                        if not slots or not slots[1] or slots[1].value == 0 then
                            return nil, "null_element_ptr"
                        end
                        currentBase = slots[1].value
                    end
                    currentMeta = node.elements
                else
                    return nil, "array_has_no_elements: " .. seg.name
                end
            elseif isLeafField(node) and i == #segments then
                finalField = node
                break
            elseif type(node) == "table" and not isLeafField(node) and i < #segments then
                currentMeta = node
            else
                return nil, "unknown_field: " .. tostring(id)
            end
        end

        if finalField then
            return { field = finalField, base = currentBase }
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
            return nil, "unsupported_type: Object fields are not yet readable (missing nested metadata)"
        end

        if not isOffsetKnown(field) then
            return nil, "offset_unknown: " .. id
        end

        if field.type == "Array" then
            return Repeated.get(base, shadowStringDirectArray(field, opts))
        end

        if field.repeated then
            return Repeated.get(base, field)
        end

        local impl = Type.resolve(field.type)
        if not impl then
            return nil, "no_type_impl: " .. tostring(field.type)
        end

        return impl.get(base, shadowStringDirect(field, opts))
    end

    local function writeFieldById(id, value)
        local result, err = resolvePath(id)
        if not result then
            return false, err
        end

        if result.resolved then
            if not result.writeAddr then
                return false, "cannot_set_array_element_value_directly"
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
                f.indirect = false
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
            return false, "unsupported_type: Object fields are not yet writable (missing nested metadata)"
        end

        if not isOffsetKnown(field) then
            return false, "offset_unknown: " .. id
        end

        if field.type == "Array" then
            return Repeated.set(base, shadowStringDirectArray(field, opts), value)
        end

        if field.repeated then
            return Repeated.set(base, field, value)
        end

        local impl = Type.resolve(field.type)
        if not impl then
            return false, "no_type_impl: " .. tostring(field.type)
        end

        local ok = impl.set(base, shadowStringDirect(field, opts), value)
        if not ok then
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
            return nil, baseErr
        end

        if id == nil then
            return {
                base = base,
                get = function(fieldId) return readFieldById(fieldId) end,
            }
        end

        return readFieldById(id)
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
                return false, dryErr
            end
            return true, nil
        end
        return writeFieldById(op.id, op.value)
    end

    function SetOperation:dry()
        self._dry = true
        return performWrite(self)
    end

    setmetatable(SetOperation, {
        __call = function(cls, id, value)
            local self = setmetatable({ id = id, value = value, _dry = false }, cls)
            local ok, err = performWrite(self)
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
