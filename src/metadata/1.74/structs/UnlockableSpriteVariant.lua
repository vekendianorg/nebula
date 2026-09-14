--==================================================
-- metadata/1.74/UnlockableSpriteVariant.lua
--==================================================
-- Element template for List<UnlockableSpriteVariant>
-- (LootDefinition.unlockVehicleSpriteVariants).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class UnlockableSpriteVariant
--       // Size: 0x48  Confidence: exact
--       public string vehicleId; // 0x0
--       public string partId;    // 0x18
--       public string variantId; // 0x30
--
-- !! DISCREPANCY !! The legacy inline template had partId@0x0,
-- variantId@0x18, vehicleId@0x30 — the dump puts vehicleId FIRST
-- at 0x0. The dump is exact-confidence, so the dump order is used
-- here. Needs an on-device spot check to confirm.

return {
    ["vehicleId"] = {
        offset = 0x0,
        type = "String"
    },
    ["partId"] = {
        offset = 0x18,
        type = "String"
    },
    ["variantId"] = {
        offset = 0x30,
        type = "String"
    }
}
