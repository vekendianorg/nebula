--==================================================
-- metadata/manifest.lua
--==================================================
-- Automatic metadata version resolution for Nebula.defineApi().
-- Callers never specify a metadata version themselves (e.g. "1.73")
-- — it is always derived from the running game's version.
--
-- Layout: metadata/<version>/structs/<Struct>.lua and
-- metadata/<version>/enums/<Enum>.lua — one folder PER GAME
-- VERSION, containing every struct's metadata file (structs/) and
-- every enum's value table (enums/). Each version folder is a
-- COMPLETE snapshot: when a new version is cut, the whole previous
-- folder is copied wholesale and only the structs/enums that
-- actually changed get edited — this is a deliberate choice to keep
-- authoring simple (copy the folder, edit what changed) rather than
-- tracking which individual structs/enums moved at which version.
--
-- Enums are versioned for the same reason structs are: flag bits
-- and enum IDs can be reassigned between game versions, so an enum
-- table is just as much a per-version snapshot as a struct layout.
--
-- Versioning rules (finalized):
--   - Nebula is 64-bit only. There is no architecture-specific
--     branch here.
--   - Metadata versions use the first two HCR2 version components
--     ("1.73", "1.74", ...). A running game version such as
--     "1.74.2" resolves against the "1.74" metadata folder; the
--     patch component is always ignored.
--   - There is no recursive merging or runtime patch/diff
--     application — each version folder is loaded as-is.
--   - Resolution picks the closest known version <= the running
--     game's two-component version. If the game is older than
--     every known version, the oldest known version is used (best
--     available) rather than failing.

local M = {}

-- Ascending list of known "MAJOR.MINOR" metadata version folders
-- under metadata/<version>/.
local VERSIONS = { "1.73", "1.74" }

M.VERSIONS = VERSIONS

---Parse "1.73" or "1.73.2" into { major, minor }. A patch
---component, if present, is ignored — metadata versioning is
---two-component only.
---@param v string
---@return table|nil @ { major, minor }
local function parseTwoComponent(v)
    if type(v) ~= "string" then return nil end
    local ma, mi = v:match("^(%d+)%.(%d+)")
    if not ma then return nil end
    return { tonumber(ma), tonumber(mi) }
end

M.parseTwoComponent = parseTwoComponent

---@param a table @ {major, minor}
---@param b table @ {major, minor}
---@return integer @ -1, 0, or 1 (a<b, a==b, a>b)
local function cmp(a, b)
    if a[1] ~= b[1] then return a[1] < b[1] and -1 or 1 end
    if a[2] ~= b[2] then return a[2] < b[2] and -1 or 1 end
    return 0
end

M.cmp = cmp

---Read the running game's version via GameGuardian's target info
---and truncate it to two components. This is the only place
---Nebula reads the game version — see how-to-get-game-version.lua
---for the equivalent lookup (gg.getTargetInfo().versionName) used
---elsewhere in the wider toolchain.
---@return string|nil version @ "MAJOR.MINOR"
---@return string|nil error
function M.currentGameVersion()
    local ok, target = pcall(function() return gg.getTargetInfo() end)
    if not ok or type(target) ~= "table" or type(target.versionName) ~= "string" then
        return nil, "game_version_unavailable"
    end

    local parsed = parseTwoComponent(target.versionName)
    if not parsed then
        return nil, "game_version_unparseable: " .. tostring(target.versionName)
    end

    return string.format("%d.%d", parsed[1], parsed[2])
end

---Pick the closest known metadata version <= gameVersion. Falls
---back to the oldest known version if the game is older than
---everything registered. Fails only if no versions are known at
---all.
---@param gameVersion string @ "MAJOR.MINOR"
---@return string|nil version, string|nil error
function M.resolveVersion(gameVersion)
    -- Consult the exported M.VERSIONS, not the captured upvalue:
    -- M.VERSIONS is the module's documented, tested surface (the
    -- spec swaps it to exercise multi-version resolution), and a
    -- consumer may register additional version folders at runtime.
    -- An explicitly emptied M.VERSIONS means "no versions known"
    -- and must fail; only a nil (never-set) falls back.
    local versions = M.VERSIONS or VERSIONS
    if #versions == 0 then
        return nil, "no_versions_registered"
    end

    local gv = parseTwoComponent(gameVersion)
    if not gv then
        return nil, "unparseable_game_version: " .. tostring(gameVersion)
    end

    -- versions is ascending, so the last one that is <= the game
    -- version is the closest applicable one.
    local best = nil
    for _, v in ipairs(versions) do
        local vt = parseTwoComponent(v)
        if vt and cmp(vt, gv) <= 0 then
            best = v
        end
    end

    if not best then
        best = versions[1] -- game is older than every known snapshot; use the oldest
    end

    return best, nil
end

---Shared version-resolution step used by both M.resolve (structs)
---and M.resolveEnum (enums) — figures out which version folder to
---read from, once, so the two loaders can't drift out of sync.
---@return string|nil version, string|nil error
local function resolveCurrentVersion()
    local gameVersion, gvErr = M.currentGameVersion()
    if not gameVersion then
        return nil, gvErr
    end

    local version, verErr = M.resolveVersion(gameVersion)
    if not version then
        return nil, verErr
    end

    return version, nil
end

---Resolve and load a struct's metadata for the running game
---version, from metadata/<version>/structs/<structName>.lua. This
---is the single entry point Nebula.defineApi() uses — no caller
---ever passes a version string in.
---@param structName string
---@return table|nil metadata, string|nil version, string|nil error
function M.resolve(structName)
    local version, verErr = resolveCurrentVersion()
    if not version then
        return nil, nil, verErr
    end

    local metadata, loadErr = loadModule("metadata/" .. version .. "/structs/" .. structName .. ".lua", true)
    if not metadata then
        return nil, nil, "metadata_load_failed: " .. tostring(loadErr)
    end

    return metadata, version, nil
end

-- Alias: every metadata/<version>/structs/*.lua file that pulls in
-- a shared element template calls Manifest.load("SomeStruct") (see
-- e.g. metadata/1.73/structs/GameStatus.lua), and api/PlayerInfo.lua
-- calls Manifest.load("GameStatus") expecting the same
-- (metadata, version) return shape as M.resolve. Same function,
-- just the name every caller already uses.
M.load = M.resolve

---Resolve and load an enum's value table for the running game
---version, from metadata/<version>/enums/<enumName>.lua. Mirrors
---M.resolve, but for enums/ instead of structs/.
---@param enumName string
---@return table|nil enum, string|nil version, string|nil error
function M.resolveEnum(enumName)
    local version, verErr = resolveCurrentVersion()
    if not version then
        return nil, nil, verErr
    end

    local enum, loadErr = loadModule("metadata/" .. version .. "/enums/" .. enumName .. ".lua", true)
    if not enum then
        return nil, nil, "enum_load_failed: " .. tostring(loadErr)
    end

    return enum, version, nil
end

-- Alias, matching M.load's naming convention above.
M.loadEnum = M.resolveEnum

return M
