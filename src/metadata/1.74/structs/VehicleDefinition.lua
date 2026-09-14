--==================================================
-- metadata/1.74/VehicleDefinition.lua
--==================================================
-- Complete metadata snapshot for the VehicleDefinition struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file —
-- this file is VehicleDefinition only.
--
-- Dump source (temp/libcocos2dcpp.cs, 1.73 dump):
--   public class VehicleDefinition // TypeDefIndex: 2305 Size: 0x548
--   Confidence: exact
--
-- The dump contains a comment at styleTracks @0x258:
--   "-- in 1.74, offset shift happened here"
-- This means in the actual 1.74 binary, ALL fields at/after styleTracks
-- are shifted by +0x20 relative to the 1.73 dump offsets. Offsets
-- BELOW 0x258 are unchanged. Offsets AT/ABOVE 0x258 get +0x20.
--
-- Every offset and type below matches the 1.74 layout exactly. No
-- layout, size, stride, pointer representation, or schema is guessed.
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
--   boost @0x328 (0x370-0x328 = 0x48 = sizeof VehicleBoostDefinition)
--   exhaust @0x370 (0x3C8-0x370 = 0x58 = sizeof VehicleExhaustDefinition)
--   cartConnect @0x3C8 (0x408-0x3C8 = 0x40 = sizeof VehicleCartConnectDefinition)
--   offerShowcase @0x528 (0x53C-0x528 = 0x14 = sizeof VehicleOfferShowcaseDefinition)
--   offerIcon @0x53C (0x550-0x53C = 0x14, same)
-- Their element-relative layouts live in VehicleBoostDefinition.lua,
-- VehicleExhaustDefinition.lua, VehicleCartConnectDefinition.lua and
-- VehicleOfferShowcaseDefinition.lua (shared across 1.73/1.74).
--
-- Intentionally NOT metadata (no supported representation — omitted,
-- not guessed):
--   - customRubeFiles Dictionary<string,string> @0x80,
--     vehicleSettings Dictionary<string,float> @0x478, spriteVariants
--     Dictionary<string,Dictionary<string,CarSprite>> @0x4E0,
--     particleVariants Dictionary<string,VehicleParticlesDefinition>
--     @0x4F8, particleShowcases
--     Dictionary<string,List<ParticleShowcaseDefinition>> @0x510
--     (std::map ABI, no supported representation)
--   - masteryUnlockTimestamp JSONSafeInt @0x290,
--     masteryXpRequiredPerLevel JSONSafeInt @0x2B0 (JSONSafeInt reader
--     not verified — see GameData.lua:592-595)
--   - unlockTypes List<UnlockDefinition> @0x118, attachmentSlots
--     List<AttachmentSlotDefinition> @0x1E0, upgrades
--     List<VehicleUpgradeDefinition> @0x1F8, tuningPartsBase
--     List<TuningPartParams> @0x210, tuningParts List<TuningPartParams>
--     @0x228, masteries List<VehicleMasteryDefinition> @0x240,
--     styleTracks List<VehicleStyleTrack> @0x278 — header-only Array
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
        offset = 0x110,
        type = "Enum",
        enum = "UnlockType"
    },
    ["unlockTypes"] = {
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
        offset = 0x1E0,
        type = "Array"
    },
    ["upgrades"] = {
        offset = 0x1F8,
        type = "Array"
    },
    ["tuningPartsBase"] = {
        offset = 0x210,
        type = "Array"
    },
    ["tuningParts"] = {
        offset = 0x228,
        type = "Array"
    },
    ["masteries"] = {
        offset = 0x240,
        type = "Array"
    },
    ["styleTracks"] = {
        offset = 0x258,
        type = "Array"
    },
    ["styleTracksUnlockTimeStamp"] = {
        -- ONLY in 1.74
        offsets = 0x270,
        type = "JSONSafeInt"
    },
    ["masteryUnlockTimestamp"] = {
        -- dump: JSONSafeInt masteryUnlockTimestamp // 0x290 (shifted from 0x270)
        offset = 0x290,
        type = "JSONSafeInt"
    },
    ["masteryXpRequiredPerLevel"] = {
        -- dump: JSONSafeInt masteryXpRequiredPerLevel // 0x2B0 (shifted from 0x290)
        offset = 0x2B0,
        type = "JSONSafeInt"
    },
    ["tuningPartImpulseEffectScale"] = {
        -- 1.73: 0x2B0 -> 1.74: 0x2D0
        offset = 0x2D0,
        type = "Float"
    },
    ["masteryMaxVehiclePower"] = {
        -- 1.73: 0x2B4 -> 1.74: 0x2D4
        offset = 0x2D4,
        type = "Int32"
    },
    ["masteryBonusXpDescription"] = {
        -- 1.73: 0x2B8 -> 1.74: 0x2D8
        offset = 0x2D8,
        type = "String"
    },
    ["fuelTank"] = {
        -- 1.73: 0x2D0 -> 1.74: 0x2F0
        offset = 0x2F0,
        type = "Float"
    },
    ["collectiblesOverride"] = {
        -- 1.73: 0x2D8 -> 1.74: 0x2F8 (INLINE, stride 0x1A0)
        offset = 0x2F8,
        type = "Array",
        elementStride = 0x1A0,
        elements = CollectibleDefinition
    },
    ["maxAngularVelocity"] = {
        -- 1.73: 0x2F0 -> 1.74: 0x310
        offset = 0x310,
        type = "Float"
    },
    ["rpmScale"] = {
        -- 1.73: 0x2F4 -> 1.74: 0x314
        offset = 0x314,
        type = "Float"
    },
    ["revModeCoeffUp"] = {
        -- 1.73: 0x2F8 -> 1.74: 0x318
        offset = 0x318,
        type = "Float"
    },
    ["revModeCoeffDown"] = {
        -- 1.73: 0x2FC -> 1.74: 0x31C
        offset = 0x31C,
        type = "Float"
    },
    ["downforce"] = {
        -- 1.73: 0x300 -> 1.74: 0x320
        offset = 0x320,
        type = "Float"
    },
    ["boost"] = {
        -- 1.73: 0x308 -> 1.74: 0x328 (INLINE, 0x48)
        ["file"] = {
            offset = 0x328,
            type = "String"
        },
        ["offset"] = {
            offset = 0x340,
            type = "Vec2"
        },
        ["behindCar"] = {
            offset = 0x348,
            type = "Bool"
        },
        ["node"] = {
            offset = 0x350,
            type = "String"
        },
        ["fuelPickupBoostEnabled"] = {
            offset = 0x368,
            type = "Bool"
        },
        ["fuelPickupBoostPower"] = {
            offset = 0x36C,
            type = "Float"
        },
    },
    ["exhaust"] = {
        -- 1.73: 0x350 -> 1.74: 0x370 (INLINE, 0x58)
        ["file"] = {
            offset = 0x370,
            type = "String"
        },
        ["node"] = {
            offset = 0x388,
            type = "String"
        },
        ["offset"] = {
            offset = 0x3A0,
            type = "Vec2"
        },
        ["angle"] = {
            offset = 0x3A8,
            type = "Float"
        },
        ["minParticles"] = {
            offset = 0x3AC,
            type = "Int32"
        },
        ["maxParticles"] = {
            offset = 0x3B0,
            type = "Int32"
        },
        ["lifeMin"] = {
            offset = 0x3B4,
            type = "Float"
        },
        ["lifeMax"] = {
            offset = 0x3B8,
            type = "Float"
        },
        ["scale"] = {
            offset = 0x3BC,
            type = "Float"
        },
        ["zOrder"] = {
            offset = 0x3C0,
            type = "Int32"
        },
    },
    ["cartConnect"] = {
        -- 1.73: 0x3A8 -> 1.74: 0x3C8 (INLINE, 0x40)
        ["offset"] = {
            offset = 0x3C8,
            type = "Vec2"
        },
        ["hookImage"] = {
            offset = 0x3D0,
            type = "String"
        },
        ["hookScale"] = {
            offset = 0x3E8,
            type = "Float"
        },
        ["attachNode"] = {
            offset = 0x3F0,
            type = "String"
        },
    },
    ["attachableObjectOffset"] = {
        -- 1.73: 0x3E8 -> 1.74: 0x408
        offset = 0x408,
        type = "Vec2"
    },
    ["nameFloaterOffset"] = {
        -- 1.73: 0x3F0 -> 1.74: 0x410
        offset = 0x410,
        type = "Vec2"
    },
    ["frontSuspensionColliderLimits"] = {
        -- 1.73: 0x3F8 -> 1.74: 0x418
        offset = 0x418,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4
    },
    ["rearSuspensionColliderLimits"] = {
        -- 1.73: 0x410 -> 1.74: 0x430
        offset = 0x430,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4
    },
    ["vehiclePrice"] = {
        -- 1.73: 0x428 -> 1.74: 0x448 (INLINE, stride 0x20)
        offset = 0x448,
        type = "Array",
        elementStride = 0x20,
        elements = CurrencyAmount
    },
    ["uiElements"] = {
        -- 1.73: 0x440 -> 1.74: 0x460 (INLINE, stride 0xA0)
        offset = 0x460,
        type = "Array",
        elementStride = 0xA0,
        elements = UiElementDefinition
    },
    ["bridgeModifier"] = {
        -- 1.73: 0x470 -> 1.74: 0x490
        offset = 0x490,
        type = "Float"
    },
    ["slowdownOnLiquidContact"] = {
        -- 1.73: 0x474 -> 1.74: 0x494
        offset = 0x494,
        type = "Bool"
    },
    ["liquidLinearDragModifier"] = {
        -- 1.73: 0x478 -> 1.74: 0x498
        offset = 0x498,
        type = "Float"
    },
    ["liquidAngularDragModifier"] = {
        -- 1.73: 0x47C -> 1.74: 0x49C
        offset = 0x49C,
        type = "Float"
    },
    ["surfaceBodySpeedModifier"] = {
        -- 1.73: 0x480 -> 1.74: 0x4A0
        offset = 0x4A0,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4
    },
    ["surfaceBodyOnLiquids"] = {
        -- 1.73: 0x498 -> 1.74: 0x4B8
        offset = 0x4B8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["baseCCvalue"] = {
        -- 1.73: 0x4B0 -> 1.74: 0x4D0
        offset = 0x4D0,
        type = "Int32"
    },
    ["collisionDamageFactor"] = {
        -- 1.73: 0x4B4 -> 1.74: 0x4D4
        offset = 0x4D4,
        type = "Float"
    },
    ["collisionMassFactor"] = {
        -- 1.73: 0x4B8 -> 1.74: 0x4D8
        offset = 0x4D8,
        type = "Float"
    },
    ["isGenericVehicle"] = {
        -- 1.73: 0x4BC -> 1.74: 0x4DC
        offset = 0x4DC,
        type = "Bool"
    },
    ["offerShowcase"] = {
        -- 1.73: 0x508 -> 1.74: 0x528 (INLINE, 0x14)
        ["position"] = {
            offset = 0x528,
            type = "Vec2"
        },
        ["scale"] = {
            offset = 0x530,
            type = "Float"
        },
        ["rotation"] = {
            offset = 0x534,
            type = "Float"
        },
        ["hasPosition"] = {
            offset = 0x538,
            type = "Bool"
        },
        ["hasScale"] = {
            offset = 0x539,
            type = "Bool"
        },
        ["hasRotation"] = {
            offset = 0x53A,
            type = "Bool"
        },
    },
    ["offerIcon"] = {
        -- 1.73: 0x51C -> 1.74: 0x53C (INLINE, 0x14)
        ["position"] = {
            offset = 0x53C,
            type = "Vec2"
        },
        ["scale"] = {
            offset = 0x544,
            type = "Float"
        },
        ["rotation"] = {
            offset = 0x548,
            type = "Float"
        },
        ["hasPosition"] = {
            offset = 0x54C,
            type = "Bool"
        },
        ["hasScale"] = {
            offset = 0x54D,
            type = "Bool"
        },
        ["hasRotation"] = {
            offset = 0x54E,
            type = "Bool"
        },
    },
    ["tuningPartSlotMinUpgradeLevels"] = {
        -- 1.73: 0x530 -> 1.74: 0x550
        offset = 0x550,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
}