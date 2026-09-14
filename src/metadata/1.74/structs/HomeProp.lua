--==================================================
-- metadata/1.74/HomeProp.lua
--==================================================
-- Element template for Room.props
-- (RepeatedPtrField<HomeProp>, POINTER-slot elements, default stride).
-- position is a POINTER to Vector2Int (8-byte slot, last proto field),
-- resolved from the Vector2Int snapshot (see metadata/Vector2Int/).

local Manifest = loadModule("metadata/manifest.lua")

local Vector2Int = Manifest.load("Vector2Int")

-- position is a POINTER member — Object = pointer deref; children
-- come from the Vector2Int snapshot.

return {
    ["typeId"] = {
        offset = 0x18,
        type = "String"
    },
    ["propId"] = {
        offset = 0x20,
        type = "String"
    },
    ["position"] = {
        offset = 0x28,
        type = "Object",
        elements = Vector2Int
    },  -- Vector2Int
}
