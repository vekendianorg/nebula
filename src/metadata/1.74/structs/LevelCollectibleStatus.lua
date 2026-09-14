--==================================================
-- metadata/1.74/LevelCollectibleStatus.lua
--==================================================
-- LevelCollectibleStatus (dump Size 0x50, exact):
--   levelid_ 0x18, items_ 0x20 (RepeatedPtrField<LevelCollectibleItem>),
--   collected_ 0x38, totalcollectedvalue_ 0x48, totalvalue_ 0x4c
--==================================================
-- Element template for DistanceCollectibleStatus.levels. items is a
-- RepeatedPtrField<LevelCollectibleItem> (pointer-slot elements, default
-- stride). Dump LevelCollectibleItem = { x_ float @0x18, y_ float @0x1c,
-- rarity_ int32 @0x20 } (Size 0x28).
local Manifest = loadModule("metadata/manifest.lua")
local LevelCollectibleItem = Manifest.load("LevelCollectibleItem")

return {
    ["levelId"] = {
        offset = 0x18,
        type = "String"
    },
    ["items"] = {
        offset = 0x20,
        type = "Array",
        elements = LevelCollectibleItem
    },
    ["collected"] = {
        offset = 0x38,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
    ["totalCollectedValue"] = {
        offset = 0x48,
        type = "Int32"
    },
    ["totalValue"] = {
        offset = 0x4C,
        type = "Int32"
    },
}
