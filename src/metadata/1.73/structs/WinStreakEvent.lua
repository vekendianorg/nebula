-- metadata/1.73/WinStreakEvent.lua

-- Snapshot for the WinStreakEvent submessage — the singular member
-- GameStatus.winStreakEvent @0x870 (POINTER, deref'd via Object).

return {
    ["cupCounter"] = { offset = 0x18, type = "SafeInt32" },
    ["endTime"] = { offset = 0x20, type = "SafeInt32" },
    ["startStreak"] = { offset = 0x28, type = "SafeInt32" },
    ["claimedRewards"] = { offset = 0x30, type = "Array", elementType = "SafeInt32" },
    ["vehicleId"] = { offset = 0x48, type = "String" },
    ["rewards"] = { offset = 0x50, type = "Array", elementType = "SafeInt32" },
    ["cooldownTime"] = { offset = 0x68, type = "SafeInt32" },
    ["active"] = { offset = 0x70, type = "Bool" },
    ["pendingEnd"] = { offset = 0x71, type = "Bool" },
}
