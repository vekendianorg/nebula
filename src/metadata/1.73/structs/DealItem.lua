-- metadata/1.73/DealItem.lua
-- Element template for DealStatus.purchasedItems / DealStatus.items
-- (RepeatedPtrField<DealItem>, POINTER-slot elements, default stride).
return {
    ["id"] = { offset = 0x18, type = "String" },
    ["type"] = { offset = 0x20, type = "String" },
    ["amount"] = { offset = 0x28, type = "Int32" },
}
