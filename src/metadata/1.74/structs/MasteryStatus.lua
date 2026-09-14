--==================================================
-- metadata/1.74/MasteryStatus.lua
--==================================================
-- Element template for VehicleStatus.masteryStatus
-- (RepeatedPtrField<MasteryStatus>, POINTER-slot elements).
-- Dump: MasteryStatus // Size 0x20: unlocked bool @0x18,
-- purchased bool @0x19, enabled bool @0x1a,
-- progressstarttimestamp int32 @0x1c
return {
    ["unlocked"] = {
        offset = 0x18,
        type = "Bool"
    },
    ["purchased"] = {
        offset = 0x19,
        type = "Bool"
    },
    ["enabled"] = {
        offset = 0x1A,
        type = "Bool"
    },
    ["progressStartTimestamp"] = {
        offset = 0x1C,
        type = "Int32"
    },
}
