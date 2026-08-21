--==================================================
-- core/Field.lua
--==================================================
-- Generic field/message accessor factory.
--
-- Creates proxy objects that wrap (baseAddress, metadataNode)
-- and support __index navigation through metadata-defined fields.
-- This is NOT a parallel system — it routes every read/write
-- through the existing Type registry and Repeated module, just
-- with a one-level-at-a-time access pattern instead of the
-- dotted-path walk used by the module-level get(id)/set(id, value).
--
-- Three accessor kinds:
--
--   MessageView   — wraps a base + metadata node. __index resolves
--                   field names from metadata and returns the
--                   appropriate accessor. Methods (get, set, now,
--                   fields, meta) are stored as closures on the
--                   table itself, so dot syntax works without self:
--                     event.get("startTime")      -- backward compat
--                     event.startTime.get()        -- new style
--                     event.startTime.set(1700000000)
--                     event.sessionEntry.entryFeeTickets.get()
--
--   ScalarAccessor — wraps a single typed field. get()/set() go
--                   straight to the Type implementation.
--
--   ArrayAccessor   — wraps an Array/repeated field. get()/set()
--                   go through Repeated.
--
-- ABI configuration (opts):
--   stringDirect = true   — String fields are inlined into the
--                           struct (no pointer indirection). This
--                           is the same fact that the api modules
--                           encode via shadowStringDirect().
--   container = "vector"  — Arrays use C++ std::vector ABI (vs
--                           protobuf RepeatedField default).
--
-- Base resolution:
--   The root MessageView (created by api module's get()) receives
--   a resolveFn closure. Base is resolved lazily on first field
--   access or explicit now() call. Nested MessageViews (created
--   by __index traversal) receive a pre-resolved base — no
--   resolveFn needed.

local Type     = loadModule("core/Type.lua")
local Repeated = loadModule("core/Repeated.lua")
local Memory   = loadModule("core/Memory.lua")

local Field = {}

--==================================================
-- Shared helpers
--==================================================

---A metadata node is a leaf (readable) field iff it has a `type`
---string. Pure namespace containers (sessionEntry, gameMode) have
---no `type` — only typed children.
local function isLeaf(node)
    return type(node) == "table" and type(node.type) == "string"
end

---Offset is known (not the 0xBAAD placeholder).
local function isOffsetKnown(field)
    return field.offset ~= nil and field.offset ~= 0xBAAD
end

---Shadow a String field with indirect=false when opts.stringDirect
---is set. Same logic as every api module's shadowStringDirect().
---Does NOT mutate the shared metadata — returns a shadow table.
local function shadowString(field, opts)
    if field.type == "String" and field.indirect == nil
       and opts and opts.stringDirect then
        return setmetatable({ indirect = false }, { __index = field })
    end
    return field
end

---Shadow an Array field with stringDirect + container when opts
---requires it. Same logic as every api module's
---shadowStringDirectArray().
local function shadowArray(field, opts)
    if field.stringDirect == nil
       and opts and opts.stringDirect then
        return setmetatable({
            stringDirect = true,
            container = opts.container or "vector",
        }, { __index = field })
    end
    return field
end

---Walk a metadata tree looking up a dotted-path field id,
---starting from the given metadata node (not necessarily root).
---@param metadata table
---@param id string  e.g. "sessionEntry.entryFeeTickets"
---@return table|nil field, string|nil error
local function lookupInMetadata(metadata, id)
    local node = metadata
    for part in id:gmatch("[^.]+") do
        if type(node) ~= "table" or node[part] == nil then
            return nil, "unknown_field: " .. tostring(id)
        end
        node = node[part]
    end
    if not isLeaf(node) then
        return nil, "unknown_field: " .. tostring(id)
    end
    return node
end

---Generic read: walk metadata from the given node, read the field
---through the Type/Repeated system. Same logic as each api module's
---readField(), just factored out so nested MessageViews can use it
---without duplicating the module's local readField.
---@param base integer
---@param metadata table
---@param opts table|nil
---@param id string  dotted field id
---@return any|nil value, string|nil error
local function readFieldGeneric(base, metadata, opts, id)
    local field, err = lookupInMetadata(metadata, id)
    if not field then return nil, err end

    if field.type == "Object" then
        return nil, "unsupported_type: Object fields are not yet readable (missing nested metadata)"
    end

    if not isOffsetKnown(field) then
        return nil, "offset_unknown: " .. id
    end

    if field.type == "Array" then
        return Repeated.get(base, shadowArray(field, opts))
    end

    if field.repeated then
        return Repeated.get(base, field)
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return nil, "no_type_impl: " .. tostring(field.type)
    end

    return impl.get(base, shadowString(field, opts))
end

---Generic write: same structure as readFieldGeneric, but writes.
---@param base integer
---@param metadata table
---@param opts table|nil
---@param id string
---@param value any
---@return boolean ok, string|nil error
local function writeFieldGeneric(base, metadata, opts, id, value)
    local field, err = lookupInMetadata(metadata, id)
    if not field then return false, err end

    if field.type == "Object" then
        return false, "unsupported_type: Object fields are not yet writable (missing nested metadata)"
    end

    if not isOffsetKnown(field) then
        return false, "offset_unknown: " .. id
    end

    if field.type == "Array" then
        return Repeated.set(base, shadowArray(field, opts), value)
    end

    if field.repeated then
        return Repeated.set(base, field, value)
    end

    local impl = Type.resolve(field.type)
    if not impl then
        return false, "no_type_impl: " .. tostring(field.type)
    end

    return impl.set(base, shadowString(field, opts), value)
end

---Walk a metadata node collecting leaf field IDs (dotted paths).
---Same logic as each api module's walkFields(), but starts from
---the given node instead of root.
---@param node table
---@param prefix string|nil
---@param results string[]
local function walkFields(node, prefix, results)
    for key, child in pairs(node) do
        if type(key) == "string" and type(child) == "table" then
            local id = prefix and (prefix .. "." .. key) or key
            if isLeaf(child) then
                if isOffsetKnown(child) then
                    results[#results + 1] = id
                end
            else
                walkFields(child, id, results)
            end
        end
    end
end

--==================================================
-- ScalarAccessor
--==================================================
-- Plain table with get/set closures (dot syntax, no self needed).
-- Created when __index resolves a leaf field that's a scalar type
-- (Int32, String, Float, Enum, Bool, BitMask, etc.).

function Field.scalar(base, field, opts)
    local shadowedField = shadowString(field, opts)

    return {
        get = function()
            if not isOffsetKnown(field) then
                return nil, "offset_unknown"
            end
            local impl = Type.resolve(field.type)
            if not impl then
                return nil, "no_type_impl: " .. tostring(field.type)
            end
            return impl.get(base, shadowedField)
        end,

        set = function(value)
            if not isOffsetKnown(field) then
                return false, "offset_unknown"
            end
            local impl = Type.resolve(field.type)
            if not impl then
                return false, "no_type_impl: " .. tostring(field.type)
            end
            return impl.set(base, shadowedField, value)
        end,

        meta = function()
            return {
                type     = field.type,
                offset   = field.offset,
                known    = isOffsetKnown(field),
                repeated = field.repeated == true,
            }
        end,
    }
end

--==================================================
-- ArrayAccessor
--==================================================
-- Plain table with get/set closures. Routes through Repeated,
-- same as the module-level readField/writeField for Array fields.

function Field.array(base, field, opts)
    local shadowedField = shadowArray(field, opts)

    return {
        get = function()
            if not isOffsetKnown(field) then
                return nil, "offset_unknown"
            end
            return Repeated.get(base, shadowedField)
        end,

        set = function(value)
            if not isOffsetKnown(field) then
                return false, "offset_unknown"
            end
            return Repeated.set(base, shadowedField, value)
        end,

        meta = function()
            return {
                type     = field.type,
                offset   = field.offset,
                known    = isOffsetKnown(field),
                repeated = true,
            }
        end,
    }
end

--==================================================
-- MessageView
--==================================================
-- Wraps a base address + metadata node. Supports:
--
--   __index navigation:  event.startTime → ScalarAccessor
--                        event.sessionEntry → MessageView (same base)
--                        event.lootDefinition → MessageView (base+offset)
--                        event.eventRewards → ArrayAccessor
--
--   Method closures (dot syntax, no colon needed):
--     event.get("dotted.path")  — backward compat, returns value
--     event.set("dotted.path", v) — backward compat, writes value
--     event.now()               — resolve base, return (self|nil, err)
--     event.fields()            — list known field IDs
--     event.meta("field")       — field metadata
--
-- Methods are stored as table fields (found by rawget before
-- __index), so they never shadow metadata field names. No known
-- metadata field is named "get", "set", "now", "fields", or "meta".

function Field.message(base, metadata, opts, resolveFn)
    opts = opts or {}
    local self = {}

    -- Private state
    self._base      = base
    self._metadata  = metadata
    self._opts      = opts
    self._resolveFn = resolveFn
    self._resolveErr = nil

    ---Resolve base address if not already resolved.
    ---Returns true if base is available.
    local function ensureBase()
        if self._base == nil and resolveFn then
            self._base, self._resolveErr = resolveFn()
        end
        return self._base ~= nil
    end

    --================================
    -- Method closures (dot syntax)
    --================================

    ---Resolve base and return self (for backward compat with the
    ---get():now() pattern). Returns (nil, error) if resolution fails.
    self.now = function()
        if not ensureBase() then
            return nil, self._resolveErr
        end
        return self
    end

    ---Read a field by dotted path (backward compat). Delegates to
    ---readFieldGeneric which walks metadata from this node.
    self.get = function(id)
        if id == nil then return self end
        if not ensureBase() then
            return nil, self._resolveErr
        end
        return readFieldGeneric(self._base, metadata, opts, id)
    end

    ---Write a field by dotted path (backward compat).
    self.set = function(id, value)
        if not ensureBase() then
            return false, self._resolveErr
        end
        return writeFieldGeneric(self._base, metadata, opts, id, value)
    end

    ---List every offset-verified field's dotted id, starting from
    ---this metadata node.
    self.fields = function()
        local results = {}
        walkFields(metadata, nil, results)
        table.sort(results)
        return results
    end

    ---Return metadata about a field by dotted path.
    self.meta = function(id)
        local field, err = lookupInMetadata(metadata, id)
        if not field then return nil, err end
        return {
            type     = field.type,
            offset   = field.offset,
            known    = isOffsetKnown(field),
            repeated = field.repeated == true,
        }
    end

    --================================
    -- __index field navigation
    --================================

    local mt = {
        __index = function(t, k)
            -- Methods are in the table itself (rawget finds them
            -- before __index is called). So if we're here, k is
            -- not a method — it's a field name to resolve from
            -- metadata.
            local node = metadata[k]
            if node == nil then
                return nil
            end

            if not ensureBase() then
                return nil, self._resolveErr
            end

            if isLeaf(node) then
                if node.type == "Object" then
                    -- Pointer-backed nested sub-struct (e.g.
                    -- lootDefinition) — same convention as
                    -- core/Struct.lua's M.get(): base+offset holds
                    -- a POINTER to the sub-struct, not the
                    -- sub-struct's data itself. Must deref, not
                    -- just add the offset.
                    local ptr, derefErr = Memory.deref(self._base, node.offset or 0)
                    if not ptr or ptr == 0 then
                        return nil, derefErr or "null_pointer"
                    end
                    return Field.message(ptr, node, opts, nil)
                elseif node.type == "Array" then
                    return Field.array(self._base, node, opts)
                elseif node.repeated then
                    -- Plain repeated field (not Array type)
                    return Field.array(self._base, node, opts)
                else
                    return Field.scalar(self._base, node, opts)
                end
            else
                -- Namespace container (e.g. sessionEntry, gameMode):
                -- children have absolute offsets from the struct base.
                -- Base stays the same; only the metadata scope narrows.
                return Field.message(self._base, node, opts, nil)
            end
        end,
    }

    setmetatable(self, mt)
    return self
end

return Field
