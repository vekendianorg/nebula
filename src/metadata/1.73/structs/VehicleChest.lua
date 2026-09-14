--==================================================
-- metadata/1.73/VehicleChest.lua
--==================================================
-- Element template for List<VehicleChest> (LootDefinition.vehicleChests).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class VehicleChest
--       // Size: 0x20  Confidence: exact
--       public string vehicleId; // 0x0
--       public int chestIndex;   // 0x18
--       public int targetIndex;  // 0x1c
--
-- chestIndex (0x18) is dump-confirmed and newly exposed; the
-- legacy metadata only read targetIndex (0x1C).

return {
    ["vehicleId"] = {
        offset = 0x0,
        type = "String"
    },
    ["chestIndex"] = {
        offset = 0x18,
        type = "Enum",
        enum = "ChestType"
    },
    ["targetIndex"] = {
        offset = 0x1C,
        type = "Int32"
    }
}
