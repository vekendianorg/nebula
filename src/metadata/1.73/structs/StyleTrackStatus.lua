--==================================================
-- metadata/1.73/StyleTrackStatus.lua
--==================================================
-- Element template for RepeatedPtrField<StyleTrackStatus>
-- (GameStatus: VehicleStatus.styleTracks @0x170, POINTER-slot proto
-- elements, default stride).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class StyleTrackStatus
--       // Size: 0x40  Confidence: exact
--       public string trackid_;   // 0x18
--       public RepeatedPtrField<StyleTrackItemStatus> items_; // 0x20
--       public bool rewardclaimed_; // 0x38

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["trackId"] = { offset = 0x18, type = "String" },
    ["items"] = {
        offset = 0x20,
        type = "Array",
        elements = Manifest.load("StyleTrackItemStatus")
    },
    ["rewardClaimed"] = { offset = 0x38, type = "Bool" },
}
