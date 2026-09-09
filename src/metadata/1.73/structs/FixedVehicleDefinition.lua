--==================================================
-- metadata/1.73/FixedVehicleDefinition.lua
--==================================================
-- Struct-element template for FixedVehicleDefinition
-- (EventDefinition.fixedVehicles — std::vector<FixedVehicleDefinition>,
-- INLINE elements; elementStride = sizeof(FixedVehicleDefinition)
-- = 0x118, derived from the field extents below:
-- last field allowCustomization bool@0x114, padded to 8 = 0x118).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class FixedVehicleDefinition
--       // Size: 0x118  Confidence: exact
--
-- Every offset below matches the dump. All previously header-only
-- members (vehicleUpgradePriceCurve, tuningParts,
-- availableTuningParts, tuningPartUpgradePriceCurves, rent) are now
-- fully mapped from the dump.

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["id"] = {
        offset = 0x0,
        type = "String"
    },
    ["upgradeLevels"] = {
        -- dump: List<int> // 0x18, inline 4-byte elements
        offset = 0x18,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
    ["upgradeMaxLevels"] = {
        -- dump: List<int> // 0x30, inline 4-byte elements
        offset = 0x30,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
    ["upgradeCurveOverride"] = {
        -- dump: string upgradeCurveOverride // 0x48
        offset = 0x48,
        type = "String"
    },
    ["vehicleUpgradePriceCurve"] = {
        -- dump: PriceCurveDefinition // 0x60, INLINE member (next
        -- field tuningParts@0x98 -> gap 0x38 = sizeof
        -- (PriceCurveDefinition)). Children carry ABSOLUTE offsets.
        -- PriceCurveDefinition.cost is an inline CurrencyAmount
        -- (currency@0x0, amount@0x18); priceCurve is List<int>
        -- (inline std::vector<int>).
        ["currency"] = { offset = 0x60, type = "String" },
        ["amount"] = { offset = 0x78, type = "Int32" },
        ["priceCurve"] = {
            offset = 0x80,
            type = "Array",
            elementType = "Int32",
            elementStride = 0x4
        },
    },
    ["tuningParts"] = {
        -- dump: List<FixedTuningPartDefinition> // 0x98, INLINE
        -- elements (stride = sizeof(FixedTuningPartDefinition) =
        -- 0x28 from field extents: levelUpsPerPurchase@0x20 + 4,
        -- padded).
        offset = 0x98,
        type = "Array",
        elementStride = 0x28,
        elements = Manifest.load("FixedTuningPartDefinition")
    },
    ["availableTuningParts"] = {
        -- dump: List<FixedTuningPartDefinition> // 0xb0, same
        -- inline element layout as tuningParts.
        offset = 0xB0,
        type = "Array",
        elementStride = 0x28,
        elements = Manifest.load("FixedTuningPartDefinition")
    },
    ["tuningPartUpgradePriceCurves"] = {
        -- dump: List<PriceCurveDefinition> // 0xc8, INLINE elements
        -- (stride = sizeof(PriceCurveDefinition) = 0x38 from field
        -- extents: priceCurve vector@0x20 + 0x18).
        offset = 0xC8,
        type = "Array",
        elementStride = 0x38,
        elements = Manifest.load("PriceCurveDefinition")
    },
    ["rent"] = {
        -- dump: RentDefinition // 0xe8, INLINE member (next field
        -- eventPointsToUnlock@0x110 -> gap 0x28 = sizeof
        -- (RentDefinition)). cost is an inline CurrencyAmount
        -- (currency@0x0, amount@0x18); duration int @0x20.
        ["currency"] = { offset = 0xE8, type = "String" },
        ["amount"] = { offset = 0x100, type = "Int32" },
        ["duration"] = { offset = 0x120, type = "Int32" },
    },
    ["levelUpsPerPurchase"] = {
        offset = 0xE0,
        type = "Int32"
    },
    ["tuningPartSlots"] = {
        offset = 0xE4,
        type = "Int32"
    },
    ["eventPointsToUnlock"] = {
        offset = 0x110,
        type = "Int32"
    },
    ["allowCustomization"] = {
        offset = 0x114,
        type = "Bool"
    }
}
