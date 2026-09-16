--==================================================
-- metadata/1.74/LevelDefinition.lua
--==================================================
-- Complete metadata snapshot for the LevelDefinition struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is LevelDefinition only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump; 1.74 layout identical):
--   public class LevelDefinition // TypeDefIndex: 1594 Size: 0x370
--   Confidence: exact
--
-- Every offset and type below matches that dump exactly. No layout,
-- size, stride, pointer representation, or schema is guessed.
--
-- Field-name normalization (camelCase): a leading `m` is stripped
-- and the next character lowercased; fields without the `m` prefix
-- keep their dump names unchanged.
--
-- NOTE: Many nested types (BlockDefinition, LevelScript, FuelDensityIncreaseDefinition,
-- PostProcessDefinition, EffectObjectDefinition, UnlockRequirements) have no metadata
-- snapshots and are omitted. List<T> fields with unknown element types are omitted.

local Manifest = loadModule("metadata/manifest.lua")
local Algorithm = Manifest.load("Algorithm")

return {
    ["id"] = {
        -- dump: public string id // 0x0
        offset = 0x0,
        type = "String",
    },
    ["filename"] = {
        -- dump: public string filename // 0x18
        offset = 0x18,
        type = "String",
    },
    ["buttonId"] = {
        -- dump: public string buttonId // 0x30
        offset = 0x30,
        type = "String",
    },
    ["title"] = {
        -- dump: public string title // 0x48
        offset = 0x48,
        type = "String",
    },
    ["englishTitle"] = {
        -- dump: public string englishTitle // 0x60
        offset = 0x60,
        type = "String",
    },
    ["description"] = {
        -- dump: public string description // 0x78
        offset = 0x78,
        type = "String",
    },
    ["startMessage"] = {
        -- dump: public string startMessage // 0x90
        offset = 0x90,
        type = "String",
    },
    ["worldId"] = {
        -- dump: public string worldId // 0xa8
        offset = 0xA8,
        type = "String",
    },
    ["levelType"] = {
        -- dump: public LevelType levelType // 0xc0
        offset = 0xC0,
        type = "Enum",
        enum = "LevelType",
    },
    ["levelDifficulty"] = {
        -- dump: public LevelDifficulty levelDifficulty // 0xc4
        offset = 0xC4,
        type = "Enum",
        enum = "LevelDifficulty",
    },
    ["unlocks"] = {
        -- dump: public List<string> unlocks // 0xc8
        offset = 0xC8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["removeBlocksFromBehind"] = {
        -- dump: public bool removeBlocksFromBehind // 0xe0
        offset = 0xE0,
        type = "Bool",
    },
    ["levelDistance"] = {
        -- dump: public float levelDistance // 0xe4
        offset = 0xE4,
        type = "Float",
    },
    ["levelDrawDistance"] = {
        -- dump: public float levelDrawDistance // 0xe8
        offset = 0xE8,
        type = "Float",
    },
    ["spawnObjectDelay"] = {
        -- dump: public float spawnObjectDelay // 0xec
        offset = 0xEC,
        type = "Float",
    },
    ["postprocessLayer"] = {
        -- dump: public PostProcessDefinition postprocessLayer // 0xf0
        offset = 0xF0,
        type = "Object",
        -- elements = PostProcessDefinition (no metadata snapshot)
    },
    ["lapDistance"] = {
        -- dump: public float lapDistance // 0xf8
        offset = 0xF8,
        type = "Float",
    },
    ["checkpointDistance"] = {
        -- dump: public float checkpointDistance // 0xfc
        offset = 0xFC,
        type = "Float",
    },
    ["referenceTime"] = {
        -- dump: public float referenceTime // 0x100
        offset = 0x100,
        type = "Float",
    },
    ["algorithm"] = {
        -- dump: public Algorithm algorithm // 0x108 — POINTER slot
        -- to the Algorithm class (the 0x108 → 0x110 → 0x118 8-byte
        -- spacing proves the pointer representation). Algorithm is
        -- a class, not an enum — see structs/Algorithm.lua.
        offset = 0x108,
        type = "Object",
        elements = Algorithm,
    },
    ["caveBottomAlgorithm"] = {
        -- dump: public Algorithm caveBottomAlgorithm // 0x110
        offset = 0x110,
        type = "Object",
        elements = Algorithm,
    },
    ["caveTopAlgorithm"] = {
        -- dump: public Algorithm caveTopAlgorithm // 0x118
        offset = 0x118,
        type = "Object",
        elements = Algorithm,
    },
    ["gravity"] = {
        -- dump: public cocos2d_Vec2 gravity // 0x120
        offset = 0x120,
        type = "Object",
        -- elements = Vec2 (no metadata snapshot)
    },
    ["wind"] = {
        -- dump: public bool wind // 0x128
        offset = 0x128,
        type = "Bool",
    },
    ["applyFluidForces"] = {
        -- dump: public bool applyFluidForces // 0x129
        offset = 0x129,
        type = "Bool",
    },
    ["applyFluidForcesWithoutRain"] = {
        -- dump: public bool applyFluidForcesWithoutRain // 0x12a
        offset = 0x12A,
        type = "Bool",
    },
    ["erodeSurface"] = {
        -- dump: public bool erodeSurface // 0x12b
        offset = 0x12B,
        type = "Bool",
    },
    ["friction"] = {
        -- dump: public float friction // 0x12c
        offset = 0x12C,
        type = "Float",
    },
    ["firstCoinPosition"] = {
        -- dump: public float firstCoinPosition // 0x130
        offset = 0x130,
        type = "Float",
    },
    ["firstFuelChunkIndex"] = {
        -- dump: public int firstFuelChunkIndex // 0x134
        offset = 0x134,
        type = "Int32",
    },
    ["coinSpawnDistance"] = {
        -- dump: public float coinSpawnDistance // 0x138
        offset = 0x138,
        type = "Float",
    },
    ["coinHeightOffset"] = {
        -- dump: public float coinHeightOffset // 0x13c
        offset = 0x13C,
        type = "Float",
    },
    ["noFuel"] = {
        -- dump: public bool noFuel // 0x140
        offset = 0x140,
        type = "Bool",
    },
    ["noFuelAfterDistance"] = {
        -- dump: public float noFuelAfterDistance // 0x144
        offset = 0x144,
        type = "Float",
    },
    ["fuelDensity"] = {
        -- dump: public float fuelDensity // 0x148
        offset = 0x148,
        type = "Float",
    },
    ["fuelDensityIncrease"] = {
        -- dump: public float fuelDensityIncrease // 0x14c
        offset = 0x14C,
        type = "Float",
    },
    ["fuelDensityIncreases"] = {
        -- dump: public List<FuelDensityIncreaseDefinition> fuelDensityIncreases // 0x150
        offset = 0x150,
        type = "Array",
        -- element type FuelDensityIncreaseDefinition has no metadata snapshot
    },
    ["backwallDistance"] = {
        -- dump: public float backwallDistance // 0x168
        offset = 0x168,
        type = "Float",
    },
    ["backwallStartDistance"] = {
        -- dump: public float backwallStartDistance // 0x16c
        offset = 0x16C,
        type = "Float",
    },
    ["propMasterSeed"] = {
        -- dump: public int propMasterSeed // 0x170
        offset = 0x170,
        type = "Int32",
    },
    ["blockRandomSeed"] = {
        -- dump: public int blockRandomSeed // 0x174
        offset = 0x174,
        type = "Int32",
    },
    ["logo"] = {
        -- dump: public string logo // 0x178
        offset = 0x178,
        type = "String",
    },
    ["blocks"] = {
        -- dump: public List<BlockDefinition> blocks // 0x190
        offset = 0x190,
        type = "Array",
        -- element type BlockDefinition has no metadata snapshot
    },
    ["fixedBlockOrder"] = {
        -- dump: public List<string> fixedBlockOrder // 0x1a8
        offset = 0x1A8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["defaultFixedBlockOrder"] = {
        -- dump: public List<string> defaultFixedBlockOrder // 0x1c0
        offset = 0x1C0,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["randomFixedBlocks"] = {
        -- dump: public List<string> randomFixedBlocks // 0x1d8
        offset = 0x1D8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["jsonBlockFile"] = {
        -- dump: public string jsonBlockFile // 0x1f0
        offset = 0x1F0,
        type = "String",
    },
    ["randomizeEachDay"] = {
        -- dump: public bool randomizeEachDay // 0x208
        offset = 0x208,
        type = "Bool",
    },
    ["adventureGroupMutualId"] = {
        -- dump: public string adventureGroupMutualId // 0x210
        offset = 0x210,
        type = "String",
    },
    ["adventureGroup"] = {
        -- dump: public List<string> adventureGroup // 0x228
        offset = 0x228,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["imageNodeToChange"] = {
        -- dump: public string imageNodeToChange // 0x240
        offset = 0x240,
        type = "String",
    },
    ["pathsToImagesToChange"] = {
        -- dump: public List<string> pathsToImagesToChange // 0x258
        offset = 0x258,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["pathToDailySign"] = {
        -- dump: public string pathToDailySign // 0x270
        offset = 0x270,
        type = "String",
    },
    ["useOnlyFixedBlocks"] = {
        -- dump: public bool useOnlyFixedBlocks // 0x288
        offset = 0x288,
        type = "Bool",
    },
    ["scripts"] = {
        -- dump: public List<LevelScript> scripts // 0x290
        offset = 0x290,
        type = "Array",
        -- element type LevelScript has no metadata snapshot
    },
    ["cameraMinVisibilityOffset"] = {
        -- dump: public float cameraMinVisibilityOffset // 0x2a8
        offset = 0x2A8,
        type = "Float",
    },
    ["cameraMaxVisibilityOffset"] = {
        -- dump: public float cameraMaxVisibilityOffset // 0x2ac
        offset = 0x2AC,
        type = "Float",
    },
    ["singleJumpStartDistance"] = {
        -- dump: public float singleJumpStartDistance // 0x2b0
        offset = 0x2B0,
        type = "Float",
    },
    ["targetDistance"] = {
        -- dump: public float targetDistance // 0x2b4
        offset = 0x2B4,
        type = "Float",
    },
    ["targetRadius"] = {
        -- dump: public float targetRadius // 0x2b8
        offset = 0x2B8,
        type = "Float",
    },
    ["rubeBlockOrder"] = {
        -- dump: public bool rubeBlockOrder // 0x2bc
        offset = 0x2BC,
        type = "Bool",
    },
    ["rubeBlockOrderFirstPassOnly"] = {
        -- dump: public bool rubeBlockOrderFirstPassOnly // 0x2bd
        offset = 0x2BD,
        type = "Bool",
    },
    ["isCustomTrack"] = {
        -- dump: public bool isCustomTrack // 0x2be
        offset = 0x2BE,
        type = "Bool",
    },
    ["gfxDefinitionFile"] = {
        -- dump: public string gfxDefinitionFile // 0x2c0
        offset = 0x2C0,
        type = "String",
    },
    ["gfxPlistFile"] = {
        -- dump: public string gfxPlistFile // 0x2d8
        offset = 0x2D8,
        type = "String",
    },
    ["additionalGfxDefinitionFile"] = {
        -- dump: public string additionalGfxDefinitionFile // 0x2f0
        offset = 0x2F0,
        type = "String",
    },
    ["additionalGfxPlistFile"] = {
        -- dump: public string additionalGfxPlistFile // 0x308
        offset = 0x308,
        type = "String",
    },
    ["unlockRequirements"] = {
        -- dump: public UnlockRequirements unlockRequirements // 0x320
        offset = 0x320,
        type = "Object",
        -- elements = UnlockRequirements (no metadata snapshot)
    },
    ["levelTier"] = {
        -- dump: public int levelTier // 0x328
        offset = 0x328,
        type = "Int32",
    },
    ["starCriteria"] = {
        -- dump: public List<float> starCriteria // 0x330
        offset = 0x330,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4,
        container = "vector",
    },
    ["effectObjects"] = {
        -- dump: public List<EffectObjectDefinition> effectObjects // 0x348
        offset = 0x348,
        type = "Array",
        -- element type EffectObjectDefinition has no metadata snapshot
    },
    ["globalZ"] = {
        -- dump: public cocos2d_Vec3 globalZ // 0x360
        offset = 0x360,
        type = "Object",
        -- elements = Vec3 (no metadata snapshot)
    },
    ["isCave"] = {
        -- dump: public bool isCave // 0x36c
        offset = 0x36C,
        type = "Bool",
    },
    ["isHybrid"] = {
        -- dump: public bool isHybrid // 0x36d
        offset = 0x36D,
        type = "Bool",
    },
}
