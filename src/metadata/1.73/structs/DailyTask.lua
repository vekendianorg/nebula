-- metadata/1.73/DailyTask.lua
-- Element template for GameStatus dailyTasks / CurrentFriendEvent.activeEventTasks
-- (RepeatedPtrField<DailyTask>, POINTER-slot elements, default stride).
return {
    ["type"] = { offset = 0x18, type = "Int32" },
    ["target"] = { offset = 0x1C, type = "Int32" },
    ["vehicle"] = { offset = 0x20, type = "String" },
    ["level"] = { offset = 0x28, type = "String" },
    ["completed"] = { offset = 0x30, type = "Bool" },
    ["progress"] = { offset = 0x34, type = "Int32" },
    ["slot"] = { offset = 0x38, type = "Int32" },
    ["createTimestamp"] = { offset = 0x3C, type = "Int32" },
    ["taskSpecific"] = { offset = 0x40, type = "Array", elementType = "Int32", elementStride = 0x4 },
}
