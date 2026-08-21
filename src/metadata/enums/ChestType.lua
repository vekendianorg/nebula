---@class ChestType
-- Bidirectional mapping between C++ Int32 chest IDs and schema
-- string names. Used by the Enum type module for vehicleChests.chestId
-- and chests array elements.
--
-- Source: $EventSchema chestId enum (19 values, IDs 0-18) +
-- economy.json specialCupRewards (21 entries, IDs 0-20) +
-- economy.json key indexes (freeChestIndex, vipChestIndexes, etc.)
--
-- IDs 19-20 ("style", "mythic") are NOT in the $EventSchema enum —
-- they were added to the game after the schema was written. Names
-- derived from economy.json chest image assets (toolbox_style,
-- toolbox_7) and iapChests display names ("Mythic Chest of
-- Goodies" → rewardChestTypeIndex=20).
--
--  ID | Schema Name        | Display Name          | Economy Evidence
-- ----|-------------------|-----------------------|------------------
--   0 | common            | Common Chest          | toolbox_1
--   1 | uncommon          | Uncommon Chest        | toolbox_2, vehicleChestIndex
--   2 | rare              | Rare Chest            | toolbox_3, vehicleChestIndex
--   3 | epic              | Epic Chest            | toolbox_4, epic particles
--   4 | champion          | Champion Chest         | toolbox_5
--   5 | tutorial          | Special Chest 1       | toolbox_1 (reused)
--   6 | xmas              | Xmas Chest             | toolbox_x
--   7 | legendary         | Legendary Chest       | toolbox_6, legendary particles
--   8 | free              | Blue Chest            | toolbox_free, freeChestIndex=8
--   9 | vip               | VIP Chest 1           | toolbox_vip, subscriptionChest=9
--  10 | vip2              | VIP Chest 2           | toolbox_vip, subscriptionChest=10
--  11 | video             | Video Chest           | toolbox_free, videoChestIndex=11
--  12 | tutorial_looks    | Starter Chest         | toolbox_1 (reused)
--  13 | tutorial_tuningparts | Special Chest 2    | toolbox_1 (reused)
--  14 | xpromo            | Fingersoft Chest      | toolbox_crosspromo, xpromoChestIndex=14
--  15 | mega              | Mega Chest            | mega_ad_chest
--  16 | legendary_team    | Team Legendary Chest  | toolbox_6, legendary particles
--  17 | vip_diamond       | VIP Diamond Chest     | toolbox_vip, vipChestIndexes=[10,17]
--  18 | team_support      | Team Spirit Chest     | toolbox_teamsupport, epic particles
--  19 | style             | Style Chest           | toolbox_style, legendary particles (not in schema)
--  20 | mythic            | Mythic Chest          | toolbox_7, legendary particles (not in schema)
return {
    byId = {
        [0]  = "common",
        [1]  = "uncommon",
        [2]  = "rare",
        [3]  = "epic",
        [4]  = "champion",
        [5]  = "tutorial",
        [6]  = "xmas",
        [7]  = "legendary",
        [8]  = "free",
        [9]  = "vip",
        [10] = "vip2",
        [11] = "video",
        [12] = "tutorial_looks",
        [13] = "tutorial_tuningparts",
        [14] = "xpromo",
        [15] = "mega",
        [16] = "legendary_team",
        [17] = "vip_diamond",
        [18] = "team_support",
        [19] = "style",
        [20] = "mythic",
    },
    byName = {
        common                  = 0,
        uncommon                = 1,
        rare                    = 2,
        epic                    = 3,
        champion                = 4,
        tutorial                = 5,
        xmas                    = 6,
        legendary               = 7,
        free                    = 8,
        vip                     = 9,
        vip2                    = 10,
        video                   = 11,
        tutorial_looks          = 12,
        tutorial_tuningparts    = 13,
        xpromo                  = 14,
        mega                    = 15,
        legendary_team          = 16,
        vip_diamond             = 17,
        team_support            = 18,
        style                   = 19,
        mythic                  = 20,
    },
}
