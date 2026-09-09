-- metadata/1.73/CurrentFriendEvent.lua
-- Element template for GameStatus.currentFriendEvent
-- (RepeatedPtrField<CurrentFriendEvent>, POINTER-slot elements, default
-- stride). activeEventTasks is a RepeatedPtrField<DailyTask> array.
local Manifest = loadModule("metadata/manifest.lua")

return {
    ["claimedRewards"] = { offset = 0x18, type = "Array", elementType = "SafeInt32" },
    ["eventHash"] = { offset = 0x30, type = "Int32" },
    ["hasEventPass"] = { offset = 0x34, type = "Bool" },
    ["collectibleResetTimestamp"] = { offset = 0x38, type = "SafeInt32" },
    ["collectibleCollected"] = { offset = 0x40, type = "SafeInt32" },
    ["activeEventTasks"] = { offset = 0x48, type = "Array", elements = Manifest.load("DailyTask") },
    ["taskRefillsRemaining"] = { offset = 0x60, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["singleScore"] = { offset = 0x70, type = "SafeInt32" },
    ["tasksResetTimestamp"] = { offset = 0x78, type = "Int32" },
    ["adsResetTimestamp"] = { offset = 0x7C, type = "Int32" },
    ["eventId"] = { offset = 0x80, type = "String" },
    ["teamId"] = { offset = 0x88, type = "String" },
    ["adsRemaining"] = { offset = 0x90, type = "Int32" },
}
