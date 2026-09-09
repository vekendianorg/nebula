-- metadata/1.73/Currency.lua
-- Element template for GameStatus.currencies
-- (RepeatedPtrField<Currency>, POINTER-slot elements, default stride).
return {
    ["id"] = { offset = 0x18, type = "String" },
    ["amount"] = { offset = 0x20, type = "Int32" },
    ["totalEarned"] = { offset = 0x24, type = "Int32" },
    ["totalSpent"] = { offset = 0x30, type = "Int32" },
    ["safeAmount"] = { offset = 0x28, type = "SafeInt32" },
    ["timesEarned"] = { offset = 0x34, type = "Int32" },
    ["maxEarn"] = { offset = 0x48, type = "Int32" },
    ["iapCount"] = { offset = 0x38, type = "SafeInt32" },
    ["iapAmount"] = { offset = 0x40, type = "SafeInt32" },
}
