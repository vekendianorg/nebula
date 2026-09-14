--==================================================
-- metadata/1.74/MegaAdChestProgressDay.lua
--==================================================
-- Element template for MegaAdChestProgress.progress
-- (RepeatedPtrField<MegaAdChestProgressDay>, POINTER-slot elements,
-- default stride). reward is a singular submessage member — a POINTER
-- (8-byte slot, deref'd via Object) to MegaAdChestItem.
local Manifest = loadModule("metadata/manifest.lua")
local MegaAdChestItem = Manifest.load("MegaAdChestItem")


return {
    ["watched"] = {
        offset = 0x18,
        type = "Int32"
    },
    ["claimed"] = {
        offset = 0x1C,
        type = "Bool"
    },
    ["reward"] = {
        offset = 0x20,
        type = "Object",
        elements = MegaAdChestItem
    },
}
