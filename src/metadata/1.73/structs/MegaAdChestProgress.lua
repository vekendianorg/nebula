--==================================================
-- metadata/1.73/MegaAdChestProgress.lua
--==================================================
-- Element template for GameStatus.megaAdChestProgress
-- (RepeatedPtrField<MegaAdChestProgress>, POINTER-slot elements,
-- default stride). progress is a RepeatedPtrField<MegaAdChestProgressDay>.
local Manifest = loadModule("metadata/manifest.lua")
local MegaAdChestProgressDay = Manifest.load("MegaAdChestProgressDay")

return {
    -- rewardHash (0x18) is int64 — no Int64 reader yet
    ["progress"] = {
        offset = 0x20,
        type = "Array",
        elements = MegaAdChestProgressDay
    },
}
