-- metadata/1.73/RacePoints.lua
-- Element template for GameStatus.racePoints
-- (RepeatedPtrField<RacePoints>, POINTER-slot elements, default stride).
return {
    ["levelId"] = { offset = 0x18, type = "String" },
    ["points"] = { offset = 0x20, type = "Int32" },
}
