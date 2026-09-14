--==================================================
-- metadata/1.74/TournamentPlayerStatus.lua
--==================================================
-- Element template for GameStatus tournament-player arrays
-- (RepeatedPtrField<TournamentPlayerStatus>, POINTER-slot elements,
-- default stride).
return {
    ["tournamentId"] = {
        offset = 0x18,
        type = "String"
    },
    ["sessionId"] = {
        offset = 0x20,
        type = "String"
    },
    ["remainingAttempts"] = {
        offset = 0x28,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
}
