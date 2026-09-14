--==================================================
-- metadata/1.74/SeasonStatus.lua
--==================================================
-- Element template for GameStatus.seasonStatus
-- (RepeatedPtrField<SeasonStatus>, POINTER-slot elements, default stride).
return {
    ["highestRank"] = {
        offset = 0x18,
        type = "Float"
    },
    ["startRank"] = {
        offset = 0x1C,
        type = "Float"
    },
    ["seasonId"] = {
        offset = 0x20,
        type = "String"
    },
    ["endTimestamp"] = {
        offset = 0x28,
        type = "Int32"
    },
    ["ended"] = {
        offset = 0x2C,
        type = "Bool"
    },
    ["premiumUnlocked"] = {
        offset = 0x2D,
        type = "Bool"
    },
    ["bonusChestClaimed"] = {
        offset = 0x2E,
        type = "Bool"
    },
    ["premiumProgressClaimed"] = {
        offset = 0x2F,
        type = "Bool"
    },
    ["receivedRewards"] = {
        offset = 0x30,
        type = "Array",
        elementType = "String"
    },
    ["animatedRank"] = {
        offset = 0x48,
        type = "Float"
    },
    ["premiumTierUnlocked"] = {
        offset = 0x4C,
        type = "Int32"
    },
}
