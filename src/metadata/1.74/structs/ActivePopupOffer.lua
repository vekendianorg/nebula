--==================================================
-- metadata/1.74/ActivePopupOffer.lua
--==================================================
-- Element template for GameStatus.popupOffers
-- (RepeatedPtrField<ActivePopupOffer>, POINTER-slot elements, default stride).
return {
    ["id"] = {
        offset = 0x18,
        type = "String"
    },
    ["endTimestamp"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["useAdOffer"] = {
        offset = 0x24,
        type = "Bool"
    },
    ["activationCount"] = {
        offset = 0x28,
        type = "Int32"
    },
    ["activationTimestamp"] = {
        offset = 0x2C,
        type = "Int32"
    },
    ["originalActivationTimestamp"] = {
        offset = 0x30,
        type = "Int32"
    },
}
