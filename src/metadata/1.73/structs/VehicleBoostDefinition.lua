--==================================================
-- metadata/1.73/VehicleBoostDefinition.lua
--==================================================
-- Element template for the inline VehicleBoostDefinition member
-- (VehicleDefinition.boost @0x308, INLINE — next field exhaust@0x350
-- gives 0x48 = sizeof(VehicleBoostDefinition)).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class VehicleBoostDefinition
--       // TypeDefIndex: 2300  Size: 0x48  Confidence: exact
--
-- Every offset below matches the dump (element-relative). No layout
-- is guessed.
return {
    ["file"] = {
        offset = 0x0,
        type = "String"
    },
    ["offset"] = {
        offset = 0x18,
        type = "Vec2"
    },
    ["behindCar"] = {
        offset = 0x20,
        type = "Bool"
    },
    ["node"] = {
        offset = 0x28,
        type = "String"
    },
    ["fuelPickupBoostEnabled"] = {
        offset = 0x40,
        type = "Bool"
    },
    ["fuelPickupBoostPower"] = {
        offset = 0x44,
        type = "Float"
    },
}
