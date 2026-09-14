--==================================================
-- core/types/Enum.lua
--==================================================

local Memory = loadModule("core/Memory.lua")
local Manifest = loadModule("metadata/manifest.lua")

local M = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula ~= nil and Nebula.log then
        Logfile.log("[Enum]", ...)
    end
end

local function loadEnum(field)
    if type(field.enum) == "table" then
        return field.enum
    end
    if not field.enum then
        return { byId = {}, byName = {} }
    end
    return Manifest.loadEnum(field.enum)
end

function M.get(baseAddress, field)
    local raw, err = Memory.read(baseAddress + field.offset, Memory.FLAGS.INT32)
    if err then return nil, err end
    if raw == 0 and field.allowZero == false then
        log(string.format("[get] at 0x%X offset=0x%X: raw=0 suppressed by allowZero=false", baseAddress, field.offset))
        return nil, nil
    end
    local enum = loadEnum(field)
    local name = enum.byId and enum.byId[raw]
    if name ~= nil then
        return name
    end
    if raw ~= 0 then
        log(string.format("[get] at 0x%X offset=0x%X: raw=%d not in enum '%s', returning raw",
            baseAddress, field.offset, raw, tostring(field.enum)))
    end
    return raw
end

function M.set(baseAddress, field, value)
    local raw
    if type(value) == "string" then
        local enum = loadEnum(field)
        raw = enum.byName and enum.byName[value]
        if raw == nil then
            log(string.format("[set] REJECTED at 0x%X offset=0x%X: unknown enum name '%s' in '%s'",
                baseAddress, field.offset, value, tostring(field.enum)))
            error(("Enum: unknown name '%s'"):format(value))
        end
    elseif type(value) == "number" then
        raw = math.floor(value)
    else
        log(string.format("[set] REJECTED at 0x%X offset=0x%X: non-string/number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    return Memory.write(baseAddress + field.offset, Memory.FLAGS.INT32, raw)
end

function M.collectWrite(baseAddress, field, value, writes)
    local raw
    -- true/false contract — see Int32.collectWrite for why nil broke set().
    if type(value) == "string" then
        local enum = loadEnum(field)
        raw = enum.byName and enum.byName[value]
        if raw == nil then
            log(string.format("[set] collectWrite REJECTED at 0x%X offset=0x%X: unknown enum name '%s' in '%s'",
                baseAddress, field.offset, value, tostring(field.enum)))
            return false
        end
    elseif type(value) == "number" then
        raw = math.floor(value)
    else
        log(string.format("[set] collectWrite REJECTED at 0x%X offset=0x%X: non-string/number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT32, value = raw }
    return true
end

return M
