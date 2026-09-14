--==================================================
-- api/TeamEvent.lua
--==================================================
-- Public-facing Nebula.TeamEvent module.
--
-- Bound to the shared EventDefinition struct (see
-- metadata/1.73/structs/EventDefinition.lua) through Nebula.defineApi() —
-- same struct, same metadata, same field set as Nebula.PublicEvent
-- and Nebula.CommunityEvent. See core/defineApi.lua.
--
-- Base resolution is unchanged and TeamEvent-specific: unlike
-- GameStatus's single fixed struct, several TeamEvent structs can
-- exist in memory at once (past/current/upcoming), so
-- resolveActiveTeamEventBase() picks out whichever one is currently
-- active. See core/Memory.lua for the byte-signature scan.
--
--   Nebula.TeamEvent.get("startTime")
--   Nebula.TeamEvent.get("sessionEntry.entryFeeTickets")
--   Nebula.TeamEvent.get("eventRewards")
--
--   local event = Nebula.TeamEvent.get()
--   event.get("minTeamSizeToJoin")
--   event.get("sessionEntry.numberOfParallelSessions")
--
--   Nebula.TeamEvent.set("eventRewards", {
--       [1] = { rewardCondition = { criteria = 0 },
--               maxCollectAmount = -1 }
--   })
--   Nebula.TeamEvent.set("startTime", 1700000000):dry()

local Memory    = loadModule("core/Memory.lua")
local defineApi = loadModule("core/defineApi.lua")

return defineApi.create({
    struct  = "EventDefinition",
    name    = "TeamEvent", -- log label: [PublicEvent]/[TeamEvent]/[CommunityEvent] trace lines
    resolve = Memory.resolveActiveTeamEventBase,
})
