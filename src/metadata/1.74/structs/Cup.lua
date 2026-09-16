--==================================================
-- metadata/1.74/Cup.lua
--==================================================
-- Complete metadata snapshot for the Cup struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is Cup only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump; 1.74 layout identical):
--   public class Cup : google.protobuf.Message // TypeDefIndex: 1051 Size: 0x40
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
-- When reading via RaceInfo.mCurrentCup/mGhostCups (Pointer<Cup>/Pointer<List<Pointer<Cup>>>),
-- the caller must pass stringDirect = false.

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["cupId"] = {
        -- dump: private string cupid_ // 0x18
        offset = 0x18,
        type = "String",
        indirect = true,
    },
    ["replayIds"] = {
        -- dump: private RepeatedPtrField<string> replayids_ // 0x20
        offset = 0x20,
        type = "Array",
        elementType = "String",
        elementStride = 0x8,
        container = "protobuf",
    },
    ["contentVersion"] = {
        -- dump: private int32 contentversion_ // 0x38
        offset = 0x38,
        type = "Int32",
    },
}
