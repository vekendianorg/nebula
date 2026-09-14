--==================================================
-- metadata/1.74/KickedTeamStatus.lua
--==================================================

-- Snapshot for the KickedTeamStatus submessage — the singular member
-- GameStatus.kickedTeamStatus @0x4C0 (POINTER, deref'd via Object).

return {
    ["teamEventId"] = {
        offset = 0x18,
        type = "String"
    },
    ["teamId"] = {
        offset = 0x20,
        type = "String"
    },
    ["sessionId"] = {
        offset = 0x28,
        type = "String"
    },
    ["teamTicketsRefillTime"] = {
        offset = 0x30,
        type = "Int32"
    },
}
