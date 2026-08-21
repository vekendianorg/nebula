local M = {}

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
    return segments
end

return M
