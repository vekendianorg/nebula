--==================================================
-- metadata/1.73/FixedTuningPartDefinition.lua
--==================================================
-- Element template for List<FixedTuningPartDefinition>
-- (FixedVehicleDefinition.tuningParts @0x98 and
-- availableTuningParts @0xb0, INLINE elements,
-- elementStride = sizeof(FixedTuningPartDefinition) = 0x28,
-- derived from field extents: levelUpsPerPurchase@0x20 + 4,
-- padded).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class FixedTuningPartDefinition
--       // Size: 0x28  Confidence: exact
--       public string id;                 // 0x0
--       public int level;                 // 0x18
--       public int upgradeMaxLevel;       // 0x1c
--       public int levelUpsPerPurchase;   // 0x20

return {
    ["id"] = { offset = 0x0, type = "String" },
    ["level"] = { offset = 0x18, type = "Int32" },
    ["upgradeMaxLevel"] = { offset = 0x1C, type = "Int32" },
    ["levelUpsPerPurchase"] = { offset = 0x20, type = "Int32" },
}
