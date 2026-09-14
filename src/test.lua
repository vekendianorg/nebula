--==================================================
-- test.lua
--==================================================
-- Host-script usage example. The script below is a HOST: it
-- pre-configures the SDK table and loads main.lua. Nebula writes
-- no globals besides the `Nebula` table it adopts here, so the
-- host's own environment stays untouched.
--
--   * `embed = true`  — module-load failures raise a catchable
--                        Lua error instead of alert + os.exit
--   * `log/verbose/traceMem = true` — pre-set config is honored

Nebula = { embed = true, log = true, verbose = true, traceMem = true }

local scriptDir = gg.getFile():match("(.*/)") or ""
local chunk = loadfile(scriptDir .. "main.lua")
if not chunk then gg.alert("Cannot load main.lua") return end
local ok, err = pcall(chunk)
if not ok then gg.alert(tostring(err)) return end

--==================================================
-- scratch tests
--==================================================

local name = "NebulaSDK"
local playerName = Nebula.PlayerInfo.get("gameStatus.playerName")
print("before", playerName)
Nebula.PlayerInfo.set("gameStatus.playerName", name)
local newPlayerName = Nebula.PlayerInfo.get("gameStatus.playerName")
print("after", newPlayerName)
