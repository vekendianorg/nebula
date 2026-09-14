--==================================================
-- metadata/1.74/LevelCollectibleItem.lua
--==================================================
-- Element template for RepeatedPtrField<LevelCollectibleItem>
-- (GameStatus: DistanceCollectibleStatus.levels ->
-- LevelCollectibleStatus.items @0x20, POINTER-slot proto elements,
-- default stride).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class LevelCollectibleItem
--       // Size: 0x28  Confidence: exact
--       public float x_;      // 0x18
--       public float y_;      // 0x1c
--       public int32 rarity_; // 0x20

return {
    ["x"] = {
        offset = 0x18,
        type = "Float"
    },
    ["y"] = {
        offset = 0x1C,
        type = "Float"
    },
    ["rarity"] = {
        offset = 0x20,
        type = "Enum",
        enum = "Rarity"
    },
}
