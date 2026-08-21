--==================================================
-- core/types/Enum.lua
--==================================================
-- Int32 field backed by a bidirectional enum mapping. Reads an
-- Int32 from memory and converts to the schema string name; writes
-- a string name back as the Int32 enum value.
--
-- The enum table is loaded from metadata/enums/<field.enum>.lua
-- (or used inline if field.enum is a table). It must expose:
--   byId[number]   → string name
--   byName[string] → number id
--
-- Metadata usage:
--   { offset = 0x18, type = "Enum", enum = "ChestType" }
--
-- get returns the string name (e.g. "rare") or the raw number
-- if the ID is not in the enum table.
-- set accepts either the string name or the raw number.

local Memory = loadModule("core/Memory.lua")

local M = {}

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.types.Enum]", ...)
    end
end



local function loadEnum(field)
    if type(field.enum) == "table" then
        return field.enum
    end
    if not field.enum then
        return { byId = {}, byName = {} }
    end
    return loadModule("metadata/enums/" .. field.enum .. ".lua")
end

---@param baseAddress integer
---@param field table @ { offset, enum } from metadata
---@return string|integer|nil value, string|nil error
function M.get(baseAddress, field)
    local raw, err = Memory.read(baseAddress + field.offset, Memory.FLAGS.INT32)
    if err then return nil, err end
    if raw == 0 and field.allowZero == false then
        return nil, nil
    end

    local enum = loadEnum(field)
    local name = enum.byId and enum.byId[raw]
    if name ~= nil then
        return name
    end
    -- Unknown ID: return the raw number so caller can see it
    return raw
end

---@param baseAddress integer
---@param field table
---@param value string|integer @ enum name or raw Int32
---@return boolean ok
function M.set(baseAddress, field, value)
    local raw

    if type(value) == "string" then
        local enum = loadEnum(field)
        raw = enum.byName and enum.byName[value]
        if raw == nil then
            error(("Enum: unknown name '%s'"):format(value))
        end
    elseif type(value) == "number" then
        raw = math.floor(value)
    else
        return false
    end

    function M.collectWrite(baseAddress, field, value, writes)
    local raw
    if type(value) == "string" then
        local enum = loadEnum(field)
        raw = enum.byName and enum.byName[value]
        if raw == nil then return end
    elseif type(value) == "number" then
        raw = math.floor(value)
    else
        return
    end
    writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT32, value = raw }
end

return Memory.write(baseAddress + field.offset, Memory.FLAGS.INT32, raw)
end

function M.collectWrite(baseAddress, field, value, writes)
    local raw
    if type(value) == "string" then
        local enum = loadEnum(field)
        raw = enum.byName and enum.byName[value]
        if raw == nil then return end
    elseif type(value) == "number" then
        raw = math.floor(value)
    else
        return
    end
    writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT32, value = raw }
end

return M
