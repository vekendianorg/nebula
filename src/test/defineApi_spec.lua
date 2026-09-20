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
--     findCommunityEventBases, resolvePlayerInfoBase) are NOT
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
    -- modules must resolve paths from the ENV scriptDir, never
    -- gg.getFile — a call here fails the spec loudly
    getFile = function()
        error("gg.getFile called — use the ENV scriptDir instead")
    end,
}

--==================================================
-- loadModule (same relative-path loader as main.lua, scoped to src/)
--==================================================

-- Encapsulated loader — the same private-env pattern as main.lua.
-- The spec drives Nebula the way a host script does: modules live
-- in a private environment whose reads fall through to the host
-- globals. scriptDir / loadModule / Nebula are ENVIRONMENT
-- entries, never _G pollution.
local scriptDir = (arg and arg[0] and arg[0]:match("(.*/)")) or "./"
local srcDir = scriptDir .. "../"
local ENV = setmetatable({ scriptDir = srcDir }, { __index = _G })
local _moduleCache = {}

function ENV.loadModule(name, soft)
    local path = ENV.scriptDir .. name
    if _moduleCache[path] ~= nil then
        return _moduleCache[path]
    end
    local chunk, err = loadfile(path, "t", ENV)
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

local loadModule = ENV.loadModule

Nebula = { log = false, verbose = false }
ENV.Nebula = Nebula

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
    -- 1.74 is registered now (manifest VERSIONS = {"1.73","1.74"}), so
    -- a 1.74.x game picks 1.74; only a patch beyond BOTH registered
    -- versions falls back to the newest registered one.
    MOCK_GAME_VERSION = "1.74.9"
    local metadata, version, resolveErr = Manifest.resolve("EventDefinition")
    check("resolve() picks exact registered 1.74 for a 1.74.x game", version == "1.74", version)
    MOCK_GAME_VERSION = "1.99.9"
    local _, fallbackVersion = Manifest.resolve("EventDefinition")
    check("resolve() picks best-available (1.74) for a newer unregistered patch", fallbackVersion == "1.74", fallbackVersion)
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
-- eventRewards: metadata node + PublicEvent editable path
--==================================================
-- Proves the first-class editable reward path end-to-end against the
-- REAL EventDefinition metadata (both registered versions):
--   * the metadata node exists (offset 0x528, Array, ConditionalReward-
--     Definition elements) in 1.73 AND 1.74
--   * fields()/meta() expose it through the normal dotted-path interface
--   * get("eventRewards"), get("eventRewards[1]"), nested indexed reads
--   * set() by nested path, whole element-struct (partial, edit-in-place),
--     and whole-array rewrite all route through the normal set() path
-- Same EventDefinition metadata backs TeamEvent/CommunityEvent (checked
-- above); nothing here changes their wiring.
--==================================================

print("=== eventRewards: metadata node + editable path ===")
do
    local defineApi = loadModule("core/defineApi.lua")
    local Manifest = loadModule("metadata/manifest.lua")

    -- (1) metadata node shape in BOTH registered versions
    for _, v in ipairs({ "1.73.4", "1.74.2" }) do
        MOCK_GAME_VERSION = v
        local metadata, ver = Manifest.resolve("EventDefinition")
        local node = metadata and metadata.eventRewards
        check(v .. ": eventRewards node present", node ~= nil)
        check(v .. ": eventRewards offset 0x528, type Array",
            node ~= nil and node.offset == 0x528 and node.type == "Array")
        check(v .. ": elements = ConditionalRewardDefinition template",
            node ~= nil and type(node.elements) == "table"
            and node.elements.lootDefinition ~= nil
            and node.elements.lootDefinition.offset == 0x20
            and node.elements.lootDefinition.type == "Object")
        check(v .. ": rewardCondition is the Float criteria @0x4, maxCollectAmount @0x28",
            node ~= nil and node.elements.rewardCondition ~= nil
            and node.elements.rewardCondition.offset == 0x4
            and node.elements.rewardCondition.type == "Float"
            and node.elements.maxCollectAmount ~= nil
            and node.elements.maxCollectAmount.offset == 0x28)
    end

    -- (2) the editable path against the real metadata
    MOCK_GAME_VERSION = "1.73.4"
    local FB    = 0x100000
    local SLOTS = 0x200000
    local E1    = 0x300000
    local LOOT  = 0x400000
    -- std::vector header at FB+0x528 (defineApi's default ABI for
    -- EventDefinition arrays): begin/end/capEnd, 1 pointer-slot element
    fakeMemory[FB + 0x528] = SLOTS
    fakeMemory[FB + 0x530] = SLOTS + 0x8
    fakeMemory[FB + 0x538] = SLOTS + 0x8
    fakeMemory[SLOTS] = E1
    fakeMemory[E1 + 0x4] = 1.5        -- rewardCondition (float criteria)
    fakeMemory[E1 + 0x20] = LOOT      -- lootDefinition pointer
    fakeMemory[E1 + 0x28] = 100       -- maxCollectAmount
    fakeMemory[LOOT + 0x20] = 500     -- LootDefinition.coinAmount

    local api = defineApi.create({
        struct = "EventDefinition", name = "PublicEvent",
        resolve = function() return FB end,
    })

    local ids = api.fields()
    local hasEventRewards = false
    for _, id in ipairs(ids) do
        if id == "eventRewards" then hasEventRewards = true end
    end
    check("fields() includes 'eventRewards'", hasEventRewards)

    local m = api.meta("eventRewards")
    check("meta('eventRewards') reports offset/repeated/known/address",
        m ~= nil and m.offset == 0x528 and m.repeated == true
        and m.known == true and m.address == FB + 0x528,
        tostring(m and m.address))

    local rewards = api.get("eventRewards")
    check("get('eventRewards') decodes elements",
        type(rewards) == "table" and #rewards == 1,
        tostring(rewards and #rewards))
    check("element decodes maxCollectAmount",
        rewards and rewards[1] and rewards[1].maxCollectAmount == 100,
        tostring(rewards and rewards[1] and rewards[1].maxCollectAmount))
    check("element decodes nested lootDefinition field",
        rewards and rewards[1].lootDefinition ~= nil
        and rewards[1].lootDefinition.coinAmount == 500)

    local elem = api.get("eventRewards[1]")
    check("get('eventRewards[1]') returns the element table",
        type(elem) == "table" and elem.maxCollectAmount == 100,
        tostring(elem and elem.maxCollectAmount))

    local op = api.set("eventRewards[1].maxCollectAmount", 999)
    check("set('eventRewards[1].maxCollectAmount', 999) routes through set()",
        op._ok == true, tostring(op._err))
    check("indexed nested write landed",
        api.get("eventRewards[1].maxCollectAmount") == 999)

    local op2 = api.set("eventRewards[1]", { maxCollectAmount = 555 })
    check("whole element-struct set (partial) succeeds",
        op2._ok == true, tostring(op2._err))
    check("element write preserved rewardCondition (edit-in-place)",
        api.get("eventRewards[1].rewardCondition") == 1.5,
        tostring(api.get("eventRewards[1].rewardCondition")))
    check("element write landed",
        api.get("eventRewards[1].maxCollectAmount") == 555)

    local list = api.get("eventRewards")
    list[1].maxCollectAmount = 777
    local op3 = api.set("eventRewards", list)
    check("whole-array set('eventRewards', list) succeeds",
        op3._ok == true, tostring(op3._err))
    check("whole-array write landed",
        api.get("eventRewards[1].maxCollectAmount") == 777)
    check("slot pointer unchanged (no reallocation on same-size rewrite)",
        fakeMemory[SLOTS] == E1)

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
