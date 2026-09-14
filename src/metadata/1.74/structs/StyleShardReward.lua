--==================================================
-- metadata/1.74/StyleShardReward.lua
--==================================================
-- Element template for List<StyleShardReward>
-- (LootDefinition.styleShards @0x1f8, INLINE elements,
-- elementStride = sizeof(StyleShardReward) = 0x38, derived from
-- field extents: amount@0x34 + 4, padded).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class StyleShardReward
--       // Size: 0x38  Confidence: exact
--       public string itemId;    // 0x0
--       public string vehicleId; // 0x18
--       public Rarity rarity;    // 0x30
--       public int amount;       // 0x34

return {
    ["itemId"] = {
        offset = 0x0,
        type = "String"
    },
    ["vehicleId"] = {
        offset = 0x18,
        type = "String"
    },
    ["rarity"] = {
        offset = 0x30,
        type = "Enum",
        enum = "Rarity"
    },
    ["amount"] = {
        offset = 0x34,
        type = "Int32"
    },
}
