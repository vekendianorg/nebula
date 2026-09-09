-- metadata/1.73/PendingChest.lua
-- Element template for GameStatus.pendingChests
-- (RepeatedPtrField<PendingChest>, POINTER-slot elements, default stride).
return {
    ["vehicleId"] = { offset = 0x18, type = "String" },
    ["chestIndex"] = { offset = 0x20, type = "Int32" },
    ["level"] = { offset = 0x24, type = "Int32" },
    ["type"] = { offset = 0x28, type = "String" },
}
