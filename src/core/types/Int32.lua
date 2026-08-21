--==================================================
-- core/types/Int32.lua
--==================================================
-- Plain 4-byte signed integer field. No indirection, no protobuf
-- wrapper — just a direct read/write at baseAddress + offset.

local Memory = loadModule("core/Memory.lua")

local M = {}

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.types.Int32]", ...)
    end
end



---@param baseAddress integer
---@param field table @ { offset, ... } from metadata
---@return integer|nil value, string|nil error
function M.get(baseAddress, field)
    function M.collectWrite(baseAddress, field, value, writes)
    if type(value) == "number" then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT32, value = math.floor(value) }
    end
end

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
    function M.collectWrite(baseAddress, field, value, writes)
    if type(value) == "number" then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT32, value = math.floor(value) }
    end
end

return Memory.write(baseAddress + field.offset, Memory.FLAGS.INT32, math.floor(value))
end

function M.collectWrite(baseAddress, field, value, writes)
    if type(value) == "number" then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT32, value = math.floor(value) }
    end
end

return M
