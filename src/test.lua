local scriptDir = gg.getFile():match("(.*/)") or ""
local _moduleCache = {}

function loadModule(name, soft)
    local path = scriptDir .. name
    if _moduleCache[path] ~= nil then
        return _moduleCache[path]
    end
    local chunk, err = loadfile(path)
    if not chunk then
        if soft then return nil, err end
        gg.alert("Module load failed: " .. name .. "\n" .. tostring(err))
        os.exit()
    end
    if soft then
        local results = table.pack(pcall(chunk))
        if not results[1] then return nil, results[2] end
        _moduleCache[path] = table.unpack(results, 2, results.n)
        return _moduleCache[path]
    end
    _moduleCache[path] = chunk()
    return _moduleCache[path]
end

Nebula = Nebula or {}
Nebula.log = true
Nebula.verbose = false
Nebula.GameStatus = loadModule("api/GameStatus.lua")
Nebula.PublicEvent = loadModule("api/PublicEvent.lua")
Nebula.TeamEvent  = loadModule("api/TeamEvent.lua")
Nebula.CommunityEvent = loadModule("api/CommunityEvent.lua")
Nebula.Type   = loadModule("core/Type.lua")
Nebula.Memory = loadModule("core/Memory.lua")
Nebula.Cache   = loadModule("core/Cache.lua")
Nebula.VERSION = "0.1.0"

local function log(msg)
    print(msg)
end

local t0 = os.time()

local r, err = Nebula.GameStatus.get("vehicleStatus[1].tuningPartPresets")
print(r)

r[#r+1] = {
    ['equippedParts'] = {
        [1] = 'jeep_nitro',
        [2] = 'jeep_jump'
    },
}

local w, err = Nebula.GameStatus.set("vehicleStatus[1].tuningPartPresets", r)
print(w)

local r2, err = Nebula.GameStatus.get("vehicleStatus[1].tuningPartPresets")
print(r2)
