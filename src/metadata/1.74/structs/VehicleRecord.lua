--==================================================
-- metadata/1.74/VehicleRecord.lua
--==================================================
-- Complete metadata snapshot for the VehicleRecord struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file --
-- this file is VehicleRecord only.
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump; 1.74 layout identical):
--   public class VehicleRecord // TypeDefIndex: 2322 Size: 0x20
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
    ["vehicleId"] = {
        -- dump: public string vehicleId // 0x0
        offset = 0x0,
        type = "String",
    },
    ["distance"] = {
        -- dump: public float distance // 0x18
        offset = 0x18,
        type = "Float",
    },
}
