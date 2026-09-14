--==================================================
-- metadata/1.74/MegaAdChestItem.lua
--==================================================
-- Shared item template composed into MegaAdChestRewardStatus.reward /
-- rewardLastSession and MegaAdChestProgressDay.reward (singular submessage
-- members — POINTERs, deref'd via Object containers).
-- Dump: MegaAdChestItem = { type int32, amount int32, rarity int32 }
return {
    ["type"] = {
        offset = 0x18,
        type = "Int32"
    },
    ["amount"] = {
        offset = 0x1C,
        type = "Int32"
    },
    ["rarity"] = {
        offset = 0x20,
        type = "Enum",
        enum = "Rarity"
    },
}
