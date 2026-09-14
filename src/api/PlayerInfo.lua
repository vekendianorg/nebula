--==================================================
-- api/PlayerInfo.lua
--==================================================
-- Public-facing Nebula.PlayerInfo module.
--
-- PlayerInfo is the PARENT object of the player's save data: the
-- struct the "startup_count" signature scan actually lands on
-- (hit ptr - 0xC8, see core/Memory.lua resolvePlayerInfoBase()).
-- There is no separate GameStatus module: the save struct is
-- PlayerInfo's child (mGameStatus @0x148, see
-- metadata/<version>/structs/PlayerInfo.lua) and every save field
-- is reachable as a dotted path —
-- Nebula.PlayerInfo.get("gameStatus.coins"),
-- Nebula.PlayerInfo.set("gameStatus.playerName", "..."), etc.
--
-- Bound to the PlayerInfo metadata snapshot through
-- Nebula.defineApi() (see core/defineApi.lua for the generic
-- get/set/fields/meta implementation and automatic metadata version
-- resolution). PlayerInfo's strings are inline std::string (same
-- ABI as EventDefinition), which defineApi's default stringDirect
-- shadow handles. Inline SessionTracker instances
-- (sessionDiamonds/sessionCoins/sessionScrap) are namespace
-- containers with absolute child offsets — also handled by
-- defineApi's resolver.
--
--   Nebula.PlayerInfo.get("startupCount")
--   Nebula.PlayerInfo.get("sceneName")
--   Nebula.PlayerInfo.get("sessionDiamonds.startObf")
--   Nebula.PlayerInfo.get("startupStatus")            -- Enum decode
--   Nebula.PlayerInfo.get("gameStatus.coins")          -- child save struct
--   Nebula.PlayerInfo.get("currentRace.seed")          -- non-null mid-race only
--   Nebula.PlayerInfo.set("sceneName", "garage_2")
--   Nebula.PlayerInfo.set("sessionCoins.deltaObf", 100):verify()

local Memory    = loadModule("core/Memory.lua")
local defineApi = loadModule("core/defineApi.lua")

return defineApi.create({
    struct  = "PlayerInfo",
    name    = "PlayerInfo", -- log label: [PlayerInfo] trace lines
    resolve = function(forceRescan)
        -- resolvePlayerInfoBase() always performs a fresh scan and
        -- returns the candidate list; defineApi's resolveBase owns
        -- the per-session cache (first candidate wins — PlayerInfo
        -- is a singleton) and the failure cooldown.
        local addresses, err = Memory.resolvePlayerInfoBase()
        if not addresses or #addresses == 0 then
            return nil, err or "base_not_found"
        end
        return addresses[1]
    end,
})
