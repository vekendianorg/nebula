-- metadata/1.73/UpgradeStatus.lua
-- Shared element template for RepeatedPtrField<UpgradeStatus>
-- arrays (POINTER-slot elements, default stride).
-- Dump: UpgradeStatus // Size 0x28: upgradeid string @0x18,
-- level int32 @0x20, maxlevel int32 @0x24
return {
    ["upgradeId"] = { offset = 0x18, type = "String" },
    ["level"] = { offset = 0x20, type = "Int32" },
    ["maxLevel"] = { offset = 0x24, type = "Int32" },
}
