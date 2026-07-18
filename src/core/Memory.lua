--==================================================
-- core/Memory.lua
--==================================================
-- Thin wrapper around GameGuardian's gg.getValues/gg.setValues.
-- Every Type module and api/*.lua goes through this instead of
-- calling gg.* directly. This is the only file allowed to know
-- about gg.* flag numbers.

local M = {}

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
    local ok = pcall(function()
        gg.setValues(specs)
    end)
    vlog("writeBatch", #specs, startTime)

    return ok
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

return M