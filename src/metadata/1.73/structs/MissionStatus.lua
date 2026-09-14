--==================================================
-- metadata/1.73/MissionStatus.lua
--==================================================
-- Element template for RepeatedPtrField<MissionStatus> arrays
-- (GameStatus.completedMissions / completedDailyMissions / activeDailyMissions,
-- POINTER-slot elements, default stride).
-- Element templates filled from the libcocos2dcpp dump; all offsets are
-- element-relative. Singular submessage members are POINTERS (confirmed by
-- struct-size overlap analysis), so Object containers keep the deref
-- convention.
return {
    ["missionId"] = {
        offset = 0x18,
        type = "String"
    },
    ["bestValue"] = {
        offset = 0x20,
        type = "Float"
    },
    ["achievedLevel"] = {
        offset = 0x24,
        type = "Int32"
    },
    ["missionDefinitionId"] = {
        offset = 0x28,
        type = "String"
    },
    ["allowedVehicleIds"] = {
        offset = 0x30,
        type = "Array",
        elementType = "String"
    },
    ["allowedWorldIds"] = {
        offset = 0x48,
        type = "Array",
        elementType = "String"
    },
    ["allowedLevelIds"] = {
        offset = 0x60,
        type = "Array",
        elementType = "String"
    },
    ["startingValue"] = {
        offset = 0x78,
        type = "Float"
    },
}
