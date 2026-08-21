--==================================================
-- core/types/Bool.lua
--==================================================
-- Single-byte boolean field (proto2 `bool`). Stored as 0x00/0x01.

local Memory = loadModule("core/Memory.lua")

local M = {}

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.types.Bool]", ...)
    end
end



---@param baseAddress integer
---@param field table
---@return boolean|nil value, string|nil error
function M.get(baseAddress, field)
    local raw, err = Memory.read(baseAddress + field.offset, Memory.FLAGS.BYTE)
    if raw == nil then
        return nil, err
    end
    return raw ~= 0
end

---@param baseAddress integer
---@param field table
---@param value boolean
---@return boolean ok
function M.set(baseAddress, field, value)
    if type(value) ~= "boolean" then
        return false
    end
    function M.collectWrite(baseAddress, field, value, writes)
    if type(value) == "boolean" then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.BYTE, value = value and 1 or 0 }
    end
end

return Memory.write(baseAddress + field.offset, Memory.FLAGS.BYTE, value and 1 or 0)
end

function M.collectWrite(baseAddress, field, value, writes)
    if type(value) == "boolean" then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.BYTE, value = value and 1 or 0 }
    end
end

return M
