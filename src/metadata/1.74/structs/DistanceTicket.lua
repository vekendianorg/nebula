--==================================================
-- metadata/1.74/DistanceTicket.lua
--==================================================
-- Element template for GameStatus.distanceTickets
-- (RepeatedPtrField<DistanceTicket>, POINTER-slot elements, default stride).
return {
    ["ticketId"] = {
        offset = 0x18,
        type = "String"
    },
    ["amount"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["lastRefillTime"] = {
        offset = 0x24,
        type = "Int32"
    },
    ["totalSpentAmount"] = {
        offset = 0x28,
        type = "Int32"
    },
    ["videoSkipsRemaining"] = {
        offset = 0x2C,
        type = "Int32"
    },
    ["nextVideoSkipTimestamp"] = {
        offset = 0x30,
        type = "Int32"
    },
    ["vipSkipsRemaining"] = {
        offset = 0x34,
        type = "Int32"
    },
    ["nextVipSkipTimestamp"] = {
        offset = 0x38,
        type = "Int32"
    },
}
