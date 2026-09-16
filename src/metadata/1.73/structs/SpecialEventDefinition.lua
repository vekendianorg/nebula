--==================================================
-- metadata/1.73/SpecialEventDefinition.lua
--==================================================
-- Complete metadata snapshot for the SpecialEventDefinition struct at game
-- version 1.73 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is SpecialEventDefinition only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump):
--   public class SpecialEventDefinition // TypeDefIndex: 2010 Size: 0x108
--   Confidence: exact
--
-- Every offset and type below matches that dump exactly. No layout,
-- size, stride, pointer representation, or schema is guessed.
--
-- Field-name normalization (camelCase): a leading `m` is stripped
-- and the next character lowercased; fields without the `m` prefix
-- keep their dump names unchanged.
--
-- Reused existing snapshots: BossGhostDefinition.

local Manifest = loadModule("metadata/manifest.lua")
local BossGhostDefinition = Manifest.load("BossGhostDefinition")

return {
    ["id"] = {
        -- dump: public string id // 0x0
        offset = 0x0,
        type = "String",
    },
    ["type"] = {
        -- dump: public SpecialEventType type // 0x18
        offset = 0x18,
        type = "Enum",
        enum = "SpecialEventType",
    },
    ["minRank"] = {
        -- dump: public int minRank // 0x1c
        offset = 0x1C,
        type = "Int32",
    },
    ["eventBorder"] = {
        -- dump: public string eventBorder // 0x20
        offset = 0x20,
        type = "String",
    },
    ["cupPool"] = {
        -- dump: public List<string> cupPool // 0x38
        offset = 0x38,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["cupShuffleProbability"] = {
        -- dump: public float cupShuffleProbability // 0x50
        offset = 0x50,
        type = "Float",
    },
    ["cupShuffleProbabilityAfterRewardsUnlocked"] = {
        -- dump: public float cupShuffleProbabilityAfterRewardsUnlocked // 0x54
        offset = 0x54,
        type = "Float",
    },
    ["rewardShuffle"] = {
        -- dump: public List<int> rewardShuffle // 0x58
        offset = 0x58,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4,
        container = "vector",
    },
    ["menuMusic"] = {
        -- dump: public string menuMusic // 0x70
        offset = 0x70,
        type = "String",
    },
    ["bossGhost"] = {
        -- dump: public BossGhostDefinition bossGhost // 0x88
        offset = 0x88,
        type = "Object",
        elements = BossGhostDefinition,
    },
}
