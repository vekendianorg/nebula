--==================================================
-- metadata/1.73/RewardStatus.lua
--==================================================
-- Element template for nested rewards / distanceRewards arrays
-- (RepeatedPtrField<RewardStatus>, POINTER-slot elements, default stride).
return {
    ["id"] = {
        offset = 0x18,
        type = "String"
    },
    ["state"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["startTimestamp"] = {
        offset = 0x24,
        type = "Int32"
    },
    ["vehicleId"] = {
        offset = 0x28,
        type = "String"
    },
    ["type"] = {
        offset = 0x30,
        type = "Int32"
    },
    ["target"] = {
        offset = 0x34,
        type = "Int32"
    },
    ["duration"] = {
        offset = 0x38,
        type = "Int32"
    },
    ["specialCupRewardTypeIndex"] = {
        offset = 0x3C,
        type = "Int32"
    },
    ["slot"] = {
        offset = 0x40,
        type = "Int32"
    },
    ["level"] = {
        offset = 0x44,
        type = "Int32"
    },
}
