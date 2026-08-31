--==================================================
-- metadata/GameStatus.lua
--==================================================
-- Field table for the top-level GameStatus proto2 message.
-- Sourced from descriptor.proto (field numbers / proto types)
-- cross-referenced with known offsets from the legacy flat
-- GameStatus.lua and account.lua ops.
--
-- Offsets and element layouts cross-validated against an
-- exact-confidence struct dump of libcocos2dcpp.so
-- (temp/libcocos2dcpp.cs, DWARF-recovered field names). Every
-- previously verified offset matches the dump. The remaining
-- 0xBAAD placeholders and placeholder-array element templates that
-- were previously unmapped are filled from it and will need
-- on-device spot checks before being treated as fully trusted.
--
-- offset = 0xBAAD means the offset is NOT YET KNOWN. Do not
-- trust these fields until the placeholder is replaced by a
-- verified static offset.
--
-- type = "Object" marks single nested message fields that
-- carry their own child layouts inline (or reference a shared
-- element template via a local). Fields without a reader yet are
-- left with a comment noting which sub-template is still unmapped.
--
-- type = "Array" marks repeated fields. Use elementType = "X"
-- for simple typed arrays (e.g. repeated string). Use elements =
-- { ... } for struct-element arrays with known field layouts.
-- Placeholder arrays (no elementType/elements) fail gracefully
-- until the element layout is mapped.
--
-- SafeInt32 fields: `offset` points to a POINTER to the
-- struct (not an inline struct). The static XOR key is
-- fixed account-wide at safeIntStaticKey and resolved
-- internally by core/types/SafeInt32.lua — no per-field
-- staticKeyOffset needed.

local stringIntMapElements = {
    ["key"] = { offset = 0x18, type = "String" },
    ["value"] = { offset = 0x20, type = "Int32" },
}

local seasonResultElements = {
    ["seasonId"] = { offset = 0x18, type = "String" },
    ["result"] = { offset = 0x20, type = "Float" },
}

local distanceHighscoreElements = {
    ["levelId"] = { offset = 0x18, type = "String" },
    ["distance"] = { offset = 0x20, type = "Float" },
    -- 0x24/0x28 per the libcocos2dcpp dump (was 0x28/0x2C); the dump
    -- puts previousSeasonBest directly after distance.
    ["previousSeasonBest"] = { offset = 0x24, type = "Float" },
    ["previousSeasons"] = {
        offset = 0x28,
        type = "Array",
        elements = seasonResultElements,
    },
    ["currentSeasonBest"] = { offset = 0x40, type = "Float" },
}

local timeTrialHighscoreElements = {
    ["levelId"] = { offset = 0x18, type = "String" },
    ["time"] = { offset = 0x20, type = "Float" },
    -- 0x24/0x28 per the libcocos2dcpp dump (was 0x28/0x2C)
    ["previousSeasonBest"] = { offset = 0x24, type = "Float" },
    ["previousSeasons"] = {
        offset = 0x28,
        type = "Array",
        elements = seasonResultElements,
    },
    ["currentSeasonBest"] = { offset = 0x40, type = "Float" },
}

--==================================================
-- Element templates filled from the libcocos2dcpp dump.
-- All offsets are element-relative. Singular submessage
-- members are POINTERS (confirmed by struct-size overlap
-- analysis), so Object containers keep the deref convention.
--==================================================

local missionStatusFields = {
    ["missionId"] = { offset = 0x18, type = "String" },
    ["bestValue"] = { offset = 0x20, type = "Float" },
    ["achievedLevel"] = { offset = 0x24, type = "Int32" },
    ["missionDefinitionId"] = { offset = 0x28, type = "String" },
    ["allowedVehicleIds"] = { offset = 0x30, type = "Array", elementType = "String" },
    ["allowedWorldIds"] = { offset = 0x48, type = "Array", elementType = "String" },
    ["allowedLevelIds"] = { offset = 0x60, type = "Array", elementType = "String" },
    ["startingValue"] = { offset = 0x78, type = "Float" },
}

local missionStatusElements = missionStatusFields

local missionStatusMapElements = {
    ["levelId"] = { offset = 0x18, type = "String" },
    ["missionStatus"] = { offset = 0x20, type = "Object" },
}
for k, v in pairs(missionStatusFields) do
    missionStatusMapElements.missionStatus[k] = v
end

local qualifyTimeElements = {
    ["levelId"] = { offset = 0x18, type = "String" },
    ["time"] = { offset = 0x20, type = "Float" },
}

local racePointsElements = {
    ["levelId"] = { offset = 0x18, type = "String" },
    ["points"] = { offset = 0x20, type = "Int32" },
}

local upgradeStatusElements = {
    ["upgradeId"] = { offset = 0x18, type = "String" },
    ["level"] = { offset = 0x20, type = "Int32" },
    ["maxLevel"] = { offset = 0x24, type = "Int32" },
}

local friendlyRaceElements = {
    ["sessionId"] = { offset = 0x18, type = "String" },
    ["levelId"] = { offset = 0x20, type = "String" },
    ["friendlyRaceType"] = { offset = 0x28, type = "Int32" },
    ["expirationTimestamp"] = { offset = 0x2C, type = "Int32" },
    ["retryCount"] = { offset = 0x30, type = "Int32" },
}

local iapPurchaseEventElements = {
    ["iapId"] = { offset = 0x18, type = "String" },
    ["timestamp"] = { offset = 0x20, type = "Int32" },
    ["validated"] = { offset = 0x24, type = "Bool" },
    ["transactionId"] = { offset = 0x28, type = "String" },
    ["offerId"] = { offset = 0x30, type = "String" },
    ["recipientIds"] = { offset = 0x38, type = "Array", elementType = "String" },
    ["validationState"] = { offset = 0x50, type = "Int32" },
}

local pendingChestElements = {
    ["vehicleId"] = { offset = 0x18, type = "String" },
    ["chestIndex"] = { offset = 0x20, type = "Int32" },
    ["level"] = { offset = 0x24, type = "Int32" },
    ["type"] = { offset = 0x28, type = "String" },
}

local rentalStatusElements = {
    ["id"] = { offset = 0x18, type = "String" },
    ["eventId"] = { offset = 0x20, type = "String" },
    ["expiryTimestamp"] = { offset = 0x28, type = "Int32" },
}

local dealItemElements = {
    ["id"] = { offset = 0x18, type = "String" },
    ["type"] = { offset = 0x20, type = "String" },
    ["amount"] = { offset = 0x28, type = "Int32" },
}

local dealStatusElements = {
    ["id"] = { offset = 0x18, type = "String" },
    ["purchasedItems"] = { offset = 0x20, type = "Array", elements = dealItemElements },
    ["items"] = { offset = 0x38, type = "Array", elements = dealItemElements },
    ["endTimestamp"] = { offset = 0x50, type = "Int32" },
}

local seasonStatusElements = {
    ["highestRank"] = { offset = 0x18, type = "Float" },
    ["startRank"] = { offset = 0x1C, type = "Float" },
    ["seasonId"] = { offset = 0x20, type = "String" },
    ["endTimestamp"] = { offset = 0x28, type = "Int32" },
    ["ended"] = { offset = 0x2C, type = "Bool" },
    ["premiumUnlocked"] = { offset = 0x2D, type = "Bool" },
    ["bonusChestClaimed"] = { offset = 0x2E, type = "Bool" },
    ["premiumProgressClaimed"] = { offset = 0x2F, type = "Bool" },
    ["receivedRewards"] = { offset = 0x30, type = "Array", elementType = "String" },
    ["animatedRank"] = { offset = 0x48, type = "Float" },
    ["premiumTierUnlocked"] = { offset = 0x4C, type = "Int32" },
}

local activePopupOfferElements = {
    ["id"] = { offset = 0x18, type = "String" },
    ["endTimestamp"] = { offset = 0x20, type = "Int32" },
    ["useAdOffer"] = { offset = 0x24, type = "Bool" },
    ["activationCount"] = { offset = 0x28, type = "Int32" },
    ["activationTimestamp"] = { offset = 0x2C, type = "Int32" },
    ["originalActivationTimestamp"] = { offset = 0x30, type = "Int32" },
}

local homeCosmeticsOwnershipElements = {
    ["id"] = { offset = 0x18, type = "String" },
    ["ownedCount"] = { offset = 0x20, type = "Int32" },
    ["usedCount"] = { offset = 0x24, type = "Int32" },
    ["newUnlock"] = { offset = 0x28, type = "Bool" },
}

local megaAdChestItemElements = {
    ["type"] = { offset = 0x18, type = "Int32" },
    ["amount"] = { offset = 0x1C, type = "Int32" },
    ["rarity"] = { offset = 0x20, type = "Int32" },
}

local megaAdChestRewardStatusElements = {
    ["watched"] = { offset = 0x18, type = "Int32" },
    ["watchedLastSession"] = { offset = 0x1C, type = "Int32" },
    ["reward"] = { offset = 0x20, type = "Object" },
    ["rewardLastSession"] = { offset = 0x28, type = "Object" },
    ["claimed"] = { offset = 0x30, type = "Bool" },
    ["claimedLastSession"] = { offset = 0x31, type = "Bool" },
}
for k, v in pairs(megaAdChestItemElements) do
    megaAdChestRewardStatusElements.reward[k] = v
    megaAdChestRewardStatusElements.rewardLastSession[k] = v
end

local leagueTaskElements = {
    ["id"] = { offset = 0x18, type = "Int32" },
    ["target"] = { offset = 0x1C, type = "Int32" },
    ["progress"] = { offset = 0x20, type = "Int32" },
    ["claimed"] = { offset = 0x24, type = "Bool" },
    ["createTimestamp"] = { offset = 0x28, type = "Int32" },
}

local megaAdChestProgressDayElements = {
    ["watched"] = { offset = 0x18, type = "Int32" },
    ["claimed"] = { offset = 0x1C, type = "Bool" },
    ["reward"] = { offset = 0x20, type = "Object" },
}
for k, v in pairs(megaAdChestItemElements) do
    megaAdChestProgressDayElements.reward[k] = v
end

local megaAdChestProgressElements = {
    -- rewardHash (0x18) is int64 — no Int64 reader yet
    ["progress"] = { offset = 0x20, type = "Array", elements = megaAdChestProgressDayElements },
}

local adViewsMapElements = {
    ["placementId"] = { offset = 0x18, type = "Int32" },
    ["resetTimestamp"] = { offset = 0x1C, type = "Int32" },
    ["remaining"] = { offset = 0x20, type = "Int32" },
}

local activeTriggerElements = {
    ["timestamp"] = { offset = 0x18, type = "Int32" },
    ["type"] = { offset = 0x1C, type = "Int32" },
    ["vehicleId"] = { offset = 0x20, type = "String" },
    ["level"] = { offset = 0x28, type = "Int32" },
}

local dailyTaskElements = {
    ["type"] = { offset = 0x18, type = "Int32" },
    ["target"] = { offset = 0x1C, type = "Int32" },
    ["vehicle"] = { offset = 0x20, type = "String" },
    ["level"] = { offset = 0x28, type = "String" },
    ["completed"] = { offset = 0x30, type = "Bool" },
    ["progress"] = { offset = 0x34, type = "Int32" },
    ["slot"] = { offset = 0x38, type = "Int32" },
    ["createTimestamp"] = { offset = 0x3C, type = "Int32" },
    ["taskSpecific"] = { offset = 0x40, type = "Array", elementType = "Int32", elementStride = 0x4 },
}

local currentFriendEventElements = {
    ["claimedRewards"] = { offset = 0x18, type = "Array", elementType = "SafeInt32" },
    ["eventHash"] = { offset = 0x30, type = "Int32" },
    ["hasEventPass"] = { offset = 0x34, type = "Bool" },
    ["collectibleResetTimestamp"] = { offset = 0x38, type = "SafeInt32" },
    ["collectibleCollected"] = { offset = 0x40, type = "SafeInt32" },
    ["activeEventTasks"] = { offset = 0x48, type = "Array", elements = dailyTaskElements },
    ["taskRefillsRemaining"] = { offset = 0x60, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["singleScore"] = { offset = 0x70, type = "SafeInt32" },
    ["tasksResetTimestamp"] = { offset = 0x78, type = "Int32" },
    ["adsResetTimestamp"] = { offset = 0x7C, type = "Int32" },
    ["eventId"] = { offset = 0x80, type = "String" },
    ["teamId"] = { offset = 0x88, type = "String" },
    ["adsRemaining"] = { offset = 0x90, type = "Int32" },
}

local banDataElements = {
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

local distanceTicketElements = {
    ["ticketId"] = { offset = 0x18, type = "String" },
    ["amount"] = { offset = 0x20, type = "Int32" },
    ["lastRefillTime"] = { offset = 0x24, type = "Int32" },
    ["totalSpentAmount"] = { offset = 0x28, type = "Int32" },
    ["videoSkipsRemaining"] = { offset = 0x2C, type = "Int32" },
    ["nextVideoSkipTimestamp"] = { offset = 0x30, type = "Int32" },
    ["vipSkipsRemaining"] = { offset = 0x34, type = "Int32" },
    ["nextVipSkipTimestamp"] = { offset = 0x38, type = "Int32" },
}

local featuredChallengeElements = {
    ["challengeId"] = { offset = 0x18, type = "String" },
    ["expirationTimestamp"] = { offset = 0x20, type = "Int32" },
    ["unlimitedTries"] = { offset = 0x24, type = "Bool" },
    ["challengeWon"] = { offset = 0x25, type = "Bool" },
    ["rewardClaimed"] = { offset = 0x26, type = "Bool" },
    ["videoRetriesRemaining"] = { offset = 0x28, type = "Int32" },
}

local eventStatusElements = {
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
    -- fixedVehicleStatus (0x68) is RepeatedPtrField<VehicleStatus>;
    -- the vehicleStatus element template lives inline on the
    -- vehicleStatus entry below, so no reader is attached here.
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
    -- activeBoosters (0x100) is RepeatedPtrField<ActiveBooster> — layout not yet mapped
    ["boosterFreeShopItems"] = { offset = 0x118, type = "Array", elementType = "String" },
    ["randomBoosterSelection"] = { offset = 0x130, type = "Array", elementType = "String" },
    ["activeSessionBonusVehicles"] = { offset = 0x148, type = "Array", elementType = "String" },
    ["pendingMultichoiceChestVehicles"] = { offset = 0x160, type = "Array", elementType = "String" },
    ["specialFeatureUpgrades"] = { offset = 0x178, type = "Array", elements = upgradeStatusElements },
    ["collectedSpecialsRewardIndexes"] = { offset = 0x190, type = "Array", elementType = "Int32", elementStride = 0x4 },
    ["boosterClaimedAtSession"] = { offset = 0x1A0, type = "Int32" },
}

local distanceCollectibleStatusElements = {
    ["seasonId"] = { offset = 0x18, type = "String" },
    -- levels (0x20) is RepeatedPtrField<LevelCollectibleStatus> — layout not yet mapped
    ["claimedRewardLevel"] = { offset = 0x38, type = "Int32" },
    ["totalCollectedValue"] = { offset = 0x3C, type = "Int32" },
    ["totalValue"] = { offset = 0x40, type = "Int32" },
    ["endTimestamp"] = { offset = 0x44, type = "Int32" },
}

local leaderboardItemDataElements = {
    ["playerId"] = { offset = 0x18, type = "String" },
    ["playerName"] = { offset = 0x20, type = "String" },
    ["time"] = { offset = 0x28, type = "Float" },
    ["distance"] = { offset = 0x2C, type = "Float" },
    ["levelId"] = { offset = 0x30, type = "String" },
    ["points"] = { offset = 0x38, type = "Int32" },
    ["finishingStatus"] = { offset = 0x3C, type = "Int32" },
    ["sessionId"] = { offset = 0x40, type = "String" },
    ["replayId"] = { offset = 0x48, type = "String" },
    ["flag"] = { offset = 0x50, type = "String" },
    ["vehicleId"] = { offset = 0x58, type = "String" },
    ["retryCount"] = { offset = 0x60, type = "Int32" },
    ["result"] = { offset = 0x64, type = "Float" },
    ["teamId"] = { offset = 0x68, type = "String" },
    ["resultType"] = { offset = 0x70, type = "Int32" },
    ["raceIndex"] = { offset = 0x74, type = "Int32" },
}

local tournamentPlayerStatusElements = {
    ["tournamentId"] = { offset = 0x18, type = "String" },
    ["sessionId"] = { offset = 0x20, type = "String" },
    ["remainingAttempts"] = { offset = 0x28, type = "Array", elementType = "Int32", elementStride = 0x4 },
}

local rewardStatusElements = {
    ["id"] = { offset = 0x18, type = "String" },
    ["state"] = { offset = 0x20, type = "Int32" },
    ["startTimestamp"] = { offset = 0x24, type = "Int32" },
    ["vehicleId"] = { offset = 0x28, type = "String" },
    ["type"] = { offset = 0x30, type = "Int32" },
    ["target"] = { offset = 0x34, type = "Int32" },
    ["duration"] = { offset = 0x38, type = "Int32" },
    ["specialCupRewardTypeIndex"] = { offset = 0x3C, type = "Int32" },
    ["slot"] = { offset = 0x40, type = "Int32" },
    ["level"] = { offset = 0x44, type = "Int32" },
}

local homePropElements = {
    ["typeId"] = { offset = 0x18, type = "String" },
    ["propId"] = { offset = 0x20, type = "String" },
    -- position (0x28) is Vector2Int (two packed int32s) — not mapped yet
}

local roomElements = {
    ["wallId"] = { offset = 0x18, type = "String" },
    ["floorId"] = { offset = 0x20, type = "String" },
    ["rafterId"] = { offset = 0x28, type = "String" },
    ["props"] = { offset = 0x30, type = "Array", elements = homePropElements },
}

return {
    ["playerId"] = {
        offset = 0x30,
        optional = false,
        tracked = true,
        type = "String"
    },
    ["playerName"] = {
        offset = 0x38,
        optional = false,
        tracked = true,
        type = "String"
    },
    ["flag"] = {
        offset = 0x40,
        optional = true,
        tracked = true,
        type = "String"
    },
    ["coins"] = {
        offset = 0x48,
        optional = true,
        tracked = true,
        type = "Int32"
    },
    ["totalCoinsEarned"] = {
        offset = 0x4C,
        optional = true,
        tracked = true,
        type = "Int32"
    },
    ["totalNeckFlips"] = {
        offset = 0x50,
        type = "Int32"
    },
    ["totalBackFlips"] = {
        offset = 0x54,
        type = "Int32"
    },
    ["totalFlips"] = {
        offset = 0x58,
        type = "Int32"
    },
    ["totalFuelCanistersCollected"] = {
        offset = 0x5C,
        type = "Int32"
    },
    ["totalCoinsCollected"] = {
        offset = 0x60,
        type = "Int32"
    },
    ["totalDistance"] = {
        offset = 0x64,
        type = "Float"
    },
    ["totalPlayTime"] = {
        offset = 0x68,
        type = "Float"
    },
    ["lastRaceTimestamp"] = {
        offset = 0x6C,
        type = "Float"
    },
    ["completedMissions"] = {
        offset = 0x70, -- Timerise
        type = "Array",
        elements = missionStatusElements,
    },  -- MissionStatus
    ["activeLevelMissions"] = {
        offset = 0x88, -- was 0x80 (Timerise); dump says 0x88
        type = "Array",
        elements = missionStatusMapElements,
    },  -- MissionStatusMap
    ["qualifyBests"] = {
        offset = 0xA0,
        type = "Array",
        elements = qualifyTimeElements,
    },  -- QualifyTime
    ["vehicleStatus"] = {
        offset = 0xB8,
        type = "Array",
        elements = {
            ["vehicleId"] = { offset = 0x18, type = "String" },
            ["upgrades"] = {
                offset = 0x20,
                type = "Array",
                elements = {
                    ["upgradeId"] = { offset = 0x18, type = "String" },
                    ["level"] = { offset = 0x20, type = "Int32" },
                    ["maxLevel"] = { offset = 0x24, type = "Int32" },
                },
            },
            ["customizations"] = {
                offset = 0x38,
                type = "Array",
                elements = {
                    ["id"] = { offset = 0x18, type = "String" },
                    ["value"] = { offset = 0x20, type = "String" },
                },
            },
            ["vehicleStats"] = {
                offset = 0x50,
                type = "Object",
                ["levelStars"] = {
                    offset = 0x18,
                    type = "Array",
                    elements = stringIntMapElements,
                },
                ["levelDivisionMedals"] = {
                    offset = 0x30,
                    type = "Array",
                    elements = stringIntMapElements,
                },
                ["flips"] = { offset = 0x48, type = "Int32" },
                ["backflips"] = { offset = 0x4C, type = "Int32" },
                ["neckflips"] = { offset = 0x50, type = "Int32" },
                ["airtime"] = { offset = 0x54, type = "Float" },
                ["wheelieTime"] = { offset = 0x58, type = "Float" },
                ["racesFinished"] = { offset = 0x5C, type = "Int32" },
                ["racesWon"] = { offset = 0x60, type = "Int32" },
                ["totalDistance"] = { offset= 0x64, type = "Int32" },
                ["challengesWon"] = { offset = 0x68, type = "Int32" },
                ["featuredChallengesWon"] = { offset = 0x6C, type = "Int32" },
                ["recentUsage"] = {
                    offset = 0x70,
                    type = "Array",
                    elements = {
                        ["daysSinceEpoch"] = { offset = 0x18, type = "Int32" },
                        ["raceStarts"] = { offset = 0x1C, type = "Int32" },
                        ["distanceStarts"] = { offset = 0x20, type = "Int32" },
                        ["eventStarts"] = { offset = 0x24, type = "Int32" },
                        ["totalDistance"] = { offset = 0x28, type = "Int32" },
                    },
                },
            },
            ["tuningParts"] = {
                offset = 0x58,
                type = "Array",
                elements = {
                    ["id"] = { offset = 0x18, type = "String" },
                    ["level"] = { offset = 0x20, type = "Int32" },
                    ["progressSteps"] = { offset = 0x24, type = "Int32" },
                    ["isNewUnlock"] = { offset = 0x30, type = "Bool" },
                    ["maxLevel"] = { offset = 0x34, type = "Int32" },
                },
            },
            ["equippedTuningParts"] = {
                offset = 0x70,
                type = "Array",
                elementType = "String",
            },
            ["distanceHighscores"] = {
                offset = 0x88,
                type = "Array",
                elements = distanceHighscoreElements,
            },
            ["timeTrialHighscores"] = {
                offset = 0xA0,
                type = "Array",
                elements = timeTrialHighscoreElements,
            },
            ["unlockedEquipSlotsCount"] = { offset = 0xE8, type = "Int32" },
            ["newDistanceHighscores"] = {
                offset = 0xB8,
                type = "Array",
                elements = distanceHighscoreElements,
            },
            ["newTimeTrialHighscores"] = {
                offset = 0xD0,
                type = "Array",
                elements = timeTrialHighscoreElements,
            },
            ["distanceTarget"] = {
                offset = 0xF0,
                type = "Array",
                elements = stringIntMapElements,
            },
            ["tuningPartPresets"] = {
                offset = 0x108,
                type = "Array",
                elements = {
                    ["equippedParts"] = {
                        offset = 0x18,
                        type = "Array",
                        elementType = "String"
                    },
                },
            },
            ["selectedPresetIndex"] = {
                offset = 0xEC,
                type = "Int32",
            },
            ["vehiclePower"] = {
                offset = 0x140,
                type = "Int32",
            },
            ["masteryStatus"] = {
                offset = 0x120,
                type = "Array",
                elements =  {
                    ["unlocked"] = { offset = 0x18, type = "Bool" },
                    ["purchased"] = { offset = 0x19, type = "Bool" },
                    ["enabled"] = { offset = 0x1A, type = "Bool" },
                    ["progressStartTimestamp"] = { offset = 0x1C, type = "Int32" },
                },
            },
            ["masteryXp"] = {
                offset = 0x138,
                type = "SafeInt32",
            },
            ["currentVehicleWinStreak"] = {
                offset = 0x144,
                type = "Int32",
            },
            ["bestVehicleWinStreak"] = {
                offset = 0x190,
                type = "Int32",
            },
        },
    },  -- VehicleStatus
    ["totalChampionshipPoints"] = {
        offset = 0xD0,
        type = "Int32"
    },
    ["currentDailyBestPoints"] = {
        offset = 0xD4,
        type = "Int32"
    },
    ["dailyBestPoints"] = {
        offset = 0xD8,
        type = "Array",
        elements = racePointsElements,
    },  -- RacePoints
    ["tournamentRaceBests"] = {
        offset = 0xF0,
        type = "Array",
        elements = leaderboardItemDataElements,
    },  -- LeaderboardItemData
    ["activeTournaments"] = {
        offset = 0x108,
        type = "Array",
        elements = tournamentPlayerStatusElements,
    },  -- TournamentPlayerStatus
    ["diamonds"] = {
        offset = 0x120,
        type = "Int32"
    },
    ["ladderPoints"] = {
        offset = 0x124,
        type = "Int32"
    },
    ["playerXp"] = {
        offset = 0x128,
        type = "Int32"
    },
    ["dailyMissionsFilledTimeStamp"] = {
        offset = 0x12C,
        type = "Int32"
    },
    ["dailyMissionChangesFilledTimeStamp"] = {
        offset = 0x130,
        type = "Int32"
    },
    ["availableDailyMissionChanges"] = {
        offset = 0x134,
        type = "Int32"
    },
    ["completedDailyMissions"] = {
        offset = 0x138,
        type = "Array",
        elements = missionStatusElements,
    },  -- MissionStatus
    ["activeDailyMissions"] = {
        offset = 0x150,
        type = "Array",
        elements = missionStatusElements,
    },  -- MissionStatus
    ["driver"] = {
        offset = 0x168,
        type = "Object",
        ["head"] = { offset = 0x18, type = "String" },
        ["body"] = { offset = 0x20, type = "String" },
        ["legs"] = { offset = 0x28, type = "String" },
        ["hat"] = { offset = 0x30, type = "String" },
        ["bodyAttachment"] = { offset = 0x38, type = "String" },
        ["profileAnimation"] = { offset = 0x40, type = "String" },
        ["podiumWinAnimation"] = { offset = 0x48, type = "String" },
        ["podiumLoseAnimation"] = { offset = 0x50, type = "String" },
    },
    ["levelStars"] = {
        offset = 0x170,
        type = "Array",
        elements = stringIntMapElements,
    },
    ["unlocks"] = {
        offset = 0x188,
        type = "Array",
        elements = {
            ["type"] = { offset = 0x20, type = "Enum", enum = "UnlockType" },
            ["id"] = { offset = 0x18, type = "String" },
            ["unlockState"] = { offset = 0x24, type = "Int32" },
            ["unlockType"] = { offset = 0x30, type = "Int32" },
            ["vehicleId"] = { offset = 0x28, type = "String" },
        },
    },
    ["chips"] = {
        offset = 0x1A0,
        type = "Int32"
    },
    ["totalAirtime"] = {
        offset = 0x1A4,
        type = "Int32"
    },
    ["totalWheelieTime"] = {
        offset = 0x1A8,
        type = "Int32"
    },
    ["totalRacesFinished"] = {
        offset = 0x1AC,
        type = "Int32"
    },
    ["myDivisions"] = {
        offset = 0x1B0,
        type = "Array", 
        elements = stringIntMapElements,
    },
    ["selectedLevel"] = {
        offset = 0x1C8,
        type = "Int32"
    },
    ["WCRank"] = {
        offset = 0x1CC,
        optional = true,
        type = "Float"
    },
    ["ownedWorlds"] = {
        offset = 0x1D0,
        type = "Array",
        elementType = "String",
    },
    ["AllowedLevelTier"] = {
        offset = 0x1E8,
        type = "Int32"
    },
    ["totalDistanceStarts"] = {
        offset = 0x1EC,
        type = "Int32"
    },
    ["totalRaceStarts"] = {
        offset = 0x1F0,
        type = "Int32"
    },
    ["totalRaceVictories"] = {
        offset = 0x1F4,
        type = "Int32"
    },
    ["rewardManagerStatus"] = {
        offset = 0x1F8,
        type = "Object",
        ["rewards"] = { offset = 0x18, type = "Array", elements = rewardStatusElements },
        ["nextRewardTimestamp"] = { offset = 0x30, type = "Int32" },
        ["nextVideoAdTimestamp"] = { offset = 0x34, type = "Int32" },
        ["dailyToolbox"] = {
            offset = 0x38,
            type = "Object",
            ["state"] = { offset = 0x18, type = "Int32" },
            ["startTimestamp"] = { offset = 0x1C, type = "Int32" },
            ["progress"] = { offset = 0x20, type = "Int32" },
        },
        ["nextFreeChestTimestamp"] = { offset = 0x40, type = "Int32" },
        ["videoSkipSpecialCupsRemaining"] = { offset = 0x44, type = "Int32" },
        ["nextVideoSkipsTimestamp"] = { offset = 0x48, type = "Int32" },
        ["currentSpecialCupRewardIndex"] = { offset = 0x4C, type = "Int32" },
        ["distanceRewards"] = { offset = 0x50, type = "Array", elements = rewardStatusElements },
        ["videoSkipScrapperRemaining"] = { offset = 0x68, type = "Int32" },
        ["nextVideoSkipScrapperTimestamp"] = { offset = 0x6C, type = "Int32" },
        ["videoSkipTeamEventTicketsRemaining"] = { offset = 0x70, type = "Int32" },
        ["nextVideoSkipTeamEventTicketTimestamp"] = { offset = 0x74, type = "Int32" },
        ["videoSkipEventTicketsRemaining"] = { offset = 0x78, type = "Int32" },
        ["nextVideoSkipEventTicketTimestamp"] = { offset = 0x7C, type = "Int32" },
        ["nextVideoChestTimestamp"] = { offset = 0x80, type = "Int32" },
        ["distanceVideoRewardsRemaining"] = { offset = 0x84, type = "Int32" },
        ["videoMultipliedCoinsCollected"] = { offset = 0x88, type = "Int32" },
        ["nextVideoCoinMultiplierTimestamp"] = { offset = 0x8C, type = "Int32" },
        ["activeDistanceReward"] = {
            offset = 0x90,
            type = "Object",
            ["id"] = { offset = 0x18, type = "String" },
            ["state"] = { offset = 0x20, type = "Int32" },
            ["startTimestamp"] = { offset = 0x24, type = "Int32" },
            ["vehicleId"] = { offset = 0x28, type = "String" },
            ["type"] = { offset = 0x30, type = "Int32" },
            ["target"] = { offset = 0x34, type = "Int32" },
            ["duration"] = { offset = 0x38, type = "Int32" },
            ["specialCupRewardTypeIndex"] = { offset = 0x3C, type = "Int32" },
            ["slot"] = { offset = 0x40, type = "Int32" },
            ["level"] = { offset = 0x44, type = "Int32" },
        },
        ["distanceRewardsRemaining"] = { offset = 0x98, type = "Int32" },
        ["nextDistanceRewardsTimestamp"] = { offset = 0x9C, type = "Int32" },
        ["videoDoubleEventPointsRemaining"] = { offset = 0xA0, type = "Int32" },
        ["nextVideoDoubleEventPointsTimestamp"] = { offset = 0xA4, type = "Int32" },
        ["previousConsumedXPromo"] = { offset = 0xA8, type = "String" },
        ["chestRandomCounter"] = { offset = 0xB0, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["videoChestsRemaining"] = { offset = 0xC0, type = "Int32" },
    },  -- RewardManagerStatus
    ["maxWCRank"] = {
        offset = 0x200,
        type = "Float"
    },
    ["nextFreeUpgradeTimestamp"] = {
        offset = 0x204,
        type = "Int32"
    },
    ["unlockedRaces"] = {
        offset = 0x208,
        type = "Array",
        elementType = "String",
    },
    ["totalTime"] = {
        offset = 0x238,
        type = "Int32"
    },
    ["unlockedVehicles"] = {
        offset = 0x220,
        type = "Array",
        elementType = "String",
    },
    ["totalGemsEarned"] = {
        offset = 0x23C,
        type = "Int32"
    },
    ["recentChallenges"] = {
        offset = 0x240,
        type = "Array",
        elementType = "String",
    },
    ["achievements"] = {
        offset = 0x258,
        type = "Array",
        elements = {
            ["id"] = { offset = 0x18, type = "Int32" },
            ["unlocked"] = { offset = 0x1C, type = "Bool" },
            ["steps"] = { offset = 0x20, type = "Int32" },
        },
    },
    ["totalCupVictories"] = {
        offset = 0x270,
        type = "Int32"
    },
    ["cloudSaveVersion"] = {
        offset = 0x274,
        type = "Int32"
    },
    ["ratingsAsked"] = {
        offset = 0x278,
        type = "Int32"
    },
    ["ratingEventCounter"] = {
        offset = 0x27C,
        type = "Int32"
    },
    ["tutorialState"] = {
        offset = 0x280,
        type = "Int32"
    },
    ["totalCupsFinished"] = {
        offset = 0x284,
        type = "Int32"
    },
    ["adFree"] = {
        offset = 0x3DC,
        type = "Bool"
    },
    ["purchasedSpecialOffers"] = {
        offset = 0x288,
        type = "Array",
        elementType = "String",
    },
    ["teamId"] = {
        offset = 0x2A0,
        type = "String"
    },
    ["activeFriendlyRaces"] = {
        offset = 0x2A8,
        type = "Array",
        elements = friendlyRaceElements,
    },  -- FriendlyRace
    ["cheater"] = {
        offset = 0x3DD,
        type = "Bool"
    },
    ["currentCupId"] = {
        offset = 0x2C0,
        type = "String"
    },
    ["deviceSignature"] = {
        offset = 0x2C8,
        type = "String"
    },
    ["deviceHash"] = {
        offset = 0x2D0, -- was 0x2C8; dump: devicesignature_ 0x2c8, devicehash_ 0x2d0
        type = "String"
    },
    ["currentSpecialEventId"] = {
        offset = 0x2D8,
        type = "String"
    },
    ["contentVersion"] = {
        offset = 0x300,
        type = "Int32"
    },
    ["seasonStatus"] = {
        offset = 0x2E0,
        type = "Object",
        ["highestRank"] = { offset = 0x18, type = "Float" },
        ["startRank"] = { offset = 0x1C, type = "Float" },
        ["seasonId"] = { offset = 0x20, type = "String" },
        ["endTimestamp"] = { offset = 0x28, type = "Int32" },
        ["ended"] = { offset = 0x2C, type = "Bool" },
        ["premiumUnlocked"] = { offset = 0x2D, type = "Bool" },
        ["bonusChestClaimed"] = { offset = 0x2E, type = "Bool" },
        ["premiumProgressClaimed"] = { offset = 0x2F, type = "Bool" },
        ["receivedRewards"] = { offset = 0x30, type = "Array", elementType = "String" },
        ["animatedRank"] = { offset = 0x48, type = "Float" },
        ["premiumTierUnlocked"] = { offset = 0x4C, type = "Int32" },
    },  -- SeasonStatus
    ["purchasedIaps"] = {
        offset = 0x2E8,
        type = "Array",
        elements = iapPurchaseEventElements,
    },  -- IapPurchaseEvent
    ["acsPlayerGuid"] = {
        offset = 0x308,
        type = "String"
    },
    ["challengesWon"] = {
        offset = 0x304,
        type = "Int32"
    },
    ["featuredChallengesWon"] = {
        offset = 0x310,
        type = "Int32"
    },
    ["totalRank"] = {
        offset = 0x314,
        type = "Float"
    },
    ["nameChanges"] = {
        offset = 0x318,
        type = "Int32"
    },
    ["nextFreeTuningPartUpgradeTimestamp"] = {
        offset = 0x31C,
        type = "Int32"
    },
    ["activeEventStatus"] = {
        offset = 0x320,
        type = "Object",
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
        -- fixedVehicleStatus (0x68) is RepeatedPtrField<VehicleStatus>;
        -- the vehicleStatus element template lives inline on the
        -- vehicleStatus entry above, so no reader is attached here.
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
        -- activeBoosters (0x100) is RepeatedPtrField<ActiveBooster> — layout not yet mapped
        ["boosterFreeShopItems"] = { offset = 0x118, type = "Array", elementType = "String" },
        ["randomBoosterSelection"] = { offset = 0x130, type = "Array", elementType = "String" },
        ["activeSessionBonusVehicles"] = { offset = 0x148, type = "Array", elementType = "String" },
        ["pendingMultichoiceChestVehicles"] = { offset = 0x160, type = "Array", elementType = "String" },
        ["specialFeatureUpgrades"] = { offset = 0x178, type = "Array", elements = upgradeStatusElements },
        ["collectedSpecialsRewardIndexes"] = { offset = 0x190, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["boosterClaimedAtSession"] = { offset = 0x1A0, type = "Int32" },
    },  -- EventStatus
    ["flags"] = {
        offset = 0x328,
        type = "BitMask",
        enum = "GameStatusFlag"
    },
    ["ownedVehicles"] = {
        offset = 0x330,
        type = "Array",
        elementType = "String",
    },
    ["nextVehicleChestTimestamp"] = {
        offset = 0x348,
        type = "Int32"
    },
    ["vehicleChestsPurchased"] = {
        offset = 0x34C,
        type = "Int32"
    },
    ["gachaNewVehicleCounter"] = {
        offset = 0x368,
        type = "Int32"
    },
    ["purchasedPopupOffers"] = {
        offset = 0x350,
        type = "Array",
        elementType = "String",
    },
    ["activePopupOffer"] = {
        offset = 0x370,
        type = "String"
    },
    ["activePopupOfferEndTimestamp"] = {
        offset = 0x36C,
        type = "Int32"
    },
    ["expiredPopupOffers"] = {
        offset = 0x378,
        type = "Array",
        elementType = "String",
    },
    ["pendingChests"] = {
        offset = 0x390,
        type = "Array",
        elements = pendingChestElements,
    },  -- PendingChest
    ["libHash"] = {
        offset = 0x3B0,
        type = "Int32"
    },
    ["vipStatus"] = {
        offset = 0x3A8,
        type = "Object",
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
        ["manuallyEnabled"] = { offset = 0x50, type = "Bool" } -- was 0x2E; dump: hasbeenvipbefore_ 0x2e, manuallyenabled_ 0x50
    },
    ["totalEventsJoined"] = {
        offset = 0x3B4,
        type = "Int32"
    },
    ["totalEventPoints"] = {
        offset = 0x3B8,
        type = "Int32"
    },
    ["totalEventRaces"] = {
        offset = 0x3BC,
        type = "Int32"
    },
    ["totalEarnedTickets"] = {
        offset = 0x3C0,
        type = "Int32"
    },
    ["totalSpentTickets"] = {
        offset = 0x3C4,
        type = "Int32"
    },
    ["device"] = {
        offset = 0x3C8,
        type = "String"
    },
    ["os"] = {
        offset = 0x3D0,
        type = "String"
    },
    ["totalEventRacesWon"] = {
        offset = 0x3D8,
        type = "Int32"
    },
    ["rentedVehicles"] = {
        offset = 0x3E0,
        type = "Array",
        elements = rentalStatusElements,
    },  -- RentalStatus
    ["unlockedWorlds"] = {
        offset = 0x3F8,
        type = "Array",
        elementType = "String",
    },
    ["segmentId"] = {
        offset = 0x410,
        type = "String"
    },
    ["playerSegments"] = {
        offset = 0x418,
        type = "String"
    },
    ["checkinReward"] = {
        offset = 0x420,
        type = "Object",
        ["id"] = { offset = 0x18, type = "String" },
        ["rewardIndex"] = { offset = 0x20, type = "Int32" },
        ["lastCollectedTimestamp"] = { offset = 0x24, type = "Int32" },
        ["startTimestamp"] = { offset = 0x28, type = "Int32" },
        ["endTimestamp"] = { offset = 0x2C, type = "Int32" },
        ["claimedRewards"] = { offset = 0x30, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["allowDaySkip"] = { offset = 0x40, type = "Bool" },
        ["updateRewardIndexAfterSkip"] = { offset = 0x41, type = "Bool" },
        ["minCollectInterval"] = { offset = 0x44, type = "Int32" },
        ["maxCollectInterval"] = { offset = 0x48, type = "Int32" },
        ["shuffleKey"] = { offset = 0x4C, type = "Int32" },
    },  -- CheckinReward
    ["seasonRank"] = {
        offset = 0x428,
        type = "Float"
    },
    ["totalSeasonRank"] = {
        offset = 0x42C,
        type = "Float"
    },
    ["bestSeasonRank"] = {
        offset = 0x438,
        type = "Float"
    },
    ["currentSeasonId"] = {
        offset = 0x430,
        type = "String"
    },
    ["totalEventRaceStarts"] = {
        offset = 0x43C,
        type = "Int32"
    },
    ["createTimestamp"] = {
        offset = 0x458,
        type = "Int32"
    },
    ["deals"] = {
        offset = 0x440,
        type = "Array",
        elements = dealStatusElements,
    },  -- DealStatus
    ["scrap"] = {
        offset = 0x45C,
        type = "Int32"
    },
    ["scrapperStatus"] = {
        offset = 0x460,
        type = "Object",
        ["readyTimestamp"] = { offset = 0x18, type = "Int32" },
        ["partsIn"] = { offset = 0x1C, type = "Int32" },
        ["scrapOut"] = { offset = 0x20, type = "Int32" },
        ["isUnlocked"] = { offset = 0x24, type = "Bool" },
        ["isExcessTutorialShown"] = { offset = 0x25, type = "Bool" },
    },  -- ScrapperStatus
    ["totalScrapEarned"] = {
        offset = 0x480,
        type = "Int32"
    },
    ["oldSeasons"] = {
        offset = 0x468,
        type = "Array",
        elements = seasonStatusElements,
    },  -- SeasonStatus
    ["targetedAdsConsent"] = {
        offset = 0x484,
        type = "Int32"
    },
    ["acceptedEulaVersion"] = {
        offset = 0x4A8,
        type = "Int32"
    },
    ["activePopupOffers"] = {
        offset = 0x488,
        type = "Array",
        elements = activePopupOfferElements,
    },  -- ActivePopupOffer
    ["activeTeamEventStatus"] = {
        offset = 0x4A0,
        type = "Object",
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
        -- fixedVehicleStatus (0x68) is RepeatedPtrField<VehicleStatus>;
        -- the vehicleStatus element template lives inline on the
        -- vehicleStatus entry above, so no reader is attached here.
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
        -- activeBoosters (0x100) is RepeatedPtrField<ActiveBooster> — layout not yet mapped
        ["boosterFreeShopItems"] = { offset = 0x118, type = "Array", elementType = "String" },
        ["randomBoosterSelection"] = { offset = 0x130, type = "Array", elementType = "String" },
        ["activeSessionBonusVehicles"] = { offset = 0x148, type = "Array", elementType = "String" },
        ["pendingMultichoiceChestVehicles"] = { offset = 0x160, type = "Array", elementType = "String" },
        ["specialFeatureUpgrades"] = { offset = 0x178, type = "Array", elements = upgradeStatusElements },
        ["collectedSpecialsRewardIndexes"] = { offset = 0x190, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["boosterClaimedAtSession"] = { offset = 0x1A0, type = "Int32" },
    },  -- EventStatus
    ["teamStatus"] = {
        offset = 0x4B0,
        type = "Object",
        ["collectedTeamChests"] = { offset = 0x18, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["joinedToTeamTimestamp"] = { offset = 0x28, type = "Int32" },
        ["pendingTeamChestContribution"] = { offset = 0x2C, type = "Float" },
        ["numberOfTeamJoins"] = { offset = 0x30, type = "Int32" },
        ["numberOfKickedOut"] = { offset = 0x34, type = "Int32" },
        ["reportedMessages"] = { offset = 0x38, type = "Array", elementType = "String" },
        ["currentTeamDonations"] = { offset = 0x50, type = "SafeInt32" },
        ["collectedTeamBossChests"] = { offset = 0x58, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["waitingJoinLeaveResponse"] = { offset = 0x68, type = "Bool" },
        ["waitingCreateResponse"] = { offset = 0x69, type = "Bool" },
    },  -- TeamStatus
    ["specialTickets"] = {
        offset = 0x4AC,
        type = "Int32"
    },
    ["totalEarnedSpecialTickets"] = {
        offset = 0x4B8,
        type = "Int32"
    },
    ["totalSpentSpecialTickets"] = {
        offset = 0x4BC,
        type = "Int32"
    },
    ["kickedTeamStatus"] = {
        offset = 0x4C0,
        type = "Object",
        ["teamEventId"] = { offset = 0x18, type = "String" },
        ["teamId"] = { offset = 0x20, type = "String" },
        ["sessionId"] = { offset = 0x28, type = "String" },
        ["teamTicketsRefillTime"] = { offset = 0x30, type = "Int32" },
    },  -- KickedTeamStatus
    ["teamEventOfferShown"] = {
        offset = 0x4C8,
        type = "String"
    },
    ["weeklyEventOfferShown"] = {
        offset = 0x4D0,
        type = "String"
    },
    ["playerNameApprovalState"] = {
        offset = 0x4F0,
        type = "Int32",
        enum = "PlayerNameApprovalState"
    },
    ["distanceTickets"] = {
        offset = 0x4D8,
        type = "Array",
        elements = distanceTicketElements,
    },  -- DistanceTicket
    ["previousEventStatuses"] = {
        offset = 0x4F8,
        type = "Array",
        elements = eventStatusElements,
    },  -- EventStatus
    ["garagePower"] = {
        offset = 0x4F4,
        type = "Int32"
    },
    ["premiumWCUnlocked"] = {
        offset = 0x3DE,
        type = "Bool"
    },
    ["receivedWCRewards"] = {
        offset = 0x510,
        type = "Array",
        elementType = "String",
    },
    ["animatedWCRank"] = {
        offset = 0x528,
        type = "Float"
    },
    ["adventurerRank"] = {
        offset = 0x52C,
        type = "Float"
    },
    ["receivedAdventurerRewards"] = {
        offset = 0x530,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4, -- RepeatedField<int> packs elements at 4 bytes
    },
    ["secret"] = {
        offset = 0x540,
        type = "String"
    },
    ["animatedAdventurerRank"] = {
        offset = 0x568,
        type = "Float"
    },
    ["banData"] = {
        offset = 0x548,
        type = "Array",
        elements = banDataElements,
    },  -- BanData
    ["banReviewed"] = {
        offset = 0x3DF,
        type = "Bool"
    },
    ["teamSeasonStatus"] = {
        offset = 0x560,
        type = "Object",
        ["seasonId"] = { offset = 0x18, type = "String" },
        ["division"] = { offset = 0x20, type = "Int32" },
        ["rank"] = { offset = 0x24, type = "Float" },
        ["previousOpponents"] = { offset = 0x28, type = "Array", elementType = "String" },
        ["startTimestamp"] = { offset = 0x40, type = "Int32" },
        ["endTimestamp"] = { offset = 0x44, type = "Int32" },
        ["finalPlacement"] = { offset = 0x48, type = "Int32" },
        ["subdivision"] = { offset = 0x4C, type = "Int32" },
        ["teamSupportLevel"] = { offset = 0x50, type = "Int32" },
    },  -- TeamSeasonStatus
    ["nonRewardedTeamSeasons"] = {
        offset = 0x570,
        type = "Array",
        elementType = "String",
    },
    ["activeDailyBonusTasks"] = {
        offset = 0x588,
        type = "Array",
        elements = dailyTaskElements,
    },  -- DailyTask
    ["activeDailyTasks"] = {
        offset = 0x5A0,
        type = "Array",
        elements = dailyTaskElements,
    },  -- DailyTask
    ["nextDailyTaskTimeStamp"] = {
        offset = 0x56C,
        type = "Int32"
    },
    ["nextDailyTaskRerollTimeStamp"] = {
        offset = 0x5B8,
        type = "Int32"
    },
    ["dailyTaskRerollsRemaining"] = {
        offset = 0x5BC,
        type = "Int32"
    },
    ["shownGDPRVersion"] = {
        offset = 0x5C0,
        type = "Int32"
    },
    ["dailyTaskRerollsWithVideoRemaining"] = {
        offset = 0x5C4,
        type = "Int32"
    },
    ["pendingofferid"] = {
        offset = 0x5C8,
        type = "String"
    },
    ["pendingOfferIds"] = {
        offset = 0x5D0,
        type = "Array",
        elements = iapPurchaseEventElements,
    },  -- IapPurchaseEvent
    ["dailyTaskRefillsRemaining"] = {
        offset = 0x5E8,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4, -- RepeatedField<int> packs elements at 4 bytes
    },
    ["currencies"] = {
        offset = 0x5F8,
        type = "Array",
        elements = {
            ["id"] = { offset = 0x18, type = "String" },
            ["amount"] = { offset = 0x20, type = "Int32" },
            ["totalEarned"] = { offset = 0x24, type = "Int32" },
            ["totalSpent"] = { offset = 0x30, type = "Int32" },
            ["safeAmount"] = { offset = 0x28, type = "SafeInt32" },
            ["timesEarned"] = { offset = 0x34, type = "Int32" },
            ["maxEarn"] = { offset = 0x48, type = "Int32" },
            ["iapCount"] = { offset = 0x38, type = "SafeInt32" },
            ["iapAmount"] = { offset = 0x40, type = "SafeInt32" },
        },
    },  -- Currency
    ["publishedLevels"] = {
        offset = 0x610,
        type = "Array",
        elementType = "String",
    },
    ["featuredChallenges"] = {
        offset = 0x628,
        type = "Array",
        elements = featuredChallengeElements,
    },  -- FeaturedChallenge
    ["featuredChallengeIndex"] = {
        offset = 0x640,
        type = "Int32"
    },
    ["nextFreeFeaturedChallengeTimestamp"] = {
        offset = 0x644,
        type = "Int32"
    },
    ["lastPlayerNameChangedTimestamp"] = {
        offset = 0x6A8,
        type = "Int32"
    },
    ["firstPlayerNameChange"] = {
        offset = 0x754,
        type = "Bool"
    },
    ["distanceCollectibles"] = {
        offset = 0x648,
        type = "Array",
        elements = distanceCollectibleStatusElements,
    },  -- DistanceCollectibleStatus
    ["activeCommunityEventStatus"] = {
        offset = 0x660,
        type = "Object",
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
        -- fixedVehicleStatus (0x68) is RepeatedPtrField<VehicleStatus>;
        -- the vehicleStatus element template lives inline on the
        -- vehicleStatus entry above, so no reader is attached here.
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
        -- activeBoosters (0x100) is RepeatedPtrField<ActiveBooster> — layout not yet mapped
        ["boosterFreeShopItems"] = { offset = 0x118, type = "Array", elementType = "String" },
        ["randomBoosterSelection"] = { offset = 0x130, type = "Array", elementType = "String" },
        ["activeSessionBonusVehicles"] = { offset = 0x148, type = "Array", elementType = "String" },
        ["pendingMultichoiceChestVehicles"] = { offset = 0x160, type = "Array", elementType = "String" },
        ["specialFeatureUpgrades"] = { offset = 0x178, type = "Array", elements = upgradeStatusElements },
        ["collectedSpecialsRewardIndexes"] = { offset = 0x190, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["boosterClaimedAtSession"] = { offset = 0x1A0, type = "Int32" },
    },  -- EventStatus
    ["currentPublicLevels"] = {
        offset = 0x668,
        type = "Array",
        elementType = "String",
    },
    ["unlockedEditorThemes"] = {
        offset = 0x680,
        type = "Array",
        elementType = "String",
    },
    ["FSHomeProfileID"] = {
        offset = 0x698,
        type = "String"
    },
    ["home"] = {
        offset = 0x6A0,
        type = "Object",
        ["rooms"] = { offset = 0x18, type = "Array", elements = roomElements },
    },  -- Home
    ["ownedHomeProps"] = {
        offset = 0x6B0,
        type = "Array",
        elements = homeCosmeticsOwnershipElements,
    },  -- HomeCosmeticsOwnership
    ["ownedHomeBackgrounds"] = {
        offset = 0x6C8,
        type = "Array",
        elements = homeCosmeticsOwnershipElements,
    },  -- HomeCosmeticsOwnership
    ["megaAdChestRewards"] = {
        offset = 0x6E0,
        type = "Array",
        elements = megaAdChestRewardStatusElements,
    },  -- MegaAdChestRewardStatus
    ["activeLeagueTasks"] = {
        offset = 0x6F8,
        type = "Array",
        elements = leagueTaskElements,
    },  -- LeagueTask
    ["communityEvent"] = {
        offset = 0x710,
        type = "Object",
        ["seasonId"] = { offset = 0x18, type = "String" },
        ["results"] = { offset = 0x20, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["oldSeasons"] = { offset = 0x30, type = "Array", elements = stringIntMapElements },
        ["levelIds"] = { offset = 0x48, type = "Array", elementType = "String" },
        ["levelTimestamps"] = { offset = 0x60, type = "Array", elements = stringIntMapElements },
        ["eventPoints"] = { offset = 0x78, type = "Int32" },
    },
    ["masteryBonusXp"] = {
        offset = 0x718,
        type = "SafeInt32"
    },
    ["safeIntStaticKey"] = {
        offset = 0x6AC,
        type = "Int32"
    },
    ["adFreeEndTimestamp"] = {
        offset = 0x720,
        type = "SafeInt32"
    },
    ["safeCoins"] = {
        offset = 0x728,
        type = "SafeInt32"
    },
    ["safeDiamonds"] = {
        offset = 0x730,
        type = "SafeInt32"
    },
    ["safeScrap"] = {
        offset = 0x738,
        type = "SafeInt32"
    },
    ["megaAdChestMultiplier"] = {
        offset = 0x750,
        type = "Int32"
    },
    ["safeUnlocks"] = {
        offset = 0x740,
        type = "SafeInt32"
    },
    ["safeUnlockedVehicles"] = {
        offset = 0x748,
        type = "SafeInt32"
    },
    ["safeOwnedVehicles"] = {
        offset = 0x758,
        type = "SafeInt32"
    },
    ["safeOwnedWorlds"] = {
        offset = 0x760,
        type = "SafeInt32"
    },
    ["currentWinStreak"] = {
        offset = 0x768,
        type = "SafeInt32"
    },
    ["bestWinStreak"] = {
        offset = 0x770,
        type = "SafeInt32"
    },
    ["pendingWinStreakRestore"] = {
        offset = 0x755,
        type = "Bool"
    },
    ["rankedCupOngoing"] = {
        offset = 0x756,
        type = "Bool"
    },
    ["rankedCupVehicle"] = {
        offset = 0x778,
        type = "String"
    },
    ["supportHmac"] = {
        offset = 0x780,
        type = "String"
    },
    ["megaAdChestProgress"] = {
        offset = 0x788,
        type = "Array",
        elements = megaAdChestProgressElements,
    },  -- MegaAdChestProgress
    ["signatureChallengeId"] = {
        offset = 0x7A0,
        type = "String"
    },
    ["activeTutorialVersion"] = {
        offset = 0x7C0,
        type = "Int32"
    },
    ["adviews"] = {
        offset = 0x7A8,
        type = "Array",
        elements = adViewsMapElements,
    },  -- AdViewsMap
    ["premiumTierWCUnlocked"] = {
        offset = 0x7C4,
        type = "Int32"
    },
    ["premiumProgressWCClaimed"] = {
        offset = 0x757,
        type = "Bool"
    },
    ["currentGachaProgress"] = {
        offset = 0x7C8,
        type = "Object",
        ["pendingReward"] = { offset = 0x18, type = "SafeInt32" },
        ["eventHash"] = { offset = 0x20, type = "Int32" },
        ["totalSpins"] = { offset = 0x24, type = "Int32" },
        ["claimedRewards"] = { offset = 0x28, type = "Array", elementType = "SafeInt32" },
        ["claimedBonusRewards"] = { offset = 0x40, type = "SafeInt32" },
        ["adSpinDay"] = { offset = 0x48, type = "SafeInt32" },
        ["dailyAdSpins"] = { offset = 0x50, type = "SafeInt32" },
        ["safeTotalSpins"] = { offset = 0x58, type = "SafeInt32" },
    },  -- CurrentGachaProgress
    ["claimedResearchRewardAmount"] = {
        offset = 0x7D0,
        type = "Array",
        elementType = "SafeInt32",
    },
    ["claimedResearchDonationAmount"] = {
        offset = 0x7E8,
        type = "SafeInt32"
    },
    ["currentFriendEvent"] = {
        offset = 0x7F0,
        type = "Object",
        ["claimedRewards"] = { offset = 0x18, type = "Array", elementType = "SafeInt32" },
        ["eventHash"] = { offset = 0x30, type = "Int32" },
        ["hasEventPass"] = { offset = 0x34, type = "Bool" },
        ["collectibleResetTimestamp"] = { offset = 0x38, type = "SafeInt32" },
        ["collectibleCollected"] = { offset = 0x40, type = "SafeInt32" },
        ["activeEventTasks"] = { offset = 0x48, type = "Array", elements = dailyTaskElements },
        ["taskRefillsRemaining"] = { offset = 0x60, type = "Array", elementType = "Int32", elementStride = 0x4 },
        ["singleScore"] = { offset = 0x70, type = "SafeInt32" },
        ["tasksResetTimestamp"] = { offset = 0x78, type = "Int32" },
        ["adsResetTimestamp"] = { offset = 0x7C, type = "Int32" },
        ["eventId"] = { offset = 0x80, type = "String" },
        ["teamId"] = { offset = 0x88, type = "String" },
        ["adsRemaining"] = { offset = 0x90, type = "Int32" },
    },  -- CurrentFriendEvent
    ["teamDonationTrack"] = {
        offset = 0x808,
        type = "Int32"
    },
    ["displayedInfoPopups"] = {
        offset = 0x7F8,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4, -- RepeatedField<int> packs elements at 4 bytes
    },
    ["teamSupportChestTransactions"] = {
        offset = 0x810,
        type = "Array",
        elementType = "String",
    },
    ["showOnlineStatus"] = {
        id = "showOnlineStatus",
        offset = 0x80C,
        optional = true,
        tracked = true,
        type = "Bool"
    },
    ["eventPointUnlockVehicle"] = {
        id = "eventPointUnlockVehicle",
        offset = 0x828,
        optional = true,
        tracked = true,
        type = "String"
    },
    ["eventPointUnlockProgress"] = {
        id = "eventPointUnlockProgress",
        offset = 0x860,
        optional = true,
        tracked = true,
        type = "Int32"
    },
    ["purchasedIapGifts"] = {
        id = "purchasedIapGifts",
        offset = 0x830,
        optional = false,
        tracked = false,
        type = "Array",
        elementType = "String",
    },
    ["claimedInboxMessages"] = {
        id = "claimedInboxMessages",
        offset = 0x848,
        optional = false,
        tracked = false,
        type = "Array",
        elementType = "String",
    },
    ["currentWinStreakAdRestores"] = {
        id = "currentWinStreakAdRestores",
        offset = 0x868,
        optional = true,
        tracked = true,
        type = "SafeInt32"
    },
    ["winStreakSpecialShield"] = {
        id = "winStreakSpecialShield",
        offset = 0x864,
        optional = true,
        tracked = true,
        type = "Int32"
    },
    ["winStreakEvent"] = {
        id = "winStreakEvent",
        offset = 0x870,
        optional = true,
        tracked = true,
        type = "Object",
        ["cupCounter"] = { offset = 0x18, type = "SafeInt32" },
        ["endTime"] = { offset = 0x20, type = "SafeInt32" },
        ["startStreak"] = { offset = 0x28, type = "SafeInt32" },
        ["claimedRewards"] = { offset = 0x30, type = "Array", elementType = "SafeInt32" },
        ["vehicleId"] = { offset = 0x48, type = "String" },
        ["rewards"] = { offset = 0x50, type = "Array", elementType = "SafeInt32" },
        ["cooldownTime"] = { offset = 0x68, type = "SafeInt32" },
        ["active"] = { offset = 0x70, type = "Bool" },
        ["pendingEnd"] = { offset = 0x71, type = "Bool" },
    }, --WinStreakEvent
    ["activeTriggers"] = {
        id = "activeTriggers",
        offset = 0x878,
        optional = false,
        tracked = true,
        type = "Array",
        elements = activeTriggerElements,
    }, -- ActiveTrigger
    ["previousPlayerIds"] = {
        id = "previousPlayerIds",
        offset = 0x890,
        optional = true,
        tracked = true,
        type = "Array",
        elementType = "String",
    }, -- String (was Object; dump: RepeatedPtrField<string>)
    ["currentFriendEvents"] = {
        id = "currentFriendEvents",
        offset = 0x8A8,
        optional = false,
        tracked = true,
        type = "Array",
        elements = currentFriendEventElements,
    }, -- CurrentFriendEvent
    ["nextBonusLevelRank"] = {
        id = "nextBonusLevelRank",
        offset = 0x8C0,
        optional = true,
        tracked = true,
        type = "Float" -- was Object; dump: float nextbonuslevelrank_
    },
}
