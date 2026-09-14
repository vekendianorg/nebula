---@class UnlockConditionType
-- Source (IL2CPP dump): UnlockType (TypeDefIndex: 394)
--
-- NOTE ON NAMING: the raw dump names this enum "UnlockType", but
-- that name was already taken by the hand-curated
-- metadata/1.74/enums/UnlockType.lua (driver customization slot
-- types — DRIVER_HEAD/DRIVER_BODY/etc, which in the dump is
-- actually a *different* enum literally named "Unlock_Type",
-- matching the protobuf descriptor's UnlockType field type).
-- Renamed to UnlockConditionType here to avoid clobbering that
-- file — this enum describes how something becomes unlocked
-- (rank threshold, event, gacha pull, purchase, ...), not a
-- customization slot.
--
-- Auto-generated from a bulk enum dump (enums.cs). Not
-- individually curated/cross-referenced — verify a given ID
-- against on-device behavior before relying on it for anything
-- write-side.
return {
    byId = {
        [0]  = "UNLOCKED",
        [1]  = "RANK",
        [2]  = "SEASONRANK",
        [3]  = "ADVENTURERRANK",
        [4]  = "EVENT",
        [5]  = "RESOURCES",
        [6]  = "OFFER",
        [7]  = "LOCKED",
        [8]  = "PREMIUMPASS",
        [9]  = "GACHA",
        [10] = "EVENTPOINTS",
    },
    byName = {
        UNLOCKED       = 0,
        RANK           = 1,
        SEASONRANK     = 2,
        ADVENTURERRANK = 3,
        EVENT          = 4,
        RESOURCES      = 5,
        OFFER          = 6,
        LOCKED         = 7,
        PREMIUMPASS    = 8,
        GACHA          = 9,
        EVENTPOINTS    = 10,
    },
}
