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
-- root. It strips the loader block below and replaces it with a
-- VFS-aware loader backed by an embedded __vfs table, so the
-- exact same require-style calls in every module keep working
-- with zero edits.
--
--==================================================
-- Host-script contract (encapsulation)
--==================================================
-- Nebula is a guest in the host script's environment:
--
--   * The ONLY global Nebula ever writes is the exported `Nebula`
--     table itself. No `scriptDir`, no `loadModule`, no `__vfs`.
--   * The export is merge-tolerant: if the host already has a
--     Nebula table, it is adopted as-is. The host's keys survive;
--     the SDK only fills in its own reserved keys.
--   * Config keys (log, verbose, traceMem, embed) are
--     read-honored: a host may pre-set them BEFORE loading and
--     Nebula will not overwrite the host's values.
--   * Modules run inside a private environment: they can READ the
--     host's globals (gg, print, io, ...) but their `scriptDir` /
--     `loadModule` / `Nebula` accesses resolve to Nebula's own
--     private entries — the host's identically-named globals are
--     neither visible to modules nor touched by them.
--   * Failure semantics: when a module cannot be loaded, the
--     standalone default alerts the user and exits (the SDK cannot
--     work without its modules). A host embedding Nebula sets
--     `Nebula = { embed = true }` before loading: failures then
--     raise a catchable Lua error instead of killing the host
--     script.

--==================================================
-- Encapsulated module loader
--==================================================
-- Everything from the banner down to `local loadModule =
-- ENV.loadModule` is one self-contained block. bundle.py strips it
-- in packed builds and provides an equivalent VFS-backed prologue —
-- nothing below the block may reference its internals.

-- Private module environment. Reads fall through to the host's
-- globals; `scriptDir` / `loadModule` / `Nebula` live HERE, never
-- in the host's namespace.
local ENV = setmetatable({
    scriptDir = gg.getFile():match("(.*/)") or "",
}, { __index = _G })

local _moduleCache = {}

function ENV.loadModule(name, soft)
    local path = ENV.scriptDir .. name
    if _moduleCache[path] ~= nil then
        return _moduleCache[path]
    end
    local chunk, err = loadfile(path, "t", ENV)
    if not chunk then
        if soft then return nil, err end
        -- Failure semantics: embed mode raises a catchable error;
        -- standalone mode alerts the user and exits. ENV.Nebula is
        -- seeded by the wiring below before the first hard load,
        -- so the embed flag is readable here.
        local n = ENV.Nebula
        if n and n.embed then
            error("Module load failed: " .. name .. ": " .. tostring(err), 0)
        end
        gg.alert("Module load failed: " .. name .. "\n" .. tostring(err))
        os.exit()
        return nil -- unreachable in GG; keeps mock runners deterministic
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

local loadModule = ENV.loadModule

--==================================================
-- Nebula wiring
--==================================================

-- The single deliberate global write. Merge-tolerant: adopts the
-- host's pre-existing table (pre-config, embed flag) instead of
-- replacing it.
Nebula = Nebula or {}

-- The SDK's private view of the same exported table.
ENV.Nebula = Nebula

-- Global logging switch. No per-operation :log() — see api/PlayerInfo.lua.
-- Read-honored: a host that pre-set Nebula.log keeps its value.
Nebula.log = Nebula.log or false

-- Verbose, timed logging for every gg.getValues/setValues round-trip
-- — see core/Memory.lua's vlog(). Flip to true to see exactly where
-- time is going: number of calls, batch sizes, per-call duration.
Nebula.verbose = Nebula.verbose or false

-- Raw memory-I/O trace — see core/Memory.lua's memtrace(). Flip to
-- true (best together with Nebula.log) to dump EVERY address read
-- or written with its raw value:
--   [Memory] [read]  addr=0x7A00000100 flags=32/INT64 -> 155640572816 (0x244C60410)
--   [Memory] [write] addr=0x7A00000108 flags=4/INT32 <- 42
-- Cross-check any line directly in GG's memory viewer. Very noisy —
-- leave off unless actively debugging.
Nebula.traceMem = Nebula.traceMem or false

-- While Nebula.log is true, all diagnostics go to nebula.log next to
-- the script instead of the console — every line written and flushed
-- immediately, full trace, survives a crash. No config: if the file
-- can't be opened, lines fall back to the old console print.
-- See core/Logfile.lua.

Nebula.PlayerInfo = loadModule("api/PlayerInfo.lua")
Nebula.GameData   = loadModule("api/GameData.lua")

-- PlayerInfo is the parent object of the player's save data. There
-- is no separate GameStatus module: the save struct is PlayerInfo's
-- child (mGameStatus @0x148, see
-- metadata/<version>/structs/PlayerInfo.lua) and is reachable as a
-- dotted path — Nebula.PlayerInfo.get("gameStatus.coins"),
-- Nebula.PlayerInfo.get("gameStatus.playerName"), etc.

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

Nebula.VERSION = "1.0.0"

return Nebula
