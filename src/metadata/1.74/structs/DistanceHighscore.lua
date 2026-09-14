--==================================================
-- metadata/1.74/DistanceHighscore.lua
--==================================================
-- Shared element template for RepeatedPtrField<DistanceHighscore>
-- arrays (POINTER-slot elements, default stride).
-- Dump: DistanceHighscore // Size 0x48: levelid string @0x18,
-- distance float @0x20, previousseasonbest float @0x24,
-- previousseasons RepeatedPtrField<SeasonResult> @0x28,
-- currentseasonbest float @0x40

local Manifest = loadModule("metadata/manifest.lua")
local SeasonResult = Manifest.load("SeasonResult")

return {
    ["levelId"] = {
        offset = 0x18,
        type = "String"
    },
    ["distance"] = {
        offset = 0x20,
        type = "Float"
    },
    ["previousSeasonBest"] = {
        offset = 0x24,
        type = "Float"
    },
    ["previousSeasons"] = {
        offset = 0x28,
        type = "Array",
        elements = SeasonResult
    },
    ["currentSeasonBest"] = {
        offset = 0x40,
        type = "Float"
    },
}
