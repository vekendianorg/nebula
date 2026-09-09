-- metadata/1.73/BanData.lua
-- Element template for GameStatus.banData
-- (RepeatedPtrField<BanData>, POINTER-slot elements, default stride).
return {
    ["bundleId"] = { offset = 0x18, type = "String" },
    ["timestamp"] = { offset = 0x20, type = "Int32" },
    ["oldIntValue"] = { offset = 0x24, type = "Int32" },
    ["key"] = { offset = 0x28, type = "String" },
    ["newIntValue"] = { offset = 0x30, type = "Int32" },
    ["oldFloatValue"] = { offset = 0x34, type = "Float" },
    ["oldStringValue"] = { offset = 0x38, type = "String" },
    ["newStringValue"] = { offset = 0x40, type = "String" },
    ["newFloatValue"] = { offset = 0x48, type = "Float" },
}
