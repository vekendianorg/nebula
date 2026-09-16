--==================================================
-- metadata/1.74/BossDriverDefinition.lua
--==================================================
-- Complete metadata snapshot for the BossDriverDefinition struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is BossDriverDefinition only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump; 1.74 layout identical):
--   public class BossDriverDefinition // TypeDefIndex: 947 Size: 0x30
--   Confidence: exact
--
-- Every offset and type below matches that dump exactly. No layout,
-- size, stride, pointer representation, or schema is guessed.
--
-- Field-name normalization (camelCase): a leading `m` is stripped
-- and the next character lowercased; fields without the `m` prefix
-- keep their dump names unchanged.

local Manifest = loadModule("metadata/manifest.lua")

return {
    ["name"] = {
        -- dump: public string name // 0x0
        offset = 0x0,
        type = "String",
    },
    ["looks"] = {
        -- dump: public string looks // 0x18
        offset = 0x18,
        type = "String",
    },
}
