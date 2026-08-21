--==================================================
-- api/CommunityEvent.lua
--==================================================
-- Public-facing Nebula.CommunityEvent module.
--
-- CommunityShowcase (社区赛道) is a distinct event type from
-- PublicEvent and TeamEvent — simpler struct, no reward/loot
-- fields, and resolved via string search instead of AOB.
--
-- Base resolution uses a string-search method: search for the ASCII
-- bytes of "community Showcase\0", validate with a vtable marker
-- (0x6D6F631E at hit-0x18), then extract the struct pointer at
-- hit-0x20. See core/Memory.lua's resolveActiveCommunityEventBase()
-- for the full flow.
--
--   Nebula.CommunityEvent.get("startTime")
--   Nebula.CommunityEvent.get("sessionEntry.entryFeeTickets")
--   Nebula.CommunityEvent.get("minRankToJoin")
--
--   local event = Nebula.CommunityEvent.get()
--   event.get("name")
--   event.get("sessionEntry.maxEventTickets")
--
--   Nebula.CommunityEvent.set("startTime", 1700000000)
--   Nebula.CommunityEvent.set("startTime", 1700000000):dry()

local Memory   = loadModule("core/Memory.lua")
local Type     = loadModule("core/Type.lua")
local Repeated = loadModule("core/Repeated.lua")
local Path     = loadModule("core/Path.lua")
local Struct   = loadModule("core/Struct.lua")
local metadata = loadModule("metadata/CommunityEvent.lua")

local M = {}

M.metadata = metadata

-- Cached per script session.
local baseAddress = nil

--==================================================
-- Base address resolution
--==================================================

---@param forceRescan boolean|nil
---@return integer|nil address, string|nil error
local function resolveBase(forceRescan)
    if baseAddress ~= nil and not forceRescan then
        return baseAddress
    end

    local address, err = Memory.resolveActiveCommunityEventBase()
    if not address then
        log("resolveBase failed:", err)
        return nil, err or "base_not_found"
    end

    baseAddress = address
    return baseAddress
end

M.resolveBase = resolveBase

--==================================================
-- Field lookup helpers
--==================================================

---A field is a leaf (readable) entry iff its own `type` is a
---string. Pure namespace containers (sessionEntry, gameMode) have
---no `type` of their own — only typed children.
---@param node any
---@return boolean
local function isLeafField(node)
    return type(node) == "table" and type(node.type) == "string"
end

local function log(...)
    if Nebula ~= nil and Nebula.log then
        print("[Nebula.CommunityEvent]", ...)
    end
end

local function isOffsetKnown(field)
    return field.offset ~= nil and field.offset ~= 0xBAAD
end

local function shadowStringDirect(field)
    if field.type == "String" and field.indirect == nil then
        return setmetatable({ indirect = false }, { __index = field })
    end
    return field
end

local function shadowStringDirectArray(field)
    if field.stringDirect == nil then
        return setmetatable({ stringDirect = true, container = "vector" }, { __index = field })
    end
    return field
end

---@param id string @ dotted field id, e.g. "sessionEntry.entryFeeTickets"
---@return table|nil field, string|nil error
local function resolvePath(id)
    local segments = Path.parse(id)
    if #segments == 0 then
        return nil, "empty_path"
    end

    local base, baseErr = resolveBase()
    if not base then
        return nil, baseErr
    end

    local currentBase = base
    local currentMeta = metadata
    local finalField = nil

    for i, seg in ipairs(segments) do
        local node = currentMeta[seg.name]
        if node == nil then
            return nil, "unknown_field: " .. tostring(id)
        end

        if seg.index ~= nil then
            if node.type ~= "Array" then
                return nil, "not_an_array: " .. seg.name
            end
            if not isOffsetKnown(node) then
                return nil, "offset_unknown: " .. seg.name
            end
            local arr, arrErr = Repeated.get(currentBase, shadowStringDirectArray(node))
            if not arr then
                return nil, arrErr
            end
            local luaIdx = seg.index
            if luaIdx < 1 or luaIdx > #arr then
                return nil, string.format("index_out_of_bounds: %s[%d] (size=%d)", seg.name, seg.index, #arr)
            end
            if i == #segments then
                local elemStride = node.elementStride or 0x8
                local header, _ = Repeated.readHeaderForSet(currentBase, node)
                local writeAddr = nil
                if header and header.arrayPtr and header.arrayPtr ~= 0 then
                    if elemStride > 0x8 then
                        writeAddr = header.arrayPtr + (seg.index - 1) * elemStride
                    else
                        local slots, _ = Memory.readBatchChunked({
                            { address = header.arrayPtr + (seg.index - 1) * 0x8, flags = Memory.FLAGS.INT64 }
                        })
                        if slots and slots[1] and slots[1].value ~= 0 then
                            writeAddr = slots[1].value
                        end
                    end
                end
                return { value = arr[luaIdx], resolved = true, writeAddr = writeAddr, elementType = node.elementType }
            end
            if node.elements then
                local stride = node.elementStride or 0x8
                if stride > 0x8 then
                    local header, hErr = Repeated.readHeaderForSet(currentBase, node)
                    if not header then return nil, hErr end
                    currentBase = header.arrayPtr + (seg.index - 1) * stride
                else
                    local h, he = Repeated.readHeaderForSet(currentBase, node)
                    if not h then return nil, he end
                    local slots, sErr = Memory.readBatchChunked({
                        { address = h.arrayPtr + (seg.index - 1) * 0x8, flags = Memory.FLAGS.INT64 }
                    })
                    if not slots or not slots[1] or slots[1].value == 0 then
                        return nil, "null_element_ptr"
                    end
                    currentBase = slots[1].value
                end
                currentMeta = node.elements
            else
                return nil, "array_has_no_elements: " .. seg.name
            end
        elseif isLeafField(node) and i == #segments then
            finalField = node
            break
        elseif type(node) == "table" and not isLeafField(node) and i < #segments then
            currentMeta = node
        else
            return nil, "unknown_field: " .. tostring(id)
        end
    end

    if finalField then
        return { field = finalField, base = currentBase }
    end
    return nil, "unknown_field: " .. tostring(id)
end



---Same ABI fact as PublicEvent/TeamEvent — CommunityShowcase's
---strings are inlined into the struct (no pointer indirection).
---Does NOT mutate the shared metadata.
---@param field table
---@return table field

---Shadow an Array-with-elements field to add stringDirect=true.
---@param field table
---@return table field

---Shared by M.get(id) and the accessor object returned by M.get() with no id.
---@param base integer
---@param id string
---@return any|nil value, string|nil error
local function readFieldById(id)
    local result, err = resolvePath(id)
    if not result then
        log("get failed:", err)
        return nil, err
    end

    if result.resolved then
        return result.value
    end

    local field = result.field
    local base = result.base

    if field.type == "Object" then
        return nil, "unsupported_type: Object fields are not yet readable (missing nested metadata)"
    end

    if not isOffsetKnown(field) then
        return nil, "offset_unknown: " .. id
    end

    if field.type == "Array" then
        return Repeated.get(base, shadowStringDirectArray(field))
    end

    if field.repeated then
        return Repeated.get(base, field)
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return nil, "no_type_impl: " .. tostring(field.type)
    end

    local value, valErr = impl.get(base, shadowStringDirect(field))
    if value == nil and valErr then
        log("get('" .. id .. "') failed:", valErr)
    end
    return value, valErr
end

---Shared by M.set(id, value) and SetOperation.
---@param base integer
---@param id string
---@param value any
---@return boolean ok, string|nil error
local function writeFieldById(id, value)
    local result, err = resolvePath(id)
    if not result then
        return false, err
    end

    if result.resolved then
        if not result.writeAddr then
            return false, "cannot_set_array_element_value_directly"
        end
        if op._dry then
            log(string.format("[dry] would set '%s' = %s", op.id, tostring(op.value)))
            return true, nil
        end
        local elemType = result.elementType
        if not elemType then
            return false, "unknown_element_type"
        end
        local impl = Type.resolve(elemType)
        if not impl then
            return false, "no_type_impl: " .. tostring(elemType)
        end
        local f = { offset = 0, type = elemType }
        if elemType == "String" then
            f.indirect = false
        end
        local ok = impl.set(result.writeAddr, f, op.value)
        if not ok then
            log("set('" .. op.id .. "') failed")
            return false, "write_failed"
        end
        log(string.format("set '%s' = %s", op.id, tostring(op.value)))
        return true, nil
    end

    local field = result.field
    local base = result.base

    if field.type == "Object" then
        return false, "unsupported_type: Object fields are not yet writable (missing nested metadata)"
    end

    if not isOffsetKnown(field) then
        return false, "offset_unknown: " .. id
    end

    if field.type == "Array" then
        return Repeated.set(base, shadowStringDirectArray(field), value)
    end

    if field.repeated then
        return Repeated.set(base, field, value)
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return false, "no_type_impl: " .. tostring(field.type)
    end

    local ok = impl.set(base, shadowStringDirect(field), value)
    if not ok then
        return false, "write_failed"
    end
    return true, nil
end

--==================================================
-- get()
--==================================================
-- Called with a dotted id, reads that field immediately. Called
-- with no id, resolves the base immediately and returns an
-- accessor/context object with its own get(id) bound to that exact
-- snapshot — no separate :now() step required.

---@param id string|nil @ omit to get an event accessor bound to the currently-active struct
---@return any|nil value, string|nil error
function M.get(id)
    local base, baseErr = resolveBase()
    if not base then
        log("get failed, no base:", baseErr)
        return nil, baseErr
    end

    if id == nil then
        return {
            base = base,
            get = function(fieldId)
                return readFieldById(fieldId)
            end,
        }
    end

    return readFieldById(id)
end

--==================================================
-- set() — returns a chainable operation object supporting
-- :dry()
--==================================================

local SetOperation = {}
SetOperation.__index = SetOperation

local function performWrite(op)
    if op._dry then
        local result, dryErr = resolvePath(op.id)
        if not result then
            log("set failed:", dryErr)
            return false, dryErr
        end
        log(string.format("[dry] would set '%s' = %s", op.id, tostring(op.value)))
        return true, nil
    end

    local ok, err = writeFieldById(op.id, op.value)
    if not ok and err then
        log("set('" .. op.id .. "') failed:", err)
    end
    return ok, err
end

---Mark this operation as a dry run: validates everything (field
---exists, offset known) but never touches memory.
---Returns (ok, err).
function SetOperation:dry()
    self._dry = true
    return performWrite(self)
end

setmetatable(SetOperation, {
    __call = function(cls, id, value)
        local self = setmetatable({ id = id, value = value, _dry = false }, cls)
        local ok, err = performWrite(self)
        self._ok, self._err = ok, err
        return self
    end
})

---Write a field value to the currently-active CommunityEvent struct.
---@param id string @ dotted field id
---@param value any
---@return table operation @ chainable; already executed
function M.set(id, value)
    return SetOperation(id, value)
end

--==================================================
-- fields() / meta() — read-only introspection
--==================================================

---@param node table
---@param prefix string|nil
---@param results string[]
local function walkFields(node, prefix, results)
    for key, child in pairs(node) do
        if type(child) == "table" then
            local id = prefix and (prefix .. "." .. key) or key
            if isLeafField(child) then
                if isOffsetKnown(child) then
                    results[#results + 1] = id
                end
            else
                walkFields(child, id, results)
            end
        end
    end
end

---List every offset-verified field's dotted id.
---@return string[] ids
function M.fields()
    local results = {}
    walkFields(metadata, nil, results)
    table.sort(results)
    return results
end

---@param id string
---@return table|nil metaView, string|nil error
function M.meta(id)
    local result, err = resolvePath(id)
    local field = result and result.field
    if not field then
        return nil, err
    end

    local known = isOffsetKnown(field)
    return {
        type = field.type,
        offset = field.offset,
        known = known,
        repeated = field.repeated == true,
    }
end

return M
