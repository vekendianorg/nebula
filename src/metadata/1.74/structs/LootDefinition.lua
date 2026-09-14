--==================================================
-- metadata/1.74/LootDefinition.lua
--==================================================
-- Struct-element template for LootDefinition — the reward payload
-- object pointed to by ConditionalRewardDefinition.lootDefinition.
--
-- Runtime layout note:
--   The resolved LootDefinition object has an additional 0x8-byte
--   header before the dump-mapped instance fields.
--
-- Therefore every dump offset below is shifted by +0x8 for runtime
-- memory access:
--
--   dump offset 0x00 -> runtime offset 0x08
--   dump offset 0x1C -> runtime offset 0x24
--   dump offset 0x20 -> runtime offset 0x28
--   ...
--
-- Dump source (temp/libcocoos2dcpp.cs):
--   public class LootDefinition
--       // Size: 0x278  Confidence: exact
--
-- Every runtime offset below is the corresponding dump offset + 0x8.
-- The only header-only entries are lootIcons (self-referential
-- pointers) and contentsJson (Json_Value, no mapped layout).

local Manifest = loadModule("metadata/manifest.lua")
local UnlockablePaint         = Manifest.load("UnlockablePaint")
local UnlockableSpriteVariant = Manifest.load("UnlockableSpriteVariant")
local VehicleChest            = Manifest.load("VehicleChest")
local CurrencyAmount          = Manifest.load("CurrencyAmount")
local TuningPartLoot          = Manifest.load("TuningPartLoot")
local HomePropLoot            = Manifest.load("HomePropLoot")
local CustomChest             = Manifest.load("CustomChest")
local CustomizationLoot       = Manifest.load("CustomizationLoot")
local UpgradeLoot             = Manifest.load("UpgradeLoot")
local VehicleMasteryXpReward  = Manifest.load("VehicleMasteryXpReward")
local StyleShardReward        = Manifest.load("StyleShardReward")

local M = {
    ["id"] = {
        offset = 0x08,
        type = "String"
    },
    ["rankAmount"] = {
        -- dump: float rankAmount // 0x1c
        offset = 0x24,
        type = "Float"
    },
    ["coinAmount"] = {
        offset = 0x28,
        type = "Int32"
    },
    ["gemAmount"] = {
        offset = 0x2C,
        type = "Int32"
    },
    ["masteryBonusXp"] = {
        -- dump: int masteryBonusXp // 0x28 (legacy name: bonusXpAmount)
        offset = 0x30,
        type = "Int32"
    },
    ["unlockVehicleLevel"] = {
        offset = 0x34,
        type = "Int32"
    },
    ["unlockVehicles"] = {
        -- dump: List<string> // 0x48, inline std::string elements
        offset = 0x50,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["unlockDriverAssets"] = {
        offset = 0x68,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["unlockDriverAnimations"] = {
        offset = 0x80,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["unlockVehiclePaints"] = {
        -- dump: List<UnlockablePaint> // 0x90
        offset = 0x98,
        type = "Array",
        elementStride = 0x30,
        elements = UnlockablePaint
    },
    ["unlockVehicleSpriteVariants"] = {
        -- dump: List<UnlockableSpriteVariant> // 0xa8
        offset = 0xB0,
        type = "Array",
        elementStride = 0x48,
        elements = UnlockableSpriteVariant
    },
    ["unlockAdventureMaps"] = {
        offset = 0xC8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["unlockEditorThemes"] = {
        offset = 0xE0,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["chests"] = {
        -- dump: List<int> // 0xf0 — chest IDs, Int32 ↔ name via ChestType
        offset = 0xF8,
        type = "Array",
        elementType = "Enum",
        elementStride = 4,
        enum = "ChestType"
    },
    ["vehicleChests"] = {
        -- dump: List<VehicleChest> // 0x108
        offset = 0x110,
        type = "Array",
        elementStride = 0x20,
        elements = VehicleChest
    },
    ["currencies"] = {
        -- dump: List<CurrencyAmount> // 0x120
        offset = 0x128,
        type = "Array",
        elementStride = 0x20,
        elements = CurrencyAmount
    },
    ["tuningParts"] = {
        -- dump: List<TuningPartLoot> // 0x150
        offset = 0x158,
        type = "Array",
        elementStride = 0x38,
        elements = TuningPartLoot
    },
    ["unlockHomeProps"] = {
        -- dump: List<HomePropLoot> // 0x180
        offset = 0x188,
        type = "Array",
        elementStride = 0x20,
        elements = HomePropLoot
    },
    ["customChests"] = {
        -- dump: List<CustomChest> // 0x138
        -- NOTE: the legacy inline metadata read this at 0x1B0,
        -- but per the dump 0x1B0 is `boosters`. 0x138 is the
        -- confirmed customChests dump offset.
        --
        -- Runtime offset = dump offset + 0x8.
        offset = 0x140,
        type = "Array",
        elementStride = 0x150,
        elements = CustomChest
    },
    ["unlockHomeBackgrounds"] = {
        -- dump: List<string> // 0x198
        offset = 0x1A0,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["multipleChoice"] = {
        -- dump: bool multipleChoice // 0x18
        offset = 0x20,
        type = "Bool"
    },
    ["customReward"] = {
        -- dump: string customReward // 0x30
        offset = 0x38,
        type = "String"
    },
    ["customizations"] = {
        -- dump: List<CustomizationLoot> // 0x168, INLINE elements
        offset = 0x170,
        type = "Array",
        elementStride = 0x50,
        elements = CustomizationLoot
    },
    ["boosters"] = {
        -- dump: List<string> // 0x1b0, inline std::string elements
        offset = 0x1B8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["upgrades"] = {
        -- dump: List<UpgradeLoot> // 0x1c8, INLINE elements
        offset = 0x1D0,
        type = "Array",
        elementStride = 0x50,
        elements = UpgradeLoot
    },
    ["vehicleMasteryXp"] = {
        -- dump: List<VehicleMasteryXpReward> // 0x1e0, INLINE elements
        offset = 0x1E8,
        type = "Array",
        elementStride = 0x20,
        elements = VehicleMasteryXpReward
    },
    ["styleShards"] = {
        -- dump: List<StyleShardReward> // 0x1f8, INLINE elements
        offset = 0x200,
        type = "Array",
        elementStride = 0x38,
        elements = StyleShardReward
    },
    ["useClientDecidedVehicleId"] = {
        -- dump: bool useClientDecidedVehicleId // 0x210
        offset = 0x218,
        type = "Bool"
    },
    ["clientDecidedVehicleId"] = {
        -- dump: string clientDecidedVehicleId // 0x218
        offset = 0x220,
        type = "String"
    },
    ["contentsJson"] = {
        -- dump: Json_Value contentsJson // 0x230; layout unmapped.
        offset = 0x238,
        type = "Object"
    },
    ["lootIcons"] = {
        -- dump: List<Pointer<LootDefinition>> // 0x258; elements are
        -- pointers back into LootDefinition — header only for now.
        offset = 0x260,
        type = "Array"
    }
}

--==================================================
-- Legacy fields offerDiscountLabel (0x270) and offerValueMultiplier
-- (0x274) do NOT exist in the dump: the dump class ends at
-- lootIcons (0x258) + tail padding to Size 0x278. They were
-- leftovers from an older on-device derivation and must NOT be
-- (re-)added.
--
-- NOTE:
-- The +0x8 adjustment is intentionally applied only to the field
-- offsets above. Array element strides remain unchanged because
-- they describe the size/layout of the element type itself.
--==================================================

return M