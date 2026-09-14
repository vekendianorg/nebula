--==================================================
-- metadata/1.73/MegaAdChestRewardStatus.lua
--==================================================
-- Element template for GameStatus megaAdChest reward-status arrays
-- (RepeatedPtrField<MegaAdChestRewardStatus>, POINTER-slot elements,
-- default stride). reward / rewardLastSession are singular submessage
-- members — POINTERs (8-byte slots, deref'd via Object) to MegaAdChestItem.
local Manifest = loadModule("metadata/manifest.lua")
local MegaAdChestItem = Manifest.load("MegaAdChestItem")


return {
    ["watched"] = {
        offset = 0x18,
        type = "Int32"
    },
    ["watchedLastSession"] = {
        offset = 0x1C,
        type = "Int32"
    },
    ["reward"] = {
        offset = 0x20,
        type = "Object",
        elements = MegaAdChestItem
    },
    ["rewardLastSession"] = {
        offset = 0x28,
        type = "Object",
        elements = MegaAdChestItem
    },
    ["claimed"] = {
        offset = 0x30,
        type = "Bool"
    },
    ["claimedLastSession"] = {
        offset = 0x31,
        type = "Bool"
    },
}
