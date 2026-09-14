--==================================================
-- metadata/1.73/QualifyTime.lua
--==================================================
-- Element template for GameStatus.qualifyBests
-- (RepeatedPtrField<QualifyTime>, POINTER-slot elements, default stride).
return {
    ["levelId"] = {
        offset = 0x18,
        type = "String"
    },
    ["time"] = {
        offset = 0x20,
        type = "Float"
    },
}
