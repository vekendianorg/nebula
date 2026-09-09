-- metadata/1.73/Home.lua

-- Snapshot for the Home submessage — the singular member
-- GameStatus.home @0x6A0 (POINTER, deref'd via Object). rooms is a
-- RepeatedPtrField<Room> array.

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["rooms"] = { offset = 0x18, type = "Array", elements = Manifest.load("Room") },
}
