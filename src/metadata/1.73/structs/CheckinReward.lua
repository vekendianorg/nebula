-- metadata/1.73/CheckinReward.lua

-- Snapshot for the CheckinReward submessage — the singular member
-- GameStatus.checkinReward @0x420 (POINTER, deref'd via Object).

return {
    ["id"] = { offset = 0x18, type = "String" },
    ["rewardIndex"] = { offset = 0x20, type = "Int32" },
    ["lastCollectedTimestamp"] = { offset = 0x24, type = "Int32" },
    ["startTimestamp"] = { offset = 0x28, type = "Int32" },
    ["endTimestamp"] = { offset = 0x2C, type = "Int32" },
    ["claimedRewards"] = { offset = 0x30, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["allowDaySkip"] = { offset = 0x40, type = "Bool" },
    ["updateRewardIndexAfterSkip"] = { offset = 0x41, type = "Bool" },
    ["minCollectInterval"] = { offset = 0x44, type = "Int32" },
    ["maxCollectInterval"] = { offset = 0x48, type = "Int32" },
    ["shuffleKey"] = { offset = 0x4C, type = "Int32" },
}
