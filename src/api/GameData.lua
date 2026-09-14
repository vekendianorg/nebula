--==================================================
-- api/GameData.lua
--==================================================
-- Public-facing Nebula.GameData module.
--
--   Nebula.GameData.get("minVisibleRange")
--   Nebula.GameData.get("maxVisibleRange")
--   Nebula.GameData.get("showMoreGhostsMode")

local Memory    = loadModule("core/Memory.lua")
local defineApi = loadModule("core/defineApi.lua")

return defineApi.create({
    struct  = "GameData",
    name    = "GameData",
    resolve = Memory.resolveGameDataBase,
})
