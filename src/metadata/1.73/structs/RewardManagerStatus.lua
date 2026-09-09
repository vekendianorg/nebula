-- metadata/1.73/RewardManagerStatus.lua

-- Snapshot for the RewardManagerStatus submessage — the singular
-- member GameStatus.rewardManagerStatus @0x1F8 (POINTER, deref'd
-- via Object). rewards / distanceRewards are RepeatedPtrField<
-- RewardStatus> arrays; dailyToolbox and activeDistanceReward are
-- singular submessage members (POINTERs) resolved from their own
-- snapshots.

local Manifest = loadModule("metadata/manifest.lua")

local RewardStatus = Manifest.load("RewardStatus")
local DailyToolbox = Manifest.load("DailyToolbox")

local dailyToolboxObj = { offset = 0x38, type = "Object" }
for k, v in pairs(DailyToolbox) do dailyToolboxObj[k] = v end

local activeDistanceRewardObj = { offset = 0x90, type = "Object" }
for k, v in pairs(RewardStatus) do activeDistanceRewardObj[k] = v end

return {
    ["rewards"] = { offset = 0x18, type = "Array", elements = RewardStatus },
    ["nextRewardTimestamp"] = { offset = 0x30, type = "Int32" },
    ["nextVideoAdTimestamp"] = { offset = 0x34, type = "Int32" },
    ["dailyToolbox"] = dailyToolboxObj,
    ["nextFreeChestTimestamp"] = { offset = 0x40, type = "Int32" },
    ["videoSkipSpecialCupsRemaining"] = { offset = 0x44, type = "Int32" },
    ["nextVideoSkipsTimestamp"] = { offset = 0x48, type = "Int32" },
    ["currentSpecialCupRewardIndex"] = { offset = 0x4C, type = "Int32" },
    ["distanceRewards"] = { offset = 0x50, type = "Array", elements = RewardStatus },
    ["videoSkipScrapperRemaining"] = { offset = 0x68, type = "Int32" },
    ["nextVideoSkipScrapperTimestamp"] = { offset = 0x6C, type = "Int32" },
    ["videoSkipTeamEventTicketsRemaining"] = { offset = 0x70, type = "Int32" },
    ["nextVideoSkipTeamEventTicketTimestamp"] = { offset = 0x74, type = "Int32" },
    ["videoSkipEventTicketsRemaining"] = { offset = 0x78, type = "Int32" },
    ["nextVideoSkipEventTicketTimestamp"] = { offset = 0x7C, type = "Int32" },
    ["nextVideoChestTimestamp"] = { offset = 0x80, type = "Int32" },
    ["distanceVideoRewardsRemaining"] = { offset = 0x84, type = "Int32" },
    ["videoMultipliedCoinsCollected"] = { offset = 0x88, type = "Int32" },
    ["nextVideoCoinMultiplierTimestamp"] = { offset = 0x8C, type = "Int32" },
    ["activeDistanceReward"] = activeDistanceRewardObj,
    ["distanceRewardsRemaining"] = { offset = 0x98, type = "Int32" },
    ["nextDistanceRewardsTimestamp"] = { offset = 0x9C, type = "Int32" },
    ["videoDoubleEventPointsRemaining"] = { offset = 0xA0, type = "Int32" },
    ["nextVideoDoubleEventPointsTimestamp"] = { offset = 0xA4, type = "Int32" },
    ["previousConsumedXPromo"] = { offset = 0xA8, type = "String" },
    ["chestRandomCounter"] = { offset = 0xB0, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["videoChestsRemaining"] = { offset = 0xC0, type = "Int32" },
}
