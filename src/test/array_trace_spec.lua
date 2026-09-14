--==================================================
-- test/array_trace_spec.lua
--==================================================
-- Array / header-parsing / trace-instrumentation spec.
--
-- Exercises the machinery behind the corrupted "n=15" array
-- report: Repeated.readHeader's header parsing (vector + protobuf
-- ABIs), its rejection paths, Struct.get's batched pre-read path,
-- Repeated.set's grow/append path (ZeroPage allocation), String
-- SSO element reads, Memory.deref, and Memory.validateEventAddress.
--
-- It also verifies the logging layer itself:
--   - get()/set() results are IDENTICAL with Nebula.log on and off
--   - with Nebula.log=false there is NO diagnostic output
--   - with Nebula.verbose=true (log=false) the ONLY output is
--     [Nebula.Memory] timing lines from vlog()
--   - the trace shows the earliest appearance of a suspicious
--     value: raw vector headers, computed size/capacity, and every
--     header rejection with the offending values
--
-- Run from src/ on plain Lua 5.4+: lua test/array_trace_spec.lua

--==================================================
-- Minimal byte-addressable gg mock
--==================================================

local mem = {} -- addr -> byte (default 0)

local FLAGS = { BYTE = 1, WORD = 2, INT32 = 4, FLOAT = 16, INT64 = 32, DOUBLE = 64 }

local function width(flags)
    if flags == FLAGS.BYTE then return 1 end
    if flags == FLAGS.WORD then return 2 end
    if flags == FLAGS.INT32 or flags == FLAGS.FLOAT then return 4 end
    return 8 -- INT64 / DOUBLE / POINTER
end

local function readAt(address, flags)
    local w = width(flags)
    local v = 0
    for i = 0, w - 1 do
        local b = mem[address + i] or 0
        v = v | (b << (8 * i))
    end
    -- INT32/WORD are signed reads (gg semantics)
    if flags == FLAGS.INT32 and v >= 0x80000000 then v = v - 0x100000000 end
    if flags == FLAGS.WORD and v >= 0x8000 then v = v - 0x10000 end
    -- BYTE reads return signed bytes in gg
    if flags == FLAGS.BYTE and v >= 0x80 then v = v - 0x100 end
    return v
end

local function writeAt(address, flags, value)
    local w = width(flags)
    -- normalize negatives to unsigned bit patterns
    if value < 0 then
        value = value & 0xFFFFFFFFFFFFFFFF
    end
    for i = 0, w - 1 do
        mem[address + i] = (value >> (8 * i)) & 0xFF
    end
    return true
end

gg = {
    getValues = function(specs)
        local results = {}
        for i, spec in ipairs(specs) do
            results[i] = { address = spec.address, flags = spec.flags, value = readAt(spec.address, spec.flags) }
        end
        return results
    end,
    setValues = function(specs)
        for _, spec in ipairs(specs) do
            writeAt(spec.address, spec.flags, spec.value)
        end
        return true
    end,
    getRangesList = function()
        -- One safe zero region for ZeroPage; everything defaults to 0.
        return { { start = 0x7000000000, ["end"] = 0x7000002000, state = "O", type = "rw-p", name = "", internalName = "" } }
    end,
    getTargetInfo = function()
        return { versionName = "1.73.4", packageName = "test.pkg", pid = 1 }
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
-- loadModule (same relative-path loader as defineApi_spec.lua)
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

-- Type registry (mirrors main.lua): type impls like BitMask
-- resolve their Int32 sibling through Nebula.Type.
Nebula.Type = loadModule("core/Type.lua")

--==================================================
-- print capture
--==================================================

local captured = {}
local realPrint = print
print = function(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[#parts + 1] = tostring(select(i, ...))
    end
    captured[#captured + 1] = table.concat(parts, " ")
end

local function clearCaptured() captured = {} end

local function capturedText()
    return table.concat(captured, "\n")
end

-- Logfile resolves its default sink from the ENV scriptDir now.
-- Intercept that open so the default file lands in `captured`
-- (byte-identical to the old console print) instead of on disk;
-- explicit setPath() targets still hit the real filesystem.
local realOpen = io.open
io.open = function(path, mode)
    if path == ENV.scriptDir .. "nebula.log" then
        local fh = {}
        fh.write = function(_, ...)
            for i = 1, select("#", ...) do
                local s = select(i, ...)
                if type(s) == "string" and s:sub(-1) == "\n" then s = s:sub(1, -2) end
                if s ~= "" then captured[#captured + 1] = s end
            end
            return fh
        end
        fh.flush = function() return true end
        fh.close = function() return true end
        return fh
    end
    return realOpen(path, mode)
end

local function capturedContains(pattern)
    for _, line in ipairs(captured) do
        if line:find(pattern, 1, true) then return true end -- plain find
    end
    return false
end

--==================================================
-- Assertion helper
--==================================================

local pass, fail = 0, 0
local function check(name, ok, detail)
    -- Uses realPrint directly: the trace-collector overrides print.
    if ok then
        realPrint("  [PASS] " .. name)
        pass = pass + 1
    else
        realPrint("  [FAIL] " .. name .. (detail and (" — " .. tostring(detail)) or ""))
        fail = fail + 1
    end
end

--==================================================
-- Fixture builders
--==================================================

local function w64(addr, v) writeAt(addr, FLAGS.INT64, v) end
local function w32(addr, v) writeAt(addr, FLAGS.INT32, v) end

-- Build a std::string SSO object at addr: length byte (len*2) + bytes.
local function writeSSO(addr, s)
    writeAt(addr, FLAGS.BYTE, #s * 2)
    for i = 1, #s do
        writeAt(addr + i, FLAGS.BYTE, string.byte(s, i))
    end
end

local BASE = 0x5000000000

-- Vector container header at containerAddr: {begin, end, capEnd}
local function writeVectorHeader(containerAddr, beginP, endP, capEndP)
    endP = endP or beginP or 0
    w64(containerAddr, beginP or 0)
    w64(containerAddr + 0x8, endP)
    w64(containerAddr + 0x10, capEndP or endP)
end

-- Protobuf container header at containerAddr: {arrayPtr, size(i32), capacity(i32)}
local function writeProtoHeader(containerAddr, arrayPtr, size, capacity)
    w64(containerAddr, arrayPtr)
    w32(containerAddr + 0x8, size)
    w32(containerAddr + 0xC, capacity)
end

local Memory   = loadModule("core/Memory.lua")
local Repeated = loadModule("core/Repeated.lua")
local Struct   = loadModule("core/Struct.lua")
local String   = loadModule("core/types/String.lua")

--==================================================
-- Section 1: Repeated.readHeader — healthy headers
--==================================================

realPrint("=== Repeated.readHeader: healthy headers ===")
do
    -- healthy vector of 3 string slots
    local slots = 0x7A00000100
    local strs  = 0x7A00000200
    writeSSO(strs,        "alpha")
    writeSSO(strs + 0x20, "beta")
    writeSSO(strs + 0x40, "gamma")
    w64(slots + 0x00, strs)
    w64(slots + 0x08, strs + 0x20)
    w64(slots + 0x10, strs + 0x40)
    writeVectorHeader(BASE + 0x100, slots, slots + 0x18, slots + 0x20)

    local field = { offset = 0x100, type = "Array", elementType = "String", elementStride = 0x8, container = "vector" }

    Nebula.log = true
    clearCaptured()
    local values, getErr = Repeated.get(BASE, field)
    Nebula.log = false

    check("vector-of-strings get returns 3 elements", type(values) == "table" and #values == 3, values)
    check("string elements decoded correctly",
        values and values[1] == "alpha" and values[2] == "beta" and values[3] == "gamma", values)
    check("trace logs raw vector header (earliest value provenance)",
        capturedContains("[readHeader]") and capturedContains("SIZE=3 CAPACITY=4"))
    check("trace logs containerPtr and base+offset provenance",
        capturedContains("BASE=0x5000000000") and capturedContains("OFF=0x100"))

    -- behavior identical with logging off
    local values2 = Repeated.get(BASE, field)
    check("results identical with Nebula.log off",
        type(values2) == "table" and #values2 == 3 and values2[1] == "alpha")

    clearCaptured()
    Repeated.get(BASE, field)
    check("no output with log=false", #captured == 0, capturedText())

    -- verbose=true, log=false → ONLY [Nebula.Memory] timing lines
    Nebula.verbose = true
    clearCaptured()
    Repeated.get(BASE, field)
    local onlyTiming = true
    for _, line in ipairs(captured) do
        if not line:find("^%[Nebula%.Memory%]") then onlyTiming = false end
    end
    check("Nebula.verbose emits only [Nebula.Memory] timing lines", onlyTiming, capturedText())
    Nebula.verbose = false
end

--==================================================
-- Section 2: readHeader rejection paths (protobuf ABI)
--==================================================

realPrint("=== Repeated.readHeader: rejection paths (protobuf ABI) ===")
do
    local cases = {
        { name = "negative size",            size = -1,      capacity = 4,  errPart = "header_negative_size_or_capacity" },
        { name = "size out of bounds",       size = 1000000, capacity = 1000000, errPart = "header_size_out_of_bounds" },
        { name = "size exceeds capacity",    size = 5,      capacity = 3,  errPart = "header_size_exceeds_capacity" },
    }
    for _, case in ipairs(cases) do
        local container = BASE + 0x400
        writeProtoHeader(container, 0x7A00001000, case.size, case.capacity)
        local field = { offset = 0x400, type = "Array", elementType = "Int32", elementStride = 0x4 }

        Nebula.log = true
        clearCaptured()
        local values, err = Repeated.get(BASE, field)
        Nebula.log = false

        check(case.name .. " rejected with error", values == nil and err ~= nil and err:find(case.errPart, 1, true), err)
        check(case.name .. " trace shows [readHeader] REJECTED with offending values",
            capturedContains("[readHeader]") and capturedContains("ERR="))
    end

    -- verify identical rejection with logging off
    writeProtoHeader(BASE + 0x400, 0x7A00001000, 5, 3)
    local field = { offset = 0x400, type = "Array", elementType = "Int32", elementStride = 0x4 }
    local v1, e1 = Repeated.get(BASE, field)
    check("rejection identical with log off", v1 == nil and tostring(e1):find("header_size_exceeds_capacity", 1, true), e1)
end

--==================================================
-- Section 3: readHeader rejection paths (vector ABI)
--==================================================

realPrint("=== Repeated.readHeader: rejection paths (vector ABI) ===")
do
    -- end < begin
    writeVectorHeader(BASE + 0x500, 0x7A00000100, 0x7A00000080)
    local field = { offset = 0x500, type = "Array", elementType = "String", elementStride = 0x8, container = "vector" }

    Nebula.log = true
    clearCaptured()
    local values, err = Repeated.get(BASE, field)
    Nebula.log = false

    check("end_before_begin rejected", values == nil and err ~= nil and err:find("vector_end_before_begin", 1, true), err)
    check("end_before_begin trace shows both pointers",
        capturedContains("[null]") and capturedContains("ERR=vector_end_before_begin"), capturedText())

    -- empty vector (begin == 0) is a VALID empty array, not an error
    writeVectorHeader(BASE + 0x500, 0)
    local empty, emptyErr = Repeated.get(BASE, field)
    check("empty vector returns {} (no error)", type(empty) == "table" and #empty == 0, emptyErr)

    -- the "n=15" shape: a header that LOOKS valid (end > begin,
    -- size <= capacity) but carries a wrong size. readHeader must
    -- accept it structurally — the trace must show the exact raw
    -- header bytes so the earliest bad value is visible on-device.
    local slots15 = 0x7A00000400
    for i = 0, 14 do
        w32(slots15 + i * 8, i * 100) -- inline Int32 elements, stride 8
    end
    writeVectorHeader(BASE + 0x600, slots15, slots15 + 15 * 8, slots15 + 16 * 8)
    local field15 = { offset = 0x600, type = "Array", elementType = "Int32", elementStride = 0x8, container = "vector" }

    Nebula.log = true
    clearCaptured()
    local fifteen = Repeated.get(BASE, field15)
    Nebula.log = false

    check("valid-looking 15-element vector returns 15 elements", type(fifteen) == "table" and #fifteen == 15, fifteen)
    check("n=15 trace shows raw begin/end and computed size=15",
        capturedContains("BEGIN=0x7A00000400") and capturedContains("SIZE=15 CAPACITY=16"), capturedText())
end

--==================================================
-- Section 4: Struct.get batched pre-read path
--==================================================

realPrint("=== Struct.get: batched array-header pre-read ===")
do
    -- This path bypasses Repeated.readHeader, so it must log its own
    -- raw header values — otherwise a corrupted size would enter the
    -- trace silently.
    local slots15 = 0x7A00000400
    local template = {
        parts = { offset = 0x600, type = "Array", elementType = "Int32", elementStride = 0x8, container = "vector" },
    }

    Nebula.log = true
    clearCaptured()
    local result = Struct.get(BASE, template, true)
    Nebula.log = false

    check("Struct.get returns 15 elements for the same header", type(result.parts) == "table" and #result.parts == 15, result)
    check("Struct trace shows raw vector header (pre-read path)",
        capturedContains("INFO=preReadHeader") and capturedContains("BEGIN=0x7A00000400"), capturedText())
    check("Struct trace shows accepted header with size",
        capturedContains("INFO=preHeader_accepted") and capturedContains("SIZE=15"))

    -- behavior identical with logging off
    local result2 = Struct.get(BASE, template, true)
    check("Struct.get identical with log off",
        type(result2.parts) == "table" and #result2.parts == 15)

    -- garbage header (end < begin) is treated as empty, visibly
    writeVectorHeader(BASE + 0x600, 0x7A00000400, 0x7A00000080)
    Nebula.log = true
    clearCaptured()
    local result3 = Struct.get(BASE, template, true)
    Nebula.log = false
    check("garbage vector header treated as empty (no elements)",
        type(result3) == "table" and result3.parts == nil, result3)
    check("garbage header skip is visible in trace",
        capturedContains("[null]") and capturedContains("ERR=end_le_begin_treated_empty"))
end

--==================================================
-- Section 5: Repeated.set grow path (protobuf ABI) + ZeroPage
--==================================================

realPrint("=== Repeated.set: grow path (append) ===")
do
    local ZeroPage = loadModule("core/ZeroPage.lua")
    local oldArr = 0x7A00002000
    w32(oldArr, 42)
    writeProtoHeader(BASE + 0x700, oldArr, 1, 1)
    local field = { offset = 0x700, type = "Array", elementType = "Int32", elementStride = 0x4 }

    Nebula.log = true
    clearCaptured()
    local ok = Repeated.set(BASE, field, { 42, 43 })
    Nebula.log = false

    check("append 1→2 elements succeeds", ok == true, ok)

    -- header must now point at the new array with size=2 capacity=2
    local hdr = Repeated.readHeaderForSet(BASE, field)
    check("header updated: size=2 capacity=2, new arrayPtr",
        hdr and hdr.size == 2 and hdr.capacity == 2 and hdr.arrayPtr ~= oldArr, hdr)

    local values = Repeated.get(BASE, field)
    check("read-back returns old + new element", values and #values == 2 and values[1] == 42 and values[2] == 43, values)

    check("trace shows ZeroPage allocation for the new array",
        capturedContains("[ZeroPage]") and capturedContains("allocate("))
    check("trace shows header parse of grown array",
        capturedContains("[readHeader]") and capturedContains("SIZE=1 CAPACITY=1"))

    -- vector containers now GROW past capacity via ZeroPage realloc:
    -- new buffer, old elements copied, begin/end/capEnd swapped atomically
    writeVectorHeader(BASE + 0x800, 0x7A00003000, 0x7A00003008, 0x7A00003008)
    w32(0x7A00003000, 1)
    local vfield = { offset = 0x800, type = "Array", elementType = "Int32", elementStride = 0x8, container = "vector" }
    local ok2, err2 = Repeated.set(BASE, vfield, { 1, 2, 3 })
    check("vector grow past capacity succeeds via ZeroPage", ok2 == true, err2)
    local v2 = Repeated.get(BASE, vfield)
    check("grown vector reads back all elements",
        v2 and #v2 == 3 and v2[1] == 1 and v2[2] == 2 and v2[3] == 3, v2)
    local newBegin = readAt(BASE + 0x800, FLAGS.INT64)
    local newEnd = readAt(BASE + 0x808, FLAGS.INT64)
    local newCap = readAt(BASE + 0x810, FLAGS.INT64)
    check("vector begin moved to the ZeroPage buffer",
        newBegin ~= 0x7A00003000 and newBegin ~= 0, string.format("%X", newBegin))
    check("vector end/capEnd swapped consistently (size 3, cap 3)",
        newEnd == newBegin + 3 * 0x8 and newCap == newBegin + 3 * 0x8,
        string.format("%X %X %X", newBegin, newEnd, newCap))
    check("old element copied into the new buffer",
        readAt(newBegin, FLAGS.INT32) == 1, readAt(newBegin, FLAGS.INT32))
    check("game-owned old buffer is not Nebula's to reclaim",
        ZeroPage.owns(0x7A00003000) == false, tostring(ZeroPage.owns(0x7A00003000)))

    -- behavior identical with logging off (fresh container)
    local oldArr2 = 0x7A00004000
    w32(oldArr2, 7)
    writeProtoHeader(BASE + 0x900, oldArr2, 1, 1)
    local f2 = { offset = 0x900, type = "Array", elementType = "Int32", elementStride = 0x4 }
    local ok3 = Repeated.set(BASE, f2, { 7, 8 })
    check("append identical with log off", ok3 == true)
    local v3 = Repeated.get(BASE, f2)
    check("read-back identical with log off", v3 and #v3 == 2 and v3[1] == 7 and v3[2] == 8, v3)
end

--==================================================
-- Section 6: Memory.deref + validateEventAddress traces
--==================================================

realPrint("=== Memory: deref and validateEventAddress ===")
do
    w64(BASE + 0x1000, 0x7A00005000)

    Nebula.log = true
    clearCaptured()
    local ptr = Memory.deref(BASE, 0x1000)
    local badPtr, badErr = Memory.deref(BASE, 0x1100) -- zero → null
    Nebula.log = false

    check("deref resolves pointer", ptr == 0x7A00005000, ptr)
    check("deref null rejected", badPtr == nil and badErr ~= nil, badErr)
    check("deref trace shows base/offset/ptr",
        capturedContains("[deref]") and capturedContains("PTR=0x7A00005000"))
    check("deref rejection visible in trace",
        capturedContains("[Memory] [null]") and capturedContains("NULL/INVALID"))

    -- validateEventAddress: plausible event window
    local ev = 0x7A00006000
    w32(ev + 0x0,   3)             -- contentVersion
    w32(ev + 0x14C, 1700000000)    -- startTime
    w32(ev + 0x154, 1800000000)    -- endTime
    check("valid event address accepted", Memory.validateEventAddress(ev) == true)

    w32(ev + 0x154, 1700000000 - 5) -- endTime < startTime → reject
    Nebula.log = true
    clearCaptured()
    check("end<=start event rejected", Memory.validateEventAddress(ev) == false)
    Nebula.log = false
    check("validate rejection visible in trace with values",
        capturedContains("[validate]") and capturedContains("REJECTED") and capturedContains("1700000000"))
end

--==================================================
-- Section 7: gate discipline summary
--==================================================

realPrint("=== logging gates ===")
do
    clearCaptured()
    Nebula.log = false
    Nebula.verbose = false
    Repeated.get(BASE, { offset = 0x100, type = "Array", elementType = "String", elementStride = 0x8, container = "vector" })
    check("no diagnostic output when both switches off", #captured == 0, capturedText())

    Nebula.verbose = true
    clearCaptured()
    Repeated.get(BASE, { offset = 0x100, type = "Array", elementType = "String", elementStride = 0x8, container = "vector" })
    local sawTiming = false
    local onlyTiming = true
    for _, line in ipairs(captured) do
        if line:find("^%[Nebula%.Memory%]") then sawTiming = true else onlyTiming = false end
    end
    check("verbose=true produces timing lines", sawTiming)
    check("verbose=true produces ONLY timing lines", onlyTiming, capturedText())
    Nebula.verbose = false

    -- sanity: the diagnostic switch controls diagnostics
    Nebula.log = true
    clearCaptured()
    Repeated.get(BASE, { offset = 0x100, type = "Array", elementType = "String", elementStride = 0x8, container = "vector" })
    check("log=true produces [readHeader] diagnostics", capturedContains("[readHeader]"))
    Nebula.log = false
end


--==================================================
-- Section 8: end-to-end API trace (defineApi + real metadata)
--==================================================
-- The primary debugging path, exercised in full:
--   API call -> [PublicEvent] resolvePath -> [readHeader] ->
--   element reads -> resulting array — with logging on.
print("=== end-to-end API trace (defineApi) ===")
do
    local defineApi = loadModule("core/defineApi.lua")
    local FAKE_BASE = 0x5000010000

    -- requiredPackages: Array<String> inline stride 0x18 (offset 0x50)
    local arr = 0x7A00008000
    writeSSO(arr,        "alpha")
    writeSSO(arr + 0x18, "beta")
    writeVectorHeader(FAKE_BASE + 0x50, arr, arr + 2 * 0x18, arr + 2 * 0x18)
    -- startTime: Int32 @ 0x150
    w32(FAKE_BASE + 0x150, 1700000000)

    local api = defineApi.create({
        struct  = "EventDefinition",
        name    = "PublicEvent", -- log label, like api/PublicEvent.lua
        resolve = function() return FAKE_BASE end,
    })

    Nebula.log = true
    clearCaptured()
    local parts, partsErr = api.get("requiredPackages")
    Nebula.log = false

    check("API-level array read returns 2 strings",
        type(parts) == "table" and #parts == 2 and parts[1] == "alpha" and parts[2] == "beta", partsErr or parts)
    check("trace shows [PublicEvent] API-level entry",
        capturedContains("[PublicEvent] [get] PATH=requiredPackages"))
    check("trace shows [PublicEvent] resolvePath segment walk",
        capturedContains("[PublicEvent] [path] PATH=requiredPackages"))
    check("trace shows [PublicEvent] Array dispatch with base+offset",
        capturedContains("[PublicEvent] [get] PATH=requiredPackages")
            and capturedContains("TYPE=Array")
            and capturedContains("OFF=0x") and capturedContains("ADDR=0x"))
    check("trace shows [readHeader] vector parse with size=2",
        capturedContains("[readHeader]") and capturedContains("SIZE=2"))

    -- scalar get + set through the API
    Nebula.log = true
    clearCaptured()
    local st = api.get("startTime")
    local op = api.set("startTime", 1700000123)
    Nebula.log = false

    check("scalar get returns value", st == 1700000000, st)
    check("scalar set succeeds", op._ok == true, op._err)
    check("set trace shows [PublicEvent] dispatch + write address",
        capturedContains("[PublicEvent] [set] PATH=startTime")
            and capturedContains("TYPE=Int32") and capturedContains("ADDR=0x"))

    -- identical results with logging off (startTime was set to
    -- 1700000123 just above, so that's the expected read-back)
    local parts2 = api.get("requiredPackages")
    local st2 = api.get("startTime")
    check("API-level results identical with log off",
        type(parts2) == "table" and #parts2 == 2 and parts2[1] == "alpha" and st2 == 1700000123, st2)
end


--==================================================
-- Section 9: raw memory-I/O trace (Nebula.traceMem)
--==================================================
-- Every address + raw value that crosses gg.getValues/setValues,
-- dumpable for cross-checking in GG's memory viewer.
print("=== raw memory-I/O trace (Nebula.traceMem) ===")
do
    -- fresh vector-of-2-strings at a new offset
    local slots = 0x7A0000A000
    local strs  = 0x7A0000B000
    writeSSO(strs,        "hello")
    writeSSO(strs + 0x20, "world")
    w64(slots + 0x00, strs)
    w64(slots + 0x08, strs + 0x20)
    writeVectorHeader(BASE + 0xA00, slots, slots + 0x10, slots + 0x10)
    local field = { offset = 0xA00, type = "Array", elementType = "String", elementStride = 0x8, container = "vector" }

    -- off by default: no raw I/O lines
    Nebula.log = true
    Nebula.traceMem = false
    clearCaptured()
    local v_off = Repeated.get(BASE, field)
    local sawIo = false
    for _, line in ipairs(captured) do
        if line:find("[read] addr=", 1, true) or line:find("[write] addr=", 1, true) then sawIo = true end
    end
    check("no raw I/O lines with traceMem off", not sawIo)

    -- on: every read logged with address + flags + raw value
    Nebula.traceMem = true
    clearCaptured()
    local v_on = Repeated.get(BASE, field)
    Nebula.traceMem = false

    check("results identical with traceMem on/off",
        type(v_on) == "table" and #v_on == 2 and v_on[1] == "hello" and v_on[2] == "world")
    check("trace shows raw header read with address",
        capturedContains(string.format("[read] addr=0x5000000A00 flags=32/INT64")))
    check("trace shows header begin pointer value in dec+hex",
        capturedContains(string.format("-> %d (0x7A0000A000)", 0x7A0000A000)))
    check("trace shows string length-byte read with raw value",
        capturedContains("flags=1/BYTE -> 10 (0xA)"))
    check("trace shows slot pointer reads", capturedContains("0x7A0000B000"))

    -- writes: set an Int32 through the API path
    w32(BASE + 0x150, 1)
    Nebula.traceMem = true
    clearCaptured()
    writeAt(BASE + 0x150, 1, 999) -- spec-local helper
    Memory.write(BASE + 0x150, 4, 12345)
    Nebula.traceMem = false
    check("trace shows write line with address + value",
        capturedContains("[write] addr=0x5000000150 flags=4/INT32 <- 12345"))
    check("write landed in fake memory", readAt(BASE + 0x150, 4) == 12345)

    -- rejection visibility: nil-address writes/reads
    Nebula.traceMem = true
    clearCaptured()
    Memory.write(0, 4, 5)
    local rnil = Memory.read(0, 4)
    Nebula.traceMem = false
    check("nil-address operations visible in raw trace",
        capturedContains("[write] REJECTED") and capturedContains("[read] REJECTED"))
    check("nil-address read still returns nil/err", rnil == nil)
end


--==================================================
-- Section 10: standardized trace format (all metadata APIs)
--==================================================
-- One record vocabulary everywhere: ADDR/OFF/PTR/BEGIN/END/CAP/
-- ELEM/NESTED/IDX tags, MODE=cold/warm, NULL/INVALID markers,
-- per-op [summary], and identical format across every
-- defineApi-backed module (PlayerInfo / GameData / events).
print("=== standardized trace format ===")
do
    local defineApi = loadModule("core/defineApi.lua")
    local FAKE_BASE = 0x5000020000

    -- vector of 2 structs, stride 0x18, one nested pointer field
    local arr = 0x7A00009000
    local nested = 0x7A0000A000
    w32(arr + 0x00, 111)                    -- elem[0].maxCollectAmount
    w64(arr + 0x08, nested)                 -- elem[0].lootDefinition ptr
    w32(nested + 0x10, 50)                  -- lootDefinition.maxCollectAmount
    w32(arr + 0x18, 222)                    -- elem[1].maxCollectAmount
    w64(arr + 0x20, 0)                      -- elem[1].lootDefinition = NULL
    writeVectorHeader(FAKE_BASE + 0x60, arr, arr + 2 * 0x18, arr + 2 * 0x18)
    w32(FAKE_BASE + 0x150, 1700000000)

    -- inline metadata with a struct-elements array + nested Object
    local LootDefinition = {
        ["maxCollectAmount"] = { offset = 0x10, type = "Int32" },
    }
    local RewardCondition = {
        ["maxCollectAmount"]  = { offset = 0x00, type = "Int32" },
        ["lootDefinition"]    = {
            offset = 0x08, type = "Object",
            ["maxCollectAmount"] = LootDefinition.maxCollectAmount,
        },
    }
    local EV = {
        ["eventRewards"] = {
            offset = 0x60, type = "Array", container = "vector",
            elementStride = 0x18, elements = RewardCondition,
        },
        ["startTime"] = { offset = 0x150, type = "Int32" },
    }

    local function mkApi(name)
        return defineApi.create({
            struct  = "EventDefinition",
            name    = name,
            resolve = function() return FAKE_BASE end,
        })
    end

    -- swap in the inline metadata for all three APIs (the factory
    -- resolves via Manifest; the spec loader swaps it in directly)
    local Manifest = loadModule("metadata/manifest.lua")
    local realResolve = Manifest.resolve
    Manifest.resolve = function(s)
        if s == "EventDefinition" then return EV, "1.73", nil end
        return realResolve(s)
    end

    local PublicEvent = mkApi("PublicEvent")
    local TeamEvent = mkApi("TeamEvent")
    local CommunityEvent = mkApi("CommunityEvent")

    -- cold vs warm resolution records
    Nebula.log = true
    clearCaptured()
    local v1 = PublicEvent.get("startTime")
    check("cold resolve record on first use",
        capturedContains("[PublicEvent] [resolve] ADDR=0x5000020000 MODE=cold STRUCT=EventDefinition"))
    clearCaptured()
    local v2 = PublicEvent.get("startTime")
    check("warm resolve record on cached base",
        capturedContains("[PublicEvent] [resolve] ADDR=0x5000020000 MODE=warm STRUCT=EventDefinition"))
    check("get value correct cold+warm", v1 == 1700000000 and v2 == 1700000000)

    -- nested address chain: base -> field -> vector header -> element -> nested
    clearCaptured()
    local rewards = TeamEvent.get("eventRewards")
    check("struct-elements array read OK",
        type(rewards) == "table" and #rewards == 2
            and rewards[1].maxCollectAmount == 111
            and rewards[2].maxCollectAmount == 222, rewards)
    check("repeated header record with PTR/BEGIN/END/CAP/SIZE",
        capturedContains("PTR=0x7A00009000")
            and capturedContains("BEGIN=0x7A00009000")
            and capturedContains("END=0x7A00009030"))
    check("header record carries SIZE/CAPACITY/ELEM_TYPE/STRIDE tags",
        capturedContains("SIZE=2 CAPACITY=2")
            and capturedContains("STRIDE=0x18"))
    check("elem record with IDX/ELEM/NESTED chain",
        capturedContains("[Repeated] [elem]")
            and capturedContains("IDX=0")
            and capturedContains("ELEM=0x7A00009000")
            and capturedContains("NESTED=0x7A00009000"))
    check("nested lootDefinition chain printed",
        capturedContains("PATH=eventRewards[0].lootDefinition")
            and capturedContains("PTR=0x7A0000A000")
            and capturedContains("NESTED=0x7A0000A000"))
    check("nested field value recorded with full path",
        capturedContains("PATH=eventRewards[0].lootDefinition.maxCollectAmount")
            and capturedContains("VALUE=50 (0x32)"))
    check("null nested pointer explicitly marked",
        capturedContains("NULL/INVALID"))

    -- per-op summary records
    check("summary record with OP/FIELDS/OK/FAIL/SLOWEST",
        capturedContains("[TeamEvent] [summary]")
            and capturedContains("OP=get")
            and capturedContains("FIELDS=1 OK=1 FAIL=0")
            and capturedContains("SLOWEST=eventRewards("))

    -- warm up all three APIs (lazy metadata + base resolution)
    -- with logging off, so each traceOf() capture below contains the
    -- identical record set
    Nebula.log = false
    PublicEvent.get("startTime")
    TeamEvent.get("startTime")
    CommunityEvent.get("startTime")

    -- same record format for all three APIs
    local function traceOf(api, field)
        Nebula.log = true
        clearCaptured()
        api.get(field)
        Nebula.log = false
        local out = {}
        for _, line in ipairs(captured) do
            -- strip module label + timing jitter: compare only the
            -- record shape (addresses, tags, key order)
            out[#out + 1] = line:gsub("^%[%a+%.?%a*%]", "[X]")
                             :gsub("%([%d%.]+ms%)", "(ms)")
        end
        return table.concat(out, "\n")
    end
    local t1 = traceOf(PublicEvent, "startTime")
    local t2 = traceOf(TeamEvent, "startTime")
    local t3 = traceOf(CommunityEvent, "startTime")
    check("all three event APIs emit identical record formats",
        t1 == t2 and t2 == t3, t1)

    -- determinism: two identical ops -> identical address records
    local a, b = traceOf(PublicEvent, "startTime"), traceOf(PublicEvent, "startTime")
    check("address records deterministic across runs", a == b)

    -- results identical with logging off
    Nebula.log = false
    local rewards2 = TeamEvent.get("eventRewards")
    check("results identical with logging off",
        type(rewards2) == "table" and #rewards2 == 2
            and rewards2[1].maxCollectAmount == 111)

    Manifest.resolve = realResolve
end


--==================================================
-- Section 11: file logging (core/Logfile.lua)
--==================================================
-- Console records are ALSO appended to nebula.log: buffered writes,
-- relative timestamps, 2 MiB rotation, off-switch, crash-safe.
--==================================================
-- Section 12: Object resolution — the vipStatus pattern
--==================================================
-- An Object field is read via its field-address QWORD (the nested
-- object's runtime base), never a blind deref, never extra offsets.
-- Covers both metadata shapes: injected children (vipStatus /
-- 1.74 specialFeatures) and the elements template (1.73 shape).
print("=== Object resolution (vipStatus pattern) ===")
do
    local defineApi = loadModule("core/defineApi.lua")
    local FAKE_BASE = 0x5000040000

    local OBJ = 0x7A0000C000
    w64(FAKE_BASE + 0x4D0, OBJ)              -- Object field QWORD
    writeSSO(OBJ + 0x00, "feature_42")       -- id
    w32(OBJ + 0x78, 3)                       -- startingLevel
    w32(OBJ + 0x7C, 9)                       -- maxLevels
    w32(OBJ + 0x80, 2)                       -- mode

    local OBJ2 = 0x7A0000D000
    w64(FAKE_BASE + 0x4E0, OBJ2)
    writeSSO(OBJ2 + 0x00, "feat_b")
    w32(OBJ2 + 0x78, 7)

    w64(FAKE_BASE + 0x4F0, 0)                -- null object base
    w32(FAKE_BASE + 0x150, 1700000000)

    local SFD = {
        ["id"]            = { offset = 0x00, type = "String" },
        ["vehicleId"]     = { offset = 0x18, type = "String" },
        ["startingLevel"] = { offset = 0x78, type = "Int32" },
        ["maxLevels"]     = { offset = 0x7C, type = "Int32" },
        ["mode"]          = { offset = 0x80, type = "Int32" },
    }
    local injectedObj = { offset = 0x4D0, type = "Object" }
    for k, v in pairs(SFD) do injectedObj[k] = v end

    local EV = {
        ["specialFeatures"] = injectedObj,                        -- 1.74 shape
        ["legacyFeatures"]  = { offset = 0x4E0, type = "Object",  -- 1.73 shape
                                elements = SFD },
        ["nullFeature"]     = { offset = 0x4F0, type = "Object",
                                elements = SFD },
        ["plainObject"]     = { offset = 0x500, type = "Object" }, -- childless
        ["startTime"]       = { offset = 0x150, type = "Int32" },
    }

    local Manifest = loadModule("metadata/manifest.lua")
    local realResolve = Manifest.resolve
    Manifest.resolve = function(s)
        if s == "EventDefinition" then return EV, "1.73", nil end
        return realResolve(s)
    end

    local api = defineApi.create({
        struct  = "EventDefinition",
        name    = "PublicEvent",
        resolve = function() return FAKE_BASE end,
    })

    Nebula.log = true

    -- whole-object read, injected-children (vipStatus) shape
    clearCaptured()
    local sf = api.get("specialFeatures")
    check("Object whole read returns nested field values",
        type(sf) == "table" and sf.startingLevel == 3
            and sf.maxLevels == 9 and sf.mode == 2, tostring(sf))
    check("Object string child read via inline SSO",
        sf ~= nil and sf.id == "feature_42", sf and sf.id)
    check("Object read logs field address + declared type",
        capturedContains("[PublicEvent] [get] PATH=specialFeatures")
            and capturedContains("OFF=0x4D0 ADDR=0x50000404D0 TYPE=Object INFO=qword-read"),
        capturedText())
    check("Object read logs raw QWORD + nested base",
        capturedContains("[PublicEvent] [nested] PATH=specialFeatures")
            and capturedContains("PTR=0x7A0000C000 QWORD=0x7A0000C000 NESTED=0x7A0000C000"),
        capturedText())
    check("nested field logs offset/address/type/value",
        capturedContains("PATH=specialFeatures.startingLevel")
            and capturedContains("OFF=0x78 ADDR=0x7A0000C078 TYPE=Int32")
            and capturedContains("VALUE=3 (0x3)"),
        capturedText())

    -- elements-template (1.73) shape
    clearCaptured()
    local lf = api.get("legacyFeatures")
    check("Object elements-template (1.73 shape) read OK",
        type(lf) == "table" and lf.startingLevel == 7 and lf.id == "feat_b",
        tostring(lf))

    -- mid-path descent: specialFeatures.mode
    clearCaptured()
    local mode = api.get("specialFeatures.mode")
    check("mid-path Object descent read OK", mode == 2, tostring(mode))
    check("mid-path descent logs QWORD + nested base",
        capturedContains("PATH=specialFeatures.mode")
            and capturedContains("QWORD=0x7A0000C000 NESTED=0x7A0000C000 INFO=mid_path_object"),
        capturedText())

    -- null object base: rejected, recorded — never blindly dereferenced
    clearCaptured()
    local nf, nerr = api.get("nullFeature")
    check("null object base rejected with null record",
        nf == nil and nerr == "null_pointer: nullFeature",
        tostring(nerr))
    check("null object base visible in trace",
        capturedContains("[PublicEvent] [null] PATH=nullFeature")
            and capturedContains("PTR=NULL/INVALID"),
        capturedText())

    -- childless Object still rejected (unchanged behavior)
    local po, perr = api.get("plainObject")
    check("childless Object still rejected",
        po == nil and perr ~= nil, tostring(perr))

    Nebula.log = false
    Manifest.resolve = realResolve
end

--==================================================
-- Section 13: PlayerInfo -> gameStatus child -> vipStatus chain
--==================================================
-- The standalone Nebula.GameStatus module is GONE: the save struct
-- is PlayerInfo's child (mGameStatus @0x148), reachable as dotted
-- paths. Base resolution must be followed by actual field-level
-- logging: PlayerInfo base -> child QWORD -> nested object base ->
-- nested field reads.
print("=== PlayerInfo -> gameStatus -> vipStatus field chain ===")
do
    local PlayerInfo = loadModule("api/PlayerInfo.lua")
    local Memory = loadModule("core/Memory.lua")
    local GS_BASE = 0x5000050000
    local PI_BASE = 0x5000040000
    local VIP = 0x7A0000E000

    -- stub the AOB scan (base resolution), keep everything else real
    local realResolvePI = Memory.resolvePlayerInfoBase
    Memory.resolvePlayerInfoBase = function() return { PI_BASE }, nil end
    w64(PI_BASE + 0x148, GS_BASE)

    -- GameStatus.vipStatus @0x3A8 (Object): QWORD -> VipStatus base
    w64(GS_BASE + 0x3A8, VIP)
    w32(VIP + 0x1C, 5)              -- vipSkipCupsRemaining
    w32(VIP + 0x20, 1750000000)     -- nextVipSkipTimestamp
    w32(VIP + 0x38, 3)              -- vipSkipScrapperRemaining

    Nebula.log = true
    clearCaptured()
    local vip = PlayerInfo.get("gameStatus.vipStatus")
    check("vipStatus resolves through the child + QWORD chain",
        type(vip) == "table" and vip.vipSkipCupsRemaining == 5
            and vip.nextVipSkipTimestamp == 1750000000,
        tostring(vip))
    check("path start logged with the PlayerInfo base",
        capturedContains("[PlayerInfo] [path] PATH=gameStatus.vipStatus SEG=2 ADDR=0x5000040000"),
        capturedText())
    check("child descent logged (Object QWORD -> nested base)",
        capturedContains("FIELD=gameStatus OFF=0x148 PTR=0x5000050000 QWORD=0x5000050000 NESTED=0x5000050000 INFO=mid_path_object"),
        capturedText())
    check("proto2 ABI override logged at the family boundary",
        capturedContains("FIELD=gameStatus INFO=abi_override stringDirect=false"),
        capturedText())
    check("Object read logs field address, declared type, raw QWORD, nested base",
        capturedContains("[PlayerInfo] [get] PATH=gameStatus.vipStatus")
            and capturedContains("OFF=0x3A8 ADDR=0x50000503A8 TYPE=Object INFO=qword-read")
            and capturedContains("PTR=0x7A0000E000 QWORD=0x7A0000E000 NESTED=0x7A0000E000 INFO=object_base"),
        capturedText())
    check("nested field reads logged (offset/address/type/value)",
        capturedContains("[Struct] [get] PATH=gameStatus.vipStatus.vipSkipCupsRemaining")
            and capturedContains("OFF=0x1C ADDR=0x7A0000E01C TYPE=Int32")
            and capturedContains("VALUE=5 (0x5)"),
        capturedText())
    check("base resolution is followed by field-level logging",
        #captured > 5, capturedText())

    Nebula.log = false
    Memory.resolvePlayerInfoBase = realResolvePI
end

--==================================================
-- Section 13b: element-struct write + verify on gameStatus.achievements
--==================================================
-- achievements @0x258 is a PROTOBUF-ABI array (raw metadata: no
-- container key). Through the PlayerInfo path the ABI override
-- (gameStatus stringDirect=false) must keep the protobuf header
-- read intact, while the element-struct write/verify semantics
-- stay identical to defineApi's.
print("=== PlayerInfo element-struct write + verify (protobuf ABI) ===")
do
    local PlayerInfo = loadModule("api/PlayerInfo.lua")
    local Memory = loadModule("core/Memory.lua")
    local GS_BASE = 0x5000050000
    local PI_BASE = 0x5000040000
    local SLOTS = 0x7A00040000
    local ACH1 = 0x7A00041000
    local ACH2 = 0x7A00042000

    local realResolvePI = Memory.resolvePlayerInfoBase
    Memory.resolvePlayerInfoBase = function() return { PI_BASE }, nil end
    w64(PI_BASE + 0x148, GS_BASE)

    -- achievements @0x258 (protobuf ABI header — the ABI override
    -- keeps the raw metadata, so no vector shadow applies:
    -- {arrayPtr, size, capacity} — pointer-slot elements of
    -- Achievement: id Enum@0x18, unlocked Bool@0x1C, steps Int32@0x20)
    writeProtoHeader(GS_BASE + 0x258, SLOTS, 2, 2)
    w64(SLOTS, ACH1); w64(SLOTS + 0x8, ACH2)
    w32(ACH1 + 0x18, 1)       -- id = enum 1
    w32(ACH1 + 0x1C, 0)       -- unlocked = false
    w32(ACH1 + 0x20, 10)      -- steps = 10
    w32(ACH2 + 0x18, 2)
    w32(ACH2 + 0x20, 20)

    -- (a) whole element-struct write, partial keys
    local op = PlayerInfo.set("gameStatus.achievements[1]", { steps = 42, unlocked = true })
    check("element struct write succeeds through the PlayerInfo path",
        op._ok == true, tostring(op._err))
    check("element write landed (Int32 key)",
        readAt(ACH1 + 0x20, FLAGS.INT32) == 42,
        tostring(readAt(ACH1 + 0x20, FLAGS.INT32)))
    check("element write landed (Bool key)",
        readAt(ACH1 + 0x1C, FLAGS.BYTE) == 1,
        tostring(readAt(ACH1 + 0x1C, FLAGS.BYTE)))
    check("partial write left sibling fields intact",
        readAt(ACH1 + 0x18, FLAGS.INT32) == 1,
        tostring(readAt(ACH1 + 0x18, FLAGS.INT32)))

    -- (b) read back the whole element
    local elem = PlayerInfo.get("gameStatus.achievements[1]")
    check("element read back",
        type(elem) == "table" and elem.steps == 42 and elem.unlocked == true,
        tostring(elem))

    -- (c) verify() passes on a clean element write
    local opV = PlayerInfo.set("gameStatus.achievements[1]", { steps = 43 }):verify()
    check("verify passes on element write",
        opV._ok == true and opV._verified == true,
        tostring(opV._verified) .. " " .. tostring(opV._err))

    -- (d) non-table value on an elements-template array is rejected
    local op2 = PlayerInfo.set("gameStatus.achievements[1]", 99)
    check("non-table element write rejected",
        op2._ok == false, tostring(op2._ok))

    -- (e) unknown keys are safe no-ops
    local op3 = PlayerInfo.set("gameStatus.achievements[2]", { steps = 50, bogus = 1 })
    check("unknown key is a safe no-op", op3._ok == true, tostring(op3._err))
    check("unknown-key write landed the real field",
        readAt(ACH2 + 0x20, FLAGS.INT32) == 50,
        tostring(readAt(ACH2 + 0x20, FLAGS.INT32)))

    -- (f) null slot rejected on the PlayerInfo path
    w64(SLOTS + 0x8, 0)
    local op4 = PlayerInfo.set("gameStatus.achievements[2]", { steps = 1 })
    check("null slot element write rejected",
        op4._ok == false, tostring(op4._ok))

    -- (g) unverified write still reports the stale value
    w32(ACH1 + 0x20, 0x7F)
    local op5 = PlayerInfo.set("gameStatus.achievements[1]", { steps = 60 })
    check("unverified write does not read back",
        op5._ok == true and op5._verified == nil,
        tostring(op5._verified))

    Memory.resolvePlayerInfoBase = realResolvePI
end

--==================================================
-- Section 13c: PlayerInfo API — parent struct, defineApi-backed
--==================================================
-- PlayerInfo is the parent object the signature scan lands on.
-- The module is defineApi-backed: namespaces (inline SessionTracker
-- instances), Enum decode, Object descent, verify(), and the
-- stringDirect ABI threading must all work through the generic
-- machinery.
print("=== PlayerInfo API: parent struct, defineApi-backed ===")
do
    local PlayerInfo = loadModule("api/PlayerInfo.lua")
    local Memory = loadModule("core/Memory.lua")
    local PI_BASE = 0x5000040000
    local GS_BASE = 0x5000050000
    local STR = 0x7A00060000

    local realResolvePI = Memory.resolvePlayerInfoBase
    Memory.resolvePlayerInfoBase = function() return { PI_BASE }, nil end
    w64(PI_BASE + 0x148, GS_BASE)

    -- (a) scalar read: startupCount Int32 @0xC8
    w32(PI_BASE + 0xC8, 7)
    check("PlayerInfo scalar read (startupCount)",
        PlayerInfo.get("startupCount") == 7,
        tostring(PlayerInfo.get("startupCount")))

    -- (b) namespace container read: inline SessionTracker
    --     sessionDiamonds.startObf Int32 @0x160 (absolute offset)
    w32(PI_BASE + 0x160, 1234)
    check("namespace read (sessionDiamonds.startObf)",
        PlayerInfo.get("sessionDiamonds.startObf") == 1234,
        tostring(PlayerInfo.get("sessionDiamonds.startObf")))

    -- (c) namespace write + read-back verification
    local op = PlayerInfo.set("sessionCoins.deltaObf", 55):verify()
    check("namespace write landed (sessionCoins.deltaObf @0x18C)",
        readAt(PI_BASE + 0x18C, FLAGS.INT32) == 55,
        tostring(readAt(PI_BASE + 0x18C, FLAGS.INT32)))
    check("namespace write verified",
        op._verified == true, tostring(op._actual))

    -- (d) Enum decode: startupStatus @0xF8 -> "BackupRestored"
    w32(PI_BASE + 0xF8, 1)
    check("Enum read (startupStatus)",
        PlayerInfo.get("startupStatus") == "BackupRestored",
        tostring(PlayerInfo.get("startupStatus")))

    -- (e) Object descent into the child save struct:
    --     gameStatus.totalCupVictories Int32 @0x270
    w32(GS_BASE + 0x270, 4321)
    check("child GameStatus read via PlayerInfo",
        PlayerInfo.get("gameStatus.totalCupVictories") == 4321,
        tostring(PlayerInfo.get("gameStatus.totalCupVictories")))

    -- (f) null Object pointer: currentRace @0x40 is 0 outside a
    --     race — rejected, never blindly dereferenced
    local r, rerr = PlayerInfo.get("currentRace.seed")
    check("null currentRace rejected with null_pointer",
        r == nil and tostring(rerr):find("null_pointer", 1, true) ~= nil,
        tostring(rerr))

    -- (g) unknown field
    local u, uerr = PlayerInfo.get("bogus")
    check("unknown field rejected",
        u == nil and uerr ~= nil, tostring(uerr))

    -- (h) PlayerInfo's OWN strings stay INLINE (direct ABI):
    --     sceneName @0xB0 is an inline std::string embedded in the
    --     struct — no pointer deref. SSO marker: len*2, then bytes.
    writeAt(PI_BASE + 0xB0, FLAGS.BYTE, 12)
    writeAt(PI_BASE + 0xB1, FLAGS.BYTE, string.byte("g"))
    writeAt(PI_BASE + 0xB2, FLAGS.BYTE, string.byte("a"))
    writeAt(PI_BASE + 0xB3, FLAGS.BYTE, string.byte("r"))
    writeAt(PI_BASE + 0xB4, FLAGS.BYTE, string.byte("a"))
    writeAt(PI_BASE + 0xB5, FLAGS.BYTE, string.byte("g"))
    writeAt(PI_BASE + 0xB6, FLAGS.BYTE, string.byte("e"))
    check("inline String read (sceneName, direct ABI)",
        PlayerInfo.get("sceneName") == "garage",
        tostring(PlayerInfo.get("sceneName")))

    -- (i) GameStatus's proto2 strings stay INDIRECT through the
    --     ABI override: playerName @0x38 is a POINTER to a
    --     std::string object. If the root inline ABI leaked into
    --     the gameStatus subtree, this read would decode garbage
    --     at GS_BASE+0x38 instead of dereferencing.
    w64(GS_BASE + 0x38, STR)
    writeAt(STR, FLAGS.BYTE, 12)          -- SSO marker: 6 chars * 2
    for i = 1, 6 do
        writeAt(STR + i, FLAGS.BYTE, string.byte("Nebula", i))
    end
    check("indirect String read (gameStatus.playerName, proto2 ABI)",
        PlayerInfo.get("gameStatus.playerName") == "Nebula",
        tostring(PlayerInfo.get("gameStatus.playerName")))

    -- (j) indirect String write round-trips
    local opW = PlayerInfo.set("gameStatus.playerName", "NebulaSDK"):verify()
    check("indirect String write round-trips",
        opW._ok == true and opW._verified == true,
        tostring(opW._verified) .. " " .. tostring(opW._err))

    Memory.resolvePlayerInfoBase = realResolvePI
end

--==================================================
-- Section 13d: whole-Object read/write — ABI boundary on the
-- BARE single-segment path (get("gameStatus"))
--==================================================
-- Regression: defineApi's Object dispatch once computed leafDirect
-- with `field.stringDirect ~= nil and field.stringDirect or
-- result.direct` — a Lua and/or chain that falls through to the
-- ROOT ABI whenever the declared override is FALSE. Dotted paths
-- (gameStatus.playerName) were safe (resolvePath threads the
-- override mid-path), but the bare whole-Object read walked the
-- entire proto2 save subtree with PlayerInfo's inline/vector ABI:
-- proto2 strings dumped raw pointer bytes and protobuf
-- {ptr,size,cap} headers were read as vector {begin,end,capEnd}
-- (end_le_begin_treated_empty, seen live in nebula.log).
print("=== whole-Object read/write: ABI boundary on bare get('gameStatus') ===")
do
    local PlayerInfo = loadModule("api/PlayerInfo.lua")
    local Memory = loadModule("core/Memory.lua")
    local PI_BASE = 0x5000040000
    local GS_BASE = 0x5000050000
    local STR    = 0x7A00060000
    local SLOTS  = 0x7A00040000
    local ACH1   = 0x7A00041000
    local ACH2   = 0x7A00042000

    local realResolvePI = Memory.resolvePlayerInfoBase
    Memory.resolvePlayerInfoBase = function() return { PI_BASE }, nil end
    w64(PI_BASE + 0x148, GS_BASE)

    -- proto2 child state: scalar, indirect string, protobuf array
    w32(GS_BASE + 0x270, 4321)               -- totalCupVictories
    w64(GS_BASE + 0x38, STR)                 -- playerName -> pointer
    writeAt(STR, FLAGS.BYTE, 12)             -- SSO marker: 6 chars * 2
    for i = 1, 6 do
        writeAt(STR + i, FLAGS.BYTE, string.byte("Nebula", i))
    end
    writeProtoHeader(GS_BASE + 0x258, SLOTS, 2, 2)   -- achievements
    w64(SLOTS, ACH1); w64(SLOTS + 0x8, ACH2)
    w32(ACH1 + 0x18, 1)
    w32(ACH1 + 0x1C, 0)
    w32(ACH1 + 0x20, 10)
    w32(ACH2 + 0x18, 2)
    w32(ACH2 + 0x20, 20)

    -- (a) bare whole-Object GET: the walk must run with the
    --     gameStatus override (proto2 ABI), not the root's
    Nebula.log = true
    clearCaptured()
    local gs, gsErr = PlayerInfo.get("gameStatus")
    Nebula.log = false

    check("bare whole-Object read returns a table",
        type(gs) == "table", tostring(gsErr))
    check("whole-Object read: proto2 string decoded (playerName)",
        gs ~= nil and gs.playerName == "Nebula",
        tostring(gs and gs.playerName))
    check("whole-Object read: proto2 array decoded (achievements, 2)",
        gs ~= nil and gs.achievements ~= nil and #gs.achievements == 2,
        tostring(gs and gs.achievements and #gs.achievements))
    check("whole-Object read: scalar child (totalCupVictories)",
        gs ~= nil and gs.totalCupVictories == 4321,
        tostring(gs and gs.totalCupVictories))
    check("whole-Object walk traced with stringDirect=false",
        capturedContains("PATH=gameStatus ") and capturedContains("stringDirect=false"),
        capturedText())

    -- (b) whole-Object SET: same boundary on the write side — a
    --     partial table write must reach the proto2 string
    --     INDIRECTLY (deref), not inline at the field slot
    local op = PlayerInfo.set("gameStatus", { playerName = "WholeWalk" }):verify()
    check("whole-Object set: proto2 string write + verify",
        op._ok == true and op._verified == true,
        tostring(op._verified) .. " " .. tostring(op._err))
    check("whole-Object set landed indirectly (read-back via dotted path)",
        PlayerInfo.get("gameStatus.playerName") == "WholeWalk",
        tostring(PlayerInfo.get("gameStatus.playerName")))

    Memory.resolvePlayerInfoBase = realResolvePI
end

--==================================================
-- Section 14: set()/get() parity — Object writes
--==================================================
print("=== set/get parity: Object writes ===")
do
    local defineApi = loadModule("core/defineApi.lua")
    local FAKE_BASE = 0x5000080000
    local OBJ = 0x7A00002000
    w64(FAKE_BASE + 0x4D0, OBJ)
    writeSSO(OBJ + 0x00, "feature_42")
    w32(OBJ + 0x78, 3); w32(OBJ + 0x7C, 9); w32(OBJ + 0x80, 2)
    local SFD = {
        ["id"]            = { offset = 0x00, type = "String" },
        ["startingLevel"] = { offset = 0x78, type = "Int32" },
        ["maxLevels"]     = { offset = 0x7C, type = "Int32" },
        ["mode"]          = { offset = 0x80, type = "Int32" },
    }
    local injectedObj = { offset = 0x4D0, type = "Object" }
    for k, v in pairs(SFD) do injectedObj[k] = v end
    local EV = { ["specialFeatures"] = injectedObj,
                 ["startTime"] = { offset = 0x150, type = "Int32" } }
    w32(FAKE_BASE + 0x150, 1700000000)
    local Manifest = loadModule("metadata/manifest.lua")
    local realResolve = Manifest.resolve
    Manifest.resolve = function(s)
        if s == "EventDefinition" then return EV, "1.73", nil end
        return realResolve(s)
    end
    local api = defineApi.create({
        struct = "EventDefinition", name = "PublicEvent",
        resolve = function() return FAKE_BASE end,
    })

    -- (a) whole-Object set writes nested fields at the QWORD base
    local op = api.set("specialFeatures", { startingLevel = 7, mode = 4 })
    check("whole-Object set succeeds", op._ok == true, tostring(op._err))
    local snap = api.get("specialFeatures")
    check("whole-Object set wrote through (get reads back new values)",
        snap.startingLevel == 7 and snap.mode == 4, tostring(snap.startingLevel) .. "/" .. tostring(snap.mode))
    check("whole-Object set left untouched fields intact", snap.maxLevels == 9, tostring(snap.maxLevels))

    -- (b) mid-path leaf write through the Object
    op = api.set("specialFeatures.mode", 6)
    check("mid-path Object leaf set succeeds", op._ok == true, tostring(op._err))
    check("mid-path write landed (get returns new value)",
        api.get("specialFeatures.mode") == 6, tostring(api.get("specialFeatures.mode")))

    -- (c) null Object pointer is rejected, not dereferenced
    w64(FAKE_BASE + 0x4D0, 0)
    op = api.set("specialFeatures", { mode = 1 })
    check("null Object pointer rejected on set",
        op._ok == false and tostring(op._err):find("null_pointer", 1, true), tostring(op._err))
    w64(FAKE_BASE + 0x4D0, OBJ)

    -- (d) Object set logs the same chain shape as get
    Nebula.log = true
    clearCaptured()
    api.set("specialFeatures", { mode = 5 })
    check("set chain logs field address + qword-write",
        capturedContains("[PublicEvent] [set] PATH=specialFeatures")
            and capturedContains("OFF=0x4D0 ADDR=0x50000804D0 TYPE=Object INFO=qword-write"),
        capturedText())
    check("set chain logs nested base",
        capturedContains("PTR=0x7A00002000 QWORD=0x7A00002000 NESTED=0x7A00002000 INFO=object_base"),
        capturedText())
    Nebula.log = false

    Manifest.resolve = realResolve
end

--==================================================
-- Section 15: set()/get() parity — eventRewards write patterns
--==================================================
print("=== set/get parity: eventRewards write patterns ===")
do
    local defineApi = loadModule("core/defineApi.lua")
    local FB = 0x50000B0000
    local SLOTS = 0x7A00010000
    local E1 = 0x7A00011000
    local E2 = 0x7A00012000
    local LOOT1 = 0x7A00013000
    -- ConditionalRewardDefinition at real dump offsets
    -- (rewardCondition Float @0x4, lootDefinition Object @0x20,
    -- maxCollectAmount Int32 @0x28); pointer-slot elements
    local CRD = {
        ["rewardCondition"]  = { offset = 0x4,  type = "Float" },
        ["lootDefinition"]   = { offset = 0x20, type = "Object" },
        ["maxCollectAmount"] = { offset = 0x28, type = "Int32" },
    }
    CRD.lootDefinition["type"] = { offset = 0x0, type = "Int32" }
    local EV = { ["eventRewards"] = { offset = 0x528, type = "Array", elements = CRD } }
    -- std::vector container header at FB+0x528 (defineApi's
    -- default ABI): begin/end/capEnd, pointer-slot elements,
    -- size 2 (end-begin)/8, capacity 4
    writeVectorHeader(FB + 0x528, SLOTS, SLOTS + 2 * 0x8, SLOTS + 4 * 0x8)
    w64(SLOTS, E1); w64(SLOTS + 0x8, E2)
    w32(E1 + 0x4, 0x40B00000)          -- rewardCondition = 5.5f
    w64(E1 + 0x20, LOOT1); w32(LOOT1, 7)
    w32(E1 + 0x28, 100)
    w64(E2 + 0x20, LOOT1)
    w32(E2 + 0x28, 200)
    local Manifest = loadModule("metadata/manifest.lua")
    local realResolve = Manifest.resolve
    Manifest.resolve = function(s)
        if s == "EventDefinition" then return EV, "1.73", nil end
        return realResolve(s)
    end
    local ZeroPage = loadModule("core/ZeroPage.lua")
    local api = defineApi.create({
        struct = "EventDefinition", name = "PublicEvent",
        resolve = function() return FB end,
    })

    -- (a) indexed element leaf write (path indices are 1-based:
    --     eventRewards[1] is the first tier)
    local op = api.set("eventRewards[2].maxCollectAmount", 999)
    check("indexed element set succeeds", op._ok == true, tostring(op._err))
    check("indexed write landed in memory",
        readAt(E2 + 0x28, FLAGS.INT32) == 999, readAt(E2 + 0x28, FLAGS.INT32))
    check("indexed write read-back matches",
        api.get("eventRewards[2].maxCollectAmount") == 999,
        tostring(api.get("eventRewards[2].maxCollectAmount")))

    -- (b) whole-array rewrite of existing elements
    local rewards = api.get("eventRewards")
    check("get returns 2 tiers",
        type(rewards) == "table" and #rewards == 2, tostring(rewards and #rewards))
    rewards[1].maxCollectAmount = 500
    local op2 = api.set("eventRewards", rewards)
    check("whole-array set succeeds", op2._ok == true, tostring(op2._err))
    local back = api.get("eventRewards")
    check("whole-array set wrote element 1",
        back[1].maxCollectAmount == 500, tostring(back[1] and back[1].maxCollectAmount))
    check("whole-array set preserved element 2", back[2].maxCollectAmount == 999,
        tostring(back[2] and back[2].maxCollectAmount))
    check("whole-array set kept slot pointers (no realloc)",
        readAt(SLOTS + 0x8, FLAGS.INT64) == E2, string.format("%X", readAt(SLOTS + 0x8, FLAGS.INT64)))
    check("end pointer unchanged after same-size rewrite",
        readAt(FB + 0x530, FLAGS.INT64) == SLOTS + 2 * 0x8,
        string.format("%X", readAt(FB + 0x530, FLAGS.INT64)))

    -- (c) append a new tier (read, clone, add, write back)
    local list = api.get("eventRewards")
    local copy = {}
    for k, v in pairs(list[1]) do copy[k] = v end
    copy.maxCollectAmount = 777
    list[#list + 1] = copy
    local op3 = api.set("eventRewards", list)
    check("append set succeeds", op3._ok == true, tostring(op3._err))
    check("vector end pointer moved to cover 3 tiers",
        readAt(FB + 0x530, FLAGS.INT64) == SLOTS + 3 * 0x8,
        string.format("%X", readAt(FB + 0x530, FLAGS.INT64)))
    local grown = api.get("eventRewards")
    check("read-back sees 3 tiers",
        type(grown) == "table" and #grown == 3, tostring(grown and #grown))
    check("new tier value landed",
        grown[3].maxCollectAmount == 777, tostring(grown[3] and grown[3].maxCollectAmount))
    check("existing tiers untouched",
        grown[1].maxCollectAmount == 500 and grown[2].maxCollectAmount == 999)
    check("new tier got a fresh slot pointer",
        readAt(SLOTS + 0x10, FLAGS.INT64) ~= 0, string.format("%X", readAt(SLOTS + 0x10, FLAGS.INT64)))

    -- (c2) grow past capacity: 3 tiers -> 5 tiers (capacity 4)
    local bigList = api.get("eventRewards")
    for _ = 1, 2 do
        local tierCopy = {}
        for k, v in pairs(bigList[#bigList]) do tierCopy[k] = v end
        tierCopy.maxCollectAmount = 555
        bigList[#bigList + 1] = tierCopy
    end
    local opGrow = api.set("eventRewards", bigList)
    check("grow-past-capacity set succeeds", opGrow._ok == true, tostring(opGrow._err))
    local gBegin = readAt(FB + 0x528, FLAGS.INT64)
    local gEnd = readAt(FB + 0x530, FLAGS.INT64)
    local gCap = readAt(FB + 0x538, FLAGS.INT64)
    check("grown vector header swapped to ZeroPage buffer",
        gBegin ~= SLOTS and gBegin ~= 0, string.format("%X", gBegin))
    check("grown end/capEnd consistent (size 5)",
        gEnd == gBegin + 5 * 0x8 and gCap == gBegin + 5 * 0x8,
        string.format("%X %X %X", gBegin, gEnd, gCap))
    local grown2 = api.get("eventRewards")
    check("grown read-back sees 5 tiers",
        type(grown2) == "table" and #grown2 == 5, tostring(grown2 and #grown2))
    check("pre-grow tiers preserved through the realloc",
        grown2[1].maxCollectAmount == 500 and grown2[2].maxCollectAmount == 999
            and grown2[3].maxCollectAmount == 777,
        tostring(grown2[1] and grown2[1].maxCollectAmount) .. "/" ..
        tostring(grown2[2] and grown2[2].maxCollectAmount) .. "/" ..
        tostring(grown2[3] and grown2[3].maxCollectAmount))
    check("grown tiers landed",
        grown2[4].maxCollectAmount == 555 and grown2[5].maxCollectAmount == 555,
        tostring(grown2[4] and grown2[4].maxCollectAmount))

    check("game-owned old slot buffer left alone by reclaim",
        ZeroPage.owns(SLOTS) == false, tostring(ZeroPage.owns(SLOTS)))

    -- (c3) grow AGAIN: the old buffer is now Nebula's own ZeroPage
    -- allocation from (c2) — it must be reclaimed, not leaked
    local zpBuf = gBegin
    local list6 = api.get("eventRewards")
    local tierCopy6 = {}
    for k, v in pairs(list6[#list6]) do tierCopy6[k] = v end
    tierCopy6.maxCollectAmount = 888
    list6[#list6 + 1] = tierCopy6
    local opGrow2 = api.set("eventRewards", list6)
    check("second grow (5→6) succeeds", opGrow2._ok == true, tostring(opGrow2._err))
    check("old ZeroPage slot buffer reclaimed",
        ZeroPage.isFreed(zpBuf) == true, string.format("%X", zpBuf))
    local grown3 = api.get("eventRewards")
    check("6 tiers readable after second grow",
        type(grown3) == "table" and #grown3 == 6 and grown3[6].maxCollectAmount == 888,
        tostring(grown3 and #grown3) .. "/" .. tostring(grown3[6] and grown3[6].maxCollectAmount))
    check("earlier tiers intact through second grow",
        grown3[1].maxCollectAmount == 500 and grown3[5].maxCollectAmount == 555,
        tostring(grown3[1] and grown3[1].maxCollectAmount) .. "/" ..
        tostring(grown3[5] and grown3[5].maxCollectAmount))

    -- (d) out-of-bounds and 0-based indices are rejected
    local op4 = api.set("eventRewards[9].maxCollectAmount", 1)
    check("out-of-bounds indexed set rejected",
        op4._ok == false and tostring(op4._err):find("index_out_of_bounds", 1, true), tostring(op4._err))
    local op5 = api.set("eventRewards[0].maxCollectAmount", 1)
    check("0-based index rejected (indices are 1-based)",
        op5._ok == false and tostring(op5._err):find("index_out_of_bounds", 1, true), tostring(op5._err))

    -- (e) indexed set logs the canonical chain
    Nebula.log = true
    clearCaptured()
    api.set("eventRewards[1].maxCollectAmount", 4242)
    check("indexed set logs [set] record with leaf address",
        capturedContains("[PublicEvent] [set] PATH=eventRewards[1].maxCollectAmount")
            and capturedContains("OFF=0x28 ADDR=0x7A00011028 TYPE=Int32"), capturedText())
    check("indexed set logs OP=set summary",
        capturedContains("OP=set") and capturedContains("SLOWEST=eventRewards[1].maxCollectAmount"),
        capturedText())
    Nebula.log = false
    check("indexed set value landed while logging",
        api.get("eventRewards[1].maxCollectAmount") == 4242)

    Manifest.resolve = realResolve
end

--==================================================
-- Section 15b: whole element-struct write + :verify()/:dry()
--==================================================
print("=== whole element-struct write + verify/dry ===")
do
    local defineApi = loadModule("core/defineApi.lua")
    local Manifest = loadModule("metadata/manifest.lua")
    local realResolve = Manifest.resolve
    local FB = 0x50000C0000
    local SLOTS = 0x7A00020000
    local E1 = 0x7A00021000
    local E2 = 0x7A00022000
    local LOOT1 = 0x7A00023000
    local CRD = {
        ["rewardCondition"]  = { offset = 0x4,  type = "Float" },
        ["lootDefinition"]   = { offset = 0x20, type = "Object",
            elements = { ["type"] = { offset = 0x0, type = "Int32" } } },
        ["maxCollectAmount"] = { offset = 0x28, type = "Int32" },
    }
    local EV = { ["eventRewards"] = { offset = 0x528, type = "Array", elements = CRD } }
    writeVectorHeader(FB + 0x528, SLOTS, SLOTS + 2 * 0x8, SLOTS + 2 * 0x8)
    w64(SLOTS, E1); w64(SLOTS + 0x8, E2)
    w32(E1 + 0x4, 0x40B00000)          -- rewardCondition = 5.5f
    w64(E1 + 0x20, LOOT1); w32(LOOT1, 7)
    w32(E1 + 0x28, 100)
    w32(E2 + 0x4, 0x40B00000)          -- E2 lootDefinition ptr stays
    w32(E2 + 0x28, 200)                -- NULL: covered by the alloc path
    Manifest.resolve = function(s)
        if s == "EventDefinition" then return EV, "1.73", nil end
        return realResolve(s)
    end
    local api = defineApi.create({
        struct = "EventDefinition", name = "PublicEvent",
        resolve = function() return FB end,
    })

    -- (a) whole element-struct write, partial keys only
    local before = api.get("eventRewards[1].rewardCondition")
    local op = api.set("eventRewards[1]", { maxCollectAmount = 555 })
    check("element struct write succeeds", op._ok == true, tostring(op._err))
    check("element struct write landed",
        api.get("eventRewards[1].maxCollectAmount") == 555,
        tostring(api.get("eventRewards[1].maxCollectAmount")))
    check("partial write preserves sibling fields",
        api.get("eventRewards[1].rewardCondition") == before,
        tostring(api.get("eventRewards[1].rewardCondition")))
    check("element write kept slot pointer (no realloc)",
        readAt(SLOTS, FLAGS.INT64) == E1, string.format("%X", readAt(SLOTS, FLAGS.INT64)))

    -- (b) multi-key write, including a nested Object key
    --     (E2's lootDefinition pointer is NULL — the write must
    --      allocate a fresh object and patch the pointer; float
    --      keys are avoided because the byte-level mock cannot
    --      encode non-integral float writes — see writeAt())
    local op2 = api.set("eventRewards[2]", { maxCollectAmount = 444, lootDefinition = { type = 9 } })
    check("multi-key element write succeeds", op2._ok == true, tostring(op2._err))
    check("scalar key landed", api.get("eventRewards[2].maxCollectAmount") == 444,
        tostring(api.get("eventRewards[2].maxCollectAmount")))
    local newLootPtr = readAt(E2 + 0x20, FLAGS.INT64)
    check("null Object key allocated a fresh pointer",
        newLootPtr ~= 0, string.format("%X", newLootPtr))
    check("nested Object key landed",
        readAt(newLootPtr, FLAGS.INT32) == 9, readAt(newLootPtr, FLAGS.INT32))
    check("nested Object read-back decodes through the new pointer",
        api.get("eventRewards[2].lootDefinition.type") == 9,
        tostring(api.get("eventRewards[2].lootDefinition.type")))

    -- (c) unknown keys in the value table are a safe no-op
    local op3 = api.set("eventRewards[1]", { maxCollectAmount = 6464, bogusKey = "x" })
    check("unknown key is a safe no-op (write still succeeds)", op3._ok == true, tostring(op3._err))
    check("unknown key did not corrupt anything",
        api.get("eventRewards[1].maxCollectAmount") == 6464,
        tostring(api.get("eventRewards[1].maxCollectAmount")))

    -- (d) non-table value rejected with a clear error
    local op4 = api.set("eventRewards[1]", 12345)
    check("non-table element write rejected",
        op4._ok == false and tostring(op4._err) == "value_not_table", tostring(op4._err))

    -- (e) null slot pointer rejected, never blindly written
    local FB2 = 0x50000C8000
    local SLOTS2 = 0x7A00024000
    writeVectorHeader(FB2 + 0x528, SLOTS2, SLOTS2 + 2 * 0x8, SLOTS2 + 2 * 0x8)
    w64(SLOTS2, E1); w64(SLOTS2 + 0x8, 0)   -- slot 2 null
    local savedResolve = Manifest.resolve
    Manifest.resolve = function(s)
        if s == "EventDefinition" then
            local EV2 = { ["eventRewards"] = { offset = 0x528, type = "Array", elements = CRD } }
            return EV2, "1.73", nil
        end
        return realResolve(s)
    end
    local api2 = defineApi.create({
        struct = "EventDefinition", name = "PublicEvent",
        resolve = function() return FB2 end,
    })
    local op5 = api2.set("eventRewards[2]", { maxCollectAmount = 1 })
    check("null slot element write rejected",
        op5._ok == false and tostring(op5._err) == "null_element_ptr", tostring(op5._err))
    check("null slot was not written through",
        readAt(SLOTS2 + 0x8, FLAGS.INT64) == 0, string.format("%X", readAt(SLOTS2 + 0x8, FLAGS.INT64)))
    Manifest.resolve = savedResolve

    -- (f) :dry() re-validates the element path without a second
    --     write (set() itself already executed by construction)
    local op6 = api.set("eventRewards[1]", { maxCollectAmount = 31337 })
    check("write before dry landed",
        api.get("eventRewards[1].maxCollectAmount") == 31337,
        tostring(api.get("eventRewards[1].maxCollectAmount")))
    local dryOk, dryErr = op6:dry()
    check("dry re-validates the element path (writable + template detected)",
        dryOk == true, tostring(dryErr))
    check("dry performed no additional write",
        readAt(E1 + 0x28, FLAGS.INT32) == 31337,
        string.format("%X", readAt(E1 + 0x28, FLAGS.INT32)))

    -- (g) :verify() read-back on scalar and element writes
    local op7 = api.set("eventRewards[1].maxCollectAmount", 777):verify()
    check("verify passes when memory matches", op7._verified == true,
        tostring(op7._actual))
    -- set() executes at construction, so the game-stomp must come
    -- AFTER the write and BEFORE :verify() for verify to catch it
    local op8 = api.set("eventRewards[1].maxCollectAmount", 777)
    w32(E1 + 0x28, 1)   -- simulate the game stomping the value
    op8:verify()
    check("verify fails when memory differs", op8._verified == false,
        tostring(op8._actual))
    check("verify exposes the actual value", op8._actual == 1, tostring(op8._actual))
    local op9 = api.set("eventRewards[1]", { maxCollectAmount = 707 }):verify()
    check("verify passes on partial element write (expected-keys compare)",
        op9._verified == true, tostring(op9._actual))
    local op10 = api.set("eventRewards[9]", { maxCollectAmount = 1 })
    check("out-of-bounds element write rejected",
        op10._ok == false and tostring(op10._err):find("index_out_of_bounds", 1, true), tostring(op10._err))
    op10:verify()
    check("verify on failed write reports unverified", op10._verified == false, tostring(op10._verified))

    Manifest.resolve = realResolve
end

--==================================================
-- Section 16: ZeroPage free / reclaim
--==================================================
print("=== ZeroPage: free and reclaim ===")
do
    local ZeroPage = loadModule("core/ZeroPage.lua")

    -- Drain free-list leftovers from earlier sections so the
    -- best-fit/split/coalesce assertions below are deterministic.
    local function drainFreeList()
        local guard = 0
        while ZeroPage._status().freeBlocks > 0 and guard < 1024 do
            ZeroPage.allocate(8)
            guard = guard + 1
        end
        return ZeroPage._status().freeBlocks == 0
    end
    check("free list drained for deterministic tests", drainFreeList() == true, "drain did not finish")

    -- (a) basic reclaim: allocate, dirty, free, reallocate same size
    local A = ZeroPage.allocate(0x40)
    check("allocate returns an address", A ~= nil, "nil")
    w64(A, 0xDEADBEEF)
    check("fresh allocation is Nebula-tracked", ZeroPage.owns(A) == true, tostring(ZeroPage.owns(A)))
    check("not freed yet", ZeroPage.isFreed(A) == false, tostring(ZeroPage.isFreed(A)))
    check("free() reclaims it", ZeroPage.free(A) == true, "free returned false")
    check("isFreed reflects the reclaim", ZeroPage.isFreed(A) == true, tostring(ZeroPage.isFreed(A)))
    local A2 = ZeroPage.allocate(0x40)
    check("reallocation reuses the reclaimed block", A2 == A, string.format("%X ~= %X", A2 or 0, A or 0))
    check("reused block is re-zeroed (old data gone)",
        readAt(A, FLAGS.INT64) == 0, string.format("%X", readAt(A, FLAGS.INT64)))

    -- (b) split: a bigger reclaimed block serves smaller requests
    local B = ZeroPage.allocate(0x80)
    for off = 0, 0x78, 8 do w64(B + off, 0xCAFEBABE) end
    ZeroPage.free(B)
    local B1 = ZeroPage.allocate(0x20)
    local B2 = ZeroPage.allocate(0x20)
    check("split reuse: first half from block start", B1 == B, string.format("%X ~= %X", B1 or 0, B or 0))
    check("split reuse: second half adjacent", B2 == B + 0x20, string.format("%X ~= %X", B2 or 0, B or 0))
    check("both split halves re-zeroed",
        readAt(B, FLAGS.INT64) == 0 and readAt(B + 0x20, FLAGS.INT64) == 0,
        string.format("%X/%X", readAt(B, FLAGS.INT64), readAt(B + 0x20, FLAGS.INT64)))

    -- (c) double free and foreign free are no-ops
    ZeroPage.free(B1)
    check("double free rejected", ZeroPage.free(B1) == false, "double free returned true")
    check("free of foreign address rejected", ZeroPage.free(0x7A00009000) == false, "foreign free returned true")
    check("foreign address not owned", ZeroPage.owns(0x7A00009000) == false, "foreign address owned")

    -- (d) coalescing: two adjacent frees merge into one block
    check("free list re-drained", drainFreeList() == true, "drain did not finish")
    local C1 = ZeroPage.allocate(0x20)
    local C2 = ZeroPage.allocate(0x20)
    local C3 = ZeroPage.allocate(0x20)
    w64(C1, 1); w64(C2, 2); w64(C3, 3)
    ZeroPage.free(C2)
    ZeroPage.free(C3)   -- adjacent to C2 -> coalesce
    local D = ZeroPage.allocate(0x40)
    check("coalesced adjacent frees serve a 0x40 request",
        D == C2, string.format("%X ~= %X", D or 0, C2 or 0))
end

--==================================================
-- Section 17: ZeroPage persistence via PID-scoped cache
--==================================================
print("=== ZeroPage: PID-scoped cache persistence ===")
do
    local ZeroPage = loadModule("core/ZeroPage.lua")
    local Cache = loadModule("core/Cache.lua")

    -- drain free-list leftovers from earlier sections
    local guard = 0
    while ZeroPage._status().freeBlocks > 0 and guard < 1024 do
        ZeroPage.allocate(8)
        guard = guard + 1
    end

    -- (a) region claim writes the magic QWORD header at base
    local st = ZeroPage._status()
    check("region active after allocations", st.base ~= nil, "no region")
    check("magic QWORD written at region base",
        readAt(st.base, FLAGS.INT64) == st.magic,
        string.format("%X ~= %X", readAt(st.base, FLAGS.INT64), st.magic or 0))
    check("first 8 bytes reserved by the header", st.cursor >= 8, tostring(st.cursor))

    -- (b) free persists ownership to the PID-scoped cache
    local P = ZeroPage.allocate(0x40)
    w64(P, 0xABCD)
    ZeroPage.free(P)
    local snap = Cache.load("zeropage")
    check("snapshot saved under the zeropage cache id", type(snap) == "table", "nil")
    local reg = snap and snap.registry and snap.registry[P]
    check("freed block recorded as Nebula-owned in the snapshot",
        type(reg) == "table" and reg.freed == true and reg.size == 0x40, tostring(reg))
    check("region state persisted", snap and snap.base == st.base and snap.cursor ~= nil,
        tostring(snap and snap.base))

    -- (c) reload: state rebuilds from the cache (script-restart path)
    local cursorBefore = ZeroPage._status().cursor
    ZeroPage._reset()
    check("in-memory state cleared by reset", ZeroPage._status().base == nil, "base survived")
    local R = ZeroPage.allocate(0x40)
    check("restored region matches the persisted one",
        ZeroPage._status().base == st.base, string.format("%X", ZeroPage._status().base or 0))
    check("reclaimed block reused after reload", R == P, string.format("%X ~= %X", R or 0, P or 0))
    check("reused block re-zeroed after reload",
        readAt(P, FLAGS.INT64) == 0, string.format("%X", readAt(P, FLAGS.INT64)))
    check("ownership registry restored",
        ZeroPage.owns(P) == true and ZeroPage.isFreed(P) == false, tostring(ZeroPage.owns(P)))
    check("cursor continues from the persisted value",
        ZeroPage._status().cursor >= cursorBefore, tostring(ZeroPage._status().cursor))

    -- (d) a region whose magic was destroyed is NOT restored
    ZeroPage._reset()
    w64(st.base, 0x4141414141414141)  -- simulate the game reusing the region
    local bad = ZeroPage.allocate(0x40)
    check("torn region rejected — no stale restore",
        ZeroPage._status().base ~= st.base, string.format("%X", ZeroPage._status().base or 0))
end

print("=== file logging ===")
do
    local Logfile = loadModule("core/Logfile.lua")
    local defineApi = loadModule("core/defineApi.lua")
    local FAKE_BASE = 0x5000030000

    w32(FAKE_BASE + 0x150, 1700000000)
    local api = defineApi.create({
        struct  = "EventDefinition",
        name    = "PublicEvent",
        resolve = function() return FAKE_BASE end,
    })

    -- default: the environment scriptDir is resolvable, so diagnostics
    -- route to <scriptDir>nebula.log — intercepted by the harness
    -- into `captured`, byte-identical to the old console line
    Nebula.log = true
    clearCaptured()
    api.get("startTime")
    check("default sink resolves from the ENV scriptDir",
        capturedContains("[PublicEvent] [get] PATH=startTime"))
    check("default sink keeps the exact old line format",
        capturedContains("[Path] parse 'startTime' -> 1 segments"))

    -- explicit path: diagnostics go to the file ONLY, line by line,
    -- flushed immediately (nothing buffered — crash-safe)
    local LOGP = "/tmp/nebula_spec_nebula.log"
    os.remove(LOGP)
    Logfile.setPath(LOGP)
    clearCaptured()
    local st = api.get("startTime")
    check("get value correct while file logging", st == 1700000000, st)
    check("console is quiet while the log file is open",
        #captured == 0, table.concat(captured, " | "))

    local content = ""
    do
        local f = io.open(LOGP, "r")
        if f then content = f:read("a"); f:close() end
    end
    check("records written to file without any flush call",
        content:find("[PublicEvent] [get] PATH=startTime", 1, true) ~= nil
            and content:find("[resolve] ADDR=0x5000030000 MODE=warm", 1, true) ~= nil,
        content:sub(1, 200))
    check("file line format identical to the old console line",
        content:find("[Path] parse 'startTime' -> 1 segments", 1, true) ~= nil)
    check("no timestamps or extra prefixes added",
        content:sub(1, 1) == "[")

    -- restore the scriptDir-based default for the sections after this
    Logfile.setPath(nil)
    clearCaptured()
    api.get("startTime")
    check("scriptDir default restored after setPath(nil)",
        capturedContains("[PublicEvent] [get] PATH=startTime"))

    -- true console fallback: no ENV scriptDir, no gg.getFile in the mock
    local savedDir = ENV.scriptDir
    ENV.scriptDir = nil
    Logfile.setPath(nil)
    clearCaptured()
    api.get("startTime")
    check("print fallback when scriptDir is unavailable (no gg.getFile fallback)",
        capturedContains("[PublicEvent] [get] PATH=startTime"))
    ENV.scriptDir = savedDir
    Logfile.setPath(nil)

    Nebula.log = false
    os.remove(LOGP)
end

print = realPrint
print("")
print(string.format("=== %d passed, %d failed ===", pass, fail))
if fail > 0 then os.exit(1) end
