--==================================================
-- metadata/1.74/TuningPartLoot.lua
--==================================================
-- Element template for List<TuningPartLoot> (LootDefinition.tuningParts).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class TuningPartLoot
--       // Size: 0x38  Confidence: exact
--       public string id;         // 0x0
--       public string vehicleId;  // 0x18
--       public int amount;        // 0x30
--       public Rarity rarity;     // 0x34

return {
    ["id"] = {
        offset = 0x0,
        type = "String"
    },
    ["vehicleId"] = {
        offset = 0x18,
        type = "String"
    },
    ["amount"] = {
        offset = 0x30,
        type = "Int32"
    },
    ["rarity"] = {
        offset = 0x34,
        type = "Enum",
        enum = "TuningRarity"
    }
}
