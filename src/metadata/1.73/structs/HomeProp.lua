-- metadata/1.73/HomeProp.lua
-- Element template for Room.props
-- (RepeatedPtrField<HomeProp>, POINTER-slot elements, default stride).
-- position is a POINTER to Vector2Int (8-byte slot, last proto field),
-- resolved from the Vector2Int snapshot (see metadata/Vector2Int/).

local Manifest = loadModule("metadata/manifest.lua")

local Vector2Int = Manifest.load("Vector2Int")

-- position is a POINTER member — Object = pointer deref; children
-- come from the Vector2Int snapshot.
local positionObj = { offset = 0x28, type = "Object" }
for k, v in pairs(Vector2Int) do positionObj[k] = v end

return {
    ["typeId"] = { offset = 0x18, type = "String" },
    ["propId"] = { offset = 0x20, type = "String" },
    ["position"] = positionObj,  -- Vector2Int
}
