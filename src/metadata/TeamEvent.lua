--==================================================
-- metadata/TeamEvent.lua
--==================================================
-- Field table for the TeamEvent
--
-- TeamEvent shares its header with PublicEvent - contentVersion
-- through pointsSystem are identical offsets. The header is mirrored from PublicEvent
-- (the canonical source for that portion) rather than duplicated.
--
-- Past 0x4A0 the two structs diverge: PublicEvent has
-- fixedVehicles/specialFeatures/eventSpecials/premiumEventRewards,
-- none of which appear in the TeamEvent source. TeamEvent instead
-- has multiRaceGameModes and winningTeamReward, which PublicEvent
-- doesn't have. A bare Mirror.of("PublicEvent") would misattribute
-- both directions, so the mirrored header is patched with
-- TeamEvent's own tail instead of returned as-is.
--
-- loadModule() (see main.lua) does a fresh loadfile()+call every
-- time, not require()-style caching, so mutating the table below is
-- safe - it won't affect PublicEvent's own separately-loaded copy.
--
-- offset = 0xBAAD means the offset is NOT YET KNOWN. Do not
-- trust these fields until the placeholder is replaced by a
-- verified static offset.

local Mirror = loadModule("metadata/Mirror.lua")

local metadata = Mirror.of("PublicEvent")

-- Fields that only exist on PublicEvent - not present in the
-- TeamEvent source, so they don't belong here.
metadata.eventSpecials = nil
metadata.fixedVehicles = nil
metadata.specialFeatures = nil
metadata.premiumEventRewards = nil
metadata.unlockCurrentlyActiveSegment = nil -- not present in TeamEvent source either

-- Fields unique to TeamEvent.
metadata.multiRaceGameModes = {
    offset = 0x500,
    type = "Array"
}
metadata.winningTeamReward = {
    offset = 0x520,
    type = "Object" -- known offset, no reader yet
}

-- eventRewards (0x528) is confirmed identical in both sources and
-- stays as mirrored from PublicEvent - no patch needed.
--
-- rotatingEventRewards (0x558) / rotatingEventRewardsInterval (0x570)
-- / mainEventRewards (0x578) were previously UNVERIFIED for TeamEvent
-- (the TeamEvent source jumped from eventRewards straight to
-- multiRaceGameModes). The IL2CPP dump now confirms they are correct:
-- the game stores team event definitions in
-- Dictionary<string, Pointer<EventDefinition>>, i.e. the SAME
-- EventDefinition struct backs PublicEvent, TeamEvent and
-- CommunityEvent (Size 0x5D8, Confidence: exact). All mirrored
-- offsets in the 0x528..0x590 range are therefore verified.

return metadata