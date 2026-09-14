--==================================================
-- core/types/Float.lua
--==================================================

local Memory = loadModule("core/Memory.lua")

local M = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula ~= nil and Nebula.log then
        Logfile.log("[Float]", ...)
    end
end

function M.get(baseAddress, field)
    return Memory.read(baseAddress + field.offset, Memory.FLAGS.FLOAT)
end

function M.set(baseAddress, field, value)
    if type(value) ~= "number" then
        log(string.format("[set] REJECTED at 0x%X offset=0x%X: non-number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    return Memory.write(baseAddress + field.offset, Memory.FLAGS.FLOAT, value)
end

function M.collectWrite(baseAddress, field, value, writes)
    -- true/false contract — see Int32.collectWrite for why nil broke set().
    if type(value) ~= "number" then
        log(string.format("[set] collectWrite REJECTED at 0x%X offset=0x%X: non-number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.FLOAT, value = value }
    return true
end

return M
