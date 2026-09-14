--==================================================
-- metadata/1.74/CurrentGachaProgress.lua
--==================================================

-- Snapshot for the CurrentGachaProgress submessage — the singular member
-- GameStatus.currentGachaProgress @0x7C8 (POINTER, deref'd via Object).

return {
    ["pendingReward"] = {
        offset = 0x18,
        type = "SafeInt32"
    },
    ["eventHash"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["totalSpins"] = {
        offset = 0x24,
        type = "Int32"
    },
    ["claimedRewards"] = {
        offset = 0x28,
        type = "Array",
        elementType = "SafeInt32"
    },
    ["claimedBonusRewards"] = {
        offset = 0x40,
        type = "SafeInt32"
    },
    ["adSpinDay"] = {
        offset = 0x48,
        type = "SafeInt32"
    },
    ["dailyAdSpins"] = {
        offset = 0x50,
        type = "SafeInt32"
    },
    ["safeTotalSpins"] = {
        offset = 0x58,
        type = "SafeInt32"
    },
}
