--==================================================
-- metadata/1.73/StyleRewardTrack.lua
--==================================================
-- Dump-named snapshot for the StyleRewardTrack class — the singular
-- submessage member VehicleStatus.styleRewardTrack @0x188 (POINTER,
-- 8-byte slot, deref'd via Object). Currently VehicleStatus/1.73.lua
-- still carries its own inline definition of these fields; this file
-- is the standalone equivalent, added (not replacing anything) so
-- consumers can resolve it directly via the manifest.
--
-- Dump: StyleRewardTrack = { claimedrewardcount SafeInt32 @0x18,
--   claimedrewards RepeatedField<int32> @0x20, nextrewardindex
--   int32 @0x30 } — all offsets StyleRewardTrack-relative.
return {
    ["claimedRewardCount"] = {
        offset = 0x18,
        type = "SafeInt32"
    },
    ["claimedRewards"] = {
        offset = 0x20,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
    ["nextRewardIndex"] = {
        offset = 0x30,
        type = "Int32"
    },
}
