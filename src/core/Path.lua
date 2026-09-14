--==================================================
-- core/Path.lua
--==================================================

local M = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula and Nebula.log then
        Logfile.log("[Path]", ...)
    end
end

function M.parse(id)
    local segments = {}
    for part in id:gmatch("[^.]+") do
        local name, idxStr = part:match("^(.+)%[(%d+)%]$")
        if name then
            segments[#segments + 1] = { name = name, index = tonumber(idxStr) }
        else
            segments[#segments + 1] = { name = part }
        end
    end
    log(string.format("parse '%s' -> %d segments", tostring(id), #segments))
    return segments
end

return M
