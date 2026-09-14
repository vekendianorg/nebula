--==================================================
-- metadata/1.73/PriceCurveDefinition.lua
--==================================================
-- Element template for List<PriceCurveDefinition>
-- (FixedVehicleDefinition.tuningPartUpgradePriceCurves @0xc8,
-- INLINE elements, elementStride = sizeof(PriceCurveDefinition)
-- = 0x38, derived from field extents: priceCurve vector@0x20 +
-- 0x18). cost is an inline CurrencyAmount (currency@0x0,
-- amount@0x18); priceCurve is List<int> (inline std::vector<int>).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class PriceCurveDefinition
--       // Size: 0x38  Confidence: exact
--       public CurrencyAmount cost;  // 0x0
--       public List<int> priceCurve; // 0x20

return {
    ["currency"] = {
        offset = 0x0,
        type = "String"
    },
    ["amount"] = {
        offset = 0x18,
        type = "Int32"
    },
    ["priceCurve"] = {
        offset = 0x20,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
}
