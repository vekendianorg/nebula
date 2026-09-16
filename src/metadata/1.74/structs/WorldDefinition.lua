--==================================================
-- metadata/1.74/WorldDefinition.lua
--==================================================
-- Complete metadata snapshot for the WorldDefinition struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is WorldDefinition only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump; 1.74 layout identical):
--   public class WorldDefinition // TypeDefIndex: 2379 Size: 0x120
--   Confidence: exact
--
-- Every offset and type below matches that dump exactly. No layout,
-- size, stride, pointer representation, or schema is guessed.
--
-- Field-name normalization (camelCase): a leading `m` is stripped
-- and the next character lowercased; fields without the `m` prefix
-- keep their dump names unchanged.
--
-- Reused existing snapshots: LevelDefinition.
-- Nested types without metadata: AnimationFileFormat, AnimationNode, WorldUnlockCriteria, LootDefinition, Difficulty.

local Manifest = loadModule("metadata/manifest.lua")
local LevelDefinition = Manifest.load("LevelDefinition")

return {
    ["id"] = {
        -- dump: public string id // 0x0
        offset = 0x0,
        type = "String",
    },
    ["name"] = {
        -- dump: public string name // 0x18
        offset = 0x18,
        type = "String",
    },
    ["icon"] = {
        -- dump: public string icon // 0x30
        offset = 0x30,
        type = "String",
    },
    ["fileFormat"] = {
        -- dump: public AnimationFileFormat fileFormat // 0x48
        offset = 0x48,
        type = "Enum",
        enum = "AnimationFileFormat",
    },
    ["animatedIcon"] = {
        -- dump: public string animatedIcon // 0x50
        offset = 0x50,
        type = "String",
    },
    ["iconAtlas"] = {
        -- dump: public string IconAtlas // 0x68
        offset = 0x68,
        type = "String",
    },
    ["animationName"] = {
        -- dump: public string animationName // 0x80
        offset = 0x80,
        type = "String",
    },
    ["iconScale"] = {
        -- dump: public float iconScale // 0x98
        offset = 0x98,
        type = "Float",
    },
    ["rewardIcon"] = {
        -- dump: public string rewardIcon // 0xa0
        offset = 0xA0,
        type = "String",
    },
    ["levels"] = {
        -- dump: public List<string> levels // 0xb8
        offset = 0xB8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["unlockCriteria"] = {
        -- dump: public WorldUnlockCriteria unlockCriteria // 0xd0
        offset = 0xD0,
        type = "Object",
        -- elements = WorldUnlockCriteria (no metadata snapshot)
    },
    ["unlockReward"] = {
        -- dump: public LootDefinition unlockReward // 0xd8
        offset = 0xD8,
        type = "Object",
        -- elements = LootDefinition (no metadata snapshot)
    },
    ["maxAdventureScorePerVehicle"] = {
        -- dump: public int maxAdventureScorePerVehicle // 0xe0
        offset = 0xE0,
        type = "Int32",
    },
    ["adventurerRankMultiplier"] = {
        -- dump: public int adventurerRankMultiplier // 0xe4
        offset = 0xE4,
        type = "Int32",
    },
    ["popupAnimations"] = {
        -- dump: public List<AnimationNode> popupAnimations // 0xe8
        offset = 0xE8,
        type = "Array",
        -- element type AnimationNode has no metadata snapshot
    },
    ["difficulty"] = {
        -- dump: public Difficulty difficulty // 0x100
        offset = 0x100,
        type = "Enum",
        enum = "Difficulty",
    },
    ["allowDistanceRewards"] = {
        -- dump: public bool allowDistanceRewards // 0x104
        offset = 0x104,
        type = "Bool",
    },
    ["levelDefinitions"] = {
        -- dump: private List<LevelDefinition> mLevelDefinitions // 0x108
        -- (key camelCase-normalized from the dump's mLevelDefinitions)
        offset = 0x108,
        type = "Array",
        elementType = "Object",
        elements = LevelDefinition,
        elementStride = 0x8,
        container = "vector",
    },
}
