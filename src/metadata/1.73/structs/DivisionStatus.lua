--==================================================
-- metadata/1.73/DivisionStatus.lua
--==================================================
-- Complete metadata snapshot for the DivisionStatus struct at game
-- version 1.73 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is DivisionStatus only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump):
--   public class DivisionStatus : google.protobuf.Message // TypeDefIndex: 1119 Size: 0x40
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
-- When reading via RaceInfo.mDivisionStatus (Pointer<DivisionStatus>),
-- the caller must pass stringDirect = false.
--
-- Nested types without metadata: LeaderboardItemData.

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["levelId"] = {
        -- dump: private string levelid_ // 0x18
        offset = 0x18,
        type = "String",
        indirect = true,
    },
    ["leaderboardItems"] = {
        -- dump: private RepeatedPtrField<LeaderboardItemData> leaderboarditems_ // 0x20
        offset = 0x20,
        type = "Array",
        -- element type LeaderboardItemData has no metadata snapshot
    },
    ["divisionNumber"] = {
        -- dump: private int32 divisionnumber_ // 0x38
        offset = 0x38,
        type = "Int32",
    },
}
