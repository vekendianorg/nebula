-- metadata/1.73/LeagueTask.lua
-- Element template for GameStatus leagueTasks arrays
-- (RepeatedPtrField<LeagueTask>, POINTER-slot elements, default stride).
return {
    ["id"] = { offset = 0x18, type = "Int32" },
    ["target"] = { offset = 0x1C, type = "Int32" },
    ["progress"] = { offset = 0x20, type = "Int32" },
    ["claimed"] = { offset = 0x24, type = "Bool" },
    ["createTimestamp"] = { offset = 0x28, type = "Int32" },
}
