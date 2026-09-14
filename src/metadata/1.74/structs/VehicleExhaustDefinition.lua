--==================================================
-- metadata/1.74/VehicleExhaustDefinition.lua
--==================================================
-- Element template for the inline VehicleExhaustDefinition member
-- (VehicleDefinition.exhaust @0x350, INLINE — next field
-- cartConnect@0x3A8 gives 0x58 = sizeof(VehicleExhaustDefinition)).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class VehicleExhaustDefinition
--       // TypeDefIndex: 2307  Size: 0x58  Confidence: exact
--
-- Every offset below matches the dump (element-relative). No layout
-- is guessed.
return {
    ["file"] = {
        offset = 0x0,
        type = "String"
    },
    ["node"] = {
        offset = 0x18,
        type = "String"
    },
    ["offset"] = {
        offset = 0x30,
        type = "Vec2"
    },
    ["angle"] = {
        offset = 0x38,
        type = "Float"
    },
    ["minParticles"] = {
        offset = 0x3C,
        type = "Int32"
    },
    ["maxParticles"] = {
        offset = 0x40,
        type = "Int32"
    },
    ["lifeMin"] = {
        offset = 0x44,
        type = "Float"
    },
    ["lifeMax"] = {
        offset = 0x48,
        type = "Float"
    },
    ["scale"] = {
        offset = 0x4C,
        type = "Float"
    },
    ["zOrder"] = {
        offset = 0x50,
        type = "Int32"
    },
}
