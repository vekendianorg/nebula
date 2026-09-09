-- metadata/1.73/CommunityEvent.lua

-- Snapshot for the GameStatus.communityEvent submessage — the singular
-- member GameStatus.communityEvent @0x710 (POINTER, deref'd via Object).
-- NOTE: this is the community-event PROGRESS member inside GameStatus,
-- distinct from the api/CommunityEvent module (which is bound to the
-- EventDefinition struct). oldSeasons / levelTimestamps are
-- RepeatedPtrField<StringIntMap> arrays.

local Manifest = loadModule("metadata/manifest.lua")
local StringIntMap = Manifest.load("StringIntMap")

return {
    ["seasonId"] = { offset = 0x18, type = "String" },
    ["results"] = { offset = 0x20, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["oldSeasons"] = { offset = 0x30, type = "Array", elements = StringIntMap },
    ["levelIds"] = { offset = 0x48, type = "Array", elementType = "String" },
    ["levelTimestamps"] = { offset = 0x60, type = "Array", elements = StringIntMap },
    ["eventPoints"] = { offset = 0x78, type = "Int32" },
}
