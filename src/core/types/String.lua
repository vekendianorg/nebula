--==================================================
-- core/types/String.lua
--==================================================
-- Java-string-backed field. baseAddress + offset holds a POINTER
-- to a string object. Two on-disk encodings exist depending on
-- string length:
--
-- INLINE (short strings, fits in 6 dwords / 24 bytes incl. the
-- length byte):
--   ptr+0x0        byteCount*2 (length byte)
--   ptr+0x1..      raw chars, packed directly after the length byte
--
-- LONG (indirected — used once the inline layout would overflow):
--   ptr+0x0        header, expected in range [9, 99]
--   ptr+0x4        MUST be 0
--   ptr+0x8        length (raw char count, NOT multiplied)
--   ptr+0xC        MUST be 0
--   ptr+0x10       pointer to the actual char data
--
-- Reference: account.lua M.changeName for the inline write path;
-- the long-form layout and header-value dispatch (header == 49 in
-- that particular reference) come from vehicle part-name reads
-- elsewhere in the codebase.
--
-- No byte-length cap here. changeName's 12-byte limit is a
-- display-name UI constraint, not a property of strings in
-- general — Nebula doesn't decide that for callers.

local Memory = loadModule("core/Memory.lua")

local M = {}

-- Inline form budget: 6 dwords total, length byte included.
local INLINE_MAX_BYTES = 6 * 4 -- 24

-- Long-form header sanity range.
local LONG_HEADER_MIN = 9
local LONG_HEADER_MAX = 99

---GG returns byte reads as signed (-128..127). string.char needs
---0..255, so mask back to unsigned before building the string.
---@param signed integer
---@return integer
local function toUnsignedByte(signed)
    return signed & 0xFF
end

---Read `count` raw bytes starting at `addr` and decode them into a
---Lua string. Handles the signed-byte masking for every byte.
---@param addr integer
---@param count integer
---@return string|nil value, string|nil error
local function readRawBytes(addr, count)
    if count <= 0 then
        return "", nil
    end

    local specs = {}
    for i = 0, count - 1 do
        specs[i + 1] = { address = addr + i, flags = Memory.FLAGS.BYTE }
    end

    local results, err = Memory.readBatch(specs)
    if not results then
        return nil, err
    end

    local bytes = {}
    for i = 1, count do
        local raw = results[i] and results[i].value or 0
        bytes[i] = toUnsignedByte(raw)
    end

    return string.char(table.unpack(bytes))
end

---Read the inline-form string at `ptr` (length byte at ptr+0x0,
---chars at ptr+0x1..).
---@param ptr integer
---@return string|nil value, string|nil error
local function readInline(ptr)
    local lenRaw, lenErr = Memory.read(ptr, Memory.FLAGS.BYTE)
    if lenRaw == nil then
        return nil, lenErr
    end

    local byteCount = math.floor(toUnsignedByte(lenRaw) / 2)
    return readRawBytes(ptr + 1, byteCount)
end

---Read the long-form (indirected) string at `ptr`, per the layout
---documented above. Validates the header/reserved fields before
---trusting the data.
---@param ptr integer
---@return string|nil value, string|nil error
local function readLong(ptr)
    local fields, err = Memory.readBatch({
        { address = ptr,        flags = Memory.FLAGS.INT32 }, -- header
        { address = ptr + 0x4,  flags = Memory.FLAGS.INT32 }, -- must be 0
        { address = ptr + 0x8,  flags = Memory.FLAGS.INT32 }, -- length
        { address = ptr + 0xC,  flags = Memory.FLAGS.INT32 }, -- must be 0
        { address = ptr + 0x10, flags = Memory.FLAGS.INT64 }, -- char data ptr
    })

    if not fields then
        return nil, err
    end

    local header   = fields[1] and fields[1].value
    local reserved1 = fields[2] and fields[2].value
    local length   = fields[3] and fields[3].value
    local reserved2 = fields[4] and fields[4].value
    local dataPtr  = fields[5] and fields[5].value

    if header == nil or header < LONG_HEADER_MIN or header > LONG_HEADER_MAX then
        return nil, "long_header_invalid"
    end
    if reserved1 ~= 0 or reserved2 ~= 0 then
        return nil, "long_reserved_nonzero"
    end
    if dataPtr == nil or dataPtr == 0 then
        return nil, "long_dataptr_null"
    end
    if length == nil or length < 0 then
        return nil, "long_length_invalid"
    end

    return readRawBytes(dataPtr, length)
end

---Read the string at baseAddress+offset by following its pointer.
---Auto-detects inline vs long-form encoding: tries the long-form
---header check first (cheap, self-validating), falls back to
---inline if that check fails.
---@param baseAddress integer
---@param field table
---@return string|nil value, string|nil error
function M.get(baseAddress, field)
    local ptr, err = Memory.deref(baseAddress, field.offset)
    if not ptr then
        return nil, err
    end

    local longVal, longErr = readLong(ptr)
    if longVal ~= nil then
        return longVal
    end

    return readInline(ptr)
end

---Write the inline form at `ptr`: length byte at ptr+0x0, raw
---bytes following at ptr+0x1..
---@param ptr integer
---@param nameBytes integer[]
---@param byteCount integer
---@return boolean ok
local function writeInline(ptr, nameBytes, byteCount)
    local writes = { { address = ptr, flags = Memory.FLAGS.BYTE, value = byteCount * 2 } }
    for i = 1, #nameBytes do
        writes[#writes + 1] = { address = ptr + i, flags = Memory.FLAGS.BYTE, value = nameBytes[i] }
    end
    return Memory.writeBatch(writes)
end

---Write the long form at `ptr`: header/reserved/length fields plus
---raw bytes at the existing dataPtr (the long form's char buffer is
---not relocated/resized here — only its content and length fields
---are updated).
---@param ptr integer
---@param nameBytes integer[]
---@param byteCount integer
---@return boolean ok
local function writeLong(ptr, nameBytes, byteCount)
    local fields, err = Memory.readBatch({
        { address = ptr,        flags = Memory.FLAGS.INT32 }, -- header
        { address = ptr + 0x10, flags = Memory.FLAGS.INT64 }, -- char data ptr
    })
    if not fields then
        return false
    end

    local header  = fields[1] and fields[1].value
    local dataPtr = fields[2] and fields[2].value

    if header == nil or header < LONG_HEADER_MIN or header > LONG_HEADER_MAX then
        return false -- not actually a valid long-form string object
    end
    if dataPtr == nil or dataPtr == 0 then
        return false
    end

    local writes = {
        { address = ptr + 0x8, flags = Memory.FLAGS.INT32, value = byteCount },
    }
    for i = 1, #nameBytes do
        writes[#writes + 1] = { address = dataPtr + (i - 1), flags = Memory.FLAGS.BYTE, value = nameBytes[i] }
    end

    return Memory.writeBatch(writes)
end

---Write a string at baseAddress+offset. No length cap — the caller
---(or a higher-level field constraint, e.g. UI display limits) is
---responsible for validating length before calling this.
---
---Encoding is chosen automatically: if the encoded content
---(length byte included) fits within the inline budget (6 dwords /
---24 bytes), the inline form is used; otherwise the long
---(indirected) form is used.
---@param baseAddress integer
---@param field table
---@param value string
---@return boolean ok
function M.set(baseAddress, field, value)
    if type(value) ~= "string" then
        return false
    end

    local ptr, err = Memory.deref(baseAddress, field.offset)
    if not ptr then
        return false
    end

    local nameBytes = {}
    local byteCount = 0

    for _, code in utf8.codes(value) do
        local encoded = utf8.char(code)
        local bytes = { encoded:byte(1, -1) }
        for _, b in ipairs(bytes) do
            table.insert(nameBytes, b)
            byteCount = byteCount + 1
        end
    end

    -- +1 accounts for the inline form's length byte occupying part
    -- of the 6-dword budget alongside the character bytes.
    if byteCount + 1 <= INLINE_MAX_BYTES then
        return writeInline(ptr, nameBytes, byteCount)
    end

    return writeLong(ptr, nameBytes, byteCount)
end

return M
