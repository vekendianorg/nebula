--==================================================
-- core/types/Int32.lua
--==================================================
-- Plain 4-byte signed integer field. No indirection, no protobuf
-- wrapper — just a direct read/write at baseAddress + offset.

local Memory = loadModule("core/Memory.lua")

local M = {}

---@param baseAddress integer
---@param field table @ { offset, ... } from metadata
---@return integer|nil value, string|nil error
function M.get(baseAddress, field)
    return Memory.read(baseAddress + field.offset, Memory.FLAGS.INT32)
end

---@param baseAddress integer
---@param field table
---@param value integer
---@return boolean ok
function M.set(baseAddress, field, value)
    if type(value) ~= "number" then
        return false
    end
    return Memory.write(baseAddress + field.offset, Memory.FLAGS.INT32, math.floor(value))
end

return M
