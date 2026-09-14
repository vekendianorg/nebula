--==================================================
-- metadata/1.74/Driver.lua
--==================================================

-- Snapshot for the Driver cosmetics submessage — the singular
-- member GameStatus.driver @0x168 (POINTER, deref'd via Object).
-- All fields are String ids.

return {
    ["head"] = {
        offset = 0x18,
        type = "String"
    },
    ["body"] = {
        offset = 0x20,
        type = "String"
    },
    ["legs"] = {
        offset = 0x28,
        type = "String"
    },
    ["hat"] = {
        offset = 0x30,
        type = "String"
    },
    ["bodyAttachment"] = {
        offset = 0x38,
        type = "String"
    },
    ["profileAnimation"] = {
        offset = 0x40,
        type = "String"
    },
    ["podiumWinAnimation"] = {
        offset = 0x48,
        type = "String"
    },
    ["podiumLoseAnimation"] = {
        offset = 0x50,
        type = "String"
    },
}
