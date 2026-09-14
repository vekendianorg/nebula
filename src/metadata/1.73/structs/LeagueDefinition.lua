--==================================================
-- metadata/1.73/LeagueDefinition.lua
--==================================================
-- LeagueDefinition — exact IL2CPP layout, Size 0x108.
return {
    ["title"] = {
        offset = 0x00,
        type = "String"
    },
    ["icon"] = {
        offset = 0x18,
        type = "String"
    },
    ["cupBackground"] = {
        offset = 0x30,
        type = "String"
    },
    ["minRank"] = {
        offset = 0x48,
        type = "Int32"
    },
    ["minRankSteps"] = {
        offset = 0x4c,
        type = "Int32"
    },
    ["raceRewards"] = {
        offset = 0x50,
        type = "Array",
        elementType = "Int32"
    },
    ["majorLeagueLevel"] = {
        offset = 0x68,
        type = "Int32"
    },
    ["majorTitle"] = {
        offset = 0x70,
        type = "String"
    },
    ["majorIcon"] = {
        offset = 0x88,
        type = "String"
    },
    ["bossEvent"] = {
        offset = 0xa0,
        type = "String"
    },
    ["iconAnimations"] = {
        offset = 0xb8,
        type = "Array",
        elementType = "String"
    },
    ["starAnimations"] = {
        offset = 0xd0,
        type = "Array",
        elementType = "String"
    },
    ["staticIcon"] = {
        offset = 0xe8,
        type = "String"
    },
    ["numStars"] = {
        offset = 0x100,
        type = "Int32"
    },
}
