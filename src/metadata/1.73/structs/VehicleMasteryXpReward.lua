--==================================================
-- metadata/1.73/VehicleMasteryXpReward.lua
--==================================================
-- Element template for List<VehicleMasteryXpReward>
-- (LootDefinition.vehicleMasteryXp @0x1e0, INLINE elements,
-- elementStride = sizeof(VehicleMasteryXpReward) = 0x20, derived
-- from field extents: amount@0x18 + 4, padded).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class VehicleMasteryXpReward
--       // Size: 0x20  Confidence: exact
--       public string vehicleId; // 0x0
--       public int amount;       // 0x18

return {
    ["vehicleId"] = { offset = 0x0, type = "String" },
    ["amount"] = { offset = 0x18, type = "Int32" },
}
