--==================================================
-- metadata/1.74/Room.lua
--==================================================
-- Element template for GameStatus.rooms
-- (RepeatedPtrField<Room>, POINTER-slot elements, default stride).
-- props is a RepeatedPtrField<HomeProp>.
local Manifest = loadModule("metadata/manifest.lua")
local HomeProp = Manifest.load("HomeProp")

return {
    ["wallId"] = {
        offset = 0x18,
        type = "String"
    },
    ["floorId"] = {
        offset = 0x20,
        type = "String"
    },
    ["rafterId"] = {
        offset = 0x28,
        type = "String"
    },
    ["props"] = {
        offset = 0x30,
        type = "Array",
        elements = HomeProp
    },
}
