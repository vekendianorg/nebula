--==================================================
-- metadata/1.74/Home.lua
--==================================================

-- Snapshot for the Home submessage — the singular member
-- GameStatus.home @0x6A0 (POINTER, deref'd via Object). rooms is a
-- RepeatedPtrField<Room> array.

local Manifest = loadModule("metadata/manifest.lua")
local Room = Manifest.load("Room")

return {
    ["rooms"] = {
        offset = 0x18,
        type = "Array",
        elements = Room
    },
}
