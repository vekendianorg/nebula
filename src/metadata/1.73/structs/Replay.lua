--==================================================
-- metadata/1.73/Replay.lua
--==================================================
-- Complete metadata snapshot for the Replay struct at game
-- version 1.73 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is Replay only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump):
--   public class Replay : google.protobuf.Message // TypeDefIndex: 1865 Size: 0x180
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
-- When reading via RaceInfo.raceReplays/mCurrentCupReplays (Pointer<List<Pointer<Replay>>>),
-- or Challenge.challengerReplay (Replay), or WCRace.replays (RepeatedPtrField<Replay>),
-- the caller must pass stringDirect = false.
--
-- Nested types without metadata: ReplayFrame, VehicleCustomization, DriverCustomization,
-- FrameData, TuningPartStatus, UpgradeStatus, MasteryStatus.

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["playerId"] = {
        -- dump: private string playerid_ // 0x18
        offset = 0x18,
        type = "String",
        indirect = true,
    },
    ["vehicle"] = {
        -- dump: private string vehicle_ // 0x20
        offset = 0x20,
        type = "String",
        indirect = true,
    },
    ["levelId"] = {
        -- dump: private string levelid_ // 0x28
        offset = 0x28,
        type = "String",
        indirect = true,
    },
    ["frames"] = {
        -- dump: private RepeatedPtrField<ReplayFrame> frames_ // 0x30
        offset = 0x30,
        type = "Array",
        -- element type ReplayFrame has no metadata snapshot
    },
    ["time"] = {
        -- dump: private float time_ // 0x48
        offset = 0x48,
        type = "Float",
    },
    ["distance"] = {
        -- dump: private float distance_ // 0x4c
        offset = 0x4C,
        type = "Float",
    },
    ["playerName"] = {
        -- dump: private string playername_ // 0x50
        offset = 0x50,
        type = "String",
        indirect = true,
    },
    ["sessionId"] = {
        -- dump: private string sessionid_ // 0x58
        offset = 0x58,
        type = "String",
        indirect = true,
    },
    ["finishingStatus"] = {
        -- dump: private int32 finishingstatus_ // 0x60
        offset = 0x60,
        type = "Int32",
    },
    ["pValue"] = {
        -- dump: private float pvalue_ // 0x64
        offset = 0x64,
        type = "Float",
    },
    ["customizations"] = {
        -- dump: private RepeatedPtrField<VehicleCustomization> customizations_ // 0x68
        offset = 0x68,
        type = "Array",
        -- element type VehicleCustomization has no metadata snapshot
    },
    ["driver"] = {
        -- dump: private DriverCustomization driver_ // 0x80
        offset = 0x80,
        type = "Object",
        -- elements = DriverCustomization (no metadata snapshot)
    },
    ["flag"] = {
        -- dump: private string flag_ // 0x88
        offset = 0x88,
        type = "String",
        indirect = true,
    },
    ["playbackScale"] = {
        -- dump: private float playbackscale_ // 0x90
        offset = 0x90,
        type = "Float",
    },
    ["wcRank"] = {
        -- dump: private float wcrank_ // 0x94
        offset = 0x94,
        type = "Float",
    },
    ["skill2"] = {
        -- dump: private RepeatedField<float> skill2_ // 0x98
        offset = 0x98,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4,
        container = "protobuf",
    },
    ["frameData"] = {
        -- dump: private FrameData framedata_ // 0xa8
        offset = 0xA8,
        type = "Object",
        -- elements = FrameData (no metadata snapshot)
    },
    ["finishPosition"] = {
        -- dump: private int32 finishposition_ // 0xb0
        offset = 0xB0,
        type = "Int32",
    },
    ["captureTimestamp"] = {
        -- dump: private int32 capturetimestamp_ // 0xb4
        offset = 0xB4,
        type = "Int32",
    },
    ["byteFrameData"] = {
        -- dump: private string byteframedata_ // 0xb8
        offset = 0xB8,
        type = "String",
        indirect = true,
    },
    ["zippedFrameData"] = {
        -- dump: private string zippedframedata_ // 0xc0
        offset = 0xC0,
        type = "String",
        indirect = true,
    },
    ["levelType"] = {
        -- dump: private int32 leveltype_ // 0xc8
        offset = 0xC8,
        type = "Int32",
    },
    ["contentVersion"] = {
        -- dump: private int32 contentversion_ // 0xcc
        offset = 0xCC,
        type = "Int32",
    },
    ["available"] = {
        -- dump: private bool available_ // 0xd0
        offset = 0xD0,
        type = "Bool",
    },
    ["adventurerReplay"] = {
        -- dump: private bool adventurerreplay_ // 0xd1
        offset = 0xD1,
        type = "Bool",
    },
    ["customTrackReplay"] = {
        -- dump: private bool customtrackreplay_ // 0xd2
        offset = 0xD2,
        type = "Bool",
    },
    ["result"] = {
        -- dump: private float result_ // 0xd4
        offset = 0xD4,
        type = "Float",
    },
    ["_id"] = {
        -- dump: private string _id_ // 0xd8
        offset = 0xD8,
        type = "String",
        indirect = true,
    },
    ["tuningParts"] = {
        -- dump: private RepeatedPtrField<TuningPartStatus> tuningparts_ // 0xe0
        offset = 0xE0,
        type = "Array",
        -- element type TuningPartStatus has no metadata snapshot
    },
    ["seasonId"] = {
        -- dump: private string seasonid_ // 0xf8
        offset = 0xF8,
        type = "String",
        indirect = true,
    },
    ["resultType"] = {
        -- dump: private int32 resulttype_ // 0x100
        offset = 0x100,
        type = "Int32",
    },
    ["raceIndex"] = {
        -- dump: private int32 raceindex_ // 0x104
        offset = 0x104,
        type = "Int32",
    },
    ["teamId"] = {
        -- dump: private string teamid_ // 0x108
        offset = 0x108,
        type = "String",
        indirect = true,
    },
    ["reportReason"] = {
        -- dump: private string reportreason_ // 0x110
        offset = 0x110,
        type = "String",
        indirect = true,
    },
    ["upgrades"] = {
        -- dump: private RepeatedPtrField<UpgradeStatus> upgrades_ // 0x118
        offset = 0x118,
        type = "Array",
        -- element type UpgradeStatus has no metadata snapshot
    },
    ["variantLevelId"] = {
        -- dump: private string variantlevelid_ // 0x130
        offset = 0x130,
        type = "String",
        indirect = true,
    },
    ["levelFilename"] = {
        -- dump: private string levelfilename_ // 0x138
        offset = 0x138,
        type = "String",
        indirect = true,
    },
    ["masteryStatus"] = {
        -- dump: private RepeatedPtrField<MasteryStatus> masterystatus_ // 0x140
        offset = 0x140,
        type = "Array",
        -- element type MasteryStatus has no metadata snapshot
    },
    ["currentWinStreak"] = {
        -- dump: private int32 currentwinstreak_ // 0x158
        offset = 0x158,
        type = "Int32",
    },
    ["respawnCount"] = {
        -- dump: private int32 respawncount_ // 0x15c
        offset = 0x15C,
        type = "Int32",
    },
    ["specialFeatureUpgrades"] = {
        -- dump: private RepeatedPtrField<UpgradeStatus> specialfeatureupgrades_ // 0x160
        offset = 0x160,
        type = "Array",
        -- element type UpgradeStatus has no metadata snapshot
    },
}
