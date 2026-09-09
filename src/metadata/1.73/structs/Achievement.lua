-- metadata/1.73/Achievement.lua
-- Element template for GameStatus.achievements
-- (RepeatedPtrField<Achievement>, POINTER-slot elements, default stride).
return {
    ["id"] = { offset = 0x18, type = "Int32" },
    ["unlocked"] = { offset = 0x1C, type = "Bool" },
    ["steps"] = { offset = 0x20, type = "Int32" },
}
