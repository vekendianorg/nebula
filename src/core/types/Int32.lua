--==================================================
-- core/types/Int32.lua
--==================================================

local Memory = loadModule("core/Memory.lua")

local M = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula and Nebula.log then
        Logfile.log("[Int32]", ...)
    end
end

function M.get(baseAddress, field)
    return Memory.read(baseAddress + field.offset, Memory.FLAGS.INT32)
end

function M.set(baseAddress, field, value)
    if type(value) ~= "number" then
        log(string.format("[set] REJECTED at 0x%X offset=0x%X: non-number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    return Memory.write(baseAddress + field.offset, Memory.FLAGS.INT32, math.floor(value))
end

---Returns true when a write spec was appended, false when the
---value was rejected (wrong type) — same contract as String's
---collectWrite. Returning nil here silently failed every set()
---over scalar-element arrays: Repeated.set / setWithHeader /
---Struct.collectWrites treat a non-true result as a write failure.
function M.collectWrite(baseAddress, field, value, writes)
    if type(value) ~= "number" then
        log(string.format("[set] collectWrite REJECTED at 0x%X offset=0x%X: non-number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end
    writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT32, value = math.floor(value) }
    return true
end

return M
