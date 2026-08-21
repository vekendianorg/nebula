--==================================================
-- core/Cache.lua
--==================================================
-- Persistent, PID-scoped cache for address discovery results.
--
-- Stores serialized Lua tables to gg.FILES_DIR using plain io.open
-- / loadfile / os.remove — no LuaJava, no directory enumeration.
-- A manifest file tracks which cache IDs exist so we never need to
-- list gg.FILES_DIR.
--
--   Nebula.Cache.load("team_event_addresses")   → { 0x1234, 0x5678 }
--   Nebula.Cache.save("team_event_addresses", { 0x1234 })
--   Nebula.Cache.delete("team_event_addresses")
--   Nebula.Cache.clear_all()
--
-- PID scoping: the manifest stores the PID it was written under.
-- On load, if the current PID differs from the manifest's PID,
-- every old cache file is deleted and the manifest is reset —
-- stale addresses from a previous process never leak through.
--
-- File naming:
--   <packageName>-nebula-cache-index         (manifest)
--   <packageName>-nebula-cache-<id>          (data)
--
-- Data files contain a plain Lua table returned by loadfile():
--   return { 305419896, 2271560481 }

local M = {}

local function log(...)
    if Nebula ~= nil and Nebula.log then
        print("[Nebula.Cache]", ...)
    end
end

--==================================================
-- Serializer
--==================================================
-- Produces loadable Lua source: loadfile() on the result yields
-- the original table. Handles arrays (contiguous integer keys
-- starting at 1) and hash tables (string/integer keys). Numbers,
-- strings, booleans, and nil are handled; nested tables are
-- recursed.

local function serializeValue(v, indent)
    indent = indent or ""
    local t = type(v)
    if t == "number" then
        return tostring(v)
    elseif t == "string" then
        return string.format("%q", v)
    elseif t == "boolean" then
        return tostring(v)
    elseif t == "nil" then
        return "nil"
    elseif t == "table" then
        -- Detect array vs hash
        local maxIdx = 0
        local count = 0
        local isArray = true
        for k, _ in pairs(v) do
            count = count + 1
            if type(k) == "number" and k == math.floor(k) and k >= 1 then
                if k > maxIdx then maxIdx = k end
            else
                isArray = false
            end
        end
        if isArray and maxIdx == count and maxIdx > 0 then
            local parts = {}
            for i = 1, maxIdx do
                parts[#parts + 1] = indent .. "    " .. serializeValue(v[i], indent .. "    ")
            end
            return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
        else
            local parts = {}
            for k, val in pairs(v) do
                local keyStr
                if type(k) == "string" then
                    keyStr = string.format("[%q]", k)
                else
                    keyStr = string.format("[%s]", tostring(k))
                end
                parts[#parts + 1] = indent .. "    " .. keyStr .. " = " .. serializeValue(val, indent .. "    ")
            end
            return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
        end
    end
    return "nil"
end

---Serialize a Lua value to loadable Lua source.
---@param data any
---@return string
local function serialize(data)
    return "return " .. serializeValue(data)
end

M.serialize = serialize

--==================================================
-- Target / path helpers
--==================================================

---Get the current target info. Returns nil if unavailable.
---@return table|nil target  { pid, packageName }
local function getTarget()
    local target = gg.getTargetInfo()
    if not target or not target.packageName or not target.pid then
        return nil
    end
    return target
end

---@param packageName string
---@param id string
---@return string path
local function cache_path(packageName, id)
    return gg.FILES_DIR .. "/" .. packageName .. "-nebula-cache-" .. id
end

---@param packageName string
---@return string path
local function index_path(packageName)
    return gg.FILES_DIR .. "/" .. packageName .. "-nebula-cache-index"
end

--==================================================
-- Manifest (index) management
--==================================================
-- The manifest stores { pid = <number>, ids = { ... } }. On load,
-- if the stored PID doesn't match the current PID, all listed
-- cache files are deleted and a fresh empty manifest is returned.

---Load the manifest. If the PID has changed, invalidates all old
---caches and returns an empty manifest.
---@return table manifest  { pid = int, ids = string[] }
local function load_index()
    local target = getTarget()
    if not target then
        return { pid = 0, ids = {} }
    end

    local f = loadfile(index_path(target.packageName))
    if not f then
        return { pid = target.pid, ids = {} }
    end

    local ok, result = pcall(f)
    if not ok or type(result) ~= "table" then
        return { pid = target.pid, ids = {} }
    end

    -- PID check: if the process changed, nuke everything
    if result.pid ~= target.pid then
        if type(result.ids) == "table" then
            for _, id in ipairs(result.ids) do
                os.remove(cache_path(target.packageName, id))
            end
        end
        os.remove(index_path(target.packageName))
        log("PID changed (", result.pid, "→", target.pid, ") — old caches invalidated")
        return { pid = target.pid, ids = {} }
    end

    if type(result.ids) ~= "table" then
        result.ids = {}
    end

    return result
end

---Save the manifest. Writes to a temp file first, then renames
---over the existing file for crash-safety.
---@param manifest table  { pid = int, ids = string[] }
---@return boolean ok
local function save_index(manifest)
    local target = getTarget()
    if not target then
        return false
    end

    local path = index_path(target.packageName)
    local content = serialize(manifest)

    -- Write to temp file first, then rename for atomicity.
    local tmp = path .. ".tmp"
    local f = io.open(tmp, "w")
    if not f then
        return false
    end
    f:write(content)
    f:close()

    -- os.rename overwrites the destination on most platforms.
    -- If it fails, fall back to direct write.
    if not os.rename(tmp, path) then
        f = io.open(path, "w")
        if not f then
            return false
        end
        f:write(content)
        f:close()
        os.remove(tmp)
    end

    return true
end

--==================================================
-- Public API
--==================================================

---Load a cache entry by logical ID. Returns nil for missing,
---corrupt, or PID-mismatched caches.
---@param id string  logical cache ID (e.g. "team_event_addresses")
---@return any|nil data, string|nil error
function M.load(id)
    local target = getTarget()
    if not target then
        return nil, "no_target"
    end

    -- Check PID validity via the manifest
    local manifest = load_index()
    local found = false
    for _, existingId in ipairs(manifest.ids) do
        if existingId == id then
            found = true
            break
        end
    end
    if not found then
        return nil  -- not in manifest = doesn't exist for this PID
    end

    local f = loadfile(cache_path(target.packageName, id))
    if not f then
        return nil  -- missing file (listed in manifest but gone)
    end

    local ok, result = pcall(f)
    if not ok or result == nil then
        log("load('", id, "') — corrupt cache, ignoring")
        return nil
    end

    return result
end

---Save data under a logical ID. Updates the manifest if the ID is
---new. Never stores duplicate IDs in the manifest.
---@param id string   logical cache ID
---@param data any    value to store (must be serializable)
---@return boolean ok, string|nil error
function M.save(id, data)
    local target = getTarget()
    if not target then
        return false, "no_target"
    end

    -- Write the data file
    local path = cache_path(target.packageName, id)
    local content = serialize(data)

    local f = io.open(path, "w")
    if not f then
        log("save('", id, "') — io.open failed for ", path)
        return false, "write_failed"
    end
    f:write(content)
    f:close()

    -- Load manifest, add ID if missing, save
    local manifest = load_index()
    manifest.pid = target.pid

    local alreadyPresent = false
    for _, existingId in ipairs(manifest.ids) do
        if existingId == id then
            alreadyPresent = true
            break
        end
    end
    if not alreadyPresent then
        manifest.ids[#manifest.ids + 1] = id
    end

    save_index(manifest)
    return true
end

---Delete a cache entry and remove its ID from the manifest.
---Safe to call even if the cache doesn't exist.
---@param id string  logical cache ID
---@return boolean ok
function M.delete(id)
    local target = getTarget()
    if not target then
        return false
    end

    -- Remove the data file
    os.remove(cache_path(target.packageName, id))

    -- Update the manifest
    local manifest = load_index()
    local newIds = {}
    for _, existingId in ipairs(manifest.ids) do
        if existingId ~= id then
            newIds[#newIds + 1] = existingId
        end
    end
    manifest.ids = newIds
    save_index(manifest)

    return true
end

---Delete all Nebula cache entries for the current package + PID,
---then delete the manifest. Never enumerates gg.FILES_DIR — uses
---only the manifest's ID list.
function M.clear_all()
    local target = getTarget()
    if not target then
        return
    end

    local manifest = load_index()
    for _, id in ipairs(manifest.ids) do
        os.remove(cache_path(target.packageName, id))
    end
    os.remove(index_path(target.packageName))
end

return M
