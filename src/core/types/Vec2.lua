--==================================================
-- core/types/Vec2.lua
--==================================================

local Memory = loadModule("core/Memory.lua")
local M = {}
function M.get(base, field)
    local x, xe = Memory.read(base + field.offset, Memory.FLAGS.FLOAT)
    if x == nil then return nil, xe end
    local y, ye = Memory.read(base + field.offset + 0x4, Memory.FLAGS.FLOAT)
    if y == nil then return nil, ye end
    return { x = x, y = y }
end
function M.set(base, field, value)
    if type(value) ~= "table" or type(value.x) ~= "number" or type(value.y) ~= "number" then return false end
    return Memory.writeBatch({
        { address = base + field.offset, flags = Memory.FLAGS.FLOAT, value = value.x },
        { address = base + field.offset + 0x4, flags = Memory.FLAGS.FLOAT, value = value.y },
    })
end
function M.collectWrite(base, field, value, writes)
    if type(value) ~= "table" or type(value.x) ~= "number" or type(value.y) ~= "number" then return false end
    writes[#writes+1] = { address = base + field.offset, flags = Memory.FLAGS.FLOAT, value = value.x }
    writes[#writes+1] = { address = base + field.offset + 0x4, flags = Memory.FLAGS.FLOAT, value = value.y }
    return true
end
return M
