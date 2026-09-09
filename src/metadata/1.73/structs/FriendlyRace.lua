-- metadata/1.73/FriendlyRace.lua
-- Element template for GameStatus.friendlyRace
-- (RepeatedPtrField<FriendlyRace>, POINTER-slot elements, default stride).
return {
    ["sessionId"] = { offset = 0x18, type = "String" },
    ["levelId"] = { offset = 0x20, type = "String" },
    ["friendlyRaceType"] = { offset = 0x28, type = "Int32" },
    ["expirationTimestamp"] = { offset = 0x2C, type = "Int32" },
    ["retryCount"] = { offset = 0x30, type = "Int32" },
}
