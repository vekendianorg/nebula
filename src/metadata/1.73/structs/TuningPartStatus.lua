-- metadata/1.73/TuningPartStatus.lua
-- Element template for VehicleStatus.tuningParts
-- (RepeatedPtrField<TuningPartStatus>, POINTER-slot elements).
-- Dump: TuningPartStatus // Size 0x38: id string @0x18,
-- level @0x20, progresssteps @0x24, totalscrapped @0x28,
-- totalcrafted @0x2c, isnewunlock bool @0x30, overriddenused bool
-- @0x31, maxlevel @0x34
return {
    ["id"] = { offset = 0x18, type = "String" },
    ["level"] = { offset = 0x20, type = "Int32" },
    ["progressSteps"] = { offset = 0x24, type = "Int32" },
    ["totalScrapped"] = { offset = 0x28, type = "Int32" },
    ["totalCrafted"] = { offset = 0x2C, type = "Int32" },
    ["isNewUnlock"] = { offset = 0x30, type = "Bool" },
    ["overriddenUsed"] = { offset = 0x31, type = "Bool" },
    ["maxLevel"] = { offset = 0x34, type = "Int32" },
}
