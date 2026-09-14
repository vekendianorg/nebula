--==================================================
-- benchmark.lua
--==================================================
-- Host-script usage: pre-configure the SDK table, then load
-- main.lua. Nebula adopts this table, honors the config, and
-- writes no globals besides `Nebula` itself.
--
--   * `embed = true`  — module-load failures raise a catchable
--                        Lua error instead of alert + os.exit
--   * `log = true`     — full trace to nebula.log next to the script
--   * `verbose = true` — per-call memory timing
--   * `traceMem = true` — raw memory-I/O dump (very noisy)

Nebula = { embed = true, log = true, verbose = true, traceMem = true }

-- The host's OWN script dir (for the benchmark output file). The
-- SDK keeps its private copy in its module environment.
local scriptDir = gg.getFile():match("(.*/)") or ""

local chunk = loadfile(scriptDir .. "main.lua")
if not chunk then gg.alert("Cannot load main.lua") return end
local ok, err = pcall(chunk)
if not ok then gg.alert(tostring(err)) return end


-- Write results to file
local logFile = io.open(scriptDir .. "benchmark_output.log", "w")
local function log(msg)
    print(msg)
    if logFile then logFile:write(msg .. "\n") end
end

local function closeLog()
    if logFile then logFile:close() end
end

---------------------------------------------------------------------------
-- Timing helper
---------------------------------------------------------------------------
local function now()
    if os.clock then return os.clock() end
    return os.time()
end

local t0 = os.time()

---------------------------------------------------------------------------
-- Value preview
---------------------------------------------------------------------------
local MAX_DEPTH = 10
local ARRAY_SHOW = 999
local MAP_SHOW = 999

local function preview(v, depth)
    depth = depth or 0
    local t = type(v)
    if t == "string" then
        if #v > 80 then return ("%q..."):format(v:sub(1, 77)) end
        return ('"%s"'):format(v)
    end
    if t == "boolean" or t == "number" then return tostring(v) end
    if t ~= "table" then return ("<%s>"):format(t) end

    if depth >= MAX_DEPTH then return "{...}" end

    local n, maxI = 0, 0
    for _ in pairs(v) do n = n + 1 end
    for i in pairs(v) do
        if type(i) == "number" and i > maxI then maxI = i end
    end

    if n == 0 then return "{}" end

    local isArray = maxI == n
    local indent = string.rep("  ", depth + 1)

    if isArray then
        local parts = {}
        for i = 1, n do
            parts[i] = indent .. preview(v[i], depth + 1)
        end
        return "[\n" .. table.concat(parts, ",\n") .. "\n" .. string.rep("  ", depth) .. "]"
    end

    local parts, count = {}, 0
    for k, e in pairs(v) do
        count = count + 1
        if count > MAP_SHOW then
            parts[#parts + 1] = indent .. ("...(+%d more)"):format(n - MAP_SHOW)
            break
        end
        local key
        if type(k) == "string" and k:match("^[%a_][%w_]*$") then
            key = k .. " = "
        else
            key = ("[%s] = "):format(tostring(k))
        end
        parts[#parts + 1] = indent .. key .. preview(e, depth + 1)
    end
    return "{\n" .. table.concat(parts, ",\n") .. "\n" .. string.rep("  ", depth) .. "}"
end

--------------------------------------------------------------------------
-- Modules under test
--------------------------------------------------------------------------
local MODULES = {
    { name = "PlayerInfo",    mod = Nebula.PlayerInfo,
      skip = {
        ["countryCode"] = true, -- pointer to a heap wrapper, not a
                                -- readable string yet (see
                                -- metadata 1.74 PlayerInfo.lua)
      } },
    { name = "GameData",      mod = Nebula.GameData },
    { name = "PublicEvent",   mod = Nebula.PublicEvent },
    { name = "TeamEvent",     mod = Nebula.TeamEvent },
    { name = "CommunityEvent", mod = Nebula.CommunityEvent },
}

--------------------------------------------------------------------------
-- Per-module benchmark: enumerate every field, time each get()
--
-- Two passes per module:
--   COLD  - first read of each field (includes any pointer chasing,
--           gg memory reads, string decoding)
--   WARM  - second read (base addresses / repeated fields are cached
--           by core/Cache.lua, so this isolates raw read cost)
--------------------------------------------------------------------------
local function benchModule(m)
    local name, mod = m.name, m.mod
    log("")
    log(("=== %s ==="):format(name))

    local ids = mod.fields()
    if not ids or #ids == 0 then
        log("  (no fields returned by fields())")
        return nil
    end
    if m.skip then
        local kept = {}
        for _, id in ipairs(ids) do
            if not m.skip[id] then kept[#kept + 1] = id end
        end
        log(("  fields: %d (%d excluded by skip list)")
            :format(#kept, #ids - #kept))
        ids = kept
    else
        log(("  fields: %d"):format(#ids))
    end

    -- Resolve the base once up front and time it, so the first field
    -- read isn't polluted by resolve cost. If resolution fails (e.g.
    -- no event struct currently active in memory), SKIP this module's
    -- field passes entirely — otherwise every get() would trigger
    -- another full-memory scan.
    local baseMs, baseOk, baseErr
    if mod.resolveBase then
        local t = now()
        local okB, addrOrErr = pcall(mod.resolveBase)
        baseMs = (now() - t) * 1000
        baseOk = okB and addrOrErr ~= nil
        if not baseOk then
            baseErr = okB and "base_not_found" or tostring(addrOrErr)
        end
        log(("  resolveBase: %s (%.3f ms)%s"):format(
            baseOk and "ok" or ("FAILED: " .. tostring(baseErr)), baseMs,
            baseOk and "" or "  -- skipping field passes"))
    end

    if mod.resolveBase and not baseOk then
        return { name = name, n = #ids, skipped = true, err = baseErr }
    end

    local function pass(label)
        local rows = {}
        local total, okCount, failCount = 0, 0, 0
        for i, id in ipairs(ids) do
            local t = now()
            local ok, v = pcall(mod.get, id)
            local ms = (now() - t) * 1000
            total = total + ms
            if ok then okCount = okCount + 1 else failCount = failCount + 1 end
            rows[i] = {
                id = id, ms = ms, ok = ok,
                val = ok and v,  -- keep false; don't use "or nil" which drops false
                err = ok and nil or tostring(v),
            }
        end
        return rows, total, okCount, failCount
    end

    local coldRows, coldTotal, coldOk, coldFail = pass("cold")
    local warmRows, warmTotal, warmOk, warmFail = pass("warm")

    -- Per-field detail: id, cold/warm timing, and the fetched value
    -- rendered compactly (scalars inline, tables as {k=v, ...} with
    -- depth/width limits so huge arrays stay readable).
    for i, id in ipairs(ids) do
        local c, w = coldRows[i], warmRows[i]
        if c.ok then
            log(("    %-55s cold %8.3f  warm %8.3f ms  = %s")
                :format(id, c.ms, w.ms, preview(c.val)))
        else
            log(("    %-55s cold %8.3f  warm %8.3f ms  ERR: %s")
                :format(id, c.ms, w.ms, tostring(c.err):sub(1, 60)))
        end
    end

    -- Summary stats
    local coldMin, coldMax, coldMaxId = math.huge, 0, "-"
    for _, r in ipairs(coldRows) do
        if r.ms < coldMin then coldMin = r.ms end
        if r.ms > coldMax then coldMax, coldMaxId = r.ms, r.id end
    end

    log(("  COLD: total %.3f ms  avg %.3f ms  min %.3f ms  max %.3f ms (%s)  ok %d  fail %d")
        :format(coldTotal, coldTotal / #ids, coldMin, coldMax, coldMaxId, coldOk, coldFail))
    log(("  WARM: total %.3f ms  avg %.3f ms  (base + repeated fields cached)")
        :format(warmTotal, warmTotal / #ids))
    if coldTotal > 0 then
        log(("  cache effect: %.1fx faster on warm reads")
            :format(coldTotal / math.max(warmTotal, 1e-9)))
    end

    return {
        name = name, n = #ids, baseMs = baseMs,
        coldTotal = coldTotal, coldAvg = coldTotal / #ids,
        coldMax = coldMax, coldMaxId = coldMaxId,
        warmTotal = warmTotal, warmAvg = warmTotal / #ids,
        coldRows = coldRows,
    }
end

--------------------------------------------------------------------------
-- Run all modules
--------------------------------------------------------------------------
local results = {}
for _, m in ipairs(MODULES) do
    results[#results + 1] = benchModule(m)
end

--------------------------------------------------------------------------
-- Overall report
--------------------------------------------------------------------------
log("")
log("=== OVERALL ===")
local allCold, allWarm, allFields = 0, 0, 0
for _, r in ipairs(results) do
    if r then
        if r.skipped then
            log(("  %-15s SKIPPED — base not resolved (%s)")
                :format(r.name, tostring(r.err)))
        else
            allCold = allCold + r.coldTotal
            allWarm = allWarm + r.warmTotal
            allFields = allFields + r.n
            log(("  %-15s %3d fields  cold %9.3f ms (avg %.3f)  warm %9.3f ms (avg %.3f)")
                :format(r.name, r.n, r.coldTotal, r.coldAvg, r.warmTotal, r.warmAvg))
        end
    end
end
log(("  TOTAL: %d fields  cold %.3f ms  warm %.3f ms")
    :format(allFields, allCold, allWarm))

-- Slowest fields across all modules (cold pass)
local slow = {}
for _, r in ipairs(results) do
    if r and not r.skipped then
        for _, row in ipairs(r.coldRows) do
            slow[#slow + 1] = { mod = r.name, id = row.id, ms = row.ms, ok = row.ok }
        end
    end
end
table.sort(slow, function(a, b) return a.ms > b.ms end)
log("")
log("=== SLOWEST 15 FIELDS (cold pass) ===")
for i = 1, math.min(15, #slow) do
    local s = slow[i]
    log(("  %-15s %-55s %9.3f ms%s"):format(
        s.mod, s.id, s.ms, s.ok and "" or "  (error)"))
end

log("")
log(("done in %d s wall time"):format(os.time() - t0))
closeLog()
