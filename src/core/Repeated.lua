--==================================================
-- core/Repeated.lua
--==================================================
-- Walks a repeated-field container and dispatches each element to
-- its declared element type (field.type). This is not registered
-- in core/Type.lua's registry — it's infrastructure that
-- api/GameStatus.lua calls directly whenever field.repeated == true,
-- using field.type to know what each element actually is.
--
-- Container layout:
--
--   base + field.offset = ptr        (this address IS the container
--                                     header start — not a pointer
--                                     that needs an extra deref)
--
--   ptr + 0x0   arrayPtr   (int64, pointer to backing array)
--   ptr + 0x8   size       (int32, live element count)
--   ptr + 0xC   capacity   (int32, allocated slot count)
--   ptr + 0x10  allocSlots (int32, next-pow2 of size — derived by
--                           the allocator's growth strategy, not
--                           authoritative; capacity is the number
--                           Nebula trusts for bounds-checking)
--
-- Element slots, 8 bytes apart, `size` of them:
--
--   arrayPtr + 0x0, 0x8, 0x10, 0x18, ...
--
-- Each slot's *contents* depend on the element kind:
--
--   - Message/custom types (e.g. Achievement, SafeInt32,
--     DriverCustomization): the slot holds a POINTER to the
--     element's struct. The element type's get/set(base, field)
--     is called with that pointer as `base` and an offset of 0,
--     since the whole struct starts right there.
--
--   - Direct scalars (Int32, Bool, Float): the slot holds the
--     value inline at scalar width, not behind another pointer.
--     (Not yet exercised by a real field — Achievement is the
--     first test case and it's message-typed — but the branch
--     exists so scalar repeated fields don't silently misread.)

local Memory = loadModule("core/Memory.lua")
local Type   = loadModule("core/Type.lua")

local M = {}

local ELEMENT_STRIDE = 0x8

-- Types whose array slots hold a pointer to the element (rather
-- than the element's value inline). Message/custom types always
-- fall in here; scalar types are read/written inline.
local POINTER_ELEMENT_TYPES = {
    SafeInt32 = true,
}

---@param elementType string
---@return boolean
local function isPointerElement(elementType)
    if POINTER_ELEMENT_TYPES[elementType] then
        return true
    end
    -- Anything not a known inline scalar type is assumed to be a
    -- message/custom type, which is always pointer-indirected.
    local INLINE_SCALARS = { Int32 = true, Bool = true, Float = true, String = true, BitMask = true }
    return not INLINE_SCALARS[elementType]
end

-- Hard ceiling on element count Nebula will ever trust from a
-- container header. A real HCR2 repeated field (achievements,
-- owned vehicles, etc.) is nowhere near this size — if size or
-- capacity comes back larger than this, the header read landed on
-- garbage (wrong offset, misaligned pointer, uninitialized memory)
-- and must be rejected rather than acted on. Without this, a
-- corrupted size can turn into a multi-gigabyte table allocation
-- attempt before a single gg.* call even happens, which is enough
-- to OOM both the Lua VM and GG's host process.
local MAX_TRUSTED_ELEMENT_COUNT = 100000

---Read the container header at base+offset. The container header
---lives directly at that address — base+offset IS the header
---start, not a pointer to be dereferenced again. (Earlier versions
---of this function called Memory.deref() here, which added a
---spurious extra pointer hop and read size/capacity from the wrong
---location entirely.)
---@param baseAddress integer
---@param field table
---@return table|nil header, string|nil error
local function readHeader(baseAddress, field)
    local ptr = baseAddress + field.offset

    local fields, readErr = Memory.readBatch({
        { address = ptr,        flags = Memory.FLAGS.INT64 }, -- arrayPtr
        { address = ptr + 0x8,  flags = Memory.FLAGS.INT32 }, -- size
        { address = ptr + 0xC,  flags = Memory.FLAGS.INT32 }, -- capacity
    })

    if not fields then
        return nil, readErr
    end

    local arrayPtr = fields[1] and fields[1].value
    local size     = fields[2] and fields[2].value
    local capacity = fields[3] and fields[3].value

    if arrayPtr == nil or size == nil or capacity == nil then
        return nil, "header_read_failed"
    end

    -- Reject negative values outright — a valid size/capacity is
    -- never negative; a negative int32 here means we're reading
    -- garbage (wrong struct, misaligned offset, sign-bit garbage).
    if size < 0 or capacity < 0 then
        return nil, "header_negative_size_or_capacity"
    end

    -- Reject anything past the trusted ceiling before it's used to
    -- drive any loop or table allocation.
    if size > MAX_TRUSTED_ELEMENT_COUNT or capacity > MAX_TRUSTED_ELEMENT_COUNT then
        return nil, string.format(
            "header_size_out_of_bounds (size=%d capacity=%d, max=%d) — offset likely wrong",
            size, capacity, MAX_TRUSTED_ELEMENT_COUNT)
    end

    -- A well-formed container never has more live elements than
    -- allocated capacity. If it does, the header is corrupted.
    if size > capacity then
        return nil, string.format("header_size_exceeds_capacity (size=%d capacity=%d)", size, capacity)
    end

    return { containerPtr = ptr, arrayPtr = arrayPtr, size = size, capacity = capacity }
end

--==================================================
-- get()
--==================================================

---Read every element of a repeated field into a plain Lua array.
---@param baseAddress integer
---@param field table @ { offset, type = <element type>, repeated = true, ... }
---@return table|nil values, string|nil error
function M.get(baseAddress, field)
    local header, err = readHeader(baseAddress, field)
    if not header then
        return nil, err
    end

    if header.size <= 0 then
        return {}, nil
    end

    if header.arrayPtr == 0 then
        return nil, "null_array_ptr"
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return nil, "no_type_impl: " .. tostring(field.type)
    end

    local pointerElements = isPointerElement(field.type)
    local values = {}
    local count = 0

    if pointerElements then
        -- Read all slot pointers in one batch first.
        local slotSpecs = {}
        for i = 0, header.size - 1 do
            slotSpecs[i + 1] = { address = header.arrayPtr + i * ELEMENT_STRIDE, flags = Memory.FLAGS.INT64 }
        end

        local slots, slotErr = Memory.readBatchChunked(slotSpecs)
        if not slots then
            return nil, slotErr
        end

        if impl.specs and impl.parse then
            -- Batch-optimized path: collect every element's field
            -- specs into one cross-element readBatch, then hand
            -- each element's slice to impl.parse(). Cuts N
            -- round-trips (one get() per element) down to 1.
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
            -- Fallback: element type doesn't implement the batch
            -- interface, dispatch one get() call per element.
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
        -- Inline scalar elements: dispatch directly against the
        -- array base using a synthetic per-index offset.
        for i = 0, header.size - 1 do
            local value = impl.get(header.arrayPtr, { offset = i * ELEMENT_STRIDE, type = field.type, enum = field.enum })
            count = count + 1
            values[count] = value == nil and false or value
        end
    end

    return values, nil
end

--==================================================
-- set()
--==================================================

---Write a plain Lua array back into a repeated field. Only
-- overwrites existing slots (0..#values-1) and updates `size` —
-- never grows the backing array or allocates new element structs,
-- since Nebula doesn't own the game's allocator. Fails cleanly if
-- the new array is larger than the container's capacity.
---@param baseAddress integer
---@param field table
---@param values table @ plain Lua array of element values
---@return boolean ok, string|nil error
function M.set(baseAddress, field, values)
    if type(values) ~= "table" then
        return false, "value_not_array"
    end

    local header, err = readHeader(baseAddress, field)
    if not header then
        return false, err
    end

    local newSize = #values

    if newSize > header.capacity then
        return false, "capacity_exceeded"
    end

    if header.arrayPtr == 0 then
        return false, "null_array_ptr"
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return false, "no_type_impl: " .. tostring(field.type)
    end

    local pointerElements = isPointerElement(field.type)

    if pointerElements then
        -- Existing slot pointers must already point at live element
        -- structs to write into — Nebula can't allocate new ones.
        local slotSpecs = {}
        for i = 0, newSize - 1 do
            slotSpecs[i + 1] = { address = header.arrayPtr + i * ELEMENT_STRIDE, flags = Memory.FLAGS.INT64 }
        end

        local slots, slotErr = Memory.readBatchChunked(slotSpecs)
        if not slots then
            return false, slotErr
        end

        for i = 1, newSize do
            local elementPtr = slots[i] and slots[i].value
            if elementPtr == nil or elementPtr == 0 then
                return false, string.format("null_element_ptr_at_index_%d", i - 1)
            end
            local ok = impl.set(elementPtr, { offset = 0, type = field.type, enum = field.enum }, values[i])
            if not ok then
                return false, string.format("element_write_failed_at_index_%d", i - 1)
            end
        end
    else
        for i = 1, newSize do
            local ok = impl.set(header.arrayPtr, { offset = (i - 1) * ELEMENT_STRIDE, type = field.type, enum = field.enum }, values[i])
            if not ok then
                return false, string.format("element_write_failed_at_index_%d", i - 1)
            end
        end
    end

    local sizeOk = Memory.write(header.containerPtr + 0x8, Memory.FLAGS.INT32, newSize)
    if not sizeOk then
        return false, "size_write_failed"
    end

    return true, nil
end

return M
