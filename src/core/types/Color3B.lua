--==================================================
-- core/types/Color3B.lua
--==================================================

local Memory = loadModule("core/Memory.lua")
local M = {}
local function byte(v) return type(v) == "number" and math.floor(v) >= 0 and math.floor(v) <= 255 end
function M.get(base, field)
    local a, ea = Memory.read(base + field.offset, Memory.FLAGS.BYTE)
    if a == nil then return nil, ea end
    local b, eb = Memory.read(base + field.offset + 0x1, Memory.FLAGS.BYTE)
    if b == nil then return nil, eb end
    local c, ec = Memory.read(base + field.offset + 0x2, Memory.FLAGS.BYTE)
    if c == nil then return nil, ec end
    return { r = a & 0xFF, g = b & 0xFF, b = c & 0xFF }
end
function M.set(base, field, value)
    if type(value) ~= "table" or not byte(value.r) or not byte(value.g) or not byte(value.b) then return false end
    return Memory.writeBatch({
        { address = base + field.offset, flags = Memory.FLAGS.BYTE, value = value.r },
        { address = base + field.offset + 0x1, flags = Memory.FLAGS.BYTE, value = value.g },
        { address = base + field.offset + 0x2, flags = Memory.FLAGS.BYTE, value = value.b },
    })
end
function M.collectWrite(base, field, value, writes)
    if type(value) ~= "table" or not byte(value.r) or not byte(value.g) or not byte(value.b) then return false end
    writes[#writes+1] = { address = base + field.offset, flags = Memory.FLAGS.BYTE, value = value.r }
    writes[#writes+1] = { address = base + field.offset + 0x1, flags = Memory.FLAGS.BYTE, value = value.g }
    writes[#writes+1] = { address = base + field.offset + 0x2, flags = Memory.FLAGS.BYTE, value = value.b }
    return true
end
return M
