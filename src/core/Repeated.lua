--==================================================
-- core/Repeated.lua
--==================================================

local Memory = loadModule("core/Memory.lua")
local Type   = loadModule("core/Type.lua")
local ZeroPage = loadModule("core/ZeroPage.lua")

local M = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula and Nebula.log then
        Logfile.log("[Repeated]", ...)
    end
end

local Trace = loadModule("core/Trace.lua")

---Standardized address-trace record — see core/Trace.lua for the
---key vocabulary (ADDR/OFF/PTR/BEGIN/END/CAP/ELEM/NESTED/...).
local function rec(tag, kv)
    Trace.rec("Repeated", tag, kv)
end



local DEFAULT_STRIDE = 0x8

local POINTER_ELEMENT_TYPES = {
    SafeInt32 = true,
}

local function isPointerElement(elementType)
    if POINTER_ELEMENT_TYPES[elementType] then
        return true
    end
    local INLINE_SCALARS = { Int32 = true, Int64 = true, Bool = true, Float = true, String = true, BitMask = true, Enum = true, Vec2 = true, Color3B = true }
    return not INLINE_SCALARS[elementType]
end

local MAX_TRUSTED_ELEMENT_COUNT = 100000

local function readHeader(baseAddress, field)
    local ptr = baseAddress + field.offset
    local stride = field.elementStride or DEFAULT_STRIDE

    rec("readHeader", {
        BASE = baseAddress, OFF = field.offset, ADDR = ptr,
        CONT = tostring(field.container), TYPE = tostring(field.type),
        ELEM_TYPE = field.elementType, STRIDE = stride,
    })

    if field.container == "vector" then
        local fields, readErr = Memory.readBatch({
            { address = ptr,        flags = Memory.FLAGS.INT64 },
            { address = ptr + 0x8,  flags = Memory.FLAGS.INT64 },
            { address = ptr + 0x10, flags = Memory.FLAGS.INT64 },
        })

        if not fields then
            rec("null", { ADDR = "NULL/INVALID", ERR = "vector_header_read_failed: " .. tostring(readErr) })
            return nil, readErr
        end

        local beginPtr  = fields[1] and fields[1].value
        local endPtr    = fields[2] and fields[2].value
        local capEndPtr = fields[3] and fields[3].value

        if beginPtr == nil or endPtr == nil then
            rec("null", { ADDR = "NULL/INVALID", ERR = "nil_begin_or_end" })
            return nil, "header_read_failed"
        end

        if beginPtr == 0 then
            rec("readHeader", { ADDR = ptr, PTR = 0, BEGIN = 0, END = endPtr or 0, CAP = capEndPtr or 0,
                SIZE = 0, CAPACITY = 0, INFO = "empty_vector" })
            return { containerPtr = ptr, arrayPtr = 0, size = 0, capacity = 0 }
        end

        if endPtr < beginPtr then
            rec("null", { ADDR = ptr, BEGIN = beginPtr, END = endPtr,
                ERR = "vector_end_before_begin" })
            return nil, string.format(
                "vector_end_before_begin (begin=0x%X end=0x%X)",
                beginPtr, endPtr)
        end

        local size = math.floor((endPtr - beginPtr) / stride)
        local capacity = size
        if capEndPtr ~= nil and capEndPtr ~= 0 and capEndPtr >= beginPtr then
            capacity = math.floor((capEndPtr - beginPtr) / stride)
        end

        rec("readHeader", { ADDR = ptr, PTR = beginPtr, BEGIN = beginPtr, END = endPtr,
            CAP = capEndPtr or 0, SIZE = size, CAPACITY = capacity })

        if size < 0 or capacity < 0 then
            rec("null", { ADDR = ptr, SIZE = size, CAPACITY = capacity,
                ERR = "header_negative_size_or_capacity" })
            return nil, "header_negative_size_or_capacity"
        end

        if size > MAX_TRUSTED_ELEMENT_COUNT or capacity > MAX_TRUSTED_ELEMENT_COUNT then
            rec("null", { ADDR = ptr, SIZE = size, CAPACITY = capacity,
                ERR = "header_size_out_of_bounds" })
            return nil, string.format(
                "header_size_out_of_bounds (size=%d capacity=%d, max=%d)",
                size, capacity, MAX_TRUSTED_ELEMENT_COUNT)
        end

        if size > capacity then
            rec("null", { ADDR = ptr, SIZE = size, CAPACITY = capacity,
                ERR = "header_size_exceeds_capacity" })
            return nil, string.format("header_size_exceeds_capacity (size=%d capacity=%d)", size, capacity)
        end

        return { containerPtr = ptr, arrayPtr = beginPtr, size = size, capacity = capacity }
    end

    local fields, readErr = Memory.readBatch({
        { address = ptr,        flags = Memory.FLAGS.INT64 },
        { address = ptr + 0x8,  flags = Memory.FLAGS.INT32 },
        { address = ptr + 0xC,  flags = Memory.FLAGS.INT32 },
    })

    if not fields then
        rec("null", { ADDR = "NULL/INVALID", ERR = "proto_header_read_failed: " .. tostring(readErr) })
        return nil, readErr
    end

    local arrayPtr = fields[1] and fields[1].value
    local size     = fields[2] and fields[2].value
    local capacity = fields[3] and fields[3].value

    if arrayPtr == nil or size == nil or capacity == nil then
        rec("null", { ADDR = "NULL/INVALID", ERR = "nil_header_field" })
        return nil, "header_read_failed"
    end

    rec("readHeader", { ADDR = ptr, PTR = arrayPtr, SIZE = size, CAPACITY = capacity })

    if size < 0 or capacity < 0 then
        rec("null", { ADDR = ptr, SIZE = size, CAPACITY = capacity,
            ERR = "header_negative_size_or_capacity" })
        return nil, "header_negative_size_or_capacity"
    end

    if size > MAX_TRUSTED_ELEMENT_COUNT or capacity > MAX_TRUSTED_ELEMENT_COUNT then
        rec("null", { ADDR = ptr, SIZE = size, CAPACITY = capacity,
            ERR = "header_size_out_of_bounds" })
        return nil, string.format(
            "header_size_out_of_bounds (size=%d capacity=%d, max=%d)",
            size, capacity, MAX_TRUSTED_ELEMENT_COUNT)
    end

    if size > capacity then
        rec("null", { ADDR = ptr, SIZE = size, CAPACITY = capacity,
            ERR = "header_size_exceeds_capacity" })
        return nil, string.format("header_size_exceeds_capacity (size=%d capacity=%d)", size, capacity)
    end

    return { containerPtr = ptr, arrayPtr = arrayPtr, size = size, capacity = capacity }
end

local function readSlotPointers(header, count, stride)
    local slotSpecs = {}
    for i = 1, count do
        slotSpecs[i] = { address = header.arrayPtr + (i - 1) * stride, flags = Memory.FLAGS.INT64 }
    end
    return Memory.readBatchChunked(slotSpecs)
end

local function shadowString(field, stringDirect)
    if stringDirect and field.type == "String" and field.indirect == nil then
        return setmetatable({ indirect = false }, { __index = field })
    end
    return field
end

function M.get(baseAddress, field, preReadHeader, pathLabel)
    rec("get", { FIELD = pathLabel or field.name, BASE = baseAddress, OFF = field.offset,
        TYPE = tostring(field.type), ELEM_TYPE = field.elementType,
        STRIDE = field.elementStride or 0x8, CONT = tostring(field.container) })
    local header = preReadHeader
    if not header then
        local err
        header, err = readHeader(baseAddress, field)
        if not header then
            return nil, err
        end
    end

    if header.size <= 0 then
        return {}, nil
    end

    if header.arrayPtr == 0 then
        return nil, "null_array_ptr"
    end

if field.elements then
        local Struct = loadModule("core/Struct.lua")
        local stride = field.elementStride or DEFAULT_STRIDE
        local values = {}

        if stride > DEFAULT_STRIDE then
            for i = 1, header.size do
                local elemAddr = header.arrayPtr + (i - 1) * stride
                rec("elem", { FIELD = field.name, IDX = i - 1, ELEM = elemAddr,
                    NESTED = elemAddr, ELEM_TYPE = "struct", STRIDE = stride })
                values[i] = Struct.get(
                    elemAddr,
                    field.elements,
                    field.stringDirect,
                    (pathLabel or field.name or "elements") .. "[" .. (i - 1) .. "]"
                )
            end
        else
            local slots, slotErr = readSlotPointers(header, header.size, stride)
            if not slots then
                return nil, slotErr
            end
            for i = 1, header.size do
                local elementPtr = slots[i] and slots[i].value
                if elementPtr and elementPtr ~= 0 then
                    rec("elem", { FIELD = field.name, IDX = i - 1,
                        SLOT = header.arrayPtr + (i - 1) * stride,
                        ELEM = elementPtr, NESTED = elementPtr, ELEM_TYPE = "struct" })
                    values[i] = Struct.get(elementPtr, field.elements, field.stringDirect,
                        (pathLabel or field.name or "elements") .. "[" .. (i - 1) .. "]")
                else
                    values[i] = false
                    rec("null", { FIELD = field.name, IDX = i - 1,
                        ADDR = "NULL/INVALID", ERR = "null_element_ptr" })
                end
            end
        end
return values, nil
    end

if field.elementType then
        local elementType = field.elementType
        local stride = field.elementStride or DEFAULT_STRIDE
        local impl = Type.resolve(elementType)
        if not impl then
            return nil, "no_type_impl: " .. tostring(elementType)
        end

        local values = {}
        local pointerElements = isPointerElement(elementType)

        if pointerElements and stride == DEFAULT_STRIDE then
            local slots, slotErr = readSlotPointers(header, header.size, stride)
            if not slots then
                return nil, slotErr
            end
            for i = 1, header.size do
                local elementPtr = slots[i] and slots[i].value
                if elementPtr and elementPtr ~= 0 then
                    local f = { offset = 0, type = elementType }
                    if field.enum then f.enum = field.enum end
                    f = shadowString(f, field.stringDirect)
                    values[i] = impl.get(elementPtr, f)
                    rec("elem", { FIELD = field.name, IDX = i - 1,
                        SLOT = header.arrayPtr + (i - 1) * stride,
                        ELEM = elementPtr, TYPE = elementType, VALUE = values[i] })
                else
                    values[i] = false
                    rec("null", { FIELD = field.name, IDX = i - 1,
                        ADDR = "NULL/INVALID", ERR = "null_element_ptr" })
                end
            end
        elseif elementType == "String" and stride == DEFAULT_STRIDE then
            local slots, slotErr = readSlotPointers(header, header.size, DEFAULT_STRIDE)
            if not slots then
                return nil, slotErr
            end
            for i = 1, header.size do
                local elementPtr = slots[i] and slots[i].value
                if elementPtr and elementPtr ~= 0 then
                    local f = { offset = 0, type = "String", indirect = false }
                    values[i] = impl.get(elementPtr, f)
                    rec("elem", { FIELD = field.name, IDX = i - 1,
                        SLOT = header.arrayPtr + (i - 1) * DEFAULT_STRIDE,
                        ELEM = elementPtr, TYPE = "String", VALUE = values[i] })
                else
                    values[i] = false
                    rec("null", { FIELD = field.name, IDX = i - 1,
                        ADDR = "NULL/INVALID", ERR = "null_element_ptr" })
                end
            end
        else
            for i = 1, header.size do
                local f = { offset = (i - 1) * stride, type = elementType }
                if field.enum then f.enum = field.enum end
                -- Inline string elements are always direct (no pointer
                -- indirection) regardless of the parent struct's
                -- stringDirect flag.
                if elementType == "String" then
                    f.indirect = false
                else
                    f = shadowString(f, field.stringDirect)
                end
values[i] = impl.get(header.arrayPtr, f)
                rec("elem", { FIELD = field.name, IDX = i - 1,
                    ELEM = header.arrayPtr + (i - 1) * stride,
                    OFF = (i - 1) * stride, TYPE = elementType, VALUE = values[i] })
            end
        end

return values, nil
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return nil, "no_type_impl: " .. tostring(field.type)
    end

    local pointerElements = isPointerElement(field.type)
    local values = {}
    local count = 0

    if pointerElements then
        local slots, slotErr = readSlotPointers(header, header.size, DEFAULT_STRIDE)
        if not slots then
            return nil, slotErr
        end

        if impl.specs and impl.parse then
            local elementPtrs = {}
            local allSpecs = {}
            local specCounts = {}

            for i = 1, header.size do
                local elementPtr = slots[i] and slots[i].value
                elementPtrs[i] = elementPtr
                if elementPtr and elementPtr ~= 0 then
                    local elSpecs = impl.specs(elementPtr)
                    specCounts[i] = #elSpecs
                    for _, spec in ipairs(elSpecs) do
                        allSpecs[#allSpecs + 1] = spec
                    end
                else
                    specCounts[i] = 0
                end
            end

            local allResults, batchErr = Memory.readBatchChunked(allSpecs)
            if not allResults then
                return nil, batchErr
            end

            local cursor = 1
            for i = 1, header.size do
                count = count + 1
                local n = specCounts[i]
                if elementPtrs[i] and elementPtrs[i] ~= 0 and n > 0 then
                    local slice = {}
                    for j = 1, n do
                        slice[j] = allResults[cursor + j - 1]
                    end
                    cursor = cursor + n
                    local value, elErr = impl.parse(slice)
                    values[count] = value == nil and false or value
                else
                    values[count] = false
                end
            end
        else
            for i = 1, header.size do
                local elementPtr = slots[i] and slots[i].value
                count = count + 1
                if elementPtr and elementPtr ~= 0 then
                    local value, elErr = impl.get(elementPtr, { offset = 0, type = field.type, enum = field.enum })
                    values[count] = value == nil and false or value
                else
                    values[count] = false
                end
            end
        end
    else
        for i = 1, header.size do
            local value = impl.get(header.arrayPtr, { offset = i * DEFAULT_STRIDE, type = field.type, enum = field.enum })
            count = count + 1
            values[count] = value == nil and false or value
        end
    end

return values, nil
end

function M.set(baseAddress, field, values, preReadHeader)
    if type(values) ~= "table" then
        return false, "value_not_array"
    end

    local header = preReadHeader
    if not header then
        local err
        header, err = readHeader(baseAddress, field)
        if not header then
            return false, err
        end
    end

    local newSize = #values
    local stride = field.elementStride or DEFAULT_STRIDE

    -- Vectors CAN grow past capacity: build a replacement buffer
    -- in ZeroPage, copy the old elements over, and swap
    -- begin/end/capEnd in ONE batch after the new elements are in
    -- place (pendingVectorSwap). Until that swap lands the vector
    -- still points at its old (fully consistent) buffer, so the
    -- game never observes a half-grown header. The old buffer is
    -- abandoned — a game-side leak, acceptable for a memory mod.
    local pendingVectorSwap = nil
    local pendingVectorFree = nil
    if newSize > header.capacity then
        local allocSize = newSize * stride
        if allocSize < 8 then allocSize = 8 end
        local newArrayPtr = ZeroPage.allocate(allocSize)
        if not newArrayPtr then
            return false, "zero_page_alloc_failed"
        end
        if header.arrayPtr ~= 0 and header.size > 0 then
            local copySize = header.size * stride
            local copyOk = Memory.copyRegion(header.arrayPtr, newArrayPtr, copySize)
            if not copyOk then
                return false, "copy_region_failed"
            end
        end
        local oldArrayPtr = header.arrayPtr
        if field.container == "vector" then
            header.arrayPtr = newArrayPtr
            header.capacity = newSize
            pendingVectorSwap = newArrayPtr
            -- Reclaim Nebula's OWN old buffer (a previous ZeroPage
            -- grow). Game-owned buffers leak on purpose — the game
            -- manages that heap, we don't.
            if ZeroPage.owns(oldArrayPtr) then
                pendingVectorFree = oldArrayPtr
            end
        else
            local ptrOk = Memory.write(header.containerPtr, Memory.FLAGS.INT64, newArrayPtr)
            if not ptrOk then
                return false, "container_ptr_write_failed"
            end
            header.arrayPtr = newArrayPtr
            header.capacity = newSize
            if ZeroPage.owns(oldArrayPtr) then
                ZeroPage.free(oldArrayPtr)
            end
        end
    end

    if header.arrayPtr == 0 and newSize == 0 then
        return true, nil
    end

    if header.arrayPtr == 0 then
        return false, "null_array_ptr"
    end

if field.elements then
        local Struct = loadModule("core/Struct.lua")
        local stride = field.elementStride or DEFAULT_STRIDE

        if stride > DEFAULT_STRIDE then
            for i = 1, newSize do
                local ok = Struct.set(
                    header.arrayPtr + (i - 1) * stride,
                    field.elements,
                    values[i],
                    field.stringDirect
                )
                if not ok then
                    return false, string.format("element_write_failed_at_index_%d", i)
                end
            end
        else
            local oldSize = header.size or 0
            local slots
            if oldSize > 0 then
                local readCount = math.min(oldSize, newSize)
                local slotErr
                slots, slotErr = readSlotPointers(header, readCount, stride)
                if not slots then
                    return false, slotErr
                end
            end
            for i = 1, newSize do
                local elementPtr
                if i <= oldSize and slots and slots[i] then
                    elementPtr = slots[i].value
                end
                if elementPtr == nil or elementPtr == 0 then
                    elementPtr = ZeroPage.allocate(0x100)
                    if not elementPtr then
                        return false, "zero_page_alloc_failed"
                    end
                    Memory.write(header.arrayPtr + (i - 1) * stride, Memory.FLAGS.INT64, elementPtr)
                end
                local ok = Struct.set(elementPtr, field.elements, values[i], field.stringDirect)
                if not ok then
                    return false, string.format("element_write_failed_at_index_%d", i)
                end
            end
        end

        if field.container ~= "vector" then
            Memory.writeBatch({
                { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT32, value = newSize },
                { address = header.containerPtr + 0xC, flags = Memory.FLAGS.INT32, value = newSize },
            })
        else
            -- Vector ABI parity fix: get() derives size from
            -- (end - begin)/stride, so set() must move the end
            -- pointer to match the size it wrote — otherwise the
            -- game's begin/end iteration still sees the old size
            -- after a rewrite or an in-capacity append. When the
            -- set GREW past capacity, begin and capEnd swap in
            -- the same batch so the whole header lands atomically.
            local newEnd = header.arrayPtr + newSize * (field.elementStride or 0x8)
            if pendingVectorSwap then
                local swapOk = Memory.writeBatch({
                    { address = header.containerPtr + 0x0, flags = Memory.FLAGS.INT64, value = pendingVectorSwap },
                    { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd },
                    { address = header.containerPtr + 0x10, flags = Memory.FLAGS.INT64, value = newEnd },
                })
                if not swapOk then
                    return false, "vector_header_swap_failed"
                end
                if pendingVectorFree then
                    ZeroPage.free(pendingVectorFree)
                    pendingVectorFree = nil
                end
            else
                if not Memory.write(header.containerPtr + 0x8, Memory.FLAGS.INT64, newEnd) then
                    return false, "vector_end_write_failed"
                end
            end
        end

        return true, nil
    end

if field.elementType then
        local elementType = field.elementType
        local stride = field.elementStride or DEFAULT_STRIDE
        local impl = Type.resolve(elementType)
        if not impl then
            return false, "no_type_impl: " .. tostring(elementType)
        end

        local pointerElements = isPointerElement(elementType)

        if pointerElements and stride == DEFAULT_STRIDE then
            local slots, slotErr = readSlotPointers(header, newSize, stride)
            if not slots then
                return false, slotErr
            end
            for i = 1, newSize do
                local elementPtr = slots[i] and slots[i].value
                if elementPtr == nil or elementPtr == 0 then
                    return false, string.format("null_element_ptr_at_index_%d", i)
                end
                local f = shadowString({ offset = 0, type = elementType }, field.stringDirect)
                if impl.collectWrite then
                    local cw = {}
                    if not impl.collectWrite(elementPtr, f, values[i], cw) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                    if #cw > 0 and not Memory.writeBatch(cw) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                else
                    if not impl.set(elementPtr, f, values[i]) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                end
            end
        elseif elementType == "String" and stride == DEFAULT_STRIDE then
            local oldSize = header.size or 0
            local slots
            if oldSize > 0 then
                local readCount = math.min(oldSize, newSize)
                local slotErr
                slots, slotErr = readSlotPointers(header, readCount, DEFAULT_STRIDE)
                if not slots then
                    return false, slotErr
                end
            end
            for i = 1, newSize do
                local elementPtr
                if i <= oldSize and slots and slots[i] then
                    elementPtr = slots[i].value
                end
                if elementPtr == nil or elementPtr == 0 then
                    elementPtr = ZeroPage.allocate(0x18)
                    if not elementPtr then
                        return false, "zero_page_alloc_failed"
                    end
                    Memory.write(header.arrayPtr + (i - 1) * DEFAULT_STRIDE, Memory.FLAGS.INT64, elementPtr)
                end
                local f = { offset = 0, type = "String", indirect = false }
                if impl.collectWrite then
                    local cw = {}
                    if not impl.collectWrite(elementPtr, f, values[i], cw) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                    if #cw > 0 and not Memory.writeBatch(cw) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                else
                    if not impl.set(elementPtr, f, values[i]) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                end
            end
        else
            for i = 1, newSize do
                local f = { offset = (i - 1) * stride, type = elementType }
                if elementType == "String" then
                    -- Inline std::string elements are always direct.
                    f.indirect = false
                else
                    f = shadowString(f, field.stringDirect)
                end
                if impl.collectWrite then
                    local cw = {}
                    if not impl.collectWrite(header.arrayPtr, f, values[i], cw) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                    if #cw > 0 and not Memory.writeBatch(cw) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                else
                    if not impl.set(header.arrayPtr, f, values[i]) then
                        return false, string.format("element_write_failed_at_index_%d", i)
                    end
                end
            end
        end

        if field.container ~= "vector" then
            Memory.writeBatch({
                { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT32, value = newSize },
                { address = header.containerPtr + 0xC, flags = Memory.FLAGS.INT32, value = newSize },
            })
        else
            -- Vector ABI parity fix: get() derives size from
            -- (end - begin)/stride, so set() must move the end
            -- pointer to match the size it wrote — otherwise the
            -- game's begin/end iteration still sees the old size
            -- after a rewrite or an in-capacity append. When the
            -- set GREW past capacity, begin and capEnd swap in
            -- the same batch so the whole header lands atomically.
            local newEnd = header.arrayPtr + newSize * (field.elementStride or 0x8)
            if pendingVectorSwap then
                local swapOk = Memory.writeBatch({
                    { address = header.containerPtr + 0x0, flags = Memory.FLAGS.INT64, value = pendingVectorSwap },
                    { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd },
                    { address = header.containerPtr + 0x10, flags = Memory.FLAGS.INT64, value = newEnd },
                })
                if not swapOk then
                    return false, "vector_header_swap_failed"
                end
                if pendingVectorFree then
                    ZeroPage.free(pendingVectorFree)
                    pendingVectorFree = nil
                end
            else
                if not Memory.write(header.containerPtr + 0x8, Memory.FLAGS.INT64, newEnd) then
                    return false, "vector_end_write_failed"
                end
            end
        end

        return true, nil
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return false, "no_type_impl: " .. tostring(field.type)
    end

    local pointerElements = isPointerElement(field.type)

    if pointerElements then
        local slots, slotErr = readSlotPointers(header, newSize, DEFAULT_STRIDE)
        if not slots then
            return false, slotErr
        end
        for i = 1, newSize do
            local elementPtr = slots[i] and slots[i].value
            if elementPtr == nil or elementPtr == 0 then
                return false, string.format("null_element_ptr_at_index_%d", i)
            end
            local ok = impl.set(elementPtr, { offset = 0, type = field.type, enum = field.enum }, values[i])
            if not ok then
                return false, string.format("element_write_failed_at_index_%d", i)
            end
        end
    else
        for i = 1, newSize do
            local ok = impl.set(header.arrayPtr, { offset = (i - 1) * DEFAULT_STRIDE, type = field.type, enum = field.enum }, values[i])
            if not ok then
                return false, string.format("element_write_failed_at_index_%d", i)
            end
        end
    end

    if field.container ~= "vector" then
        Memory.writeBatch({
            { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT32, value = newSize },
            { address = header.containerPtr + 0xC, flags = Memory.FLAGS.INT32, value = newSize },
        })
    else
        -- Vector ABI parity fix: keep end == begin + size*stride so
        -- the game's begin/end iteration sees exactly newSize elements.
        -- Capacity-growing sets swap begin/capEnd in the same batch.
        local newEnd = header.arrayPtr + newSize * (field.elementStride or 0x8)
        if pendingVectorSwap then
            local swapOk = Memory.writeBatch({
                { address = header.containerPtr + 0x0, flags = Memory.FLAGS.INT64, value = pendingVectorSwap },
                { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd },
                { address = header.containerPtr + 0x10, flags = Memory.FLAGS.INT64, value = newEnd },
            })
            if not swapOk then
                return false, "vector_header_swap_failed"
            end
            if pendingVectorFree then
                ZeroPage.free(pendingVectorFree)
                pendingVectorFree = nil
            end
        else
            if not Memory.write(header.containerPtr + 0x8, Memory.FLAGS.INT64, newEnd) then
                return false, "vector_end_write_failed"
            end
        end
    end

    return true, nil
end

function M.readHeaderForSet(baseAddress, field)
    return readHeader(baseAddress, field)
end

function M.setWithHeader(baseAddress, field, values, header, writes)
    if type(values) ~= "table" then
        return false
    end

    local newSize = #values
    local stride = field.elementStride or DEFAULT_STRIDE

    -- Vector grow (see M.set): replacement buffer via ZeroPage;
    -- begin/end/capEnd swap in the final batch (pendingVectorSwap).
    local pendingVectorSwap = nil
    local pendingVectorFree = nil
    if newSize > header.capacity then
        local allocSize = newSize * stride
        if allocSize < 8 then allocSize = 8 end
        local newArrayPtr = ZeroPage.allocate(allocSize)
        if not newArrayPtr then
            return false
        end
        if header.arrayPtr ~= 0 and header.size > 0 then
            local copySize = header.size * stride
            local copyOk = Memory.copyRegion(header.arrayPtr, newArrayPtr, copySize)
            if not copyOk then return false end
        end
        local oldArrayPtr = header.arrayPtr
        if field.container == "vector" then
            header.arrayPtr = newArrayPtr
            header.capacity = newSize
            pendingVectorSwap = newArrayPtr
            if ZeroPage.owns(oldArrayPtr) then
                pendingVectorFree = oldArrayPtr
            end
        else
            writes[#writes + 1] = { address = header.containerPtr, flags = Memory.FLAGS.INT64, value = newArrayPtr }
            header.arrayPtr = newArrayPtr
            header.capacity = newSize
            if ZeroPage.owns(oldArrayPtr) then
                ZeroPage.free(oldArrayPtr)
            end
        end
    end

    if header.arrayPtr == 0 and newSize == 0 then
        return true
    end

    if header.arrayPtr == 0 then
        return false
    end

if field.elements then
        local Struct = loadModule("core/Struct.lua")
        local stride = field.elementStride or DEFAULT_STRIDE

        if stride > DEFAULT_STRIDE then
            for i = 1, newSize do
                local ok = Struct.set(
                    header.arrayPtr + (i - 1) * stride,
                    field.elements,
                    values[i],
                    field.stringDirect,
                    writes
                )
                if not ok then return false end
            end
        else
            local oldSize = header.size or 0
            local slots
            if oldSize > 0 then
                local readCount = math.min(oldSize, newSize)
                local slotErr
                slots, slotErr = readSlotPointers(header, readCount, stride)
                if not slots then return false end
            end
            for i = 1, newSize do
                local elementPtr
                if i <= oldSize and slots and slots[i] then
                    elementPtr = slots[i].value
                end
                if elementPtr == nil or elementPtr == 0 then
                    elementPtr = ZeroPage.allocate(0x100)
                    if not elementPtr then return false end
                    writes[#writes + 1] = { address = header.arrayPtr + (i - 1) * stride, flags = Memory.FLAGS.INT64, value = elementPtr }
                end
                local ok = Struct.set(elementPtr, field.elements, values[i], field.stringDirect, writes)
                if not ok then return false end
            end
        end

        if field.container ~= "vector" then
            writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT32, value = newSize }
            writes[#writes + 1] = { address = header.containerPtr + 0xC, flags = Memory.FLAGS.INT32, value = newSize }
        else
            -- Vector ABI parity fix (batched variant): keep end ==
            -- begin + size*stride in the same batch as the elements.
            -- Capacity-growing sets swap begin/capEnd in this same
            -- batch, so the whole header lands atomically.
            local newEnd = header.arrayPtr + newSize * (field.elementStride or 0x8)
            if pendingVectorSwap then
                writes[#writes + 1] = { address = header.containerPtr + 0x0, flags = Memory.FLAGS.INT64, value = pendingVectorSwap }
                writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd }
                writes[#writes + 1] = { address = header.containerPtr + 0x10, flags = Memory.FLAGS.INT64, value = newEnd }
                if pendingVectorFree then
                    ZeroPage.free(pendingVectorFree)
                    pendingVectorFree = nil
                end
            else
                writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd }
            end
        end
        return true
    end

if field.elementType then
        local elementType = field.elementType
        local stride = field.elementStride or DEFAULT_STRIDE
        local impl = Type.resolve(elementType)
        if not impl then return false end

        local pointerElements = isPointerElement(elementType)

        if pointerElements and stride == DEFAULT_STRIDE then
            local slots, slotErr = readSlotPointers(header, newSize, stride)
            if not slots then return false end
            for i = 1, newSize do
                local elementPtr = slots[i] and slots[i].value
                if elementPtr == nil or elementPtr == 0 then
                    return false
                end
                local f = shadowString({ offset = 0, type = elementType }, field.stringDirect)
                if impl.collectWrite then
                    if not impl.collectWrite(elementPtr, f, values[i], writes) then return false end
                else
                    if not impl.set(elementPtr, f, values[i]) then return false end
                end
            end
        elseif elementType == "String" and stride == DEFAULT_STRIDE then
            local oldSize = header.size or 0
            local slots
            if oldSize > 0 then
                local readCount = math.min(oldSize, newSize)
                local slotErr
                slots, slotErr = readSlotPointers(header, readCount, DEFAULT_STRIDE)
                if not slots then return false end
            end
            for i = 1, newSize do
                local elementPtr
                if i <= oldSize and slots and slots[i] then
                    elementPtr = slots[i].value
                end
                if elementPtr == nil or elementPtr == 0 then
                    elementPtr = ZeroPage.allocate(0x18)
                    if not elementPtr then return false end
                    writes[#writes + 1] = { address = header.arrayPtr + (i - 1) * DEFAULT_STRIDE, flags = Memory.FLAGS.INT64, value = elementPtr }
                end
                local f = { offset = 0, type = "String", indirect = false }
                if impl.collectWrite then
                    if not impl.collectWrite(elementPtr, f, values[i], writes) then return false end
                else
                    if not impl.set(elementPtr, f, values[i]) then return false end
                end
            end
        else
            for i = 1, newSize do
                local f = { offset = (i - 1) * stride, type = elementType }
                if elementType == "String" then
                    -- Inline std::string elements are always direct.
                    f.indirect = false
                else
                    f = shadowString(f, field.stringDirect)
                end
                if impl.collectWrite then
                    if not impl.collectWrite(header.arrayPtr, f, values[i], writes) then return false end
                else
                    if not impl.set(header.arrayPtr, f, values[i]) then return false end
                end
            end
        end

        if field.container ~= "vector" then
            writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT32, value = newSize }
            writes[#writes + 1] = { address = header.containerPtr + 0xC, flags = Memory.FLAGS.INT32, value = newSize }
        else
            -- Vector ABI parity fix (batched variant): keep end ==
            -- begin + size*stride in the same batch as the elements.
            -- Capacity-growing sets swap begin/capEnd in this same
            -- batch, so the whole header lands atomically.
            local newEnd = header.arrayPtr + newSize * (field.elementStride or 0x8)
            if pendingVectorSwap then
                writes[#writes + 1] = { address = header.containerPtr + 0x0, flags = Memory.FLAGS.INT64, value = pendingVectorSwap }
                writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd }
                writes[#writes + 1] = { address = header.containerPtr + 0x10, flags = Memory.FLAGS.INT64, value = newEnd }
                if pendingVectorFree then
                    ZeroPage.free(pendingVectorFree)
                    pendingVectorFree = nil
                end
            else
                writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd }
            end
        end
        return true
    end

    local impl = Type.resolve(field.type)
    if not impl then return false end

    local pointerElements = isPointerElement(field.type)

    if pointerElements then
        local slots, slotErr = readSlotPointers(header, newSize, DEFAULT_STRIDE)
        if not slots then return false end
        for i = 1, newSize do
            local elementPtr = slots[i] and slots[i].value
            if elementPtr == nil or elementPtr == 0 then return false end
            if not impl.set(elementPtr, { offset = 0, type = field.type, enum = field.enum }, values[i]) then return false end
        end
    else
        for i = 1, newSize do
            if not impl.set(header.arrayPtr, { offset = (i - 1) * DEFAULT_STRIDE, type = field.type, enum = field.enum }, values[i]) then return false end
        end
    end

    if field.container ~= "vector" then
        writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT32, value = newSize }
        writes[#writes + 1] = { address = header.containerPtr + 0xC, flags = Memory.FLAGS.INT32, value = newSize }
    else
        -- Vector ABI parity fix (batched variant): keep end ==
        -- begin + size*stride in the same batch as the elements.
        -- Capacity-growing sets swap begin/capEnd in this same batch.
        local newEnd = header.arrayPtr + newSize * (field.elementStride or 0x8)
        if pendingVectorSwap then
            writes[#writes + 1] = { address = header.containerPtr + 0x0, flags = Memory.FLAGS.INT64, value = pendingVectorSwap }
            writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd }
            writes[#writes + 1] = { address = header.containerPtr + 0x10, flags = Memory.FLAGS.INT64, value = newEnd }
            if pendingVectorFree then
                ZeroPage.free(pendingVectorFree)
                pendingVectorFree = nil
            end
        else
            writes[#writes + 1] = { address = header.containerPtr + 0x8, flags = Memory.FLAGS.INT64, value = newEnd }
        end
    end
    return true
end

return M
