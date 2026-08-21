--==================================================
-- core/Memory.lua
--==================================================
-- Thin wrapper around GameGuardian's gg.getValues/gg.setValues.
-- Every Type module and api/*.lua goes through this instead of
-- calling gg.* directly. This is the only file allowed to know
-- about gg.* flag numbers.
--
-- Also owns base-address resolution for the four structs Nebula
-- reads (GameStatus, PublicEvent, TeamEvent, CommunityEvent).
-- Resolution for PublicEvent and TeamEvent integrates a persistent
-- address cache (core/Cache.lua) so that addresses discovered in a
-- previous run survive even after the user modifies signature fields
-- — but the AOB scan ALWAYS runs. See resolveActiveTeamEventBase()
-- and resolveActivePublicEventBase() below for the merge flow.
-- CommunityEvent uses a string-search resolver instead of AOB but
-- shares the same cache integration — see
-- resolveActiveCommunityEventBase().

local M = {}

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.Memory]", ...)
    end
end



-- GG value-type flags used throughout Nebula.
M.FLAGS = {
    BYTE   = 1,
    WORD   = 2,
    INT32  = 4,
    XOR    = 8,   -- unused/reserved
    FLOAT  = 16,
    INT64  = 32,  -- also used for pointers
    DOUBLE = 64,
}

M.FLAGS.POINTER = M.FLAGS.INT64

---Verbose, timed logging for every gg.* round-trip. Off by default
---— gated by Nebula.verbose (separate from Nebula.log, which is
---for api/GameStatus.lua's higher-level get/set/dry logging). Use
---this to see where time is actually going: number of gg calls,
---batch sizes, and per-call duration.
local function vlog(label, count, startTime)
    if Nebula ~= nil and Nebula.verbose then
        local elapsedMs = (os.clock() - startTime) * 1000
        print(string.format("[Nebula.Memory] %-12s count=%-4d %.2fms", label, count, elapsedMs))
    end
end

---Read a single value at an address with a given flag.
---@param address integer
---@param flags integer
---@return any|nil value, string|nil error
function M.read(address, flags)
    if address == nil or address == 0 then
        return nil, "nil_address"
    end

    local startTime = os.clock()
    local ok, result = pcall(function()
        return gg.getValues({ { address = address, flags = flags } })
    end)
    vlog("read", 1, startTime)

    if not ok or type(result) ~= "table" or result[1] == nil then
        return nil, "read_failed"
    end

    return result[1].value
end

---Read multiple {address, flags} pairs in one batched call.
---@param specs table[] @ array of { address = int, flags = int }
---@return table[]|nil results, string|nil error
function M.readBatch(specs)
    local startTime = os.clock()
    local ok, result = pcall(function()
        return gg.getValues(specs)
    end)
    vlog("readBatch", #specs, startTime)

    if not ok or type(result) ~= "table" then
        return nil, "read_failed"
    end

    return result
end

---Write a single value at an address with a given flag.
---@param address integer
---@param flags integer
---@param value any
---@return boolean ok
function M.write(address, flags, value)
    if address == nil or address == 0 then
        return false
    end

    local startTime = os.clock()
    local ok = pcall(function()
        gg.setValues({ { address = address, flags = flags, value = value } })
    end)
    vlog("write", 1, startTime)

    return ok
end

---Write multiple {address, flags, value} triples in one batched call.
---@param specs table[]
---@return boolean ok
function M.writeBatch(specs)
    local startTime = os.clock()
    local ok, result = pcall(function()
        return gg.setValues(specs)
    end)
    vlog("writeBatch", #specs, startTime)

    -- pcall catches errors; also check gg.setValues return value
    -- (some GG versions return false instead of throwing)
    return ok and result ~= false
end

-- Max specs sent to gg.getValues/setValues in a single call.
-- Even with header size/capacity sanity-checked (see
-- core/Repeated.lua), a legitimately large repeated field could
-- still produce a batch big enough to strain GG's IPC layer in one
-- shot. Chunking keeps every individual gg.* call small and
-- predictable regardless of how many specs the caller has.
M.MAX_BATCH_SIZE = 256

---Read multiple {address, flags} pairs, transparently chunked into
---calls of at most M.MAX_BATCH_SIZE each. Result order matches
---input order.
---@param specs table[]
---@return table[]|nil results, string|nil error
function M.readBatchChunked(specs)
    if #specs <= M.MAX_BATCH_SIZE then
        return M.readBatch(specs)
    end

    local results = {}
    for i = 1, #specs, M.MAX_BATCH_SIZE do
        local chunk = {}
        for j = i, math.min(i + M.MAX_BATCH_SIZE - 1, #specs) do
            chunk[#chunk + 1] = specs[j]
        end

        local chunkResults, err = M.readBatch(chunk)
        if not chunkResults then
            return nil, err
        end

        for _, r in ipairs(chunkResults) do
            results[#results + 1] = r
        end
    end

    return results
end

---Write multiple {address, flags, value} triples, transparently
---chunked into calls of at most M.MAX_BATCH_SIZE each.
---@param specs table[]
---@return boolean ok
function M.writeBatchChunked(specs)
    if #specs <= M.MAX_BATCH_SIZE then
        return M.writeBatch(specs)
    end

    for i = 1, #specs, M.MAX_BATCH_SIZE do
        local chunk = {}
        for j = i, math.min(i + M.MAX_BATCH_SIZE - 1, #specs) do
            chunk[#chunk + 1] = specs[j]
        end

        if not M.writeBatch(chunk) then
            return false
        end
    end

    return true
end

---Copy a contiguous block of memory from src to dst. Uses 8-byte
---(INT64) chunks wherever possible, falling back to single bytes
---only for the final <8 remainder, and batches every read/write
---into as few gg.* calls as MAX_BATCH_SIZE allows. Replaces the
---old pattern of one gg call per byte, which is both 8x more specs
---and — critically — was issuing the writes one at a time instead
---of batched.
---@param src integer
---@param dst integer
---@param length integer
---@return boolean ok
function M.copyRegion(src, dst, length)
    if length <= 0 then
        return true
    end

    local specs = {}
    local offset = 0
    while offset < length do
        if length - offset >= 8 then
            specs[#specs + 1] = { address = src + offset, flags = M.FLAGS.INT64 }
            offset = offset + 8
        else
            specs[#specs + 1] = { address = src + offset, flags = M.FLAGS.BYTE }
            offset = offset + 1
        end
    end

    local readData, err = M.readBatchChunked(specs)
    if not readData then
        return false
    end

    local writes = {}
    offset = 0
    for i, spec in ipairs(specs) do
        local value = readData[i] and readData[i].value or 0
        writes[i] = { address = dst + offset, flags = spec.flags, value = value }
        offset = offset + (spec.flags == M.FLAGS.INT64 and 8 or 1)
    end

    return M.writeBatchChunked(writes)
end

---Follow a pointer field: read the pointer value stored at
---`baseAddress + offset`, returning the address it points to.
---@param baseAddress integer
---@param offset integer
---@return integer|nil pointer, string|nil error
function M.deref(baseAddress, offset)
    local ptr, err = M.read(baseAddress + offset, M.FLAGS.POINTER)
    if ptr == nil or ptr == 0 then
        return nil, err or "null_pointer"
    end
    return ptr
end

--==================================================
-- Base address resolution
--==================================================
-- Finds the live GameStatus struct in memory by locating the
-- "startup_count" string constant, then walking a fixed chain of
-- pointer derefs to reach the real struct base:
--
--   hit            = AOB match address of "startup_count"
--   ptr            = read(hit + 0x1F, INT64)     -- object holding the string
--   ver            = read(ptr + 0x10, INT32)     -- vtable/version marker
--   typePtr        = read(ptr + 0x80, INT64)     -- pointer to the actual struct
--   base           = read(typePtr, INT32).address -- the struct's own address
--
-- The scan must run per-region (gg.REGION_C_ALLOC / gg.REGION_OTHER)
-- — searching all regions at once misses the hit in some game
-- states, which is why this previously failed.
--
-- Result is cached per script session — see api/GameStatus.lua's
-- resolveBase(), which owns the cache. This function always does
-- a fresh scan; callers are responsible for caching.

local SIGNATURE_HEX = "73 74 61 72 74 75 70 5F 63 6F 75 6E 74" -- "startup_count"
local VALID_VTABLE_MARKERS = {
    [65792]    = true,
    [65793]    = true,
    [16843008] = true,
    [16843009] = true,
}

M.SEARCH_REGIONS = { gg.REGION_C_ALLOC, gg.REGION_OTHER }

local function regionName(region)
    if region == gg.REGION_C_ALLOC then return "C_ALLOC" end
    if region == gg.REGION_OTHER then return "OTHER" end
    return tostring(region)
end

---Scan a single region for GameStatus struct base address hits.
---@param region integer
---@return integer[] found
local function scanRegion(region)
    local found = {}

    gg.clearResults()
    gg.setRanges(region)
    gg.searchNumber("h " .. SIGNATURE_HEX, 1)
    gg.refineNumber("h 73", 1)

    local results = gg.getResults(gg.getResultsCount())
    gg.clearResults()

    if not results or #results == 0 then
        return found
    end

    for _, hit in ipairs(results) do
        local ptr = M.read(hit.address + 0x1F, M.FLAGS.INT64)

        if ptr ~= nil and ptr ~= 0 then
            -- Sanity-check: a real pointer should be in a plausible
            -- memory range. Values outside this look like ASCII text
            -- from false-positive AOB matches inside string literals.
            if ptr >= 0x10000 and ptr <= 0x7FFFFFFFFFFF then
                local ver = M.read(ptr + 0x10, M.FLAGS.INT32)
                if ver ~= nil and VALID_VTABLE_MARKERS[ver] then
                    local typePtr = M.read(ptr + 0x80, M.FLAGS.INT64)
                    if typePtr ~= nil and typePtr ~= 0 then
                        -- Reference reads a value AT typePtr just to confirm
                        -- the address is live/readable, then uses typePtr
                        -- itself (not the value read) as the resolved base.
                        local probe = M.read(typePtr, M.FLAGS.INT32)
                        if probe ~= nil then
                            table.insert(found, typePtr)
                        end
                    end
                end
            end
        end
    end

    return found
end

---Scan process memory for the GameStatus struct base address.
---Expensive — call once per session and cache the result.
---@return integer[]|nil addresses, string|nil error
function M.resolveGameStatusBase()
    for _, region in ipairs(M.SEARCH_REGIONS) do
        local ok, found = pcall(scanRegion, region)
        if ok and found and #found > 0 then
            return found
        end
    end

    return nil, "no_valid_matches"
end

--==================================================
-- Event address validation
--==================================================
-- Validates that a given address is a real event struct (not
-- freed/unmapped memory or a false positive). The AOB signature
-- may have been modified by the user (e.g. eventTicketRefillCost
-- changed from 50 to 999), so validation must NOT rely on the
-- signature bytes. Instead it checks structural fields that are
-- invariant under user modification:
--
--   contentVersion (0x0) — small positive number
--   startTime      (0x14C) — Unix timestamp > 1.5 billion
--   endTime        (0x154) — Unix timestamp > 1.5 billion
--   startTime < endTime  — valid event window
--
-- All three reads must succeed (address is in mapped memory).

-- Schema minimum for startTime/endTime — matches the JSON schema's
-- "minimum": 1500000000 constraint.
local MIN_TIMESTAMP = 1500000000

---Validate a single event struct address by reading structural
---fields that should be present regardless of signature
---modification. Returns true if all checks pass.
---@param addr integer  base address of the event struct
---@return boolean valid
local function validateEventAddress(addr)
    if addr == nil or addr == 0 then
        return false
    end

    -- Batch-read contentVersion, startTime, endTime in one call.
    local specs = {
        { address = addr,        flags = M.FLAGS.INT32 },  -- contentVersion @ 0x0
        { address = addr + 0x14C, flags = M.FLAGS.INT32 }, -- startTime
        { address = addr + 0x154, flags = M.FLAGS.INT32 }, -- endTime
    }

    local results, err = M.readBatch(specs)
    if not results or #results < 3 then
        return false
    end

    local contentVersion = results[1].value
    local startTime = results[2].value
    local endTime = results[3].value

    -- contentVersion: small positive number
    if contentVersion == nil or contentVersion < 0 or contentVersion > 10000 then
        return false
    end

    -- startTime / endTime: plausible Unix timestamps
    if startTime == nil or startTime < MIN_TIMESTAMP then
        return false
    end
    if endTime == nil or endTime < MIN_TIMESTAMP then
        return false
    end

    -- Valid event window
    if startTime >= endTime then
        return false
    end

    return true
end

M.validateEventAddress = validateEventAddress

--==================================================
-- Address cache integration helpers
--==================================================
-- Merges cached and AOB-discovered addresses into a single
-- deduplicated list of valid addresses, then persists the result.
-- The AOB scan ALWAYS runs — cache is supplementary, not a
-- replacement.
--
-- Flow:
--   load cache → validate cached → AOB scan → validate AOB →
--   merge + deduplicate → save cache → return combined

---Merge cached and AOB-discovered addresses: validate each,
---deduplicate, save the combined list, and return it.
---@param cacheId string       logical cache ID (e.g. "team_event_addresses")
---@param aobBases integer[]   raw AOB scan results (already signature-matched)
---@return integer[] combined  valid, deduplicated addresses
local function resolveWithCache(cacheId, aobBases, validator)
    validator = validator or validateEventAddress

    local Cache = loadModule("core/Cache.lua")

    local cached = Cache.load(cacheId)
    if cached == nil then
        cached = {}
    end

    local validCached = {}
    for _, addr in ipairs(cached) do
        if validator(addr) then
            validCached[#validCached + 1] = addr
        end
    end

    local validAob = {}
    for _, addr in ipairs(aobBases) do
        if validator(addr) then
            validAob[#validAob + 1] = addr
        end
    end

    -- 4. Merge + deduplicate
    local seen = {}
    local combined = {}
    for _, addr in ipairs(validCached) do
        if not seen[addr] then
            seen[addr] = true
            combined[#combined + 1] = addr
        end
    end
    for _, addr in ipairs(validAob) do
        if not seen[addr] then
            seen[addr] = true
            combined[#combined + 1] = addr
        end
    end

    -- 5. Save the combined list back to cache
    if #combined > 0 then
        Cache.save(cacheId, combined)
    end

    return combined
end

--==================================================
-- TeamEvent base resolution
--==================================================
-- Finds every live TeamEvent struct in memory by searching for the
-- raw bytes of three back-to-back sessionEntry fields:
-- eventTicketRefillTime=14400, eventTicketRefillAmount=2,
-- eventTicketRefillCost=50 (offsets 0x168/0x16C/0x170). These are
-- event-design constants, not per-instance data, so the byte
-- pattern is stable across restarts — UNLESS a future update
-- rebalances any of those three numbers, in which case this search
-- will silently return zero hits. That's the signal to re-derive
-- the signature, not a bug in the walk itself.
--
-- The AOB signature bytes can also be modified by an SDK user who
-- changes eventTicketRefillCost etc. via Nebula.TeamEvent.set().
-- To survive that, resolveActiveTeamEventBase() integrates the
-- persistent address cache: cached addresses that still pass
-- structural validation are kept even when the AOB signature no
-- longer matches them. The AOB scan ALWAYS runs regardless.

local TEAM_EVENT_SIGNATURE_HEX = "40 38 00 00 02 00 00 00 32 00 00 00"
local TEAM_EVENT_SIGNATURE_OFFSET = 0x168 -- eventTicketRefillTime, relative to struct base
local TEAM_EVENT_START_TIME_OFFSET = 0x14C
local TEAM_EVENT_END_TIME_OFFSET = 0x154

---Scan process memory for every live TeamEvent struct base address
---(via the sessionEntry byte signature), regardless of which one is
---currently active.
---@return integer[]|nil bases, string|nil error
function M.findTeamEventBases()
    for _, region in ipairs(M.SEARCH_REGIONS) do
        gg.clearResults()
        gg.setRanges(region)
        gg.searchNumber("h " .. TEAM_EVENT_SIGNATURE_HEX, 1)
        gg.refineNumber("64", 1) -- re-check eventTicketRefillTime's low byte (0x40 = 64)

        local results = gg.getResults(gg.getResultsCount())
        gg.clearResults()

        if results and #results > 0 then
            local bases = {}
            for _, hit in ipairs(results) do
                bases[#bases + 1] = hit.address - TEAM_EVENT_SIGNATURE_OFFSET
            end
            return bases
        end
    end

    return nil, "signature_not_found"
end

---Resolve the struct base of whichever TeamEvent is currently
---active (startTime < now < endTime). Integrates the persistent
---address cache so addresses discovered in a previous run survive
---even after the user modifies signature fields.
---@return integer|nil base, string|nil error
function M.resolveActiveTeamEventBase()
    -- AOB scan ALWAYS runs first.
    local aobBases, aobErr = M.findTeamEventBases()
    if not aobBases then
        aobBases = {}
    end

    -- Merge cached + AOB, validate, deduplicate, save.
    local combined = resolveWithCache("team_event_addresses", aobBases)

    if #combined == 0 then
        return nil, "no_active_team_event"
    end

    -- Filter for the currently-active event
    local currentTime = os.time()
    local readList = {}
    for _, base in ipairs(combined) do
        readList[#readList + 1] = { address = base + TEAM_EVENT_START_TIME_OFFSET, flags = M.FLAGS.INT32 }
        readList[#readList + 1] = { address = base + TEAM_EVENT_END_TIME_OFFSET, flags = M.FLAGS.INT32 }
    end

    local readValues, readErr = M.readBatch(readList)
    if not readValues then
        return nil, readErr
    end

    for i = 1, (#readValues / 2) do
        local startTime = readValues[i * 2 - 1].value
        local endTime = readValues[i * 2].value
        if startTime ~= nil and endTime ~= nil and startTime < currentTime and currentTime < endTime then
            return combined[i]
        end
    end

    return nil, "no_active_team_event"
end

--==================================================
-- PublicEvent base resolution
--==================================================
-- Same pattern as the TeamEvent section above. The anchor here is
-- gemsToPointsConversion=6 immediately followed by
-- conversionDuration=86400 (1 day) — offsets 0x3F0/0x3F4, part of
-- the header shared between PublicEvent and TeamEvent (see
-- metadata/PublicEvent.lua). Same fragility caveat: if either of
-- those two constants ever changes, this signature silently stops
-- matching.
--
-- Same cache integration as TeamEvent: the AOB scan always runs,
-- and cached addresses that pass structural validation are kept.

local PUBLIC_EVENT_SIGNATURE_HEX = "06 00 00 00 80 51 01 00"
local PUBLIC_EVENT_SIGNATURE_OFFSET = 0x3F0 -- gemsToPointsConversion, relative to struct base
local PUBLIC_EVENT_START_TIME_OFFSET = 0x14C
local PUBLIC_EVENT_END_TIME_OFFSET = 0x154

---Scan process memory for every live PublicEvent struct base address.
---@return integer[]|nil bases, string|nil error
function M.findPublicEventBases()
    for _, region in ipairs(M.SEARCH_REGIONS) do
        gg.clearResults()
        gg.setRanges(region)
        gg.searchNumber("h " .. PUBLIC_EVENT_SIGNATURE_HEX, 1)
        gg.refineNumber("6", 1) -- re-check gemsToPointsConversion is still 6

        local results = gg.getResults(gg.getResultsCount())
        gg.clearResults()

        if results and #results > 0 then
            local bases = {}
            for _, hit in ipairs(results) do
                bases[#bases + 1] = hit.address - PUBLIC_EVENT_SIGNATURE_OFFSET
            end
            return bases
        end
    end

    return nil, "signature_not_found"
end

---Resolve the struct base of whichever PublicEvent is currently
---active (startTime < now < endTime). Same caching convention as
---resolveActiveTeamEventBase() — cache + AOB always run.
---@return integer|nil base, string|nil error
function M.resolveActivePublicEventBase()
    -- AOB scan ALWAYS runs first.
    local aobBases, aobErr = M.findPublicEventBases()
    if not aobBases then
        aobBases = {}
    end

    -- Merge cached + AOB, validate, deduplicate, save.
    local combined = resolveWithCache("public_event_addresses", aobBases)

    if #combined == 0 then
        return nil, "no_active_public_event"
    end

    -- Filter for the currently-active event
    local currentTime = os.time()
    local readList = {}
    for _, base in ipairs(combined) do
        readList[#readList + 1] = { address = base + PUBLIC_EVENT_START_TIME_OFFSET, flags = M.FLAGS.INT32 }
        readList[#readList + 1] = { address = base + PUBLIC_EVENT_END_TIME_OFFSET, flags = M.FLAGS.INT32 }
    end

    local readValues, readErr = M.readBatch(readList)
    if not readValues then
        return nil, readErr
    end

    for i = 1, (#readValues / 2) do
        local startTime = readValues[i * 2 - 1].value
        local endTime = readValues[i * 2].value
        if startTime ~= nil and endTime ~= nil and startTime < currentTime and currentTime < endTime then
            return combined[i]
        end
    end

    return nil, "no_active_public_event"
end


--==================================================
-- CommunityEvent base resolution
--==================================================
-- Finds the CommunityShowcase struct in memory via a string-search
-- method.
--
-- Unlike PublicEvent/TeamEvent (AOB byte-signature scan), the
-- CommunityShowcase is located by searching for its own name field:
-- the ASCII bytes of "community Showcase\0". This is a more stable
-- search target than a config constant — it's the event's identity,
-- not a tunable value that could change between events.
--
-- Flow:
--   1. Search for "community Showcase\0" as raw bytes (BYTE flag)
--   2. Refine: the first byte of the hit must be 0x24 ('$' — the
--      SSO length byte of the std::string at name offset 0x20)
--   3. For each hit: read hit.address - 0x18 as INT32
--      If it equals 0x6D6F631E (a vtable/type marker), the hit is
--      inside a real CommunityShowcase struct
--   4. Struct base = hit.address - 0x20 (name field is at offset
--      0x20 in the struct, so base = hit - 0x20)
--   5. Validate structurally (startTime/endTime plausible)
--
-- The vtable marker 0x6D6F631E is the low 4 bytes of the string
-- "comm" (0x6D6F631E in little-endian) — used to
-- distinguish real struct hits from false-positive string matches
-- elsewhere in memory. It's read at hit-0x18, which is the
-- beginning of the std::string object's internal SSO buffer (the
-- string data starts at +0x8 in the string object, and the object
-- starts at name_offset - 0x8 = 0x18... actually the exact layout
-- reason is that the marker is a type tag in the struct header
-- area, not the string itself).
--
-- Same cache integration: string scan always runs, cached addresses
-- that pass validation are kept and merged.

local COMMUNITY_EVENT_NAME_HEX = "24 43 6F 6D 6D 75 6E 69 74 79 20 53 68 6F 77 63 61 73 65 00"
local COMMUNITY_EVENT_VTABLE_MARKER = 0x6D6F631E
local COMMUNITY_EVENT_NAME_OFFSET = 0x20 -- name field offset in struct
local COMMUNITY_EVENT_START_TIME_OFFSET = 0x14C
local COMMUNITY_EVENT_END_TIME_OFFSET = 0x154

---Scan process memory for the CommunityShowcase struct base address
---via string search + vtable marker validation.
---@return integer[]|nil bases, string|nil error
function M.findCommunityEventBases()
    for _, region in ipairs(M.SEARCH_REGIONS) do
        gg.clearResults()
        gg.setRanges(region)
        gg.searchNumber("h " .. COMMUNITY_EVENT_NAME_HEX, 1)
        gg.refineNumber("36", 1) -- 0x24 = 36, first byte of the name string

        local results = gg.getResults(gg.getResultsCount())
        gg.clearResults()

        if not results or #results == 0 then
            goto nextRegion
        end

        -- Batch-read vtable markers for all hits at once.
        local markerSpecs = {}
        for _, hit in ipairs(results) do
            markerSpecs[#markerSpecs + 1] = {
                address = hit.address - 0x18,
                flags = M.FLAGS.INT32
            }
        end

        local markerResults = M.readBatchChunked(markerSpecs)
        if not markerResults then
            goto nextRegion
        end

        local bases = {}
        for i, hit in ipairs(results) do
            if markerResults[i] and markerResults[i].value == COMMUNITY_EVENT_VTABLE_MARKER then
                bases[#bases + 1] = hit.address - COMMUNITY_EVENT_NAME_OFFSET
            end
        end

        if #bases > 0 then
            return bases
        end

        ::nextRegion::
    end

    return nil, "signature_not_found"
end

---Resolve the struct base of the currently-active CommunityEvent
---(startTime < now < endTime). Same caching convention as the
---other event modules — string scan always runs, cache merges.
---@return integer|nil base, string|nil error
function M.resolveActiveCommunityEventBase()
    -- String scan ALWAYS runs first.
    local scanBases, scanErr = M.findCommunityEventBases()
    if not scanBases then
        scanBases = {}
    end

    local function validateCommunityEventAddress(addr)
        if addr == nil or addr == 0 then
            return false
        end
        local marker = M.read(addr + COMMUNITY_EVENT_NAME_OFFSET - 0x18, M.FLAGS.INT32)
        return marker == COMMUNITY_EVENT_VTABLE_MARKER
    end

    local combined = resolveWithCache("community_event_addresses", scanBases, validateCommunityEventAddress)

    if #combined == 0 then
        return nil, "no_active_community_event"
    end

    -- Filter for the currently-active event
    local currentTime = os.time()
    local readList = {}
    for _, base in ipairs(combined) do
        readList[#readList + 1] = { address = base + COMMUNITY_EVENT_START_TIME_OFFSET, flags = M.FLAGS.INT32 }
        readList[#readList + 1] = { address = base + COMMUNITY_EVENT_END_TIME_OFFSET, flags = M.FLAGS.INT32 }
    end

    local readValues, readErr = M.readBatch(readList)
    if not readValues then
        return nil, readErr
    end

    for i = 1, (#readValues / 2) do
        local startTime = readValues[i * 2 - 1].value
        local endTime = readValues[i * 2].value
        if startTime ~= nil and endTime ~= nil and startTime < currentTime and currentTime < endTime then
            return combined[i]
        end
    end

    -- No active event found — if there's only one result, return it
    -- anyway (CommunityShowcase may not have startTime/endTime set
    -- the same way as PublicEvent/TeamEvent).
    if #combined == 1 then
        return combined[1]
    end

    return nil, "no_active_community_event"
end

return M
