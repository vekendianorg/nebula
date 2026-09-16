--==================================================
-- metadata/1.74/BossGhostDefinition.lua
--==================================================
-- Complete metadata snapshot for the BossGhostDefinition struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is BossGhostDefinition only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump; 1.74 layout identical):
--   public class BossGhostDefinition // TypeDefIndex: 948 Size: 0x80
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
    ["driver"] = {
        -- dump: public List<string> driver // 0x0
        offset = 0x0,
        type = "Array",
        elementType = "String",
        elementStride = 0x18,  -- List<string>: inline libc++ std::string (24 bytes), not pointer slots
        container = "vector",
    },
    ["flag"] = {
        -- dump: public string flag // 0x18
        offset = 0x18,
        type = "String",
    },
    ["vehicle"] = {
        -- dump: public string vehicle // 0x30
        offset = 0x30,
        type = "String",
    },
    ["vehiclePaint"] = {
        -- dump: public string vehiclePaint // 0x48
        offset = 0x48,
        type = "String",
    },
    ["vehicleWheels"] = {
        -- dump: public string vehicleWheels // 0x60
        offset = 0x60,
        type = "String",
    },
    ["rank"] = {
        -- dump: public int rank // 0x78
        offset = 0x78,
        type = "Int32",
    },
}
