--==================================================
-- main.lua
--==================================================
-- Nebula SDK entry point.
--
-- Unpacked (dev) use: run this file directly with GG's script
-- loader; loadModule() below resolves modules from disk relative
-- to this file.
--
-- Packed (release) use: run `python bundle.py` from the project
-- root. It strips the block below and replaces it with a
-- VFS-aware loadModule() backed by an embedded __vfs table, so
-- the exact same require-style calls in every module keep working
-- with zero edits.

local scriptDir = gg.getFile():match("(.*/)") or ""
local _moduleCache = {}

function loadModule(name, soft)
    local path = scriptDir .. name
    if _moduleCache[path] ~= nil then
        return _moduleCache[path]
    end
    local chunk, err = loadfile(path)
    if not chunk then
        if soft then return nil, err end
        gg.alert("Module load failed: " .. name .. "\n" .. tostring(err))
        os.exit()
    end
    if soft then
        local results = table.pack(pcall(chunk))
        if not results[1] then return nil, results[2] end
        _moduleCache[path] = table.unpack(results, 2, results.n)
        return _moduleCache[path]
    end
    _moduleCache[path] = chunk()
    return _moduleCache[path]
end

--==================================================
-- Nebula wiring
--==================================================

Nebula = Nebula or {}

-- Global logging switch. No per-operation :log() — see api/GameStatus.lua.
Nebula.log = false

-- Verbose, timed logging for every gg.getValues/setValues round-trip
-- — see core/Memory.lua's vlog(). Flip to true to see exactly where
-- time is going: number of calls, batch sizes, per-call duration.
Nebula.verbose = false

Nebula.GameStatus = loadModule("api/GameStatus.lua")

-- Generic API-to-struct bridge. See core/defineApi.lua and
-- metadata/manifest.lua. PublicEvent/TeamEvent/CommunityEvent below
-- are all thin defineApi() configs bound to the single shared
-- EventDefinition struct (metadata/1.73/structs/EventDefinition.lua) — no
-- per-event field definitions, no field filtering.
Nebula.defineApi = loadModule("core/defineApi.lua").create

-- PublicEvent, TeamEvent, and CommunityEvent (CommunityShowcase) are
-- three different in-game event types, each with its own base
-- address resolver (AOB scan or string search — see
-- core/Memory.lua), but all three share the same physical
-- EventDefinition struct and therefore the same metadata.
Nebula.PublicEvent     = loadModule("api/PublicEvent.lua")
Nebula.TeamEvent       = loadModule("api/TeamEvent.lua")
Nebula.CommunityEvent  = loadModule("api/CommunityEvent.lua")

-- Expose the type registry and Memory layer for advanced/extension
-- use (e.g. a consumer registering a custom type via
-- Nebula.Type.register("MyType", impl)).
Nebula.Type   = loadModule("core/Type.lua")
Nebula.Memory = loadModule("core/Memory.lua")

-- Persistent address cache for event resolution. Used internally
-- by Memory.lua's resolveActiveTeamEventBase/resolveActivePublicEventBase/
-- resolveActiveCommunityEventBase to preserve discovered addresses
-- across signature modifications.
Nebula.Cache   = loadModule("core/Cache.lua")

Nebula.VERSION = "0.1.0"

return Nebula
