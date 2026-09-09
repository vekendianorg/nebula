-- metadata/1.73/RentalStatus.lua
-- Element template for GameStatus.rentals
-- (RepeatedPtrField<RentalStatus>, POINTER-slot elements, default stride).
return {
    ["id"] = { offset = 0x18, type = "String" },
    ["eventId"] = { offset = 0x20, type = "String" },
    ["expiryTimestamp"] = { offset = 0x28, type = "Int32" },
}
