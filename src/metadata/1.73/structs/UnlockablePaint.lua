--==================================================
-- metadata/1.73/UnlockablePaint.lua
--==================================================
-- Element template for List<UnlockablePaint>
-- (LootDefinition.unlockVehiclePaints).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class UnlockablePaint
--       // Size: 0x30  Confidence: exact
--       public string vehicleId; // 0x0
--       public string paintId;   // 0x18
--
-- !! DISCREPANCY !! The legacy inline template had paintId@0x0 and
-- vehicleId@0x18 — swapped relative to the dump. The dump is
-- exact-confidence, so the dump order is used here. Needs an
-- on-device spot check to confirm (read one unlockVehiclePaints
-- element and see which field holds the vehicle id).

return {
    ["vehicleId"] = {
        offset = 0x0,
        type = "String"
    },
    ["paintId"] = {
        offset = 0x18,
        type = "String"
    }
}
