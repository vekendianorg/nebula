--==================================================
-- metadata/1.73/VehicleCartConnectDefinition.lua
--==================================================
-- Element template for the inline VehicleCartConnectDefinition member
-- (VehicleDefinition.cartConnect @0x3A8, INLINE — next field
-- attachableObjectOffset@0x3E8 gives 0x40 =
-- sizeof(VehicleCartConnectDefinition)).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class VehicleCartConnectDefinition
--       // TypeDefIndex: 2301  Size: 0x40  Confidence: exact
--
-- Every offset below matches the dump (element-relative). No layout
-- is guessed.
return {
    ["offset"] = {
        offset = 0x0,
        type = "Vec2"
    },
    ["hookImage"] = {
        offset = 0x8,
        type = "String"
    },
    ["hookScale"] = {
        offset = 0x20,
        type = "Float"
    },
    ["attachNode"] = {
        offset = 0x28,
        type = "String"
    },
}
