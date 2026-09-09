--==================================================
-- metadata/1.73/RangeDefinition.lua
--==================================================
-- Element template for List<RangeDefinition>
-- (CustomChest.tuningPartsAmountsPerRarity @0x120, INLINE elements,
-- elementStride = sizeof(RangeDefinition) = 0x8).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class RangeDefinition
--       // Size: 0x8  Confidence: exact
--       public int rangeMin; // 0x0
--       public int rangeMax; // 0x4

return {
    ["rangeMin"] = { offset = 0x0, type = "Int32" },
    ["rangeMax"] = { offset = 0x4, type = "Int32" },
}
