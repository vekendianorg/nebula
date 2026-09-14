--==================================================
-- metadata/1.73/CustomizationLoot.lua
--==================================================
-- Element template for List<CustomizationLoot>
-- (LootDefinition.customizations @0x168, INLINE elements,
-- elementStride = sizeof(CustomizationLoot) = 0x50, derived from
-- field extents: rarity@0x48 + 4, padded).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class CustomizationLoot
--       // Size: 0x50  Confidence: exact
--       public string id;     // 0x0
--       public string type;   // 0x18
--       public string vehicle;// 0x30
--       public Rarity rarity; // 0x48

return {
    ["id"] = {
        offset = 0x0,
        type = "String"
    },
    ["type"] = {
        offset = 0x18,
        type = "String"
    },
    ["vehicle"] = {
        offset = 0x30,
        type = "String"
    },
    ["rarity"] = {
        offset = 0x48,
        type = "Enum",
        enum = "Rarity"
    },
}
