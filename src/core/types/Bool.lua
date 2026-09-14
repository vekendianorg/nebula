--==================================================
-- core/types/Bool.lua
--==================================================

local Memory = loadModule("core/Memory.lua")

local M = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula ~= nil and Nebula.log then
        Logfile.log("[Bool]", ...)
    end
end

function M.get(baseAddress, field)
    local raw, err = Memory.read(baseAddress + field.offset, Memory.FLAGS.BYTE)
    if raw == nil then
        return nil, err
    end
    return raw ~= 0
end

function M.set(baseAddress, field, value)
    if type(value) ~= "boolean" then
        log(string.format("[set] REJECTED at 0x%X offset=0x%X: non-boolean value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    return Memory.write(baseAddress + field.offset, Memory.FLAGS.BYTE, value and 1 or 0)
end

function M.collectWrite(baseAddress, field, value, writes)
    -- true/false contract — see Int32.collectWrite for why nil broke set().
    if type(value) ~= "boolean" then
        log(string.format("[set] collectWrite REJECTED at 0x%X offset=0x%X: non-boolean value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.BYTE, value = value and 1 or 0 }
    return true
end

return M
