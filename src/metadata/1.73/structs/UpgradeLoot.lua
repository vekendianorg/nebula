--==================================================
-- metadata/1.73/UpgradeLoot.lua
--==================================================
-- Element template for List<UpgradeLoot>
-- (LootDefinition.upgrades @0x1c8, INLINE elements,
-- elementStride = sizeof(UpgradeLoot) = 0x50, derived from field
-- extents: levelUps@0x48 + 4, padded).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class UpgradeLoot
--       // Size: 0x50  Confidence: exact
--       public string id;       // 0x0
--       public string type;     // 0x18
--       public string vehicle;  // 0x30
--       public int levelUps;    // 0x48

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
    ["levelUps"] = {
        offset = 0x48,
        type = "Int32"
    },
}
