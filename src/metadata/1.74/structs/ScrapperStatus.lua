--==================================================
-- metadata/1.74/ScrapperStatus.lua
--==================================================

-- Snapshot for the ScrapperStatus submessage — the singular member
-- GameStatus.scrapperStatus @0x460 (POINTER, deref'd via Object).

return {
    ["readyTimestamp"] = {
        offset = 0x18,
        type = "Int32"
    },
    ["partsIn"] = {
        offset = 0x1C,
        type = "Int32"
    },
    ["scrapOut"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["isUnlocked"] = {
        offset = 0x24,
        type = "Bool"
    },
    ["isExcessTutorialShown"] = {
        offset = 0x25,
        type = "Bool"
    },
}
