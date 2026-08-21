--==================================================
-- core/types/Float.lua
--==================================================
-- 4-byte IEEE-754 float field.

local Memory = loadModule("core/Memory.lua")

local M = {}

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.types.Float]", ...)
    end
end



---@param baseAddress integer
---@param field table
---@return number|nil value, string|nil error
function M.get(baseAddress, field)
    function M.collectWrite(baseAddress, field, value, writes)
    if type(value) == "number" then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.FLOAT, value = value }
    end
end

return Memory.read(baseAddress + field.offset, Memory.FLAGS.FLOAT)
end

---@param baseAddress integer
---@param field table
---@param value number
---@return boolean ok
function M.set(baseAddress, field, value)
    if type(value) ~= "number" then
        return false
    end
    function M.collectWrite(baseAddress, field, value, writes)
    if type(value) == "number" then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.FLOAT, value = value }
    end
end

return Memory.write(baseAddress + field.offset, Memory.FLAGS.FLOAT, value)
end

function M.collectWrite(baseAddress, field, value, writes)
    if type(value) == "number" then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.FLOAT, value = value }
    end
end

return M
