-- metadata/1.73/EventStatus.lua
-- Element template for GameStatus event-status arrays
-- (RepeatedPtrField<EventStatus>, POINTER-slot elements, default stride).
-- activeBoosters is RepeatedPtrField<ActiveBooster>; specialFeatureUpgrades
-- is RepeatedPtrField<UpgradeStatus>; fixedVehicleStatus is
-- RepeatedPtrField<VehicleStatus> (all pointer-slot, default stride).
local Manifest = loadModule("metadata/manifest.lua")

return {
    ["instanceId"] = { offset = 0x18, type = "String" },
    ["eventId"] = { offset = 0x20, type = "String" },
    ["expirationTimestamp"] = { offset = 0x28, type = "Int32" },
    ["eventPoints"] = { offset = 0x2C, type = "Int32" },
    ["collectedRewardIndexes"] = { offset = 0x30, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["activeSessionId"] = { offset = 0x40, type = "String" },
    ["tickets"] = { offset = 0x48, type = "Int32" },
    ["lastTicketsRefillTime"] = { offset = 0x4C, type = "Int32" },
    ["spentTickets"] = { offset = 0x50, type = "Int32" },
    ["totalEventRaces"] = { offset = 0x54, type = "Int32" },
    ["latestSessionRaces"] = { offset = 0x58, type = "Int32" },
    ["eventPointsUnlockProgress"] = { offset = 0x5C, type = "Int32" },
    ["teamId"] = { offset = 0x60, type = "String" },
    -- dump: RepeatedPtrField<VehicleStatus> fixedvehiclestatus_ // 0x68.
    ["fixedVehicleStatus"] = { offset = 0x68, type = "Array", elements = Manifest.load("VehicleStatus") },
    ["eventName"] = { offset = 0x80, type = "String" },
    ["eventButtonBackground"] = { offset = 0x88, type = "String" },
    ["shownOfferIds"] = { offset = 0x90, type = "Array", elementType = "String" },
    ["spentSpecialTickets"] = { offset = 0xA8, type = "Int32" },
    ["spentEventPoints"] = { offset = 0xAC, type = "Int32" },
    ["collectedMainRewardIndexes"] = { offset = 0xB0, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["collectedRotatingRewardIndexes"] = { offset = 0xC0, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["levelId"] = { offset = 0xD0, type = "String" },
    ["videosWatched"] = { offset = 0xD8, type = "Int32" },
    ["hasUnlimitedTicket"] = { offset = 0xDC, type = "Bool" },
    ["hasScoreDoubled"] = { offset = 0xDD, type = "Bool" },
    ["hasEventPass"] = { offset = 0xDE, type = "Bool" },
    ["allBoosters"] = { offset = 0xE0, type = "Array", elementType = "String" },
    ["eventPointsPrev"] = { offset = 0xF8, type = "Int32" },
    ["totalSessionsJoined"] = { offset = 0xFC, type = "Int32" },
    ["activeBoosters"] = { offset = 0x100, type = "Array", elements = Manifest.load("ActiveBooster") },
    ["boosterFreeShopItems"] = { offset = 0x118, type = "Array", elementType = "String" },
    ["randomBoosterSelection"] = { offset = 0x130, type = "Array", elementType = "String" },
    ["activeSessionBonusVehicles"] = { offset = 0x148, type = "Array", elementType = "String" },
    ["pendingMultichoiceChestVehicles"] = { offset = 0x160, type = "Array", elementType = "String" },
    ["specialFeatureUpgrades"] = { offset = 0x178, type = "Array", elements = Manifest.load("UpgradeStatus") },
    ["collectedSpecialsRewardIndexes"] = { offset = 0x190, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["boosterClaimedAtSession"] = { offset = 0x1A0, type = "Int32" },
}
