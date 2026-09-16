--==================================================
-- metadata/1.74/Challenge.lua
--==================================================
-- Complete metadata snapshot for the Challenge struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is Challenge only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump; 1.74 layout identical):
--   public class Challenge : google.protobuf.Message // TypeDefIndex: 984 Size: 0x60
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
-- When reading via RaceInfo.mChallenge (Pointer<Challenge>),
-- the caller must pass stringDirect = false.
--
-- Reused existing snapshots: Replay, VehicleStatus, LeaderboardItemData.

local Manifest = loadModule("metadata/manifest.lua")
local Replay = Manifest.load("Replay")
local VehicleStatus = Manifest.load("VehicleStatus")

return {
    ["challengeId"] = {
        -- dump: private string challengeid_ // 0x18
        offset = 0x18,
        type = "String",
        indirect = true,
    },
    ["challengerReplay"] = {
        -- dump: private Replay challengerreplay_ // 0x20
        offset = 0x20,
        type = "Object",
        elements = Replay,
    },
    ["expirationTimestamp"] = {
        -- dump: private int32 expirationtimestamp_ // 0x28
        offset = 0x28,
        type = "Int32",
    },
    ["totalTries"] = {
        -- dump: private int32 totaltries_ // 0x2c
        offset = 0x2C,
        type = "Int32",
    },
    ["vehicleStatus"] = {
        -- dump: private VehicleStatus vehiclestatus_ // 0x30
        offset = 0x30,
        type = "Object",
        elements = VehicleStatus,
    },
    ["totalWins"] = {
        -- dump: private int32 totalwins_ // 0x38
        offset = 0x38,
        type = "Int32",
    },
    ["totalLosses"] = {
        -- dump: private int32 totallosses_ // 0x3c
        offset = 0x3C,
        type = "Int32",
    },
    ["yourBest"] = {
        -- dump: private LeaderboardItemData yourbest_ // 0x40
        offset = 0x40,
        type = "Object",
        -- elements = LeaderboardItemData (no metadata snapshot)
    },
    ["yourPosition"] = {
        -- dump: private int32 yourposition_ // 0x48
        offset = 0x48,
        type = "Int32",
    },
    ["challengeTier"] = {
        -- dump: private int32 challengetier_ // 0x4c
        offset = 0x4C,
        type = "Int32",
    },
    ["eventId"] = {
        -- dump: private string eventid_ // 0x50
        offset = 0x50,
        type = "String",
        indirect = true,
    },
    ["raceType"] = {
        -- dump: private int32 racetype_ // 0x58
        offset = 0x58,
        type = "Int32",
    },
    ["isSignatureChallenge"] = {
        -- dump: private bool issignaturechallenge_ // 0x5c
        offset = 0x5C,
        type = "Bool",
    },
}
