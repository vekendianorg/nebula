--==================================================
-- metadata/1.74/PlayerInfo_SessionTracker.lua
--==================================================
-- Session-tracker snapshot for PlayerInfo — the inline (same-base)
-- IL2CPP nested class PlayerInfo::SessionTracker, dumped as
-- PlayerInfo_SessionTracker.
--
-- PlayerInfo embeds three instances INLINE at 0x160 / 0x188 / 0x1B0
-- (start-to-start spacing is exactly the dump class size 0x28), so
-- sessionDiamonds / sessionCoins / sessionScrap use the namespace-
-- container convention: their node carries no `type`, and the
-- offsets below are ABSOLUTE from the owning PlayerInfo base —
-- shared across all three instances (see Struct.get's
-- "namespace container" branch, which recurses on the same base).
--
-- Dump: PlayerInfo_SessionTracker // TypeDefIndex 3575, Size 0x28,
-- Confidence: exact (fields list is the nested PlayerInfo::SessionTracker
-- class from the 1.74 libcocos2dcpp dump).
--
-- The fourth tracker slot, the Dictionary<string, SessionTracker>
-- at PlayerInfo+0x1D8, is intentionally NOT metadata (see
-- PlayerInfo.lua — std::map ABI, no supported representation).
return {
    ["startObf"] = {
        offset = 0x160,
        type = "Int32"
    },  -- +0x00
    ["deltaObf"] = {
        offset = 0x164,
        type = "Int32"
    },  -- +0x04
    ["initialized"] = {
        offset = 0x168,
        type = "Bool"
    },  -- +0x08
    ["source"] = {
        offset = 0x170,
        type = "String"
    },  -- +0x10
}