--==================================================
-- metadata/1.73/ReviewConditions.lua
--==================================================
-- ReviewConditions — exact IL2CPP layout, Size 0x40.
return {
    ["minWcRank"] = {
        offset = 0x00,
        type = "Float"
    },
    ["minTotalPlayTime"] = {
        offset = 0x08,
        type = "Int64"
    },
    ["minSessionTime"] = {
        offset = 0x10,
        type = "Int64"
    },
    ["maxFailedBossRaces"] = {
        offset = 0x18,
        type = "Int32"
    },
    ["showInterval"] = {
        offset = 0x20,
        type = "Int64"
    },
    ["placements"] = {
        offset = 0x28,
        type = "Array",
        elementType = "String"
    },
}
