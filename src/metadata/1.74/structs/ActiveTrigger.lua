--==================================================
-- metadata/1.74/ActiveTrigger.lua
--==================================================
-- Element template for GameStatus.activeTriggers
-- (RepeatedPtrField<ActiveTrigger>, POINTER-slot elements, default stride).
return {
    ["timestamp"] = {
        offset = 0x18,
        type = "Int32"
    },
    ["type"] = {
        offset = 0x1C,
        type = "Int32"
    },
    ["vehicleId"] = {
        offset = 0x20,
        type = "String"
    },
    ["level"] = {
        offset = 0x28,
        type = "Int32"
    },
}
