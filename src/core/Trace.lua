--==================================================
-- core/Trace.lua
--==================================================
-- Standardized address-trace record builder shared by EVERY
-- module that resolves or reads memory (defineApi-backed event
-- APIs, GameStatus, Memory, Repeated, Struct, Achievement, ...).
-- One logical address record per line, deterministic order,
-- easy to grep:
--
--   [PublicEvent] [resolve] MODE=cold ADDR=0x7A00000000 STRUCT=EventDefinition VER=1.73
--   [PublicEvent] [get] PATH=eventRewards[0].lootDefinition.maxCollectAmount NESTED=0x7A0000C410 OFF=0x10 ADDR=0x7A0000C420 TYPE=Int32 VALUE=50
--   [Repeated] [readHeader] FIELD=eventRewards BASE=0x7A00000000 OFF=0x100 ADDR=0x7A00000100 CONT=vector PTR=0x7A0000A000 BEGIN=0x7A0000A000 END=0x7A0000A090 CAP=0x7A0000A090 SIZE=3 CAPACITY=3 ELEM_TYPE=struct STRIDE=0x18
--   [Repeated] [elem] FIELD=eventRewards IDX=0 ELEM=0x7A0000A000 NESTED=0x7A0000A000 ELEM_TYPE=struct STRIDE=0x18
--   [Memory] [deref] BASE=0x7A00000000 OFF=0x20 ADDR=0x7A00000020 PTR=0x7A0000C410
--   [Memory] [null] PATH=... ADDR=NULL/INVALID ERR=null_pointer
--   [Memory] [cache] ID=public_event MODE=merge HIT=1 ADDR=0x7A00000000
--   [PublicEvent] [summary] OP=get ADDR=0x7A00000000 FIELDS=1 OK=1 FAIL=0 SLOWEST=startTime(0.31ms)
--
-- Tag vocabulary (required by the trace spec):
--   ADDR   — absolute address            OFF    — struct-relative offset
--   PTR    — vector/array pointer        BEGIN/END/CAP — std::vector header pointers
--   ELEM   — element address             NESTED — nested struct address
--   MODE   — cold|warm resolution        HIT    — cache hit (1/0)
--   NULL/INVALID — explicit marker, never swallow a null address
--
-- All records are gated by Nebula.log (the diagnostics switch).
-- Nebula.traceMem (raw gg.getValues/setValues I/O) and
-- Nebula.verbose (timing stats) stay separate switches.

-- Canonical key order — guarantees deterministic, greppable lines.
local Logfile = loadModule("core/Logfile.lua")

local KEY_ORDER = {
    "PATH", "FIELD", "IDX", "SEG", "OFF",
    "BASE", "ADDR", "PTR", "QWORD", "CONT", "BEGIN", "END", "CAP",
    "SIZE", "CAPACITY", "ELEM_TYPE", "STRIDE", "TYPE",
    "ELEM", "NESTED", "SLOT",
    "MODE", "HIT", "STRUCT", "VER", "OP", "ID",
    "FIELDS", "OK", "FAIL", "SLOWEST",
    "VALUE", "ERR", "INFO",
}

-- Keys that are addresses / offsets: hex form.
local HEX_KEYS = {
    BASE = true, ADDR = true, PTR = true, QWORD = true, BEGIN = true, END = true,
    CAP = true, ELEM = true, NESTED = true, SLOT = true,
    OFF = true, STRIDE = true,
}

local M = {}

---Deterministic value rendering for the VALUE= field (and unknown keys).
function M.repr(v)
    if v == nil then return "NULL/INVALID" end
    local t = type(v)
    if t == "string" then return string.format("%q", v) end
    if t == "number" then
        if math.type(v) == "integer" then
            return string.format("%d (0x%X)", v, v)
        end
        return string.format("%.6g", v)
    end
    if t == "boolean" then return tostring(v) end
    return tostring(v)
end

local function fmtVal(key, v)
    if HEX_KEYS[key] then
        if type(v) == "number" then return string.format("0x%X", v) end
        return tostring(v) -- e.g. the explicit "NULL/INVALID" marker
    end
    if key == "VALUE" then return M.repr(v) end
    return tostring(v)
end

---Emit one standardized record line. Keys absent from `kv` are
---omitted; known keys print in canonical order, unknown keys are
---appended alphabetically (still deterministic).
---@param module string @ module label, e.g. "PublicEvent", "Memory"
---@param tag string @ record tag, e.g. "get", "readHeader", "elem", "null", "summary"
---@param kv table @ key=value pairs (see KEY_ORDER for the vocabulary)
function M.rec(module, tag, kv)
    if Nebula == nil or not Nebula.log then return end
    local parts = {}
    local seen = {}
    for _, k in ipairs(KEY_ORDER) do
        local v = kv[k]
        if v ~= nil then
            seen[k] = true
            parts[#parts + 1] = k .. "=" .. fmtVal(k, v)
        end
    end
    local rest = {}
    for k in pairs(kv) do
        if not seen[k] then rest[#rest + 1] = k end
    end
    table.sort(rest)
    for _, k in ipairs(rest) do
        parts[#parts + 1] = k .. "=" .. M.repr(kv[k])
    end
    Logfile.log("[" .. tostring(module) .. "] [" .. tostring(tag) .. "] " .. table.concat(parts, " "))
end

--==================================================
-- Per-operation stats + end-of-resolution summary
--==================================================
-- beginOp() at the start of a public get()/set() (or a bulk
-- resolution), fieldDone() per field attempted, endOp() to print
-- the compact [summary]: module base, field count, OK, FAIL, and
-- the slowest fields.

---Start an operation-scoped stats session.
---@param module string
---@param op string @ e.g. "get", "set", "resolve"
---@param baseKv table|nil @ extra keys echoed into the summary (e.g. { ADDR = base })
function M.beginOp(module, op, baseKv)
    return {
        module = module,
        op = op,
        base = baseKv,
        t0 = os.clock(),
        n = 0, ok = 0, fail = 0,
        slow = {},
    }
end

---Record one attempted field (path) with success/failure. Timing
---is cumulative from beginOp — for single-field ops this is the
---field's total resolution time.
function M.fieldDone(opStats, path, ok)
    if type(opStats) ~= "table" then return end
    opStats.ms = (os.clock() - opStats.t0) * 1000
    opStats.n = opStats.n + 1
    if ok then opStats.ok = opStats.ok + 1 else opStats.fail = opStats.fail + 1 end
    opStats.slow[#opStats.slow + 1] = { path = tostring(path), ms = opStats.ms }
end

---Print the compact end-of-operation summary.
function M.endOp(opStats)
    if type(opStats) ~= "table" then return end
    if Nebula == nil or not Nebula.log then return end

    table.sort(opStats.slow, function(a, b) return a.ms > b.ms end)
    local slowStr = {}
    for i = 1, math.min(3, #opStats.slow) do
        slowStr[i] = string.format("%s(%.2fms)", opStats.slow[i].path, opStats.slow[i].ms)
    end

    local kv = {
        OP = opStats.op,
        FIELDS = opStats.n,
        OK = opStats.ok,
        FAIL = opStats.fail,
        SLOWEST = table.concat(slowStr, ","),
    }
    if opStats.base then
        for k, v in pairs(opStats.base) do kv[k] = v end
    end
    M.rec(opStats.module, "summary", kv)
end

return M
