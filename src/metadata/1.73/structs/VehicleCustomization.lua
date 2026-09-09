-- metadata/1.73/VehicleCustomization.lua
-- Element template for VehicleStatus.customizations
-- (RepeatedPtrField<VehicleCustomization>, POINTER-slot elements).
-- Dump: VehicleCustomization // Size 0x28: id string @0x18,
-- value string @0x20
return {
    ["id"] = { offset = 0x18, type = "String" },
    ["value"] = { offset = 0x20, type = "String" },
}
