--==================================================
-- metadata/1.73/StyleTrackItemStatus.lua
--==================================================
-- Element template for RepeatedPtrField<StyleTrackItemStatus>
-- (GameStatus: VehicleStatus.styleTracks -> StyleTrackStatus.items
-- @0x20, POINTER-slot proto elements, default stride).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class StyleTrackItemStatus
--       // Size: 0x30  Confidence: exact
--       public string id_;         // 0x18
--       public SafeInt32 shards_;  // 0x20
--       public bool owned_;        // 0x28
--       public bool equipped_;     // 0x29

return {
    ["id"] = {
        offset = 0x18,
        type = "String"
    },
    ["shards"] = {
        offset = 0x20,
        type = "SafeInt32"
    },
    ["owned"] = {
        offset = 0x28,
        type = "Bool"
    },
    ["equipped"] = {
        offset = 0x29,
        type = "Bool"
    },
}
