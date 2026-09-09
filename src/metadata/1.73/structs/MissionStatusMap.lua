-- metadata/1.73/MissionStatusMap.lua
-- Element template for GameStatus.activeLevelMissions
-- (RepeatedPtrField<MissionStatusMap>, POINTER-slot elements, default
-- stride). missionStatus is a singular submessage member — a POINTER
-- (8-byte slot, deref'd via Object) to MissionStatus.
local Manifest = loadModule("metadata/manifest.lua")
local MissionStatus = Manifest.load("MissionStatus")

local missionStatusObj = { offset = 0x20, type = "Object" }
for k, v in pairs(MissionStatus) do missionStatusObj[k] = v end

return {
    ["levelId"] = { offset = 0x18, type = "String" },
    ["missionStatus"] = missionStatusObj,
}
