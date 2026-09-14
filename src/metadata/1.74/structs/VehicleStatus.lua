--==================================================
-- metadata/1.74/VehicleStatus.lua
--==================================================
-- Element template for RepeatedPtrField<VehicleStatus>
-- (GameStatus.vehicleStatus @0xb8, POINTER-slot proto elements,
-- default stride).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class VehicleStatus
--       // Size: 0x198  Confidence: exact
--
-- All offsets are VehicleStatus-relative. Sub-elements (tuningParts,
-- upgrades, vehicleStats, masteryStatus, styleTracks, etc.) are
-- chained to their own per-class snapshots.

local Manifest = loadModule("metadata/manifest.lua")

local StringIntMap         = Manifest.load("StringIntMap")
local UpgradeStatus        = Manifest.load("UpgradeStatus")
local DistanceHighscore    = Manifest.load("DistanceHighscore")
local TimeTrialHighscore   = Manifest.load("TimeTrialHighscore")
local VehicleStats         = Manifest.load("VehicleStats")
local StyleRewardTrack     = Manifest.load("StyleRewardTrack")
local VehicleCustomization = Manifest.load("VehicleCustomization")
local TuningPartStatus     = Manifest.load("TuningPartStatus")
local TuningPartPreset     = Manifest.load("TuningPartPreset")
local MasteryStatus        = Manifest.load("MasteryStatus")
local StyleTrackStatus     = Manifest.load("StyleTrackStatus")

-- vehicleStats is a POINTER member (8-byte slot, deref'd via Object);
-- children are read at VehicleStats-relative offsets.

-- styleRewardTrack is a POINTER member (8-byte slot, deref'd via
-- Object); children come from the StyleRewardTrack snapshot.

return {
    ["vehicleId"] = {
        offset = 0x18,
        type = "String"
    },
    ["upgrades"] = {
        offset = 0x20,
        type = "Array",
        elements = UpgradeStatus
    },
    ["customizations"] = {
        offset = 0x38,
        type = "Array",
        elements = VehicleCustomization
    },
    ["vehicleStats"] = {
        offset = 0x50,
        type = "Object",
        elements = VehicleStats
    },
    ["tuningParts"] = {
        offset = 0x58,
        type = "Array",
        elements = TuningPartStatus
    },
    ["equippedTuningParts"] = {
        offset = 0x70,
        type = "Array",
        elementType = "String"
    },
    ["specialFeatureUpgrades"] = {
        offset = 0x150,
        type = "Array",
        elements = UpgradeStatus
    },
    ["distanceHighscores"] = {
        offset = 0x88,
        type = "Array",
        elements = DistanceHighscore
    },
    ["timeTrialHighscores"] = {
        offset = 0xA0,
        type = "Array",
        elements = TimeTrialHighscore
    },
    ["newDistanceHighscores"] = {
        offset = 0xB8,
        type = "Array",
        elements = DistanceHighscore
    },
    ["newTimeTrialHighscores"] = {
        offset = 0xD0,
        type = "Array",
        elements = TimeTrialHighscore
    },
    ["distanceTarget"] = {
        offset = 0xF0,
        type = "Array",
        elements = StringIntMap
    },
    ["tuningPartPresets"] = {
        offset = 0x108,
        type = "Array",
        elements = TuningPartPreset
    },
    ["selectedPresetIndex"] = {
        offset = 0xEC,
        type = "Int32"
    },
    ["vehiclePower"] = {
        offset = 0x140,
        type = "Int32"
    },
    ["masteryStatus"] = {
        offset = 0x120,
        type = "Array",
        elements = MasteryStatus
    },
    ["masteryXp"] = {
        offset = 0x138,
        type = "SafeInt32"
    },
    ["currentVehicleWinStreak"] = {
        offset = 0x144,
        type = "Int32"
    },
    ["pendingMasteryXp"] = {
        offset = 0x148,
        type = "SafeInt32"
    },
    ["maxLevelBoostExpiryTimestamp"] = {
        offset = 0x168,
        type = "SafeInt32"
    },
    ["styleTracks"] = {
        offset = 0x170,
        type = "Array",
        elements = StyleTrackStatus
    },
    ["styleRewardTrack"] = {
        offset = 0x188,
        type = "Object",
        elements = StyleRewardTrack
    },  -- StyleRewardTrack
    ["bestVehicleWinStreak"] = {
        offset = 0x190,
        type = "Int32"
    },
}
