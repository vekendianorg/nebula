--==================================================
-- core/Struct.lua
--==================================================
-- Reads/writes a struct element using a metadata template
-- (the `elements` sub-table on an Array field). Called by
-- core/Repeated.lua when a repeated field's slots point to struct
-- elements rather than inline scalars.
--
-- Node shapes from the metadata template:
--
-- LEAF FIELD — has `type` (string) and `offset`, no child
-- sub-tables with their own offsets:
--   { offset = 0x20, type = "Int32" }
--
-- ARRAY FIELD — has `type = "Array"`, `offset`, AND either
-- `elements` (struct-element template) or `elementType` +
-- `elementStride` (simple typed elements). Dispatched to
-- Repeated.get/set with a vector container shadow.
--
--   Array fields WITHOUT `elements` or `elementType` are skipped
--   (no reader available).
--
-- POINTER-BACKED CONTAINER — has `type` (string, not "Array"),
-- `offset`, AND child fields. Dereference base+offset, recurse.
--
-- NAMESPACE CONTAINER — no `type`, children at same base. Recurse.
--
-- Performance: Struct.get batch-reads ALL Array vector headers in
-- a single gg.getValues call before dispatching. This avoids
-- ~196 individual reads per eventRewards scan (14 rewards × 14
-- nested arrays = 196 reads at ~180ms each = 35s without batching).
-- With batching: 14 reads (one batch per reward element) = ~2s.
--
-- String indirection: caller passes `stringDirect = true` for C++
-- struct ABI (inline strings). Struct.get shadows String fields
-- with indirect=false.
--
-- Zero-value suppression: scalar fields with value 0/0.0/"" are
-- omitted. Bool values are never suppressed. Empty arrays (size=0)
-- are omitted for cleaner output. Empty containers (no readable
-- fields) are also omitted.

local Memory = loadModule("core/Memory.lua")
local Type   = loadModule("core/Type.lua")
local ZeroPage = loadModule("core/ZeroPage.lua")

local M = {}

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.Struct]", ...)
    end
end



local typeCache = {}
local function resolveType(name)
    if typeCache[name] == nil then
        typeCache[name] = Type.resolve(name)
    end
    return typeCache[name]
end

local DEFAULT_STRIDE = 0x8

---Check if a node has child field definitions.
local function hasChildren(node)
    for _, v in pairs(node) do
        if type(v) == "table" and type(v.offset) == "number" then
            return true
        end
    end
    return false
end

---Check if a field's offset is known (not 0xBAAD).
local function isOffsetKnown(field)
    return field.offset ~= nil and field.offset ~= 0xBAAD
end

---Check if an Array field has the metadata needed to read elements.
local function isReadableArray(field)
    return field.elements ~= nil or field.elementType ~= nil
end

---Shadow a String field with indirect=false.
local function shadowString(field, stringDirect)
    if stringDirect and field.type == "String" and field.indirect == nil then
        return setmetatable({ indirect = false }, { __index = field })
    end
    return field
end

---Build a shadow for an Array field inside a struct template.
local function shadowArray(field, stringDirect)
    local shadow = { stringDirect = stringDirect }
    return setmetatable(shadow, { __index = field })
end

---Check if a scalar value should be suppressed (0, 0.0, "").
local function isEmptyValue(field, value)
    if value == nil then return true end
    if field.type == "Bool" then return false end
    if field.type == "Enum" then return false end
    if field.type == "Int32" then return false end
    if field.type == "SafeInt32" then return false end
    if type(value) == "number" then return value == 0 end
    if type(value) == "string" then return value == "" end
    return false
end

---Check if a table is empty (no key-value pairs).
local function isEmptyTable(t)
    return t == nil or next(t) == nil
end

---Pre-read batch: collect all Array field vector headers in one
---gg.getValues call. Returns a map of key → {beginPtr, endPtr, capEndPtr}.
local function batchReadArrayHeaders(base, template, stringDirect)
    local specs = {}
    local meta = {}

    for key, field in pairs(template) do
        if type(field) == "table"
           and type(field.type) == "string"
           and field.type == "Array"
           and isOffsetKnown(field)
           and isReadableArray(field) then
            local ptr = base + field.offset
            local idx = #specs
            local isVector = stringDirect or field.container == "vector"
            if isVector then
                specs[idx + 1] = { address = ptr,        flags = Memory.FLAGS.INT64 }
                specs[idx + 2] = { address = ptr + 0x8,  flags = Memory.FLAGS.INT64 }
                specs[idx + 3] = { address = ptr + 0x10, flags = Memory.FLAGS.INT64 }
                meta[#meta + 1] = { key = key, offset = idx + 1, vector = true }
            else
                specs[idx + 1] = { address = ptr,       flags = Memory.FLAGS.INT64 }
                specs[idx + 2] = { address = ptr + 0x8, flags = Memory.FLAGS.INT32 }
                specs[idx + 3] = { address = ptr + 0xC, flags = Memory.FLAGS.INT32 }
                meta[#meta + 1] = { key = key, offset = idx + 1, vector = false }
            end
        end
    end

    local result = {}
    if #specs == 0 then
        return result
    end

    local values, err = Memory.readBatch(specs)
    if not values then
        return result
    end

    for _, m in ipairs(meta) do
        if m.vector then
            result[m.key] = {
                beginPtr  = values[m.offset]     and values[m.offset].value     or 0,
                endPtr    = values[m.offset + 1] and values[m.offset + 1].value or 0,
                capEndPtr = values[m.offset + 2] and values[m.offset + 2].value or 0,
            }
        else
            local arrayPtr = values[m.offset]     and values[m.offset].value     or 0
            local size     = values[m.offset + 1] and values[m.offset + 1].value or 0
            local capacity = values[m.offset + 2] and values[m.offset + 2].value or 0
            result[m.key] = {
                containerPtr = base + template[m.key].offset,
                arrayPtr  = arrayPtr,
                size      = size,
                capacity  = capacity,
            }
        end
    end

    return result
end

---Build a Repeated-compatible header from pre-read pointers.
local function buildPreHeader(field, base, beginPtr, endPtr, capEndPtr)
    local ptr = base + field.offset
    local stride = field.elementStride or DEFAULT_STRIDE

    if beginPtr == 0 or endPtr == 0 or endPtr < beginPtr then
        return { containerPtr = ptr, arrayPtr = 0, size = 0, capacity = 0 }
    end

    local size = math.floor((endPtr - beginPtr) / stride)
    local capacity = size
    if capEndPtr ~= 0 and capEndPtr >= beginPtr then
        capacity = math.floor((capEndPtr - beginPtr) / stride)
    end

    if size < 0 then size = 0 end
    if capacity < size then capacity = size end

    return { containerPtr = ptr, arrayPtr = beginPtr, size = size, capacity = capacity }
end

--==================================================
-- get()
--==================================================

function M.get(base, template, stringDirect)
    log(string.format("[get] base=0x%X stringDirect=%s", base, tostring(stringDirect)))
    local result = {}

    -- Pre-pass: batch-read all readable Array vector headers in
    -- one gg.getValues call.
    local preReadHeaders = batchReadArrayHeaders(base, template, stringDirect)

    for key, field in pairs(template) do
        if type(field) == "table" then
            local container = hasChildren(field)

            if type(field.type) == "string" and field.type == "Array" then
                if isOffsetKnown(field) and isReadableArray(field) then
                    local h = preReadHeaders[key]
                    if h then
                        local preHeader
                        if h.beginPtr ~= nil then
                            if h.beginPtr ~= 0 and h.endPtr > h.beginPtr then
                                preHeader = buildPreHeader(field, base,
                                    h.beginPtr, h.endPtr, h.capEndPtr)
                            end
                        else
                            if h.arrayPtr ~= 0 and h.size > 0 then
                                preHeader = h
                            end
                        end
                        if preHeader and preHeader.size > 0 then
                            local Repeated = loadModule("core/Repeated.lua")
                            local shadow = shadowArray(field, stringDirect)
                            local arrResult = Repeated.get(base, shadow, preHeader)
                            if arrResult and not isEmptyTable(arrResult) then
                                result[key] = arrResult
                            end
                        end
                    end
                end

            elseif type(field.type) == "string" and container then
                -- Pointer-backed container (e.g. lootDefinition)
                if isOffsetKnown(field) then
                    local ptr = Memory.deref(base, field.offset)
                    if ptr and ptr ~= 0 then
                        local subResult = M.get(ptr, field, stringDirect)
                        -- Only include non-empty containers
                        if not isEmptyTable(subResult) then
                            result[key] = subResult
                        end
                    end
                end

            elseif type(field.type) == "string" then
                -- Leaf field
                if isOffsetKnown(field) then
                    local impl = resolveType(field.type)
                    if impl then
                        local f = shadowString(field, stringDirect)
                        local value = impl.get(base, f)
                        if not isEmptyValue(field, value) then
                            result[key] = value
                        end
                    end
                end

            elseif container then
                -- Namespace container
                local subResult = M.get(base, field, stringDirect)
                if not isEmptyTable(subResult) then
                    result[key] = subResult
                end
            end
        end
    end
    return result
end

--==================================================
-- set()
--==================================================

local function collectWrites(base, template, values, stringDirect, writes)
    if type(values) ~= "table" then
        return false
    end

    local allOk = true

    for key, value in pairs(values) do
        local field = template[key]
        if type(field) == "table" then
            local container = hasChildren(field)

            if type(field.type) == "string" and field.type == "Array" then
                if isOffsetKnown(field) and isReadableArray(field) then
                    local Repeated = loadModule("core/Repeated.lua")
                    local shadow = shadowArray(field, stringDirect)
                    local header, hErr = Repeated.readHeaderForSet(base, shadow)
                    if not header then
                        allOk = false
                    else
                        local ok2 = Repeated.setWithHeader(base, shadow, value, header, writes)
                        if not ok2 then
                            allOk = false
                        end
                    end
                end

            elseif type(field.type) == "string" and container then
                if isOffsetKnown(field) then
                    local ptr = Memory.deref(base, field.offset)
                    local needsAlloc = not ptr or ptr == 0
                    if needsAlloc then
                        ptr = ZeroPage.allocate(0x100)
                        if ptr then
                            writes[#writes + 1] = { address = base + field.offset, flags = Memory.FLAGS.INT64, value = ptr }
                        end
                    end
                    if ptr and ptr ~= 0 then
                        if not collectWrites(ptr, field, value, stringDirect, writes) then
                            allOk = false
                        end
                    else
                        allOk = false
                    end
                end

            elseif type(field.type) == "string" then
                if isOffsetKnown(field) then
                    local impl = resolveType(field.type)
                    if impl then
                        local f = shadowString(field, stringDirect)
                        if impl.collectWrite then
                            if not impl.collectWrite(base, f, value, writes) then
                                allOk = false
                            end
                        else
                            if not impl.set(base, f, value) then
                                allOk = false
                            end
                        end
                    end
                end

            elseif container then
                if not collectWrites(base, field, value, stringDirect, writes) then
                    allOk = false
                end
            end
        end
    end

    return allOk
end

function M.set(base, template, values, stringDirect, outWrites)
    log(string.format("[set] base=0x%X stringDirect=%s outWrites=%s", base, tostring(stringDirect), tostring(outWrites ~= nil)))
    if type(values) ~= "table" then
        return false
    end

    local writes = outWrites or {}
    local ok = collectWrites(base, template, values, stringDirect, writes)

    if not outWrites and #writes > 0 then
        local wbOk = Memory.writeBatch(writes)
        if not wbOk then
            if Nebula and Nebula.log then
                print("[Struct.set] writeBatch FAILED, " .. #writes .. " writes")
                for i, w in ipairs(writes) do
                    print(string.format("  [%d] addr=0x%X flags=%d val=%s", i, w.address, w.flags, tostring(w.value)))
                end
            end
            ok = false
        end
    end

    return ok
end

return M
