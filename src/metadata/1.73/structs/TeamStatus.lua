-- metadata/1.73/TeamStatus.lua

-- Snapshot for the TeamStatus submessage — the singular member
-- GameStatus.teamStatus @0x4B0 (POINTER, deref'd via Object).

return {
    ["collectedTeamChests"] = { offset = 0x18, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["joinedToTeamTimestamp"] = { offset = 0x28, type = "Int32" },
    ["pendingTeamChestContribution"] = { offset = 0x2C, type = "Float" },
    ["numberOfTeamJoins"] = { offset = 0x30, type = "Int32" },
    ["numberOfKickedOut"] = { offset = 0x34, type = "Int32" },
    ["reportedMessages"] = { offset = 0x38, type = "Array", elementType = "String" },
    ["currentTeamDonations"] = { offset = 0x50, type = "SafeInt32" },
    ["collectedTeamBossChests"] = { offset = 0x58, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["waitingJoinLeaveResponse"] = { offset = 0x68, type = "Bool" },
    ["waitingCreateResponse"] = { offset = 0x69, type = "Bool" },
}
