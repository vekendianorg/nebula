--==================================================
-- metadata/1.74/WCRace.lua
--==================================================
-- Complete metadata snapshot for the WCRace struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is WCRace only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump; 1.74 layout identical):
--   public class WCRace : google.protobuf.Message // TypeDefIndex: 2336 Size: 0x50
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
-- When reading via RaceInfo.mWcRace (Pointer<WCRace>),
-- the caller must pass stringDirect = false.
--
-- Reused existing snapshots: Replay.

local Manifest = loadModule("metadata/manifest.lua")
local Replay = Manifest.load("Replay")

return {
    ["replays"] = {
        -- dump: private RepeatedPtrField<Replay> replays_ // 0x18
        offset = 0x18,
        type = "Array",
        elementType = "Object",
        elements = Replay,
        elementStride = 0x8,
        container = "protobuf",
    },
    ["raceFinishWcRanks"] = {
        -- dump: private RepeatedField<float> racefinishwcranks_ // 0x30
        offset = 0x30,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4,
        container = "protobuf",
    },
    ["raceFinishSeasonRanks"] = {
        -- dump: private RepeatedField<float> racefinishseasonranks_ // 0x40
        offset = 0x40,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4,
        container = "protobuf",
    },
}
