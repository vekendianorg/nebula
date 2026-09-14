--==================================================
-- metadata/1.74/CurrencyAmount.lua
--==================================================
-- Element template for List<CurrencyAmount> (LootDefinition.currencies).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class CurrencyAmount
--       // Size: 0x20  Confidence: exact
--       public string currency; // 0x0
--       public int amount;      // 0x18

return {
    ["currency"] = {
        offset = 0x0,
        type = "String"
    },
    ["amount"] = {
        offset = 0x18,
        type = "Int32"
    }
}
