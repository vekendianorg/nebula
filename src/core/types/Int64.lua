--==================================================
-- core/types/Int64.lua
--==================================================

local Memory = loadModule("core/Memory.lua")

local M = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula and Nebula.log then
        Logfile.log("[Int64]", ...)
    end
end

function M.get(baseAddress, field)
    return Memory.read(baseAddress + field.offset, Memory.FLAGS.INT64)
end

function M.set(baseAddress, field, value)
    if type(value) ~= "number" then
        log(string.format("[set] REJECTED at 0x%X offset=0x%X: non-number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    return Memory.write(baseAddress + field.offset, Memory.FLAGS.INT64, value)
end

function M.collectWrite(baseAddress, field, value, writes)
    if type(value) ~= "number" then
        log(string.format("[set] collectWrite REJECTED at 0x%X offset=0x%X: non-number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    writes[#writes + 1] = {
        address = baseAddress + field.offset,
        flags = Memory.FLAGS.INT64,
        value = value,
    }
    return true
end

return M
