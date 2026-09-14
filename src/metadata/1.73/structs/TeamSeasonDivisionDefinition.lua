--==================================================
-- metadata/1.73/TeamSeasonDivisionDefinition.lua
--==================================================
-- TeamSeasonDivisionDefinition — exact IL2CPP layout, Size 0x38.
return {
    ["division"] = {
        offset = 0x00,
        type = "Int32"
    },
    ["numberOfTeams"] = {
        offset = 0x04,
        type = "Int32"
    },
    ["promotionRankings"] = {
        offset = 0x08,
        type = "Array",
        elementType = "Int32"
    },
    ["relegationRankings"] = {
        offset = 0x20,
        type = "Array",
        elementType = "Int32"
    },
}
