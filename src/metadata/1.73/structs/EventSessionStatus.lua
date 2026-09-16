--==================================================
-- metadata/1.73/EventSessionStatus.lua
--==================================================
-- Complete metadata snapshot for the EventSessionStatus struct at game
-- version 1.73 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is EventSessionStatus only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump):
--   public class EventSessionStatus : google.protobuf.Message // TypeDefIndex: 1183 Size: 0x100
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
-- When reading via RaceInfo.mEventSessionStatus (Pointer<EventSessionStatus>),
-- the caller must pass stringDirect = false.
--
-- Nested types without metadata: PublicPlayerProfile, LeaderboardItemData.

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["sessionId"] = {
        -- dump: private string sessionid_ // 0x18
        offset = 0x18,
        type = "String",
        indirect = true,
    },
    ["eventId"] = {
        -- dump: private string eventid_ // 0x20
        offset = 0x20,
        type = "String",
        indirect = true,
    },
    ["participants"] = {
        -- dump: private RepeatedPtrField<PublicPlayerProfile> participants_ // 0x28
        offset = 0x28,
        type = "Array",
        -- element type PublicPlayerProfile has no metadata snapshot
    },
    ["raceResults"] = {
        -- dump: private RepeatedPtrField<LeaderboardItemData> raceresults_ // 0x40
        offset = 0x40,
        type = "Array",
        -- element type LeaderboardItemData has no metadata snapshot
    },
    ["startTimestamp"] = {
        -- dump: private int32 starttimestamp_ // 0x58
        offset = 0x58,
        type = "Int32",
    },
    ["createTimestamp"] = {
        -- dump: private int32 createtimestamp_ // 0x5c
        offset = 0x5C,
        type = "Int32",
    },
    ["levelId"] = {
        -- dump: private string levelid_ // 0x60
        offset = 0x60,
        type = "String",
        indirect = true,
    },
    ["perLevelResults"] = {
        -- dump: private RepeatedPtrField<LeaderboardItemData> perlevelresults_ // 0x68
        offset = 0x68,
        type = "Array",
        -- element type LeaderboardItemData has no metadata snapshot
    },
    ["team1"] = {
        -- dump: private string team1_ // 0x80
        offset = 0x80,
        type = "String",
        indirect = true,
    },
    ["team2"] = {
        -- dump: private string team2_ // 0x88
        offset = 0x88,
        type = "String",
        indirect = true,
    },
    ["team1Rank"] = {
        -- dump: private float team1rank_ // 0x90
        offset = 0x90,
        type = "Float",
    },
    ["team2Rank"] = {
        -- dump: private float team2rank_ // 0x94
        offset = 0x94,
        type = "Float",
    },
    ["team1Name"] = {
        -- dump: private string team1name_ // 0x98
        offset = 0x98,
        type = "String",
        indirect = true,
    },
    ["team2Name"] = {
        -- dump: private string team2name_ // 0xa0
        offset = 0xA0,
        type = "String",
        indirect = true,
    },
    ["status"] = {
        -- dump: private int32 status_ // 0xa8
        offset = 0xA8,
        type = "Int32",
    },
    ["team1MatchesPlayed"] = {
        -- dump: private int32 team1matchesplayed_ // 0xac
        offset = 0xAC,
        type = "Int32",
    },
    ["team1Icon"] = {
        -- dump: private string team1icon_ // 0xb0
        offset = 0xB0,
        type = "String",
        indirect = true,
    },
    ["team2Icon"] = {
        -- dump: private string team2icon_ // 0xb8
        offset = 0xB8,
        type = "String",
        indirect = true,
    },
    ["team2MatchesPlayed"] = {
        -- dump: private int32 team2matchesplayed_ // 0xc0
        offset = 0xC0,
        type = "Int32",
    },
    ["endTimestamp"] = {
        -- dump: private int32 endtimestamp_ // 0xc4
        offset = 0xC4,
        type = "Int32",
    },
    ["team1IconHue"] = {
        -- dump: private int32 team1iconhue_ // 0xc8
        offset = 0xC8,
        type = "Int32",
    },
    ["team2IconHue"] = {
        -- dump: private int32 team2iconhue_ // 0xcc
        offset = 0xCC,
        type = "Int32",
    },
    ["team1NewRank"] = {
        -- dump: private float team1newrank_ // 0xd0
        offset = 0xD0,
        type = "Float",
    },
    ["team2NewRank"] = {
        -- dump: private float team2newrank_ // 0xd4
        offset = 0xD4,
        type = "Float",
    },
    ["team1Flag"] = {
        -- dump: private string team1flag_ // 0xd8
        offset = 0xD8,
        type = "String",
        indirect = true,
    },
    ["team2Flag"] = {
        -- dump: private string team2flag_ // 0xe0
        offset = 0xE0,
        type = "String",
        indirect = true,
    },
    ["team1BadgeBase"] = {
        -- dump: private string team1badgebase_ // 0xe8
        offset = 0xE8,
        type = "String",
        indirect = true,
    },
    ["team2BadgeBase"] = {
        -- dump: private string team2badgebase_ // 0xf0
        offset = 0xF0,
        type = "String",
        indirect = true,
    },
    ["ghostMatch"] = {
        -- dump: private bool ghostmatch_ // 0xf8
        offset = 0xF8,
        type = "Bool",
    },
    ["winBonusRank"] = {
        -- dump: private float winbonusrank_ // 0xfc
        offset = 0xFC,
        type = "Float",
    },
}
