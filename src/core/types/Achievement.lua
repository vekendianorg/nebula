--==================================================
-- core/types/Achievement.lua
--==================================================
-- message Achievement {
--   required int32 id = 1;
--   required bool unlocked = 2;
--   optional int32 steps = 3;
-- }
--
-- Struct layout (fields relative to the element's own base — for
-- repeated fields, that's the element pointer itself, offset 0):
--
--   base + 0x18  id        (int32)
--   base + 0x1C  unlocked  (bool, 1 byte)
--   base + 0x20  steps     (int32)
--
-- Unlike scalar/String/SafeInt32 type modules, this one doesn't
-- use field.offset directly — `field` here is the synthetic
-- { offset = 0, type = "Achievement" } passed in by
-- core/Repeated.lua, since each array slot already points straight
-- at the element struct. get()/set() return/accept a plain Lua
-- table: { id = ..., unlocked = ..., steps = ... }.
--
-- Also implements the optional M.specs(base)/M.parse(results) pair
-- so core/Repeated.lua can batch every element's reads into one
-- cross-element gg.getValues call instead of one call per element.
-- See core/Repeated.lua's batchGetElements() for how this is used.

local Memory = loadModule("core/Memory.lua")

local M = {}

local FIELD_ID_OFF       = 0x18
local FIELD_UNLOCKED_OFF = 0x1C
local FIELD_STEPS_OFF    = 0x20

---Optional batch-read descriptor: given an element base, describe
---the {address, flags} specs needed to read this element, in a
---fixed order, without doing any actual I/O. core/Repeated.lua
---uses this (when present) to collect every element's field specs
---into one big cross-element readBatch instead of calling get()
---once per element — cutting N round-trips down to 1 for an
---N-element array. Falls back to per-element M.get() when a type
---doesn't implement this.
---@param base integer
---@return table specs @ array of { address, flags }
function M.specs(base)
    return {
        { address = base + FIELD_ID_OFF,       flags = Memory.FLAGS.INT32 },
        { address = base + FIELD_UNLOCKED_OFF, flags = Memory.FLAGS.BYTE },
        { address = base + FIELD_STEPS_OFF,    flags = Memory.FLAGS.INT32 },
    }
end

---Parse a slice of already-fetched readBatch results (in the same
---order M.specs() described them) into this type's value shape.
---Used alongside M.specs() for batch reads; independent of get().
---@param results table @ slice of gg.getValues-style results, same order as specs()
---@return table|nil value, string|nil error
function M.parse(results)
    local id       = results[1] and results[1].value
    local unlocked = results[2] and results[2].value
    local steps    = results[3] and results[3].value

    if id == nil or unlocked == nil then
        return nil, "read_failed"
    end

    return {
        id       = id,
        unlocked = (unlocked & 0xFF) ~= 0,
        steps    = steps,
    }
end

---@param base integer @ pointer to the Achievement struct itself
---@param field table @ unused offset (struct starts at base+0), kept for interface consistency
---@return table|nil value, string|nil error
function M.get(base, field)
    local fields, err = Memory.readBatch(M.specs(base))
    if not fields then
        return nil, err
    end
    return M.parse(fields)
end

---@param base integer @ pointer to the Achievement struct itself
---@param field table @ unused offset, kept for interface consistency
---@param value table @ { id, unlocked, steps }
---@return boolean ok
function M.set(base, field, value)
    if type(value) ~= "table" then
        return false
    end

    local writes = {}

    if value.id ~= nil then
        writes[#writes + 1] = { address = base + FIELD_ID_OFF, flags = Memory.FLAGS.INT32, value = math.floor(value.id) }
    end

    if value.unlocked ~= nil then
        writes[#writes + 1] = { address = base + FIELD_UNLOCKED_OFF, flags = Memory.FLAGS.BYTE, value = value.unlocked and 1 or 0 }
    end

    if value.steps ~= nil then
        writes[#writes + 1] = { address = base + FIELD_STEPS_OFF, flags = Memory.FLAGS.INT32, value = math.floor(value.steps) }
    end

    if #writes == 0 then
        return false
    end

    return Memory.writeBatch(writes)
end

return M
