-- metadata/1.73/SeasonResult.lua
-- Shared element template for DistanceHighscore.previousSeasons /
-- TimeTrialHighscore.previousSeasons (RepeatedPtrField<SeasonResult>,
-- POINTER-slot elements, default stride).
-- Dump: SeasonResult // Size 0x28, seasonid string @0x18, result float @0x20
return {
    ["seasonId"] = { offset = 0x18, type = "String" },
    ["result"] = { offset = 0x20, type = "Float" },
}
