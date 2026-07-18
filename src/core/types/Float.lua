--==================================================
-- core/types/Float.lua
--==================================================
-- 4-byte IEEE-754 float field.

local Memory = loadModule("core/Memory.lua")

local M = {}

---@param baseAddress integer
---@param field table
---@return number|nil value, string|nil error
function M.get(baseAddress, field)
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
    return Memory.write(baseAddress + field.offset, Memory.FLAGS.FLOAT, value)
end

return M
