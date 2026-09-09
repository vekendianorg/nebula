-- metadata/1.73/RecentUsage.lua
-- Shared element template for VehicleStats.recentUsage
-- (RepeatedPtrField<RecentUsage>, POINTER-slot elements).
-- Dump: RecentUsage // Size 0x30: dayssinceepoch int32 @0x18,
-- racestarts int32 @0x1c, distancestarts int32 @0x20,
-- eventstarts int32 @0x24, totaldistance int32 @0x28
return {
    ["daysSinceEpoch"] = { offset = 0x18, type = "Int32" },
    ["raceStarts"] = { offset = 0x1C, type = "Int32" },
    ["distanceStarts"] = { offset = 0x20, type = "Int32" },
    ["eventStarts"] = { offset = 0x24, type = "Int32" },
    ["totalDistance"] = { offset = 0x28, type = "Int32" },
}
