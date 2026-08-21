local Memory = loadModule("core/Memory.lua")
local ZeroPage = loadModule("core/ZeroPage.lua")

local M = {}

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.types.String]", ...)
    end
end



local INLINE_MAX_BYTES = 6 * 4
local LONG_HEADER_MIN = 9
local LONG_HEADER_MAX = 99

local function toUnsignedByte(signed)
    return signed & 0xFF
end

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

local function readInline(ptr)
    local lenRaw, lenErr = Memory.read(ptr, Memory.FLAGS.BYTE)
    if lenRaw == nil then
        return nil, lenErr
    end

    local byteCount = math.floor(toUnsignedByte(lenRaw) / 2)
    return readRawBytes(ptr + 1, byteCount)
end

local function readLong(ptr)
    local fields, err = Memory.readBatch({
        { address = ptr,        flags = Memory.FLAGS.INT32 },
        { address = ptr + 0x4,  flags = Memory.FLAGS.INT32 },
        { address = ptr + 0x8,  flags = Memory.FLAGS.INT32 },
        { address = ptr + 0xC,  flags = Memory.FLAGS.INT32 },
        { address = ptr + 0x10, flags = Memory.FLAGS.INT64 },
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

local function resolvePtr(baseAddress, field)
    if field.indirect == false then
        return baseAddress + field.offset
    end
    return Memory.deref(baseAddress, field.offset)
end

function M.get(baseAddress, field)
    log(string.format("[get] base=0x%X offset=0x%X indirect=%s", baseAddress, field.offset, tostring(field.indirect)))
    local ptr, err = resolvePtr(baseAddress, field)
    if not ptr then
        return nil, err
    end
    log(string.format("[get] resolved ptr=0x%X", ptr))

    local longVal, longErr = readLong(ptr)
    log(string.format("[get] readLong result=%s err=%s", tostring(longVal), tostring(longErr)))
    if longVal ~= nil then
        return longVal
    end

    log(string.format("[get] falling back to readInline at ptr=0x%X", ptr))
    return readInline(ptr)
end

local function writeInline(ptr, nameBytes, byteCount)
    local writes = { { address = ptr, flags = Memory.FLAGS.BYTE, value = byteCount * 2 } }
    for i = 1, #nameBytes do
        writes[#writes + 1] = { address = ptr + i, flags = Memory.FLAGS.BYTE, value = nameBytes[i] }
    end
    return Memory.writeBatch(writes)
end

local function isLongForm(ptr)
    local fields, err = Memory.readBatch({
        { address = ptr,       flags = Memory.FLAGS.INT32 },
        { address = ptr + 0x4, flags = Memory.FLAGS.INT32 },
        { address = ptr + 0xC, flags = Memory.FLAGS.INT32 },
        { address = ptr + 0x10, flags = Memory.FLAGS.INT64 },
    })
    if not fields then return false end
    local header = fields[1] and fields[1].value
    local r1 = fields[2] and fields[2].value
    local r2 = fields[3] and fields[3].value
    local dp = fields[4] and fields[4].value
    if header == nil or header < LONG_HEADER_MIN or header > LONG_HEADER_MAX then return false end
    if r1 ~= 0 or r2 ~= 0 then return false end
    if dp == nil or dp == 0 then return false end
    return true
end

local function writeLong(ptr, nameBytes, byteCount)
    local fields, err = Memory.readBatch({
        { address = ptr,       flags = Memory.FLAGS.INT32 },
        { address = ptr + 0x4, flags = Memory.FLAGS.INT32 },
        { address = ptr + 0xC, flags = Memory.FLAGS.INT32 },
        { address = ptr + 0x10, flags = Memory.FLAGS.INT64 },
    })

    local header = fields and fields[1] and fields[1].value
    local r1 = fields and fields[2] and fields[2].value
    local r2 = fields and fields[3] and fields[3].value
    local dataPtr = fields and fields[4] and fields[4].value

    local alreadyLong = header ~= nil and header >= LONG_HEADER_MIN and header <= LONG_HEADER_MAX
        and r1 == 0 and r2 == 0 and dataPtr ~= nil and dataPtr ~= 0

    if not alreadyLong then
        local n = math.ceil(math.sqrt(byteCount))
        header = (n * n) | 1
        dataPtr = ZeroPage.allocate(byteCount + 1)
        if not dataPtr then
            return false
        end
    end

    local writes = {
        { address = ptr,      flags = Memory.FLAGS.INT32, value = header },
        { address = ptr + 0x4, flags = Memory.FLAGS.INT32, value = 0 },
        { address = ptr + 0x8, flags = Memory.FLAGS.INT32, value = byteCount },
        { address = ptr + 0xC, flags = Memory.FLAGS.INT32, value = 0 },
        { address = ptr + 0x10, flags = Memory.FLAGS.INT64, value = dataPtr },
    }
    for i = 1, #nameBytes do
        writes[#writes + 1] = { address = dataPtr + (i - 1), flags = Memory.FLAGS.BYTE, value = nameBytes[i] }
    end
    writes[#writes + 1] = { address = dataPtr + byteCount, flags = Memory.FLAGS.BYTE, value = 0 }

    return Memory.writeBatch(writes)
end

local STRING_OBJECT_SIZE = 0x18

function M.set(baseAddress, field, value)
    log(string.format("[set] base=0x%X offset=0x%X value='%s'", baseAddress, field.offset, tostring(value)))
    if type(value) ~= "string" then
        return false
    end

    local ptr, err = resolvePtr(baseAddress, field)
    local needsAlloc = not ptr or ptr == 0

    if needsAlloc then
        -- indirect == false means baseAddress+offset IS the string
        -- storage (no separate object to allocate) — nothing we can do.
        if field.indirect == false then
            return false
        end
        ptr = ZeroPage.allocate(STRING_OBJECT_SIZE)
        if not ptr then
            return false
        end
    end

    local nameBytes = {}
    local byteCount = #value

    for i = 1, byteCount do
        nameBytes[i] = string.byte(value, i)
    end

    local writeOk
    if byteCount + 1 <= INLINE_MAX_BYTES then
        writeOk = writeInline(ptr, nameBytes, byteCount)
    else
        writeOk = writeLong(ptr, nameBytes, byteCount)
    end

    if not writeOk then
        return false
    end

    if needsAlloc then
        return Memory.write(baseAddress + field.offset, Memory.FLAGS.INT64, ptr)
    end

    return true
end

function M.collectWrite(baseAddress, field, value, writes)
    if type(value) ~= "string" then return false end

    local ptr, err = resolvePtr(baseAddress, field)
    local needsAlloc = not ptr or ptr == 0

    if needsAlloc then
        if field.indirect == false then return false end
        ptr = ZeroPage.allocate(STRING_OBJECT_SIZE)
        if not ptr then return false end
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT64, value = ptr }
    end

    local nameBytes = {}
    local byteCount = #value
    for i = 1, byteCount do
        nameBytes[i] = string.byte(value, i)
    end
    if byteCount + 1 <= INLINE_MAX_BYTES then
        writes[#writes + 1] = { address = ptr, flags = Memory.FLAGS.BYTE, value = byteCount * 2 }
        for i = 1, #nameBytes do
            writes[#writes + 1] = { address = ptr + i, flags = Memory.FLAGS.BYTE, value = nameBytes[i] }
        end
    else
        local alreadyLong = not needsAlloc and isLongForm(ptr)
        local header, dataPtr
        if alreadyLong then
            local fields = Memory.readBatch({
                { address = ptr, flags = Memory.FLAGS.INT32 },
                { address = ptr + 0x10, flags = Memory.FLAGS.INT64 },
            })
            header = fields and fields[1] and fields[1].value
            dataPtr = fields and fields[2] and fields[2].value
        end
        if not alreadyLong or dataPtr == nil or dataPtr == 0 then
            local n = math.ceil(math.sqrt(byteCount))
            header = (n * n) | 1
            dataPtr = ZeroPage.allocate(byteCount + 1)
            if not dataPtr then return false end
        end
        writes[#writes + 1] = { address = ptr, flags = Memory.FLAGS.INT32, value = header }
        writes[#writes + 1] = { address = ptr + 0x4, flags = Memory.FLAGS.INT32, value = 0 }
        writes[#writes + 1] = { address = ptr + 0x8, flags = Memory.FLAGS.INT32, value = byteCount }
        writes[#writes + 1] = { address = ptr + 0xC, flags = Memory.FLAGS.INT32, value = 0 }
        writes[#writes + 1] = { address = ptr + 0x10, flags = Memory.FLAGS.INT64, value = dataPtr }
        for i = 1, #nameBytes do
            writes[#writes + 1] = { address = dataPtr + (i - 1), flags = Memory.FLAGS.BYTE, value = nameBytes[i] }
        end
        writes[#writes + 1] = { address = dataPtr + byteCount, flags = Memory.FLAGS.BYTE, value = 0 }
    end

    return true
end

return M
