--==================================================
-- metadata/1.74/HomeCosmeticsOwnership.lua
--==================================================
-- Element template for GameStatus owned-home-cosmetics arrays
-- (RepeatedPtrField<HomeCosmeticsOwnership>, POINTER-slot elements, default stride).
return {
    ["id"] = {
        offset = 0x18,
        type = "String"
    },
    ["ownedCount"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["usedCount"] = {
        offset = 0x24,
        type = "Int32"
    },
    ["newUnlock"] = {
        offset = 0x28,
        type = "Bool"
    },
}
