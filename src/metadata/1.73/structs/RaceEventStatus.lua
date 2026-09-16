--==================================================
-- metadata/1.73/RaceEventStatus.lua
--==================================================
-- Complete metadata snapshot for the RaceEventStatus struct at game
-- version 1.73 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is RaceEventStatus only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump):
--   public class RaceEventStatus : google.protobuf.Message // TypeDefIndex: 1835 Size: 0x60
--   Confidence: exact
--
-- Every offset and type below matches that dump exactly. No layout,
-- size, stride, pointer representation, or schema is guessed.
--
-- Field-name normalization (camelCase): a leading `m` is stripped
-- and the next character lowercased; fields without the `m` prefix
-- keep their dump names unchanged.
--
-- This is a protobuf Message (proto2). All strings are pointer-backed
-- (indirect). Arrays use protobuf RepeatedField/RepeatedPtrField headers.
-- When reading via RaceInfo.mRaceEventStatus (Pointer<RaceEventStatus>),
-- the caller must pass stringDirect = false.
--
-- Nested types without metadata: TournamentParticipant.

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["eventId"] = {
        -- dump: private string eventid_ // 0x18
        offset = 0x18,
        type = "String",
        indirect = true,
    },
    ["finishPositions"] = {
        -- dump: private RepeatedField<int> finishpositions_ // 0x20
        offset = 0x20,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4,
        container = "protobuf",
    },
    ["participants"] = {
        -- dump: private RepeatedPtrField<TournamentParticipant> participants_ // 0x30
        offset = 0x30,
        type = "Array",
        -- element type TournamentParticipant has no metadata snapshot
    },
    ["sessionId"] = {
        -- dump: private string sessionid_ // 0x48
        offset = 0x48,
        type = "String",
        indirect = true,
    },
    ["specialEventId"] = {
        -- dump: private string specialeventid_ // 0x50
        offset = 0x50,
        type = "String",
        indirect = true,
    },
    ["isSpecial"] = {
        -- dump: private bool isspecial_ // 0x58
        offset = 0x58,
        type = "Bool",
    },
    ["isRanked"] = {
        -- dump: private bool isranked_ // 0x59
        offset = 0x59,
        type = "Bool",
    },
}
