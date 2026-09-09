-- metadata/1.73/IapPurchaseEvent.lua
-- Element template for GameStatus iapPurchaseEvents arrays
-- (RepeatedPtrField<IapPurchaseEvent>, POINTER-slot elements, default stride).
return {
    ["iapId"] = { offset = 0x18, type = "String" },
    ["timestamp"] = { offset = 0x20, type = "Int32" },
    ["validated"] = { offset = 0x24, type = "Bool" },
    ["transactionId"] = { offset = 0x28, type = "String" },
    ["offerId"] = { offset = 0x30, type = "String" },
    ["recipientIds"] = { offset = 0x38, type = "Array", elementType = "String" },
    ["validationState"] = { offset = 0x50, type = "Int32" },
}
