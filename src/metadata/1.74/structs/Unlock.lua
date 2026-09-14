--==================================================
-- metadata/1.74/Unlock.lua
--==================================================
-- Element template for GameStatus.unlocks
-- (RepeatedPtrField<Unlock>, POINTER-slot elements, default stride).
-- type is the UnlockType enum (metadata/1.74/enums/UnlockType.lua).
return {
    ["type"] = {
        offset = 0x20,
        type = "Enum",
        enum = "UnlockType"
    },
    ["id"] = {
        offset = 0x18,
        type = "String"
    },
    ["unlockState"] = {
        offset = 0x24,
        type = "Int32"
    },
    ["unlockType"] = {
        offset = 0x30,
        type = "Int32"
    },
    ["vehicleId"] = {
        offset = 0x28,
        type = "String"
    },
    ["isComplete"] = {
        offset = 0x34,
        type = "Bool"
    },
}
