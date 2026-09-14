--==================================================
-- metadata/1.74/VehicleOfferShowcaseDefinition.lua
--==================================================
-- Element template for the two inline
-- VehicleOfferShowcaseDefinition members (VehicleDefinition.
-- offerShowcase @0x508 and offerIcon @0x51C, both INLINE —
-- 0x51C-0x508 = 0x14 and next field
-- tuningPartSlotMinUpgradeLevels@0x530 gives 0x14 =
-- sizeof(VehicleOfferShowcaseDefinition)).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class VehicleOfferShowcaseDefinition
--       // TypeDefIndex: 2317  Size: 0x14  Confidence: exact
--
-- Every offset below matches the dump (element-relative). No layout
-- is guessed.
return {
    ["position"] = {
        offset = 0x0,
        type = "Vec2"
    },
    ["scale"] = {
        offset = 0x8,
        type = "Float"
    },
    ["rotation"] = {
        offset = 0xC,
        type = "Float"
    },
    ["hasPosition"] = {
        offset = 0x10,
        type = "Bool"
    },
    ["hasScale"] = {
        offset = 0x11,
        type = "Bool"
    },
    ["hasRotation"] = {
        offset = 0x12,
        type = "Bool"
    },
}
