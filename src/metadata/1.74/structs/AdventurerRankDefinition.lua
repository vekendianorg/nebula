--==================================================
-- metadata/1.74/AdventurerRankDefinition.lua
--==================================================
-- AdventurerRankDefinition — exact IL2CPP layout, Size 0x60.
local Manifest = loadModule("metadata/manifest.lua")
local LootDefinition = Manifest.load("LootDefinition")

return {
    ["title"] = {
        offset = 0x00,
        type = "String"
    },
    ["subTitle"] = {
        offset = 0x18,
        type = "String"
    },
    ["icon"] = {
        offset = 0x30,
        type = "String"
    },
    ["requiredRank"] = {
        offset = 0x48,
        type = "Float"
    },
    ["minRankSteps"] = {
        offset = 0x4c,
        type = "Float"
    },
    ["levelUpReward"] = {
        offset = 0x50,
        type = "Object",
        elements = LootDefinition
    },
    ["rankStepReward"] = {
        offset = 0x58,
        type = "Object",
        elements = LootDefinition
    },
}
