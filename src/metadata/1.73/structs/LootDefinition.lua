--==================================================
-- metadata/1.73/LootDefinition.lua
--==================================================
-- Struct-element template for LootDefinition — the reward payload
-- object pointed to by ConditionalRewardDefinition.lootDefinition.
--
-- Dump source (temp/libcocoos2dcpp.cs):
--   public class LootDefinition
--       // Size: 0x278  Confidence: exact
--
-- Every offset below matches the dump. Every field of the dump
-- class is mapped; the only header-only entries are lootIcons
-- (self-referential pointers) and contentsJson (Json_Value, no
-- mapped layout). See the note at the bottom re: legacy
-- offerDiscountLabel / offerValueMultiplier.

local Manifest = loadModule("metadata/manifest.lua")

local M = {
    ["id"] = {
        offset = 0x0,
        type = "String"
    },
    ["rankAmount"] = {
        -- dump: float rankAmount // 0x1c
        offset = 0x1C,
        type = "Float"
    },
    ["coinAmount"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["gemAmount"] = {
        offset = 0x24,
        type = "Int32"
    },
    ["masteryBonusXp"] = {
        -- dump: int masteryBonusXp // 0x28 (legacy name: bonusXpAmount)
        offset = 0x28,
        type = "Int32"
    },
    ["unlockVehicleLevel"] = {
        offset = 0x2C,
        type = "Int32"
    },
    ["unlockVehicles"] = {
        -- dump: List<string> // 0x48, inline std::string elements
        offset = 0x48,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["unlockDriverAssets"] = {
        offset = 0x60,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["unlockDriverAnimations"] = {
        offset = 0x78,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["unlockVehiclePaints"] = {
        -- dump: List<UnlockablePaint> // 0x90
        offset = 0x90,
        type = "Array",
        elementStride = 0x30,
        elements = Manifest.load("UnlockablePaint")
    },
    ["unlockVehicleSpriteVariants"] = {
        -- dump: List<UnlockableSpriteVariant> // 0xa8
        offset = 0xA8,
        type = "Array",
        elementStride = 0x48,
        elements = Manifest.load("UnlockableSpriteVariant")
    },
    ["unlockAdventureMaps"] = {
        offset = 0xC0,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["unlockEditorThemes"] = {
        offset = 0xD8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["chests"] = {
        -- dump: List<int> // 0xf0 — chest IDs, Int32 ↔ name via ChestType
        offset = 0xF0,
        type = "Array",
        elementType = "Enum",
        elementStride = 4,
        enum = "ChestType"
    },
    ["vehicleChests"] = {
        -- dump: List<VehicleChest> // 0x108
        offset = 0x108,
        type = "Array",
        elementStride = 0x20,
        elements = Manifest.load("VehicleChest")
    },
    ["currencies"] = {
        -- dump: List<CurrencyAmount> // 0x120
        offset = 0x120,
        type = "Array",
        elementStride = 0x20,
        elements = Manifest.load("CurrencyAmount")
    },
    ["tuningParts"] = {
        -- dump: List<TuningPartLoot> // 0x150
        offset = 0x150,
        type = "Array",
        elementStride = 0x38,
        elements = Manifest.load("TuningPartLoot")
    },
    ["unlockHomeProps"] = {
        -- dump: List<HomePropLoot> // 0x180
        offset = 0x180,
        type = "Array",
        elementStride = 0x20,
        elements = Manifest.load("HomePropLoot")
    },
    ["customChests"] = {
        -- dump: List<CustomChest> // 0x138. NOTE: the legacy inline
        -- metadata read this at 0x1B0 — but per the dump 0x1B0 is
        -- `boosters` (List<string>); 0x138 is the confirmed
        -- customChests offset. Moved to the dump offset.
        -- Inline std::vector<CustomChest> elements; stride = sizeof
        -- (CustomChest) = 0x150 derived from the element's field
        -- extents (0x138 + 0x18 vector) — NOT from the dump
        -- class-line Size annotation.
        offset = 0x138,
        type = "Array",
        elementStride = 0x150,
        elements = Manifest.load("CustomChest")
    },
    ["unlockHomeBackgrounds"] = {
        -- dump: List<string> // 0x198
        offset = 0x198,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["multipleChoice"] = {
        -- dump: bool multipleChoice // 0x18
        offset = 0x18,
        type = "Bool"
    },
    ["customReward"] = {
        -- dump: string customReward // 0x30
        offset = 0x30,
        type = "String"
    },
    ["customizations"] = {
        -- dump: List<CustomizationLoot> // 0x168, INLINE elements
        -- (stride = sizeof(CustomizationLoot) = 0x50 from field
        -- extents: rarity@0x48 + 4, padded).
        offset = 0x168,
        type = "Array",
        elementStride = 0x50,
        elements = Manifest.load("CustomizationLoot")
    },
    ["boosters"] = {
        -- dump: List<string> // 0x1b0, inline std::string elements
        offset = 0x1B0,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["upgrades"] = {
        -- dump: List<UpgradeLoot> // 0x1c8, INLINE elements
        -- (stride = sizeof(UpgradeLoot) = 0x50 from field extents:
        -- levelUps@0x48 + 4, padded).
        offset = 0x1C8,
        type = "Array",
        elementStride = 0x50,
        elements = Manifest.load("UpgradeLoot")
    },
    ["vehicleMasteryXp"] = {
        -- dump: List<VehicleMasteryXpReward> // 0x1e0, INLINE
        -- elements (stride = sizeof(VehicleMasteryXpReward) = 0x20
        -- from field extents: amount@0x18 + 4, padded).
        offset = 0x1E0,
        type = "Array",
        elementStride = 0x20,
        elements = Manifest.load("VehicleMasteryXpReward")
    },
    ["styleShards"] = {
        -- dump: List<StyleShardReward> // 0x1f8, INLINE elements
        -- (stride = sizeof(StyleShardReward) = 0x38 from field
        -- extents: amount@0x34 + 4, padded).
        offset = 0x1F8,
        type = "Array",
        elementStride = 0x38,
        elements = Manifest.load("StyleShardReward")
    },
    ["useClientDecidedVehicleId"] = {
        -- dump: bool useClientDecidedVehicleId // 0x210
        offset = 0x210,
        type = "Bool"
    },
    ["clientDecidedVehicleId"] = {
        -- dump: string clientDecidedVehicleId // 0x218
        offset = 0x218,
        type = "String"
    },
    ["contentsJson"] = {
        -- dump: Json_Value contentsJson // 0x230; layout unmapped.
        offset = 0x230,
        type = "Object"
    },
    ["lootIcons"] = {
        -- dump: List<Pointer<LootDefinition>> // 0x258; elements are
        -- pointers back into LootDefinition — header only for now.
        offset = 0x258,
        type = "Array"
    }
}

--==================================================
-- Legacy fields offerDiscountLabel (0x270) and offerValueMultiplier
-- (0x274) do NOT exist in the dump: the dump class ends at
-- lootIcons (0x258) + tail padding to Size 0x278. They were
-- leftovers from an older on-device derivation and must NOT be
-- (re-)added.
--==================================================

return M
