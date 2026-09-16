--==================================================
-- metadata/1.73/RaceEventDefinition.lua
--==================================================
-- Complete metadata snapshot for the RaceEventDefinition struct at game
-- version 1.73 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is RaceEventDefinition only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump):
--   public class RaceEventDefinition // TypeDefIndex: 1831 Size: 0xc0
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
-- Nested types without metadata: EventUnlockType.

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
    ["eventIcon"] = {
        -- dump: public string eventIcon // 0x30
        offset = 0x30,
        type = "String",
    },
    ["levels"] = {
        -- dump: public List<string> levels // 0x48
        offset = 0x48,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["price"] = {
        -- dump: public int price // 0x60
        offset = 0x60,
        type = "Int32",
    },
    ["eventUnlockType"] = {
        -- dump: public EventUnlockType eventUnlockType // 0x64
        offset = 0x64,
        type = "Enum",
        enum = "EventUnlockType",
    },
    ["eventUnlockRank"] = {
        -- dump: public float eventUnlockRank // 0x68
        offset = 0x68,
        type = "Float",
    },
    ["eventUnlockLevelButtonId"] = {
        -- dump: public string eventUnlockLevelButtonId // 0x70
        offset = 0x70,
        type = "String",
    },
    ["eventUnlockDistance"] = {
        -- dump: public int eventUnlockDistance // 0x88
        offset = 0x88,
        type = "Int32",
    },
    ["allowedVehicles"] = {
        -- dump: public List<string> allowedVehicles // 0x90
        offset = 0x90,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["levelDefinitions"] = {
        -- dump: private List<LevelDefinition> mLevelDefinitions // 0xa8
        -- (key camelCase-normalized from the dump's mLevelDefinitions)
        offset = 0xA8,
        type = "Array",
        elementType = "Object",
        elements = LevelDefinition,
        elementStride = 0x8,
        container = "vector",
    },
}
