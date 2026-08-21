--==================================================
-- metadata/Mirror.lua
--==================================================
-- Utility for metadata schemas that intentionally mirror an existing
-- metadata file. The source remains canonical; the mirror gets its
-- own module entry without duplicating the field table.

local M = {}

function M.of(name)
    assert(type(name) == "string" and name ~= "", "metadata mirror requires a source name")

    local metadata, err = loadModule("metadata/" .. name .. ".lua", true)
    if not metadata then
        print("metadata mirror source failed: " .. tostring(err))
    end

    return metadata
end

return M
