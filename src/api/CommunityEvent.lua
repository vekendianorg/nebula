--==================================================
-- api/CommunityEvent.lua
--==================================================
-- Public-facing Nebula.CommunityEvent module.
--
-- CommunityShowcase (社区赛道) is bound to the SAME shared
-- EventDefinition struct as PublicEvent/TeamEvent (confirmed via
-- IL2CPP dump — see metadata/1.73/structs/EventDefinition.lua) through
-- Nebula.defineApi(). It is resolved differently (string search
-- rather than AOB) and only a subset of EventDefinition fields have
-- ever been populated for this event type in practice, but every
-- EventDefinition field is reachable here like any other API bound
-- to this struct — Nebula does not filter fields per event type.
--
-- Base resolution is unchanged: search for the ASCII bytes of
-- "community Showcase\0", validate with a vtable marker
-- (0x6D6F631E at hit-0x18), then extract the struct pointer at
-- hit-0x20. See core/Memory.lua's resolveActiveCommunityEventBase()
-- for the full flow.
--
--   Nebula.CommunityEvent.get("startTime")
--   Nebula.CommunityEvent.get("sessionEntry.entryFeeTickets")
--   Nebula.CommunityEvent.get("minRankToJoin")
--
--   local event = Nebula.CommunityEvent.get()
--   event.get("name")
--   event.get("sessionEntry.maxEventTickets")
--
--   Nebula.CommunityEvent.set("startTime", 1700000000)
--   Nebula.CommunityEvent.set("startTime", 1700000000):dry()

local Memory    = loadModule("core/Memory.lua")
local defineApi = loadModule("core/defineApi.lua")

return defineApi.create({
    struct  = "EventDefinition",
    resolve = Memory.resolveActiveCommunityEventBase,
})
