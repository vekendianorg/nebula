--==================================================
-- api/PublicEvent.lua
--==================================================
-- Public-facing Nebula.PublicEvent module.
--
-- Bound to the shared EventDefinition struct (see
-- metadata/1.73/structs/EventDefinition.lua, the single authoritative field
-- layout) through Nebula.defineApi() — see core/defineApi.lua for
-- the generic get/set/fields/meta implementation and automatic
-- metadata version resolution. Every EventDefinition field is
-- reachable here, not just the ones PublicEvent's own gameplay
-- currently uses.
--
-- Base resolution is unchanged: whichever PublicEvent struct is
-- currently active, found via the existing byte-signature scan —
-- see core/Memory.lua's resolveActivePublicEventBase().
--
--   Nebula.PublicEvent.get("startTime")
--   Nebula.PublicEvent.get("gameMode.duration")
--   Nebula.PublicEvent.get("eventRewards")
--
--   local event = Nebula.PublicEvent.get()
--   event.get("minTeamSizeToJoin")
--   event.get("sessionEntry.numberOfParallelSessions")
--
--   Nebula.PublicEvent.set("eventRewards", {
--       [1] = { rewardCondition = { criteria = 0 },
--               maxCollectAmount = -1 }
--   })
--   Nebula.PublicEvent.set("startTime", 1700000000)
--   Nebula.PublicEvent.set("startTime", 1700000000):dry()

local Memory    = loadModule("core/Memory.lua")
local defineApi = loadModule("core/defineApi.lua")

return defineApi.create({
    struct  = "EventDefinition",
    name    = "PublicEvent", -- log label: [PublicEvent]/[TeamEvent]/[CommunityEvent] trace lines
    resolve = Memory.resolveActivePublicEventBase,
})
