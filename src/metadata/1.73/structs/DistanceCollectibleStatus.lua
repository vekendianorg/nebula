-- metadata/1.73/DistanceCollectibleStatus.lua
-- Element template for GameStatus.distanceCollectibles
-- (RepeatedPtrField<DistanceCollectibleStatus>, POINTER-slot elements,
-- default stride). levels is a RepeatedPtrField<LevelCollectibleStatus>.
local Manifest = loadModule("metadata/manifest.lua")

return {
    ["seasonId"] = { offset = 0x18, type = "String" },
    ["levels"] = { offset = 0x20, type = "Array", elements = Manifest.load("LevelCollectibleStatus") },
    ["claimedRewardLevel"] = { offset = 0x38, type = "Int32" },
    ["totalCollectedValue"] = { offset = 0x3C, type = "Int32" },
    ["totalValue"] = { offset = 0x40, type = "Int32" },
    ["endTimestamp"] = { offset = 0x44, type = "Int32" },
}
