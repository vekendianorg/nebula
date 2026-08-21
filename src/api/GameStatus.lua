--==================================================
-- api/GameStatus.lua
--==================================================
-- Public-facing Nebula.GameStatus module.
--
--   Nebula.GameStatus.get("coins")
--   Nebula.GameStatus.set("coins", 999)
--   Nebula.GameStatus.set("cheater", true):force()
--   Nebula.GameStatus.set("coins", 999):dry()
--   Nebula.GameStatus.has("device")
--   Nebula.GameStatus.add("coins", 1000)
--   Nebula.GameStatus.add("coins", 1000):dry()
--   Nebula.GameStatus.sub("coins", 500)
--   Nebula.GameStatus.meta("coins")
--   Nebula.GameStatus.fields()

local Memory   = loadModule("core/Memory.lua")
local Type     = loadModule("core/Type.lua")
local Repeated = loadModule("core/Repeated.lua")
local Path     = loadModule("core/Path.lua")
local Struct   = loadModule("core/Struct.lua")
local metadata = loadModule("metadata/GameStatus.lua")

local M = {}

-- Fields considered dangerous enough to require :force().
local DANGEROUS_FIELDS = {
    playerId = true,
    coins = true,
    gems = true,
    cheater = true,
}

-- Cached per script session — resolveGameStatusBase() is an
-- expensive signature scan, only run it once unless forced.
local baseAddress = nil

-- Cache for enum module loads. loadModule() re-reads and
-- re-executes the file from disk every call — with no cache, every
-- BitMask get/set/log line pays that cost again, which adds up
-- fast when scanning many fields in a loop.
local enumCache = {}

---@param enumName string|table
---@return table|nil
local function resolveEnum(enumName)
    if type(enumName) == "table" then
        return enumName
    end
    if enumCache[enumName] ~= nil then
        return enumCache[enumName]
    end
    local enum = loadModule("metadata/enums/" .. enumName .. ".lua")
    enumCache[enumName] = enum
    return enum
end

--==================================================
-- Base address resolution
--==================================================

---Resolve and cache the GameStatus struct base address.
---@param forceRescan boolean|nil
---@return integer|nil address, string|nil error
local function resolveBase(forceRescan)
    if baseAddress ~= nil and not forceRescan then
        return baseAddress
    end

    local addresses, err = Memory.resolveGameStatusBase()
    if not addresses or #addresses == 0 then
        return nil, err or "base_not_found"
    end

    baseAddress = addresses[1]
    return baseAddress
end

M.resolveBase = resolveBase

--==================================================
-- Field lookup helpers
--==================================================

local function log(...)
    if Nebula ~= nil and Nebula.log then
        print("[Nebula.GameStatus]", ...)
    end
end

local function isOffsetKnown(field)
    return field.offset ~= nil and field.offset ~= 0xBAAD
end

local function resolvePath(id)
    local segments = Path.parse(id)
    if #segments == 0 then
        log("[resolvePath] empty path")
        return nil, "empty_path"
    end

    local base, baseErr = resolveBase()
    if not base then
        log(string.format("[resolvePath] base resolution failed: %s", tostring(baseErr)))
        return nil, baseErr
    end
    log(string.format("[resolvePath] id='%s' base=0x%X segments=%d", id, base, #segments))

    local currentBase = base
    local currentMeta = metadata
    local finalField = nil

    for i, seg in ipairs(segments) do
        local node = currentMeta[seg.name]
        if node == nil then
            log(string.format("[resolvePath] seg[%d] '%s' not found in metadata", i, seg.name))
            return nil, "unknown_field: " .. tostring(id)
        end

        if seg.index ~= nil then
            log(string.format("[resolvePath] seg[%d] '%s[%d]' type=%s offset=0x%X base=0x%X", i, seg.name, seg.index, tostring(node.type), node.offset or 0, currentBase))
            if node.type ~= "Array" then
                return nil, "not_an_array: " .. seg.name
            end
            if not isOffsetKnown(node) then
                return nil, "offset_unknown: " .. seg.name
            end
            local arr, arrErr = Repeated.get(currentBase, node)
            if not arr then
                log(string.format("[resolvePath] Repeated.get failed for '%s': %s", seg.name, tostring(arrErr)))
                return nil, arrErr
            end
            log(string.format("[resolvePath] '%s' array size=%d", seg.name, #arr))
            local luaIdx = seg.index
            if luaIdx < 1 or luaIdx > #arr then
                return nil, string.format("index_out_of_bounds: %s[%d] (size=%d)", seg.name, seg.index, #arr)
            end
            if i == #segments then
                log(string.format("[resolvePath] returning resolved value for '%s[%d]'", seg.name, seg.index))
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
                    log(string.format("[resolvePath] inline element base=0x%X (arrayPtr=0x%X + (%d-1)*0x%X)", currentBase, header.arrayPtr, seg.index, stride))
                else
                    local h, he = Repeated.readHeaderForSet(currentBase, node)
                    if not h then return nil, he end
                    local slotAddr = h.arrayPtr + (seg.index - 1) * 0x8
                    local slots, sErr = Memory.readBatchChunked({
                        { address = slotAddr, flags = Memory.FLAGS.INT64 }
                    })
                    if not slots or not slots[1] or slots[1].value == 0 then
                        log(string.format("[resolvePath] null element ptr at slotAddr=0x%X", slotAddr))
                        return nil, "null_element_ptr"
                    end
                    currentBase = slots[1].value
                    log(string.format("[resolvePath] ptr element base=0x%X (slotAddr=0x%X)", currentBase, slotAddr))
                end
                currentMeta = node.elements
            else
                return nil, "array_has_no_elements: " .. seg.name
            end
        elseif node.type == "Object" and i < #segments then
            log(string.format("[resolvePath] seg[%d] '%s' Object offset=0x%X base=0x%X", i, seg.name, node.offset, currentBase))
            if not isOffsetKnown(node) then
                return nil, "offset_unknown: " .. seg.name
            end
            local ptr = Memory.deref(currentBase, node.offset)
            if not ptr or ptr == 0 then
                log(string.format("[resolvePath] null pointer deref at base+0x%X=0x%X", node.offset, currentBase))
                return nil, "null_pointer: " .. seg.name
            end
            log(string.format("[resolvePath] Object deref ptr=0x%X", ptr))
            currentBase = ptr
            currentMeta = node
        elseif node.type == "Array" and i == #segments then
            log(string.format("[resolvePath] seg[%d] '%s' Array (final) offset=0x%X base=0x%X", i, seg.name, node.offset, currentBase))
            finalField = node
            break
        elseif type(node.type) == "string" and i == #segments then
            log(string.format("[resolvePath] seg[%d] '%s' type=%s (final) offset=0x%X base=0x%X", i, seg.name, node.type, node.offset, currentBase))
            finalField = node
            break
        elseif type(node) == "table" and node.type == nil and i < #segments then
            log(string.format("[resolvePath] seg[%d] '%s' namespace container", i, seg.name))
            currentMeta = node
        else
            log(string.format("[resolvePath] seg[%d] '%s' unhandled node type=%s", i, seg.name, tostring(node.type)))
            return nil, "unknown_field: " .. tostring(id)
        end
    end

    if finalField then
        log(string.format("[resolvePath] resolved field='%s' type=%s offset=0x%X base=0x%X", tostring(finalField.name or "?"), tostring(finalField.type), finalField.offset or 0, currentBase))
        return { field = finalField, base = currentBase }
    end
    log(string.format("[resolvePath] no final field found for '%s'", id))
    return nil, "unknown_field: " .. tostring(id)
end

---Produce a compact, human-readable description of a value for
---logging. Boxed types (like BitMask) dump their entire internal
---table via plain tostring(), which is noisy and useless in a log
---line — this gives each type a chance to describe itself sensibly.
---@param field table
---@param value any
---@return string
local function describeValue(field, value)
    if field.type == "Array" and type(value) == "table" then
        return string.format("[ %d element(s) ]", #value)
    end

    if field.type == "BitMask" and type(value) == "table" then
        local ok, hasMethod = pcall(function() return value.has end)
        if ok and hasMethod then
            local enum = resolveEnum(field.enum)
            local active = {}
            if enum then
                for name in pairs(enum) do
                    if value:has(name) then
                        active[#active + 1] = name
                    end
                end
                table.sort(active)
            end
            return string.format("{ %s }", table.concat(active, ", "))
        end
    end

    return tostring(value)
end

--==================================================
-- get()
--==================================================

---@param id string
---@return any|nil value, string|nil error
function M.get(id)
    log(string.format("[get] id='%s'", id))
    local result, err = resolvePath(id)
    if not result then
        log(string.format("[get] resolvePath failed: %s", tostring(err)))
        return nil, err
    end

    if result.resolved then
        log(string.format("[get] returning pre-resolved value for '%s'", id))
        return result.value
    end

    local field = result.field
    local base = result.base
    log(string.format("[get] field type=%s offset=0x%X base=0x%X", tostring(field.type), field.offset or 0, base))

    if field.type == "Object" then
        local hasChildren = false
        for _, v in pairs(field) do
            if type(v) == "table" and type(v.offset) == "number" then
                hasChildren = true
                break
            end
        end
        if hasChildren and isOffsetKnown(field) then
            local ptr = Memory.deref(base, field.offset)
            if not ptr or ptr == 0 then
                return nil
            end
            return Struct.get(ptr, field, false)
        end
        return nil, "unsupported_type: Object fields are not yet readable (missing nested metadata)"
    end

    if not isOffsetKnown(field) then
        return nil, "offset_unknown: " .. id
    end

    if field.type == "Array" then
        local values, arrErr = Repeated.get(base, field)
        if values == nil and arrErr then
            log("get('" .. id .. "') failed:", arrErr)
        end
        return values, arrErr
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return nil, "no_type_impl: " .. tostring(field.type)
    end

    local value, valErr = impl.get(base, field)
    if value == nil and valErr then
        log("get('" .. id .. "') failed:", valErr)
    end
    return value, valErr
end

--==================================================
-- set() — returns a chainable operation object supporting
-- :force() and :dry()
--==================================================

local SetOperation = {}
SetOperation.__index = SetOperation

local function performWrite(op)
    log(string.format("[set] id='%s' value=%s", op.id, tostring(op.value)))
    local result, err = resolvePath(op.id)
    if not result then
        log(string.format("[set] resolvePath failed: %s", tostring(err)))
        return false, err
    end

    if result.resolved then
        if not result.writeAddr then
            log("[set] cannot set array element value directly (no write address)")
            return false, "cannot_set_array_element_value_directly"
        end
        if op._dry then
            log(string.format("[dry] would set '%s' = %s", op.id, tostring(op.value)))
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
            f.indirect = false
        end
        local ok = impl.set(result.writeAddr, f, op.value)
        if not ok then
            log("set('" .. op.id .. "') failed")
            return false, "write_failed"
        end
        log(string.format("set '%s' = %s", op.id, tostring(op.value)))
        return true, nil
    end

    local field = result.field
    local base = result.base
    log(string.format("[set] field type=%s offset=0x%X base=0x%X", tostring(field.type), field.offset or 0, base))

    if field.type == "Object" then
        local hasChildren = false
        for _, v in pairs(field) do
            if type(v) == "table" and type(v.offset) == "number" then
                hasChildren = true
                break
            end
        end
        if hasChildren and isOffsetKnown(field) then
            if op._dry then
                log(string.format("[dry] would set '%s' = %s", op.id, describeValue(field, op.value)))
                return true, nil
            end
            local ptr = Memory.deref(base, field.offset)
            if not ptr or ptr == 0 then
                return false, "null_pointer"
            end
            local ok = Struct.set(ptr, field, op.value, false)
            if not ok then
                log("set('" .. op.id .. "') failed")
                return false, "write_failed"
            end
            log(string.format("set '%s' = %s", op.id, describeValue(field, op.value)))
            return true, nil
        end
        return false, "unsupported_type: Object fields are not yet writable (missing nested metadata)"
    end

    if not isOffsetKnown(field) then
        return false, "offset_unknown: " .. op.id
    end

    if DANGEROUS_FIELDS[op.id] and not op._forced then
        return false, "dangerous_field_requires_force: " .. op.id
    end

    if op._dry then
        log(string.format("[dry] would set '%s' = %s", op.id, describeValue(field, op.value)))
        return true, nil
    end

    if field.type == "Array" then
        local ok, setErr = Repeated.set(base, field, op.value)
        if not ok then
            log("set('" .. op.id .. "') failed:", setErr)
            return false, setErr or "write_failed"
        end
        log(string.format("set '%s' = %s", op.id, describeValue(field, op.value)))
        return true, nil
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return false, "no_type_impl: " .. tostring(field.type)
    end

    local ok = impl.set(base, field, op.value)
    if not ok then
        log("set('" .. op.id .. "') failed")
        return false, "write_failed"
    end

    log(string.format("set '%s' = %s", op.id, describeValue(field, op.value)))
    return true, nil
end

---Mark this operation as forced, bypassing the dangerous-field guard,
---then execute it. Returns (ok, err).
function SetOperation:force()
    self._forced = true
    return performWrite(self)
end

---Mark this operation as a dry run: validates everything (field
---exists, offset known, force requirement) but never touches memory.
---Returns (ok, err).
function SetOperation:dry()
    self._dry = true
    return performWrite(self)
end

-- Calling set() executes immediately (no modifier required), while
-- still returning the chainable object so :force()/:dry() remain
-- usable for staged/conditional execution.
setmetatable(SetOperation, {
    __call = function(cls, id, value)
        local self = setmetatable({ id = id, value = value, _forced = false, _dry = false }, cls)
        local ok, err = performWrite(self)
        self._ok, self._err = ok, err
        return self
    end
})

---@param id string
---@param value any
---@return table operation @ chainable; already executed unless dangerous-field guard blocked it
function M.set(id, value)
    return SetOperation(id, value)
end

--==================================================
-- add() / sub() — numeric read-modify-write shortcuts
--==================================================
-- Nebula.GameStatus.add("coins", 1000)  ==  set("coins", get("coins") + 1000)
-- Nebula.GameStatus.sub("coins", 500)   ==  set("coins", get("coins") - 500)
--
-- Only meaningful for numeric field types (Int32, Float,
-- SafeInt32) — String, Bool, BitMask, Array, Object, and repeated
-- fields don't have a sensible "add" operation and are rejected
-- with unsupported_operation rather than silently coercing.
--
-- Both go through the exact same SetOperation as set() (internally
-- they just compute the new value and call M.set()), so :force()
-- and :dry() work identically: Nebula.GameStatus.add("coins", 1000):dry().

local NUMERIC_TYPES = {
    Int32     = true,
    Float     = true,
    SafeInt32 = true,
}

---@param id string
---@param delta number
---@param negate boolean
---@return table operation @ chainable, same shape as set()'s return
local function performArithmetic(id, delta, negate)
    local result, fieldErr = resolvePath(id)
    local field = result and result.field
    if not field then
        log("add/sub failed:", fieldErr)
        local self = setmetatable({ id = id, value = nil, _forced = false, _dry = false }, SetOperation)
        self._ok, self._err = false, fieldErr
        return self
    end

    if not NUMERIC_TYPES[field.type] then
        log("add/sub failed: unsupported_operation for type " .. tostring(field.type))
        local self = setmetatable({ id = id, value = nil, _forced = false, _dry = false }, SetOperation)
        self._ok, self._err = false, "unsupported_operation: add/sub not valid for type " .. tostring(field.type)
        return self
    end

    local current, getErr = M.get(id)
    if current == nil then
        log("add/sub failed, get() failed:", getErr)
        local self = setmetatable({ id = id, value = nil, _forced = false, _dry = false }, SetOperation)
        self._ok, self._err = false, getErr or "read_failed"
        return self
    end

    local newValue = negate and (current - delta) or (current + delta)
    return SetOperation(id, newValue)
end

---@param id string
---@param delta number
---@return table operation
function M.add(id, delta)
    return performArithmetic(id, delta, false)
end

---@param id string
---@param delta number
---@return table operation
function M.sub(id, delta)
    return performArithmetic(id, delta, true)
end

--==================================================
-- has() — cheap existence check, no full decode
--==================================================
-- For pointer-backed fields (String, SafeInt32, message/repeated
-- types), "exists" means the pointer at base+offset is non-null —
-- this is a single Memory.deref(), far cheaper than a full get()
-- when all you need to know is whether something's there.
--
-- Plain inline scalars (Int32, Bool, Float, BitMask) have no null
-- state — they always "exist" once GameStatus itself is resolved —
-- so has() for those just reflects whether the offset is known.
--
-- Note: this is field-level existence, distinct from BitMask's own
-- boxed-value :has(flagName), which checks bit membership on an
-- already-read value. Nebula.GameStatus.has("flags") asks "is the
-- flags field itself present"; flags:has("IsPitCrew") asks "is
-- this specific bit set" — different questions, kept separate.

local POINTER_BACKED_TYPES = {
    String      = true,
    SafeInt32   = true,
}

---@param field table
---@return boolean
local function isPointerBackedType(field)
    if field.type == "Array" then
        return true -- array fields are always pointer-backed containers
    end
    if POINTER_BACKED_TYPES[field.type] then
        return true
    end
    -- Anything not a known inline scalar is assumed to be a
    -- pointer-backed message/custom type.
    local INLINE_SCALARS = { Int32 = true, Bool = true, Float = true, BitMask = true, Enum = true }
    return not INLINE_SCALARS[field.type]
end

---@param id string
---@return boolean|nil exists, string|nil error
function M.has(id)
    local result, fieldErr = resolvePath(id)
    local field = result and result.field
    if not field then
        log("has failed:", fieldErr)
        return nil, fieldErr
    end

    if field.type == "Object" then
        return nil, "unsupported_type: Object fields are not yet checkable (missing nested metadata)"
    end

    if not isOffsetKnown(field) then
        return nil, "offset_unknown: " .. id
    end

    if not isPointerBackedType(field) then
        -- No null state for inline scalars — known offset means it exists.
        return true, nil
    end

    local base, baseErr = resolveBase()
    if not base then
        log("has failed, no base:", baseErr)
        return nil, baseErr
    end

    local ptr = Memory.read(base + field.offset, Memory.FLAGS.POINTER)
    return ptr ~= nil and ptr ~= 0, nil
end

--==================================================
-- fields() — read-only introspection
--==================================================

---List every offset-verified field's id. Fields still at the
---0xBAAD placeholder are excluded.
---@return string[] ids
function M.fields()
    local results = {}
    for key, field in pairs(metadata) do
        if type(field) == "table" and type(field.type) == "string" and isOffsetKnown(field) then
            results[#results + 1] = key
        end
    end
    table.sort(results)
    return results
end

--==================================================
-- meta() — read-only introspection
--==================================================

local MetaView = {}
MetaView.__index = MetaView

---For BitMask fields, read the live value and decode it into a
---plain { FlagName = true/false, ... } table, so introspection
---shows readable flag states instead of a raw bitmask type name.
---Returns nil if the field isn't a readable BitMask right now
---(offset unknown, base unresolved, or read failed).
---@param base integer|nil
---@param field table
---@return table|nil flags
local function decodeBitMaskFlags(base, field)
    if field.type ~= "BitMask" or base == nil or not isOffsetKnown(field) then
        return nil
    end

    local impl = Type.resolve("BitMask")
    if not impl then
        return nil
    end

    local ok, boxed = pcall(impl.get, base, field)
    if not ok or boxed == nil then
        return nil
    end

    local enum = resolveEnum(field.enum)
    if not enum then
        return nil
    end

    local decoded = {}
    for name in pairs(enum) do
        decoded[name] = boxed:has(name)
    end

    return decoded
end

---@param id string
---@return table|nil metaView, string|nil error
function M.meta(id)
    local result, err = resolvePath(id)
    local field = result and result.field
    if not field then
        return nil, err
    end

    local view = setmetatable({
        name       = id,
        type       = field.type,
        offset     = field.offset,
        repeated   = field.type == "Array" or false,
        risk       = DANGEROUS_FIELDS[id] and "high" or "low",
        known      = isOffsetKnown(field),
    }, MetaView)

    if baseAddress ~= nil and isOffsetKnown(field) then
        view.address = baseAddress + field.offset
    else
        view.address = nil
    end

    if field.type == "BitMask" then
        view.flags = decodeBitMaskFlags(baseAddress, field)
    end

    return view
end

return M
