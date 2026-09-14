--==================================================
-- metadata/1.73/DealStatus.lua
--==================================================
-- Element template for GameStatus.dealStatus
-- (RepeatedPtrField<DealStatus>, POINTER-slot elements, default stride).
-- purchasedItems / items are RepeatedPtrField<DealItem> arrays.
local Manifest = loadModule("metadata/manifest.lua")
local DealItem = Manifest.load("DealItem")

return {
    ["id"] = {
        offset = 0x18,
        type = "String"
    },
    ["purchasedItems"] = {
        offset = 0x20,
        type = "Array",
        elements = DealItem
    },
    ["items"] = {
        offset = 0x38,
        type = "Array",
        elements = DealItem
    },
    ["endTimestamp"] = {
        offset = 0x50,
        type = "Int32"
    },
}
