--==================================================
-- metadata/1.74/MissionStatusMap.lua
--==================================================
-- Element template for GameStatus.activeLevelMissions
-- (RepeatedPtrField<MissionStatusMap>, POINTER-slot elements, default
-- stride). missionStatus is a singular submessage member — a POINTER
-- (8-byte slot, deref'd via Object) to MissionStatus.
local Manifest = loadModule("metadata/manifest.lua")
local MissionStatus = Manifest.load("MissionStatus")


return {
    ["levelId"] = {
        offset = 0x18,
        type = "String"
    },
    ["missionStatus"] = {
        offset = 0x20,
        type = "Object",
        elements = MissionStatus
    },
}
