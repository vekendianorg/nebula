local Memory = loadModule("core/Memory.lua")

--==================================================
-- core/ZeroPage.lua
--==================================================
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

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.ZeroPage]", ...)
    end
end



local DEFAULT_REGION_BYTES = 2048
local MIN_REGION_BYTES     = 256

local zeroPageBase   = nil
local zeroPageCursor = 0
local zeroPageSize   = 0
local _claimed       = {}

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
                            return base, regionBytes
                        end
                    end
                end
            end
        end
    end

    return nil, 0
end

function M.allocate(size)
    size = (size + 7) & ~7  -- align to 8 bytes

    if zeroPageBase == nil
       or zeroPageCursor + size > zeroPageSize then
        local desired = math.max(size * 4, DEFAULT_REGION_BYTES)
        zeroPageBase, zeroPageSize = findZeroRegion(desired)
        zeroPageCursor = 0
        if zeroPageBase == nil then
            zeroPageBase, zeroPageSize = findZeroRegion(size)
            zeroPageCursor = 0
            if zeroPageBase == nil then
                return nil
            end
        end
    end

    local addr = zeroPageBase + zeroPageCursor
    zeroPageCursor = zeroPageCursor + size
    return addr
end

function M._status()
    return {
        base   = zeroPageBase,
        cursor = zeroPageCursor,
        size   = zeroPageSize,
        claimed = (function()
            local n = 0
            for _ in pairs(_claimed) do n = n + 1 end
            return n
        end)()
    }
end

return M
