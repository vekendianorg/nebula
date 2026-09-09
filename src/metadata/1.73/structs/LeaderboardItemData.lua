-- metadata/1.73/LeaderboardItemData.lua
-- Element template for GameStatus leaderboard arrays
-- (RepeatedPtrField<LeaderboardItemData>, POINTER-slot elements, default stride).
return {
    ["playerId"] = { offset = 0x18, type = "String" },
    ["playerName"] = { offset = 0x20, type = "String" },
    ["time"] = { offset = 0x28, type = "Float" },
    ["distance"] = { offset = 0x2C, type = "Float" },
    ["levelId"] = { offset = 0x30, type = "String" },
    ["points"] = { offset = 0x38, type = "Int32" },
    ["finishingStatus"] = { offset = 0x3C, type = "Int32" },
    ["sessionId"] = { offset = 0x40, type = "String" },
    ["replayId"] = { offset = 0x48, type = "String" },
    ["flag"] = { offset = 0x50, type = "String" },
    ["vehicleId"] = { offset = 0x58, type = "String" },
    ["retryCount"] = { offset = 0x60, type = "Int32" },
    ["result"] = { offset = 0x64, type = "Float" },
    ["teamId"] = { offset = 0x68, type = "String" },
    ["resultType"] = { offset = 0x70, type = "Int32" },
    ["raceIndex"] = { offset = 0x74, type = "Int32" },
    ["teamName"] = { offset = 0x78, type = "String" },
    ["icon"] = { offset = 0x80, type = "String" },
    ["iconHue"] = { offset = 0x88, type = "Int32" },
    ["rank"] = { offset = 0x8C, type = "Float" },
    ["badgeBase"] = { offset = 0x90, type = "String" },
    ["seasonId"] = { offset = 0x98, type = "String" },
    ["finalPlacement"] = { offset = 0xA0, type = "Int32" },
    ["divisionId"] = { offset = 0xA4, type = "Int32" },
}
