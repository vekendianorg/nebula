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

local Memory   = loadModule("core/Memory.lua")
local Type     = loadModule("core/Type.lua")
local Repeated = loadModule("core/Repeated.lua")
local metadata = loadModule("metadata/GameStatus.lua")

local M = {}

-- Fields considered dangerous enough to require :force().
local DANGEROUS_FIELDS = {
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

---@param id string
---@return table|nil field, string|nil error
local function lookupField(id)
    local field = metadata[id]
    if field == nil then
        return nil, "unknown_field: " .. tostring(id)
    end
    return field
end

---@param field table
---@return boolean known
local function isOffsetKnown(field)
    return field.offset ~= 0xBAAD
end

local function log(...)
    if Nebula ~= nil and Nebula.log then
        print("[Nebula.GameStatus]", ...)
    end
end

---Produce a compact, human-readable description of a value for
---logging. Boxed types (like BitMask) dump their entire internal
---table via plain tostring(), which is noisy and useless in a log
---line — this gives each type a chance to describe itself sensibly.
---@param field table
---@param value any
---@return string
local function describeValue(field, value)
    if field.repeated and type(value) == "table" then
        return string.format("[ %d element(s) of %s ]", #value, tostring(field.type))
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
    local field, fieldErr = lookupField(id)
    if not field then
        log("get failed:", fieldErr)
        return nil, fieldErr
    end

    if field.type == "Object" then
        return nil, "unsupported_type: Object fields are not yet readable (missing nested metadata)"
    end

    if not isOffsetKnown(field) then
        return nil, "offset_unknown: " .. id
    end

    local base, baseErr = resolveBase()
    if not base then
        log("get failed, no base:", baseErr)
        return nil, baseErr
    end

    if field.repeated then
        local values, err = Repeated.get(base, field)
        if values == nil and err then
            log("get('" .. id .. "') failed:", err)
        end
        return values, err
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return nil, "no_type_impl: " .. tostring(field.type)
    end

    local value, err = impl.get(base, field)
    if value == nil and err then
        log("get('" .. id .. "') failed:", err)
    end
    return value, err
end

--==================================================
-- set() — returns a chainable operation object supporting
-- :force() and :dry()
--==================================================

local SetOperation = {}
SetOperation.__index = SetOperation

local function performWrite(op)
    local field, fieldErr = lookupField(op.id)
    if not field then
        log("set failed:", fieldErr)
        return false, fieldErr
    end

    if field.type == "Object" then
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

    local base, baseErr = resolveBase()
    if not base then
        log("set failed, no base:", baseErr)
        return false, baseErr
    end

    if field.repeated then
        local ok, err = Repeated.set(base, field, op.value)
        if not ok then
            log("set('" .. op.id .. "') failed:", err)
            return false, err or "write_failed"
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
-- SafeInt32) — String, Bool, BitMask, Achievement, and repeated
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
    local field, fieldErr = lookupField(id)
    if not field then
        log("add/sub failed:", fieldErr)
        local self = setmetatable({ id = id, value = nil, _forced = false, _dry = false }, SetOperation)
        self._ok, self._err = false, fieldErr
        return self
    end

    if field.repeated or not NUMERIC_TYPES[field.type] then
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
    if field.repeated then
        return true -- repeated fields are always pointer-backed containers
    end
    if POINTER_BACKED_TYPES[field.type] then
        return true
    end
    -- Anything not a known inline scalar is assumed to be a
    -- pointer-backed message/custom type.
    local INLINE_SCALARS = { Int32 = true, Bool = true, Float = true, BitMask = true }
    return not INLINE_SCALARS[field.type]
end

---@param id string
---@return boolean|nil exists, string|nil error
function M.has(id)
    local field, fieldErr = lookupField(id)
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
    local field, err = lookupField(id)
    if not field then
        return nil, err
    end

    local view = setmetatable({
        name       = id,
        type       = field.type,
        offset     = field.offset,
        repeated   = field.repeated,
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
