-- metadata/1.73/VipStatus.lua

-- Snapshot for the VipStatus submessage — the singular member
-- GameStatus.vipStatus @0x3A8 (POINTER, deref'd via Object).

return {
    ["isVip"] = { offset = 0x2C, type = "Bool" },
    ["vipSkipCupsRemaining"] = { offset = 0x1C, type = "Int32" },
    ["nextVipSkipTimestamp"] = { offset = 0x20, type = "Int32" },
    ["autoRenew"] = { offset = 0x2D, type = "Bool" },
    ["vipTier"] = { offset = 0x30, type = "String" },
    ["vipSkipScrapperRemaining"] = { offset = 0x38, type = "Int32" },
    ["nextVipSkipScrapperTimestamp"] = { offset = 0x3C, type = "Int32" },
    ["vipSkipTeamEventTicketsRemaining"] = { offset = 0x40, type = "Int32" },
    ["nextVipSkipTeamEventTicketTimeStamp"] = { offset = 0x44, type = "Int32" },
    ["vipSkipEventTicketsRemaining"] = { offset = 0x48, type = "Int32" },
    ["nextVipSkipEventTicketTimeStamp"] = { offset = 0x4C, type = "Int32" },
    ["hasBeenVipBefore"] = { offset = 0x2E, type = "Bool" },
    ["manuallyEnabled"] = { offset = 0x50, type = "Bool" }, -- was 0x2E; dump: hasbeenvipbefore_ 0x2e, manuallyenabled_ 0x50
}
