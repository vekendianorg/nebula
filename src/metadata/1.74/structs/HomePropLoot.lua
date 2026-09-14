--==================================================
-- metadata/1.74/HomePropLoot.lua
--==================================================
-- Element template for List<HomePropLoot> (LootDefinition.unlockHomeProps).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class HomePropLoot
--       // Size: 0x20  Confidence: exact
--       public string id;    // 0x0
--       public int amount;   // 0x18

return {
    ["id"] = {
        offset = 0x0,
        type = "String"
    },
    ["amount"] = {
        offset = 0x18,
        type = "Int32"
    }
}
