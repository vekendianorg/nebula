--[[ core/Logfile.lua — Nebula.log diagnostics -> nebula.log

One logger: the old one. While Nebula.log is true, every diagnostic
line ([Memory], [Repeated], [PublicEvent] records, ...) is written to
<scriptDir>nebula.log — line by line, flushed immediately, nothing
buffered, nothing rotated. The full dev trace survives even a hard
crash. scriptDir is the global set by main.lua / test.lua / the packed
header; there is no gg.getFile fallback — every entry point provides
the global.

If no scriptDir is set or the file cannot be opened (read-only dir),
lines fall back to the old console print — logging never dies silently.
]]

local M = {}

local _f        = nil  -- open handle (lazily)
local _path     = nil  -- explicit override (tests)
local _fallback = nil  -- true once file open failed -> console print

local function concatArgs(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[#parts + 1] = tostring((select(i, ...)))
    end
    return table.concat(parts, " ")
end

local function fileHandle()
    if _f then return _f end
    if _fallback then return nil end
    local path = _path
    if path == nil then
        -- Global scriptDir — set by main.lua / test.lua / the packed
        -- header before any module loads. No gg.getFile fallback:
        -- every entry point already provides it.
        if type(scriptDir) == "string" then
            path = scriptDir .. "nebula.log"
            _path = path
        end
    end
    if path then
        _f = io.open(path, "w")
        if _f then return _f end
    end
    _fallback = true  -- open failed (or no path) -> print, once
    return nil
end

---Funnel for the per-module log() helpers. Same line as the old
---console output, written to nebula.log line by line.
function M.log(tag, ...)
    local f = fileHandle()
    if f then
        f:write(concatArgs(tag, ...), "\n")
        f:flush()
    else
        print(tag, ...)
    end
end

---One-off formatted prints (vlog/memtrace style), same routing.
function M.raw(...)
    local f = fileHandle()
    if f then
        f:write(concatArgs(...), "\n")
        f:flush()
    else
        print(...)
    end
end

---Explicit path override (tests). setPath(nil) closes the handle
---and restores the default/lazy behavior.
function M.setPath(path)
    if _f then
        pcall(function() _f:close() end)
        _f = nil
    end
    _path = path
    _fallback = nil
end

M.path = function() return _path end

return M
