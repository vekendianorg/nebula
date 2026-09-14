--==================================================
-- test/encapsulation_spec.lua
--==================================================
-- Host-script contract spec. Nebula must be an invisible guest in
-- the host script's environment:
--
--   * the ONLY global it ever writes is the exported `Nebula`
--     table (merge-tolerant, host keys preserved)
--   * config keys (log, verbose, traceMem) are read-honored
--   * modules run in a private environment: the host's
--     scriptDir / loadModule / identically-named globals are
--     neither visible to modules nor touched by them
--   * failure semantics: standalone alerts + exits, embed mode
--     raises a catchable error instead of killing the host
--   * the PACKED artifact writes exactly one global (Nebula)
--
-- Run from src/ on plain Lua 5.4+: lua test/encapsulation_spec.lua
-- The packed-artifact section expects the bundle pre-built:
--   python3 bundle.py -o /tmp/nebula_enc_packed.lua

local passed, failed = 0, 0
local function check(name, ok, extra)
    if ok then
        passed = passed + 1
        print(("  [PASS] %s"):format(name))
    else
        failed = failed + 1
        print(("  [FAIL] %s — %s"):format(name, tostring(extra)))
    end
end

--==================================================
-- gg mock + byte memory (compact, same shape as the other specs)
--==================================================

local mem = {}
local FLAGS = { BYTE = 1, INT32 = 4, INT64 = 32 }
local PI_BASE = 0x5000040000

local function w32(addr, v)
    v = v & 0xFFFFFFFF
    for i = 0, 3 do mem[addr + i] = (v >> (i * 8)) & 0xFF end
end

gg = {
    getValues = function(items)
        for _, it in ipairs(items) do
            local v = 0
            for i = 0, 3 do
                v = v | ((mem[it.address + i] or 0) << (i * 8))
            end
            it.value = v
        end
        return items
    end,
    setValues = function(items)
        for _, it in ipairs(items) do
            if it.flags == FLAGS.INT64 then
                local v = it.value
                for i = 0, 7 do mem[it.address + i] = (v >> (i * 8)) & 0xFF end
            else
                w32(it.address, it.value)
            end
        end
    end,
    alert = function() gg.alerted = (gg.alerted or 0) + 1 end,
    getTargetInfo = function()
        return { versionName = "1.73.4", packageName = "test.pkg", pid = 1 }
    end,
    getRangesList = function()
        -- One safe zero region for ZeroPage; everything defaults to 0.
        return { { start = 0x7000000000, ["end"] = 0x7000002000, state = "O", type = "rw-p", name = "", internalName = "" } }
    end,
    FILES_DIR = "/tmp",
    REGION_C_ALLOC = 1,
    REGION_OTHER = 2,
}

--==================================================
-- Section 1: dev loader vs a hostile host environment
--==================================================
print("=== dev loader: hostile host globals survive a full load ===")
do
    local scriptDir = (arg and arg[0] and arg[0]:match("(.*/)")) or "./"
    local mainPath = scriptDir .. "../main.lua"

    -- main.lua calls gg.getFile exactly ONCE (entry-point env
    -- construction). Any further call means a module reached for
    -- the host's globals instead of its private environment.
    local getFileCalls = 0
    gg.getFile = function()
        getFileCalls = getFileCalls + 1
        if getFileCalls > 1 then
            error("gg.getFile called from a module — must use ENV.scriptDir")
        end
        return scriptDir .. "../main.lua"
    end

    -- io.open interception: record every path Logfile resolves.
    -- nebula.log opens get a fake handle (recorded, swallowed) so
    -- the spec never writes a real log file into src/.
    local openedPaths = {}
    local realOpen = io.open
    io.open = function(path, mode)
        openedPaths[#openedPaths + 1] = tostring(path)
        if tostring(path):find("nebula%.log$") then
            local fh = {}
            fh.write = function() return fh end
            fh.flush = function() return true end
            fh.close = function() return true end
            return fh
        end
        return realOpen(path, mode)
    end

    -- Hostile host environment: sentinels everywhere Nebula used
    -- to write, plus a host-owned Nebula table with config.
    _G.scriptDir = "HOST_SENTINEL_DIR/"
    _G.loadModule = function() error("host loadModule must never be called") end
    _G.__vfs = "HOST_SENTINEL_VFS"
    _G.Nebula = {
        hostKey = "host-value",
        log = true,          -- read-honored pre-config
        verbose = true,
    }

    -- Global-count snapshot: after the load NOTHING new may exist.
    local before = {}
    for k in pairs(_G) do before[k] = true end

    local chunk = assert(loadfile(mainPath, "t", _G))
    local ok, ret = pcall(chunk)

    check("main.lua loads cleanly against hostile host globals",
        ok == true, tostring(ret))
    check("main.lua returns the exported Nebula table",
        ok == true and ret == _G.Nebula, tostring(ret))

    check("host scriptDir sentinel untouched",
        _G.scriptDir == "HOST_SENTINEL_DIR/", tostring(_G.scriptDir))
    check("host loadModule sentinel untouched (and never called)",
        type(_G.loadModule) == "function", tostring(_G.loadModule))
    check("no __vfs global leaked",
        _G.__vfs == "HOST_SENTINEL_VFS", tostring(_G.__vfs))
    check("host Nebula table adopted (identity preserved)",
        _G.Nebula.hostKey == "host-value", tostring(_G.Nebula.hostKey))
    check("host pre-set Nebula.log honored (read-honored config)",
        _G.Nebula.log == true, tostring(_G.Nebula.log))
    check("host pre-set Nebula.verbose honored",
        _G.Nebula.verbose == true, tostring(_G.Nebula.verbose))

    check("SDK wired: PlayerInfo", _G.Nebula.PlayerInfo ~= nil, "nil")
    check("SDK wired: GameData", _G.Nebula.GameData ~= nil, "nil")
    check("SDK wired: PublicEvent", _G.Nebula.PublicEvent ~= nil, "nil")
    check("SDK wired: Memory", _G.Nebula.Memory ~= nil, "nil")
    check("SDK wired: Cache", _G.Nebula.Cache ~= nil, "nil")
    check("SDK wired: VERSION", _G.Nebula.VERSION == "1.0.0",
        tostring(_G.Nebula.VERSION))

    local leaked = {}
    for k in pairs(_G) do
        if not before[k] then leaked[#leaked + 1] = k end
    end
    check("ZERO new globals after a full SDK load",
        #leaked == 0, table.concat(leaked, ", "))

    check("gg.getFile called exactly once (entry point only)",
        getFileCalls == 1, tostring(getFileCalls))

    -- Full-stack behavior under encapsulation: a real read through
    -- the private environment, logging through the private sink.
    local Memory = _G.Nebula.Memory
    local realResolve = Memory.resolvePlayerInfoBase
    Memory.resolvePlayerInfoBase = function() return { PI_BASE }, nil end
    w32(PI_BASE + 0xC8, 42)
    local v = _G.Nebula.PlayerInfo.get("startupCount")
    check("read round-trip works through the private env",
        v == 42, tostring(v))
    Memory.resolvePlayerInfoBase = realResolve

    local sinkSeen = false
    for _, p in ipairs(openedPaths) do
        if p:find("nebula%.log$") then
            sinkSeen = true
            check("Logfile sink resolved from ENV.scriptDir, not the host's",
                p ~= "HOST_SENTINEL_DIR/nebula.log"
                    and p:find("HOST_SENTINEL", 1, true) == nil,
                p)
        end
    end
    check("log lines reached a sink (Nebula.log=true honored end-to-end)",
        sinkSeen, "no nebula.log open recorded")

    io.open = realOpen
end

--==================================================
-- Section 2: failure semantics
--==================================================
print("=== failure semantics: standalone exit vs embed error ===")
do
    local scriptDir = (arg and arg[0] and arg[0]:match("(.*/)")) or "./"
    local mainPath = scriptDir .. "../main.lua"

    -- sabotage: point the loader at a nonexistent directory
    gg.getFile = function() return "/nonexistent_dir/main.lua" end

    local realExit = os.exit
    local exited = false
    os.exit = function() exited = true end
    gg.alerted = 0

    -- (a) standalone default: alert + exit, host globals untouched
    _G.Nebula = nil
    local chunk = assert(loadfile(mainPath, "t", _G))
    local ok = pcall(chunk)
    check("standalone: gg.alert fired on module-load failure",
        (gg.alerted or 0) >= 1, tostring(gg.alerted))
    check("standalone: os.exit reached", exited == true, tostring(exited))
    check("standalone: if anything raised at all, it raised only AFTER alert+exit",
        (gg.alerted or 0) >= 1 and exited == true,
        tostring(ok) .. " alerted=" .. tostring(gg.alerted))
    check("standalone: host scriptDir still untouched",
        _G.scriptDir == "HOST_SENTINEL_DIR/", tostring(_G.scriptDir))

    -- (b) embed mode: catchable error, NO alert, NO exit
    gg.alerted = 0
    exited = false
    _G.Nebula = { embed = true }
    local chunk2 = assert(loadfile(mainPath, "t", _G))
    local ok2, err2 = pcall(chunk2)
    check("embed: module-load failure raises a catchable error",
        ok2 == false, tostring(ok2))
    check("embed: error names the failing module",
        ok2 == false and tostring(err2):find("Module load failed", 1, true) ~= nil,
        tostring(err2))
    check("embed: gg.alert NOT fired",
        (gg.alerted or 0) == 0, tostring(gg.alerted))
    check("embed: os.exit NOT called", exited == false, tostring(exited))
    check("embed: host scriptDir still untouched",
        _G.scriptDir == "HOST_SENTINEL_DIR/", tostring(_G.scriptDir))

    os.exit = realExit
end

--==================================================
-- Section 3: the packed artifact
--==================================================
print("=== packed artifact: exactly one global write ===")
do
    _G.Nebula = nil -- drop Section 2's leftovers: packed runs fresh
    local packedPath = "/tmp/nebula_enc_packed.lua"
    local f = io.open(packedPath, "r")
    if not f then
        print("  [SKIP] packed artifact not found — build it first:")
        print("         python3 bundle.py -o /tmp/nebula_enc_packed.lua")
    else
        f:close()

        gg.getFile = function() return "/packed_run/main.lua" end
        gg.alerted = 0

        -- Proxy environment: records every global the packed chunk
        -- writes. It hides any pre-existing global Nebula so the
        -- chunk must create its own.
        local writes = {}
        local proxy = setmetatable({}, {
            __index = function(_, k)
                if k == "Nebula" then return nil end
                return _G[k]
            end,
            __newindex = function(t, k, v)
                rawset(t, k, v)
                writes[k] = true
            end,
        })

        local chunk = assert(loadfile(packedPath, "t", proxy))
        local ok, ret = pcall(chunk)

        check("packed chunk runs cleanly in a fresh proxy env",
            ok == true, tostring(ret))
        local n = 0
        for _ in pairs(writes) do n = n + 1 end
        check("packed artifact writes EXACTLY ONE global (Nebula)",
            n == 1 and writes.Nebula == true,
            table.concat((function()
                local ks = {}
                for k in pairs(writes) do ks[#ks + 1] = k end
                return ks
            end)(), ", "))
        check("packed export lands in the proxy, not the real _G",
            rawget(proxy, "Nebula") ~= nil and _G.Nebula == nil,
            tostring(_G.Nebula))

        local pn = rawget(proxy, "Nebula")
        check("packed: SDK fully wired (PlayerInfo)",
            pn and pn.PlayerInfo ~= nil, "nil")
        check("packed: SDK fully wired (GameData)",
            pn and pn.GameData ~= nil, "nil")
        check("packed: SDK fully wired (Memory)",
            pn and pn.Memory ~= nil, "nil")
        check("packed: VERSION present",
            pn and pn.VERSION == "1.0.0", tostring(pn and pn.VERSION))
        check("packed chunk returns the exported table",
            ok == true and ret == pn, tostring(ret))

        -- full-stack read through the packed artifact
        local Memory = pn.Memory
        local realResolve = Memory.resolvePlayerInfoBase
        Memory.resolvePlayerInfoBase = function() return { PI_BASE }, nil end
        w32(PI_BASE + 0xC8, 42)
        local v = pn.PlayerInfo.get("startupCount")
        check("packed: read round-trip works",
            v == 42, tostring(v))
        Memory.resolvePlayerInfoBase = realResolve

        -- (b) host pre-config adoption on the packed artifact
        local proxy2 = setmetatable({}, {
            __index = function(_, k) return _G[k] end,
        })
        rawset(proxy2, "Nebula", { hostKey = "h2", log = true })
        local chunk2 = assert(loadfile(packedPath, "t", proxy2))
        local ok2 = pcall(chunk2)
        local pn2 = rawget(proxy2, "Nebula")
        check("packed: host Nebula table adopted",
            ok2 == true and pn2.hostKey == "h2",
            tostring(pn2 and pn2.hostKey))
        check("packed: host pre-set config honored",
            pn2 and pn2.log == true, tostring(pn2 and pn2.log))
    end
end

print()
print(("=== %d passed, %d failed ==="):format(passed, failed))
if failed > 0 then os.exit(1) end
