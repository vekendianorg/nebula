--==================================================
-- metadata/1.73/VehicleStats.lua
--==================================================
-- POINTER member VehicleStatus.vehicleStats (8-byte slot, deref'd
-- via Object). Children are VehicleStats-relative.
-- Dump: VehicleStats // Size 0x88: levelstars @0x18,
-- leveldivisionmedals @0x30 (both RepeatedPtrField<StringIntMap>),
-- flips @0x48, backflips @0x4c, neckflips @0x50, airtime float @0x54,
-- wheelietime float @0x58, racesfinished @0x5c, raceswon @0x60,
-- totaldistance @0x64, challengeswon @0x68, featuredchallengeswon
-- @0x6c, recentusage RepeatedPtrField<RecentUsage> @0x70

local Manifest = loadModule("metadata/manifest.lua")
local StringIntMap = Manifest.load("StringIntMap")
local RecentUsage  = Manifest.load("RecentUsage")

return {
    ["levelStars"] = {
        offset = 0x18,
        type = "Array",
        elements = StringIntMap
    },
    ["levelDivisionMedals"] = {
        offset = 0x30,
        type = "Array",
        elements = StringIntMap
    },
    ["flips"] = {
        offset = 0x48,
        type = "Int32"
    },
    ["backflips"] = {
        offset = 0x4C,
        type = "Int32"
    },
    ["neckflips"] = {
        offset = 0x50,
        type = "Int32"
    },
    ["airtime"] = {
        offset = 0x54,
        type = "Float"
    },
    ["wheelieTime"] = {
        offset = 0x58,
        type = "Float"
    },
    ["racesFinished"] = {
        offset = 0x5C,
        type = "Int32"
    },
    ["racesWon"] = {
        offset = 0x60,
        type = "Int32"
    },
    ["totalDistance"] = {
        offset = 0x64,
        type = "Int32"
    },
    ["challengesWon"] = {
        offset = 0x68,
        type = "Int32"
    },
    ["featuredChallengesWon"] = {
        offset = 0x6C,
        type = "Int32"
    },
    ["recentUsage"] = {
        offset = 0x70,
        type = "Array",
        elements = RecentUsage
    },
}
