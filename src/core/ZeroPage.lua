--==================================================
-- core/ZeroPage.lua
--==================================================

local Memory = loadModule("core/Memory.lua")
-- Bump-allocator for scratch memory, using alloc.lua's
-- safe region-selection logic.
--
-- Safety rules (from alloc.lua):
--   - Only rw-p (read/write private) regions
--   - Skip .bss, .data, [stack], [heap], thread stacks,
--     signal stacks — all look empty but are live game memory
--   - Verify zeros with gg.getValues, not gg.searchNumber
--   - Track claimed regions to prevent double-allocation
--
-- The bump allocator hands out 8-byte-aligned addresses
-- from a found zero region. When the cursor exceeds the
-- region, it re-probes for a fresh one.

local M = {}

local Logfile = loadModule("core/Logfile.lua")
local Cache   = loadModule("core/Cache.lua")

local function log(...)
    if Nebula and Nebula.log then
        Logfile.log("[ZeroPage]", ...)
    end
end



local DEFAULT_REGION_BYTES = 2048
local MIN_REGION_BYTES     = 256

local zeroPageBase   = nil
local zeroPageCursor = 0
local zeroPageSize   = 0
local _claimed       = {}

-- Reclaim bookkeeping: every handed-out block is registered, and
-- freed blocks return to a free list for reuse (zeroed on reuse).
-- free() is pure bookkeeping — no memory writes — so it is always
-- safe to call; the actual clearing happens at the next allocate.
local _registry = {}  -- addr -> { size, freed }
local _freeList = {}  -- array of { addr, size }

-- Persistence: the allocation registry lives in the PID-scoped
-- cache (core/Cache.lua), so ownership survives script reloads
-- within one game process and is auto-invalidated on a game
-- restart (the cache manifest drops everything when the PID
-- changes). The magic QWORD at the region base proves the
-- region still holds OUR data — if the game reused the memory
-- in between, we start fresh instead of handing out live bytes.
local CACHE_ID     = "zeropage"
local MAGIC        = 0x5A45524F50414745  -- "ZEROPAGE"
local _restoreTried = false

local function persistSnapshot()
    if zeroPageBase == nil then return end
    pcall(Cache.save, CACHE_ID, {
        base     = zeroPageBase,
        size     = zeroPageSize,
        cursor   = zeroPageCursor,
        registry = _registry,
        freeList = _freeList,
        claimed  = _claimed,
    })
end

-- Rebuild ZeroPage state from the PID-scoped cache after a script
-- reload. Called lazily from allocate() only.
local function restoreFromCache()
    if zeroPageBase ~= nil or _restoreTried then return false end
    _restoreTried = true
    local ok, cached = pcall(Cache.load, CACHE_ID)
    if not ok or type(cached) ~= "table" then return false end
    local base, size, cursor = cached.base, cached.size, cached.cursor
    if type(base) ~= "number" or type(size) ~= "number" or type(cursor) ~= "number" then
        return false
    end
    if Memory.read(base, Memory.FLAGS.INT64) ~= MAGIC then
        log("restore: region magic mismatch — starting fresh")
        return false
    end
    zeroPageBase   = base
    zeroPageSize   = size
    zeroPageCursor = math.max(cursor, 8)
    if type(cached.claimed) == "table" then
        for k, info in pairs(cached.claimed) do
            if type(k) == "number" and type(info) == "table" then
                _claimed[k] = { size = info.size }
            end
        end
    end
    if type(cached.registry) == "table" then
        for addr, e in pairs(cached.registry) do
            if type(addr) == "number" and type(e) == "table" then
                _registry[addr] = { size = e.size, freed = e.freed == true }
            end
        end
    end
    if type(cached.freeList) == "table" then
        for _, b in ipairs(cached.freeList) do
            if type(b) == "table" and type(b.addr) == "number" and type(b.size) == "number" then
                _freeList[#_freeList + 1] = { addr = b.addr, size = b.size }
            end
        end
    end
    log(string.format("restore: region=0x%X cursor=%d/%d (PID-scoped cache hit)",
        base, zeroPageCursor, size))
    return true
end

-- Returns true for regions that are unsafe to write into.
-- Only rw-p (read/write private) pages are safe.
local function isDangerousRegion(region)
    local perms = region.type or ""
    if perms ~= "" and perms ~= "rw-p" then
        return true
    end
    local name         = region.name         or ""
    local internalName = region.internalName or ""
    if name:match("%.bss") or internalName:match(":bss") then
        return true
    end
    if name:match("%.data") or internalName:match(":data") then
        return true
    end
    if name:match("%[stack%]")
        or name:match("stack_and_tls")
        or name:match("signal stack")
        or internalName:match("stack_and_tls")
        or internalName:match("signal stack")
        or name:match("%[heap%]") then
        return true
    end
    return false
end

local function isClaimed(base, size)
    for claimedBase, info in pairs(_claimed) do
        local claimedEnd = claimedBase + info.size
        local reqEnd     = base + size
        if base < claimedEnd and reqEnd > claimedBase then
            return true
        end
    end
    return false
end

-- Verify that a range of memory is all zeros using gg.getValues.
-- Reads in chunks to avoid GG batch limits.
local function verifyZeros(base, byteCount)
    local step   = 4   -- DWORD step
    local slots  = {}
    local addr   = base
    while addr < base + byteCount do
        slots[#slots + 1] = { address = addr, flags = 4 }
        addr = addr + step
    end
    if #slots == 0 then return true end
    local results = gg.getValues(slots)
    if not results then return false end
    for _, v in ipairs(results) do
        if v.value ~= 0 then return false end
    end
    return true
end

-- Find a safe zero region using gg.getRangesList.
-- Tries progressively smaller region sizes until one is found.
local function findZeroRegion(desiredBytes)
    desiredBytes = desiredBytes or DEFAULT_REGION_BYTES
    local regions = gg.getRangesList()

    -- Try the desired size first, then shrink by half each round
    local sizes = { desiredBytes }
    local s = desiredBytes
    while s > MIN_REGION_BYTES do
        s = math.floor(s / 2)
        sizes[#sizes + 1] = s
    end

    for _, regionBytes in ipairs(sizes) do
        local dwords = math.floor(regionBytes / 4)
        if dwords >= 8 then  -- need at least 32 bytes
            for _, region in ipairs(regions) do
                local regionSize = region["end"] - region.start

                if (region.state == "O" or region.state == "Ca")
                   and not isDangerousRegion(region)
                   and regionSize >= regionBytes then

                    local base = region.start
                    local rem = base % 8
                    if rem ~= 0 then base = base + (8 - rem) end

                    if base + regionBytes <= region["end"]
                       and not isClaimed(base, regionBytes) then

                        if verifyZeros(base, regionBytes) then
                            _claimed[base] = { size = regionBytes }
                            log(string.format("found zero region: base=0x%X size=%d (wanted %d)",
                                base, regionBytes, desiredBytes))
                            return base, regionBytes
                        end
                    end
                end
            end
        end
    end

    return nil, 0
end

function M.owns(addr)
    return _registry[addr] ~= nil
end

function M.isFreed(addr)
    local e = _registry[addr]
    return e ~= nil and e.freed == true
end

-- Insert a block into the free list, coalescing with adjacent
-- free blocks to keep fragmentation down.
local function insertFree(addr, size)
    local mergedAddr, mergedSize = addr, size
    local keep = {}
    for _, b in ipairs(_freeList) do
        if b.addr + b.size == mergedAddr then
            mergedAddr = b.addr
            mergedSize = mergedSize + b.size
        elseif mergedAddr + mergedSize == b.addr then
            mergedSize = mergedSize + b.size
        else
            keep[#keep + 1] = b
        end
    end
    keep[#keep + 1] = { addr = mergedAddr, size = mergedSize }
    _freeList = keep
end

function M.free(addr)
    local e = _registry[addr]
    if not e or e.freed then
        return false
    end
    e.freed = true
    insertFree(addr, e.size)
    persistSnapshot()
    log(string.format("free(0x%X) reclaimed %d bytes", addr, e.size))
    return true
end

-- Test/recovery hook: forget in-memory state WITHOUT touching the
-- persisted cache. The next allocate() rebuilds via restoreFromCache
-- — the same code path a script reload takes.
function M._reset()
    zeroPageBase, zeroPageCursor, zeroPageSize = nil, 0, 0
    _claimed, _registry, _freeList = {}, {}, {}
    _restoreTried = false
end

function M.allocate(size)
    size = (size + 7) & ~7  -- align to 8 bytes

    -- Rebuild from the PID-scoped cache FIRST — the best-fit scan
    -- below must see free blocks restored by a previous run.
    if zeroPageBase == nil then
        restoreFromCache()
    end

    -- Prefer a reclaimed block (best fit). Freed blocks hold stale
    -- data, so they are re-zeroed HERE, at reuse time — not at free
    -- time — which keeps a freed block's bytes valid for any in-flight
    -- game read until Nebula actually hands the memory out again.
    local bestIdx, best
    for i, b in ipairs(_freeList) do
        if b.size >= size and (best == nil or b.size < best.size) then
            bestIdx, best = i, b
        end
    end
    if best then
        local addr = best.addr
        local zeroWrites = {}
        for off = 0, size - 1, 8 do
            zeroWrites[#zeroWrites + 1] = { address = addr + off, flags = Memory.FLAGS.INT64, value = 0 }
        end
        if Memory.writeBatch(zeroWrites) then
            if best.size > size then
                best.addr = addr + size
                best.size = best.size - size
            else
                table.remove(_freeList, bestIdx)
            end
            _registry[addr] = { size = size, freed = false }
            log(string.format("allocate(%d) -> 0x%X (reclaimed, zeroed)", size, addr))
            return addr
        end
        log("reclaimed block re-zeroing failed; bump-allocating instead")
    end

    if zeroPageBase == nil
       or zeroPageCursor + size > zeroPageSize then
        local desired = math.max(size * 4, DEFAULT_REGION_BYTES)
        zeroPageBase, zeroPageSize = findZeroRegion(desired)
        if zeroPageBase == nil then
            zeroPageBase, zeroPageSize = findZeroRegion(size)
        end
        if zeroPageBase == nil then
            log(string.format("allocate(%d) FAILED: no safe zero region found", size))
            return nil
        end
        -- Region header: the magic QWORD lets a later run verify
        -- the region still holds OUR data. Byte 0 is reserved;
        -- allocations start at +8.
        local magicOk = Memory.writeBatch({
            { address = zeroPageBase, flags = Memory.FLAGS.INT64, value = MAGIC },
        })
        if not magicOk then
            zeroPageBase = nil
            log("allocate: region header write failed")
            return nil
        end
        zeroPageCursor = 8
        persistSnapshot()
    end

    local addr = zeroPageBase + zeroPageCursor
    zeroPageCursor = zeroPageCursor + size
    _registry[addr] = { size = size, freed = false }
    log(string.format("allocate(%d) -> 0x%X (region=0x%X cursor=%d/%d)",
        size, addr, zeroPageBase, zeroPageCursor, zeroPageSize))
    return addr
end

function M._status()
    return {
        base   = zeroPageBase,
        cursor = zeroPageCursor,
        size   = zeroPageSize,
        magic  = MAGIC,
        freeBlocks = #_freeList,
        claimed = (function()
            local n = 0
            for _ in pairs(_claimed) do n = n + 1 end
            return n
        end)()
    }
end

return M
