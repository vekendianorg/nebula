--==================================================
-- metadata/1.73/TeamSeasonStatus.lua
--==================================================

-- Snapshot for the TeamSeasonStatus submessage — the singular member
-- GameStatus.teamSeasonStatus @0x560 (POINTER, deref'd via Object).

return {
    ["seasonId"] = {
        offset = 0x18,
        type = "String"
    },
    ["division"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["rank"] = {
        offset = 0x24,
        type = "Float"
    },
    ["previousOpponents"] = {
        offset = 0x28,
        type = "Array",
        elementType = "String"
    },
    ["startTimestamp"] = {
        offset = 0x40,
        type = "Int32"
    },
    ["endTimestamp"] = {
        offset = 0x44,
        type = "Int32"
    },
    ["finalPlacement"] = {
        offset = 0x48,
        type = "Int32"
    },
    ["subdivision"] = {
        offset = 0x4C,
        type = "Int32"
    },
    ["teamSupportLevel"] = {
        offset = 0x50,
        type = "Int32"
    },
}
