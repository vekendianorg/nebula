---@class TuningRarity
-- Bidirectional mapping between C++ Int32 tuning part rarity IDs
-- and schema string names. Used by the Enum type module for
-- tuningParts.rarity.
--
-- Source: $EventSchema tuningParts.items.properties.rarity enum +
-- economy.json tuningPartsRarityWeights arrays.
--
-- Note: ID 0 is "none" (no rarity set) — not in the schema enum,
-- not a valid rarity. The schema's 4 values start at ID 1. ID 5
-- (mythic) was added after the schema was written, same as chest
-- types style/mythic.
--
--  ID | Schema Name | Economy Array Index
-- ----|------------|--------------------
--   0 | none       | 0 (always 0 weight/amount)
--   1 | common     | 1
--   2 | rare       | 2
--   3 | epic       | 3
--   4 | legendary  | 4
--   5 | mythic     | 5
return {
    byId = {
        [0] = "none",
        [1] = "common",
        [2] = "rare",
        [3] = "epic",
        [4] = "legendary",
        [5] = "mythic",
    },
    byName = {
        none      = 0,
        common    = 1,
        rare      = 2,
        epic      = 3,
        legendary = 4,
        mythic    = 5,
    },
}
