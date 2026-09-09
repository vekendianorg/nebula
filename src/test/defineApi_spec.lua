--==================================================
-- test/defineApi_spec.lua
--==================================================
-- Focused tests for:
--   - core/defineApi.lua  (API definition, struct binding, resolver
--                           invocation, delegation to existing
--                           struct/field/memory machinery)
--   - metadata/manifest.lua (version resolution)
--   - metadata/1.73/structs/EventDefinition.lua (complete metadata, loads
--                           through the generic version resolver)
--   - api/PublicEvent.lua, api/TeamEvent.lua, api/CommunityEvent.lua
--                           (bound to EventDefinition, real
--                           resolvers preserved)
--
-- IMPORTANT — test environment limitations (see final report):
-- This harness runs against a MOCKED `gg` (GameGuardian) global — a
-- fake, in-memory "process" implemented with a plain Lua table, not
-- a real device/emulator. That means:
--
--   - get()/set() round-trips below exercise the REAL
--     core/Type.lua, core/Repeated.lua, core/Struct.lua and
--     core/Memory.lua code paths — nothing about field
--     resolution/dispatch is faked.
--   - The REAL AOB/string-search resolvers in core/Memory.lua
--     (findPublicEventBases, findTeamEventBases,
--     findCommunityEventBases, resolveGameStatusBase) are NOT
--     exercised here, because they call gg.searchNumber/
--     gg.getRangesList against live process memory, which this
--     mock does not attempt to emulate. Faking a "successful" AOB
--     scan result would violate requirement #18 of the migration
--     spec, so instead these tests inject a trivial config.resolve
--     stub for defineApi()'s own tests, and separately assert
--     (without executing) that api/PublicEvent.lua,
--     api/TeamEvent.lua and api/CommunityEvent.lua still point at
--     the untouched, real Memory.resolveActive*Base functions.
--
-- Run with a Lua 5.3/5.4 interpreter from the src/ directory root
-- (adjust package.path as needed), e.g.:
--   lua5.4 test/defineApi_spec.lua
--
-- This file was NOT executed in the environment this migration was
-- prepared in (no Lua interpreter / GameGuardian runtime was
-- available there) — see the migration report's "Tests run"
-- section. Do not treat presence of this file as evidence the
-- suite passed.

--==================================================
-- Minimal mock of the pieces of `gg` Memory.lua/ZeroPage.lua touch
--==================================================

local fakeMemory = {} -- address -> raw value (flag-width packing is not modeled; sufficient for dispatch-level tests)

gg = {
    getValues = function(specs)
        local results = {}
        for i, spec in ipairs(specs) do
            results[i] = { value = fakeMemory[spec.address] or 0 }
        end
        return results
    end,
    setValues = function(specs)
        for _, spec in ipairs(specs) do
            fakeMemory[spec.address] = spec.value
        end
        return true
    end,
    getTargetInfo = function()
        return { versionName = MOCK_GAME_VERSION or "1.73.4", packageName = "test.pkg", pid = 1 }
    end,
    FILES_DIR = "/tmp",
    REGION_C_ALLOC = 1,
    REGION_OTHER = 2,
}

--==================================================
-- loadModule (same relative-path loader as main.lua, scoped to src/)
--==================================================

local scriptDir = (arg and arg[0] and arg[0]:match("(.*/)")) or "./"
local srcDir = scriptDir .. "../"
local _moduleCache = {}

function loadModule(name, soft)
    local path = srcDir .. name
    if _moduleCache[path] ~= nil then
        return _moduleCache[path]
    end
    local chunk, err = loadfile(path)
    if not chunk then
        if soft then return nil, err end
        error("Module load failed: " .. name .. "\n" .. tostring(err))
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

Nebula = { log = false, verbose = false }

--==================================================
-- Tiny assertion helper
--==================================================

local pass, fail = 0, 0
local function check(name, ok, detail)
    if ok then
        pass = pass + 1
        print("  [PASS] " .. name)
    else
        fail = fail + 1
        print("  [FAIL] " .. name .. (detail and (" — " .. tostring(detail)) or ""))
    end
end

--==================================================
-- metadata/manifest.lua — version resolution
--==================================================

print("=== manifest.lua: version resolution ===")
do
    local Manifest = loadModule("metadata/manifest.lua")

    -- exact metadata version
    local v = Manifest.resolveVersion("1.73")
    check("exact version resolves to itself", v == "1.73", v)

    -- patch-version fallback (game "1.73.9" truncates to "1.73")
    local parsed = Manifest.parseTwoComponent("1.73.9")
    check("patch component ignored in parsing", parsed[1] == 1 and parsed[2] == 73, parsed)

    -- closest applicable known version, with a synthetic multi-version list
    local realVersions = Manifest.VERSIONS
    Manifest.VERSIONS = { "1.70", "1.73", "1.80" }
    local closest = Manifest.resolveVersion("1.75")
    check("closest applicable version <= game version", closest == "1.73", closest)
    local exactMulti = Manifest.resolveVersion("1.80")
    check("closest version picks exact match when present", exactMulti == "1.80", exactMulti)
    local olderThanAll = Manifest.resolveVersion("1.60")
    check("older-than-everything falls back to oldest known", olderThanAll == "1.70", olderThanAll)
    Manifest.VERSIONS = realVersions -- restore for the rest of the suite

    -- behavior when no applicable metadata version exists at all
    local savedVersions = Manifest.VERSIONS
    Manifest.VERSIONS = {}
    local none, err = Manifest.resolveVersion("1.73")
    check("empty version list fails with an error, not a false success", none == nil and err ~= nil, err)
    Manifest.VERSIONS = savedVersions

    -- end-to-end resolve() through the mocked gg.getTargetInfo()
    MOCK_GAME_VERSION = "1.74.9"
    local metadata, version, resolveErr = Manifest.resolve("EventDefinition")
    check("resolve() picks best-available (1.73) for a newer unregistered patch", version == "1.73", version)
    check("resolve() returns loaded metadata table", type(metadata) == "table", metadata)
    MOCK_GAME_VERSION = nil
end

--==================================================
-- metadata/1.73/structs/EventDefinition.lua — complete metadata
--==================================================

print("=== EventDefinition/1.73.lua: complete metadata ===")
do
    local metadata = loadModule("metadata/1.73/structs/EventDefinition.lua")
    check("loads as a table", type(metadata) == "table")
    check("has 'id' (shared header field)", metadata.id ~= nil and metadata.id.offset == 0x8)
    check("has 'mainEventRewards' (reward-array field)", metadata.mainEventRewards ~= nil)
    check("has 'fixedVehicles' (PublicEvent-sourced field, not reduced away)", metadata.fixedVehicles ~= nil)
    check("has 'multiRaceGameModes' (TeamEvent-only field, unioned in)", metadata.multiRaceGameModes ~= nil)
    check("has 'winningTeamReward' (TeamEvent-only field, unioned in)", metadata.winningTeamReward ~= nil)
end

--==================================================
-- core/defineApi.lua — API definition / struct binding / resolver
-- invocation / delegation to existing struct machinery
--==================================================

print("=== core/defineApi.lua ===")
do
    local defineApi = loadModule("core/defineApi.lua")

    check("defineApi.create exists", type(defineApi.create) == "function")

    -- API definition creation + struct binding
    local resolveCalls = 0
    local FAKE_BASE = 0x100000
    local api = defineApi.create({
        struct = "EventDefinition",
        resolve = function()
            resolveCalls = resolveCalls + 1
            return FAKE_BASE
        end,
    })

    check("returned module has get/set/fields/meta/resolveBase", type(api.get) == "function"
        and type(api.set) == "function" and type(api.fields) == "function"
        and type(api.meta) == "function" and type(api.resolveBase) == "function")
    check("struct binding recorded", api.struct == "EventDefinition", api.struct)

    -- resolver invocation
    MOCK_GAME_VERSION = "1.73.0"
    local base = api.resolveBase()
    check("resolver invoked and its result used as base", base == FAKE_BASE and resolveCalls == 1, base)
    local base2 = api.resolveBase()
    check("resolveBase caches — resolver not called again without forceRescan", resolveCalls == 1 and base2 == FAKE_BASE)

    -- delegation to existing struct machinery: reading a normal
    -- scalar field ("id" is a String) and an Enum-bearing struct
    -- array field ("mainEventRewards"), and writing an arbitrary
    -- scalar field ("startTime").
    --
    -- Write startTime (Int32 @ offset 0x150 per EventDefinition/1.73.lua)
    local ok = api.set("startTime", 1700000000)
    check("set() on an arbitrary metadata-defined field succeeds", ok._ok == true, ok._err)
    local readBack = api.get("startTime")
    check("get() reads back what set() wrote (offsets/types from metadata)", readBack == 1700000000, readBack)

    -- Reading another metadata-defined field ("contentVersion", Int32 @ 0x0)
    local okCV = api.set("contentVersion", 5)
    check("set() on a second, different metadata field", okCV._ok == true, okCV._err)
    check("get() on that field", api.get("contentVersion") == 5, api.get("contentVersion"))

    -- fields() reflects the full EventDefinition surface, no filtering
    local ids = api.fields()
    local hasMainEventRewards = false
    for _, id in ipairs(ids) do
        if id == "mainEventRewards" then hasMainEventRewards = true end
    end
    check("fields() includes 'startTime'", (function()
        for _, id in ipairs(ids) do if id == "startTime" then return true end end
        return false
    end)())
    check("fields() includes offset-known nested fields (no per-API filtering)", hasMainEventRewards)

    MOCK_GAME_VERSION = nil
end

--==================================================
-- api/PublicEvent.lua, api/TeamEvent.lua, api/CommunityEvent.lua
--==================================================

print("=== event APIs: struct = EventDefinition, real resolvers preserved ===")
do
    local Memory = loadModule("core/Memory.lua")
    MOCK_GAME_VERSION = "1.73.0"

    local pub = loadModule("api/PublicEvent.lua")
    local team = loadModule("api/TeamEvent.lua")
    local community = loadModule("api/CommunityEvent.lua")

    check("PublicEvent bound to EventDefinition", pub.struct == "EventDefinition")
    check("TeamEvent bound to EventDefinition", team.struct == "EventDefinition")
    check("CommunityEvent bound to EventDefinition", community.struct == "EventDefinition")

    -- Confirm each API's configured resolver IS the real, untouched
    -- Memory.resolveActive*Base function — a direct identity check,
    -- not an execution (executing it would require real AOB/
    -- string-search results against live device memory, which this
    -- mock does not attempt to fake — see file header).
    check("PublicEvent.resolve is the real, unreplaced resolveActivePublicEventBase",
        pub._resolve == Memory.resolveActivePublicEventBase)
    check("TeamEvent.resolve is the real, unreplaced resolveActiveTeamEventBase",
        team._resolve == Memory.resolveActiveTeamEventBase)
    check("CommunityEvent.resolve is the real, unreplaced resolveActiveCommunityEventBase",
        community._resolve == Memory.resolveActiveCommunityEventBase)

    MOCK_GAME_VERSION = nil
end

--==================================================
-- Summary
--==================================================

print("")
print(string.format("=== %d passed, %d failed ===", pass, fail))
if fail > 0 then
    os.exit(1)
end
