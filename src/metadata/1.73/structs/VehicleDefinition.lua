--==================================================
-- metadata/1.73/VehicleDefinition.lua
--==================================================
-- Complete metadata snapshot for the VehicleDefinition struct at game
-- version 1.73 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file —
-- this file is VehicleDefinition only.
--
-- Dump source (temp/libcocos2dcpp.cs, 1.73 dump):
--   public class VehicleDefinition // TypeDefIndex: 2305 Size: 0x548
--   Confidence: exact
--
-- Every offset and type below matches that dump exactly. No layout,
-- size, stride, pointer representation, or schema is guessed.
-- VehicleDefinition has no `m` prefix on any field, so all metadata
-- keys keep their dump names unchanged.
--
-- Representable fields only:
--   int -> Int32, bool -> Bool, float -> Float, string -> String
--   (inline std::string — the api layer shadows with stringDirect),
--   cocos2d_Vec2 -> Vec2 (two inline floats, see core/types/Vec2.lua
--   and GameData.lua precedent), UnlockType -> Enum
--   (enum = "UnlockType"), List<CurrencyAmount> / List<
--   UiElementDefinition> / List<CollectibleDefinition> -> Array with
--   elements + stride from existing snapshots (CurrencyAmount 0x20,
--   UiElementDefinition 0xA0, CollectibleDefinition 0x1A0 — same
--   strides LootDefinition/EventDefinition use), List<int> /
--   List<float> -> Array (elementStride 0x4), List<string> -> Array
--   (elementType String, elementStride 0x18 for inline std::string).
--
-- Inline struct members use the namespace-container convention (no
-- `type`; children carry ABSOLUTE offsets = instance base +
-- relative, same as EventDefinition.sessionEntry and
-- PlayerInfo.sessionDiamonds). Each inline size is verified BOTH by
-- the dump Size annotation AND by next-field spacing:
--   boost @0x308 (0x350-0x308 = 0x48 = sizeof VehicleBoostDefinition)
--   exhaust @0x350 (0x3A8-0x350 = 0x58 = sizeof VehicleExhaustDefinition)
--   cartConnect @0x3A8 (0x3E8-0x3A8 = 0x40 = sizeof VehicleCartConnectDefinition)
--   offerShowcase @0x508 (0x51C-0x508 = 0x14 = sizeof VehicleOfferShowcaseDefinition)
--   offerIcon @0x51C (0x530-0x51C = 0x14, same)
-- Their element-relative layouts live in VehicleBoostDefinition.lua,
-- VehicleExhaustDefinition.lua, VehicleCartConnectDefinition.lua and
-- VehicleOfferShowcaseDefinition.lua (new snapshots in this change).
--
-- NOTE: the dump annotates styleTracks @0x258 with "in 1.74, offset
-- shift happened here" — offsets at/after 0x258 are taken as dumped.
--
-- Intentionally NOT metadata (no supported representation — omitted,
-- not guessed):
--   - customRubeFiles Dictionary<string,string> @0x80,
--     vehicleSettings Dictionary<string,float> @0x458, spriteVariants
--     Dictionary<string,Dictionary<string,CarSprite>> @0x4C0,
--     particleVariants Dictionary<string,VehicleParticlesDefinition>
--     @0x4D8, particleShowcases
--     Dictionary<string,List<ParticleShowcaseDefinition>> @0x4F0
--     (std::map ABI, no supported representation)
--   - masteryUnlockTimestamp JSONSafeInt @0x270,
--     masteryXpRequiredPerLevel JSONSafeInt @0x290 (JSONSafeInt reader
--     not verified — see GameData.lua:592-595)
--   - unlockTypes List<UnlockDefinition> @0x118, attachmentSlots
--     List<AttachmentSlotDefinition> @0x1E0, upgrades
--     List<VehicleUpgradeDefinition> @0x1F8, tuningPartsBase
--     List<TuningPartParams> @0x210, tuningParts List<TuningPartParams>
--     @0x228, masteries List<VehicleMasteryDefinition> @0x240,
--     styleTracks List<VehicleStyleTrack> @0x258 — header-only Array
--     (offset recorded, no elements/stride): element types have no
--     verified metadata snapshots and mapping them would need
--     transitive new files; not created here (one class per file, no
--     transitive explosion).
--
-- Reused existing snapshots (not duplicated): UnlockType (enum),
-- CurrencyAmount, UiElementDefinition, CollectibleDefinition.

local Manifest = loadModule("metadata/manifest.lua")

local CurrencyAmount        = Manifest.load("CurrencyAmount")
local UiElementDefinition   = Manifest.load("UiElementDefinition")
local CollectibleDefinition = Manifest.load("CollectibleDefinition")

return {
    ["id"] = {
        offset = 0x0,
        type = "String"
    },
    ["vehicleMass"] = {
        offset = 0x18,
        type = "Float"
    },
    ["name"] = {
        offset = 0x20,
        type = "String"
    },
    ["description"] = {
        offset = 0x38,
        type = "String"
    },
    ["vehicleIcon"] = {
        offset = 0x50,
        type = "String"
    },
    ["rubeFile"] = {
        offset = 0x68,
        type = "String"
    },
    ["engineSound"] = {
        offset = 0x98,
        type = "String"
    },
    ["turboSound"] = {
        offset = 0xB0,
        type = "String"
    },
    ["turboFlutterSound"] = {
        offset = 0xC8,
        type = "String"
    },
    ["impactSound"] = {
        offset = 0xE0,
        type = "String"
    },
    ["hornSound"] = {
        offset = 0xF8,
        type = "String"
    },
    ["unlockType"] = {
        -- dump: UnlockType unlockType // 0x110
        offset = 0x110,
        type = "Enum",
        enum = "UnlockType"
    },
    ["unlockTypes"] = {
        -- dump: List<UnlockDefinition> // 0x118 — header-only
        -- (UnlockDefinition has no verified snapshot)
        offset = 0x118,
        type = "Array"
    },
    ["unlockTypeDescription"] = {
        offset = 0x130,
        type = "String"
    },
    ["vehicleUnlockRank"] = {
        offset = 0x148,
        type = "Float"
    },
    ["vehicleUnlockCriteria"] = {
        offset = 0x14C,
        type = "Float"
    },
    ["vehicleEventLockCsb"] = {
        offset = 0x150,
        type = "String"
    },
    ["vehicleEventLockTopBarCsb"] = {
        offset = 0x168,
        type = "String"
    },
    ["vehicleOfferLockCsb"] = {
        offset = 0x180,
        type = "String"
    },
    ["vehicleOfferLockTopBarCsb"] = {
        offset = 0x198,
        type = "String"
    },
    ["shadowTexture"] = {
        offset = 0x1B0,
        type = "String"
    },
    ["shadowLength"] = {
        offset = 0x1C8,
        type = "Float"
    },
    ["shadowOffset"] = {
        offset = 0x1CC,
        type = "Float"
    },
    ["boundingBoxPadding"] = {
        offset = 0x1D0,
        type = "Vec2"
    },
    ["numTyreTracks"] = {
        offset = 0x1D8,
        type = "Int32"
    },
    ["airTurnRate"] = {
        offset = 0x1DC,
        type = "Float"
    },
    ["attachmentSlots"] = {
        -- dump: List<AttachmentSlotDefinition> // 0x1E0 — header-only
        offset = 0x1E0,
        type = "Array"
    },
    ["upgrades"] = {
        -- dump: List<VehicleUpgradeDefinition> // 0x1F8 — header-only
        offset = 0x1F8,
        type = "Array"
    },
    ["tuningPartsBase"] = {
        -- dump: List<TuningPartParams> // 0x210 — header-only
        offset = 0x210,
        type = "Array"
    },
    ["tuningParts"] = {
        -- dump: List<TuningPartParams> // 0x228 — header-only
        offset = 0x228,
        type = "Array"
    },
    ["masteries"] = {
        -- dump: List<VehicleMasteryDefinition> // 0x240 — header-only
        offset = 0x240,
        type = "Array"
    },
    ["styleTracks"] = {
        -- dump: List<VehicleStyleTrack> // 0x258 — header-only
        offset = 0x258,
        type = "Array"
    },
    ["masteryUnlockTimestamp"] = {
        -- dump: JSONSafeInt masteryUnlockTimestamp // 0x270
        offset = 0x270,
        type = "JSONSafeInt"
    },
    ["masteryXpRequiredPerLevel"] = {
        -- dump: JSONSafeInt masteryXpRequiredPerLevel // 0x290
        offset = 0x290,
        type = "JSONSafeInt"
    },
    ["tuningPartImpulseEffectScale"] = {
        offset = 0x2B0,
        type = "Float"
    },
    ["masteryMaxVehiclePower"] = {
        offset = 0x2B4,
        type = "Int32"
    },
    ["masteryBonusXpDescription"] = {
        offset = 0x2B8,
        type = "String"
    },
    ["fuelTank"] = {
        offset = 0x2D0,
        type = "Float"
    },
    ["collectiblesOverride"] = {
        -- dump: List<CollectibleDefinition> // 0x2D8, INLINE elements
        -- (stride = sizeof(CollectibleDefinition) = 0x1A0, same as
        -- EventDefinition.collectiblesOverride)
        offset = 0x2D8,
        type = "Array",
        elementStride = 0x1A0,
        elements = CollectibleDefinition
    },
    ["maxAngularVelocity"] = {
        offset = 0x2F0,
        type = "Float"
    },
    ["rpmScale"] = {
        offset = 0x2F4,
        type = "Float"
    },
    ["revModeCoeffUp"] = {
        offset = 0x2F8,
        type = "Float"
    },
    ["revModeCoeffDown"] = {
        offset = 0x2FC,
        type = "Float"
    },
    ["downforce"] = {
        offset = 0x300,
        type = "Float"
    },
    ["boost"] = {
        -- dump: VehicleBoostDefinition boost // 0x308 (INLINE, 0x48)
        -- relatives from VehicleBoostDefinition.lua + base 0x308
        ["file"] = {
            offset = 0x308,
            type = "String"
        },
        ["offset"] = {
            offset = 0x320,
            type = "Vec2"
        },
        ["behindCar"] = {
            offset = 0x328,
            type = "Bool"
        },
        ["node"] = {
            offset = 0x330,
            type = "String"
        },
        ["fuelPickupBoostEnabled"] = {
            offset = 0x348,
            type = "Bool"
        },
        ["fuelPickupBoostPower"] = {
            offset = 0x34C,
            type = "Float"
        },
    },
    ["exhaust"] = {
        -- dump: VehicleExhaustDefinition exhaust // 0x350 (INLINE, 0x58)
        ["file"] = {
            offset = 0x350,
            type = "String"
        },
        ["node"] = {
            offset = 0x368,
            type = "String"
        },
        ["offset"] = {
            offset = 0x380,
            type = "Vec2"
        },
        ["angle"] = {
            offset = 0x388,
            type = "Float"
        },
        ["minParticles"] = {
            offset = 0x38C,
            type = "Int32"
        },
        ["maxParticles"] = {
            offset = 0x390,
            type = "Int32"
        },
        ["lifeMin"] = {
            offset = 0x394,
            type = "Float"
        },
        ["lifeMax"] = {
            offset = 0x398,
            type = "Float"
        },
        ["scale"] = {
            offset = 0x39C,
            type = "Float"
        },
        ["zOrder"] = {
            offset = 0x3A0,
            type = "Int32"
        },
    },
    ["cartConnect"] = {
        -- dump: VehicleCartConnectDefinition cartConnect // 0x3A8 (INLINE, 0x40)
        ["offset"] = {
            offset = 0x3A8,
            type = "Vec2"
        },
        ["hookImage"] = {
            offset = 0x3B0,
            type = "String"
        },
        ["hookScale"] = {
            offset = 0x3C8,
            type = "Float"
        },
        ["attachNode"] = {
            offset = 0x3D0,
            type = "String"
        },
    },
    ["attachableObjectOffset"] = {
        offset = 0x3E8,
        type = "Vec2"
    },
    ["nameFloaterOffset"] = {
        offset = 0x3F0,
        type = "Vec2"
    },
    ["frontSuspensionColliderLimits"] = {
        -- dump: List<float> // 0x3F8, inline 4-byte elements
        offset = 0x3F8,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4
    },
    ["rearSuspensionColliderLimits"] = {
        -- dump: List<float> // 0x410, inline 4-byte elements
        offset = 0x410,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4
    },
    ["vehiclePrice"] = {
        -- dump: List<CurrencyAmount> // 0x428, INLINE elements
        -- (stride = sizeof(CurrencyAmount) = 0x20, same as
        -- LootDefinition.currencies)
        offset = 0x428,
        type = "Array",
        elementStride = 0x20,
        elements = CurrencyAmount
    },
    ["uiElements"] = {
        -- dump: List<UiElementDefinition> // 0x440, INLINE elements
        -- (stride = sizeof(UiElementDefinition) = 0xA0, same as
        -- EventDefinition.uiElements)
        offset = 0x440,
        type = "Array",
        elementStride = 0xA0,
        elements = UiElementDefinition
    },
    ["bridgeModifier"] = {
        offset = 0x470,
        type = "Float"
    },
    ["slowdownOnLiquidContact"] = {
        offset = 0x474,
        type = "Bool"
    },
    ["liquidLinearDragModifier"] = {
        offset = 0x478,
        type = "Float"
    },
    ["liquidAngularDragModifier"] = {
        offset = 0x47C,
        type = "Float"
    },
    ["surfaceBodySpeedModifier"] = {
        -- dump: List<float> // 0x480, inline 4-byte elements
        offset = 0x480,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4
    },
    ["surfaceBodyOnLiquids"] = {
        -- dump: List<string> // 0x498, inline std::string elements
        offset = 0x498,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["baseCCvalue"] = {
        offset = 0x4B0,
        type = "Int32"
    },
    ["collisionDamageFactor"] = {
        offset = 0x4B4,
        type = "Float"
    },
    ["collisionMassFactor"] = {
        offset = 0x4B8,
        type = "Float"
    },
    ["isGenericVehicle"] = {
        offset = 0x4BC,
        type = "Bool"
    },
    ["offerShowcase"] = {
        -- dump: VehicleOfferShowcaseDefinition offerShowcase // 0x508 (INLINE, 0x14)
        -- relatives from VehicleOfferShowcaseDefinition.lua + base 0x508
        ["position"] = {
            offset = 0x508,
            type = "Vec2"
        },
        ["scale"] = {
            offset = 0x510,
            type = "Float"
        },
        ["rotation"] = {
            offset = 0x514,
            type = "Float"
        },
        ["hasPosition"] = {
            offset = 0x518,
            type = "Bool"
        },
        ["hasScale"] = {
            offset = 0x519,
            type = "Bool"
        },
        ["hasRotation"] = {
            offset = 0x51A,
            type = "Bool"
        },
    },
    ["offerIcon"] = {
        -- dump: VehicleOfferShowcaseDefinition offerIcon // 0x51C (INLINE, 0x14)
        -- same relatives + base 0x51C
        ["position"] = {
            offset = 0x51C,
            type = "Vec2"
        },
        ["scale"] = {
            offset = 0x524,
            type = "Float"
        },
        ["rotation"] = {
            offset = 0x528,
            type = "Float"
        },
        ["hasPosition"] = {
            offset = 0x52C,
            type = "Bool"
        },
        ["hasScale"] = {
            offset = 0x52D,
            type = "Bool"
        },
        ["hasRotation"] = {
            offset = 0x52E,
            type = "Bool"
        },
    },
    ["tuningPartSlotMinUpgradeLevels"] = {
        -- dump: List<int> // 0x530, inline 4-byte elements
        offset = 0x530,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
}
