--==================================================
-- metadata/1.73/RentDefinition.lua
--==================================================
-- Element template for RentDefinition.
-- NOTE: as a FixedVehicleDefinition member (@0xe8) RentDefinition
-- is an INLINE by-value member (next field @0x110, gap 0x28 =
-- sizeof(RentDefinition)) — it is consumed as an absolute-offset
-- GROUP inside FixedVehicleDefinition/1.73.lua, not via
-- Manifest.load. This file documents the shared layout and is the
-- template to chain if a List<RentDefinition> ever appears.
-- cost is an inline CurrencyAmount (currency@0x0, amount@0x18).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class RentDefinition
--       // Size: 0x28  Confidence: exact
--       public CurrencyAmount cost; // 0x0
--       public int duration;        // 0x20

return {
    ["currency"] = { offset = 0x0, type = "String" },
    ["amount"] = { offset = 0x18, type = "Int32" },
    ["duration"] = { offset = 0x20, type = "Int32" },
}
