--==================================================
-- metadata/GameStatus.lua
--==================================================
-- Field table for the top-level GameStatus proto2 message.
-- Sourced from descriptor.proto (field numbers / proto types)
-- cross-referenced with known offsets from the legacy flat
-- GameStatus.lua and account.lua ops.
--
-- offset = 0xBAAD means the offset is NOT YET KNOWN. Do not
-- trust these fields until the placeholder is replaced by a
-- verified static offset.
--
-- type = "Object" marks single nested message fields that
-- need their own elements metadata before Nebula can read/write
-- them structurally.
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
    ["previousSeasonBest"] = { offset = 0x28, type = "Float" },
    ["previousSeasons"] = {
        offset = 0x2C,
        type = "Array",
        elements = seasonResultElements,
    },
    ["currentSeasonBest"] = { offset = 0x40, type = "Float" },
}

local timeTrialHighscoreElements = {
    ["levelId"] = { offset = 0x18, type = "String" },
    ["time"] = { offset = 0x20, type = "Float" },
    ["previousSeasonBest"] = { offset = 0x28, type = "Float" },
    ["previousSeasons"] = {
        offset = 0x2C,
        type = "Array",
        elements = seasonResultElements,
    },
    ["currentSeasonBest"] = { offset = 0x40, type = "Float" },
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- MissionStatus
    ["activeLevelMissions"] = {
        offset = 0x80, -- Timerise
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- MissionStatusMap
    ["qualifyBests"] = {
        offset = 0xA0,
        type = "Array",  -- placeholder: element layout not yet mapped
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
                    offset = 0xBAAD,
                    type = "Array",
                    elements = stringIntMapElements,
                },
                ["levelDivisionMedals"] = {
                    offset = 0xBAAD,
                    type = "Array",
                    elements = stringIntMapElements,
                },
                ["flips"] = { offset = 0xBAAD, type = "Int32" },
                ["backflips"] = { offset = 0xBAAD, type = "Int32" },
                ["neckflips"] = { offset = 0xBAAD, type = "Int32" },
                ["airtime"] = { offset = 0x54, type = "Float" },
                ["wheelieTime"] = { offset = 0x58, type = "Float" },
                ["racesFinished"] = { offset = 0xBAAD, type = "Int32" },
                ["racesWon"] = { offset = 0xBAAD, type = "Int32" },
                ["totalDistance"] = { offset= 0x64, type = "Int32" },
                ["challengesWon"] = { offset = 0xBAAD, type = "Int32" },
                ["featuredChallengesWon"] = { offset = 0xBAAD, type = "Int32" },
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
                offset = 0xBAAD,
                type = "Array",
                elements = distanceHighscoreElements,
            },
            ["timeTrialHighscores"] = {
                offset = 0xBAAD,
                type = "Array",
                elements = timeTrialHighscoreElements,
            },
            ["unlockedEquipSlotsCount"] = { offset = 0xBAAD, type = "Int32" },
            ["newDistanceHighscores"] = {
                offset = 0xB8,
                type = "Array",
                elements = distanceHighscoreElements,
            },
            ["newTimeTrialHighscores"] = {
                offset = 0xBAAD,
                type = "Array",
                elements = timeTrialHighscoreElements,
            },
            ["distanceTarget"] = {
                offset = 0xBAAD,
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
                offset = 0xBAAD,
                type = "SafeInt32",
            },
            ["currentVehicleWinStreak"] = {
                offset = 0xBAAD,
                type = "Int32",
            },
            ["bestVehicleWinStreak"] = {
                offset = 0xBAAD,
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- RacePoints
    ["tournamentRaceBests"] = {
        offset = 0xF0,
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- LeaderboardItemData
    ["activeTournaments"] = {
        offset = 0x108,
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- MissionStatus
    ["activeDailyMissions"] = {
        offset = 0x150,
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Object"
    },
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
        type = "Array",  -- placeholder: element layout not yet mapped
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
        offset = 0xBAAD,
        type = "String"
    },
    ["deviceHash"] = {
        offset = 0x2C8,
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
        type = "Object"
    },  -- SeasonStatus
    ["purchasedIaps"] = {
        offset = 0x2E8,
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Object"
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
        type = "Array",  -- placeholder: element layout not yet mapped
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
        ["manuallyEnabled"] = { offset = 0x2E, type = "Bool" }
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
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Object"
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- DealStatus
    ["scrap"] = {
        offset = 0x45C,
        type = "Int32"
    },
    ["scrapperStatus"] = {
        offset = 0x460,
        type = "Object"
    },  -- ScrapperStatus
    ["totalScrapEarned"] = {
        offset = 0x480,
        type = "Int32"
    },
    ["oldSeasons"] = {
        offset = 0x468,
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- ActivePopupOffer
    ["activeTeamEventStatus"] = {
        offset = 0x4A0,
        type = "Object"
    },  -- EventStatus
    ["teamStatus"] = {
        offset = 0x4B0,
        type = "Object"
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
        type = "Object"
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- DistanceTicket
    ["previousEventStatuses"] = {
        offset = 0x4F8,
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- BanData
    ["banReviewed"] = {
        offset = 0x3DF,
        type = "Bool"
    },
    ["teamSeasonStatus"] = {
        offset = 0x560,
        type = "Object"
    },  -- TeamSeasonStatus
    ["nonRewardedTeamSeasons"] = {
        offset = 0x570,
        type = "Array",
        elementType = "String",
    },
    ["activeDailyBonusTasks"] = {
        offset = 0x588,
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- DailyTask
    ["activeDailyTasks"] = {
        offset = 0x5A0,
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- IapPurchaseEvent
    ["dailyTaskRefillsRemaining"] = {
        offset = 0x5E8,
        type = "Array",
        elementType = "Int32",
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
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- DistanceCollectibleStatus
    ["activeCommunityEventStatus"] = {
        offset = 0x660,
        type = "Object"
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
        type = "Object"
    },  -- Home
    ["ownedHomeProps"] = {
        offset = 0x6B0,
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- HomeCosmeticsOwnership
    ["ownedHomeBackgrounds"] = {
        offset = 0x6C8,
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- HomeCosmeticsOwnership
    ["megaAdChestRewards"] = {
        offset = 0x6E0,
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- MegaAdChestRewardStatus
    ["activeLeagueTasks"] = {
        offset = 0x6F8,
        type = "Array",  -- placeholder: element layout not yet mapped
    },  -- LeagueTask
    ["communityEvent"] = {
        offset = 0x710,
        type = "Object"
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
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Array",  -- placeholder: element layout not yet mapped
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
        type = "Object"
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
        type = "Object"
    },  -- CurrentFriendEvent
    ["teamDonationTrack"] = {
        offset = 0x808,
        type = "Int32"
    },
    ["displayedInfoPopups"] = {
        offset = 0x7F8,
        type = "Array",
        elementType = "Int32",
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
        type = "Object"
    }, --WinStreakEvent
    ["activeTriggers"] = {
        id = "activeTriggers",
        offset = 0x878,
        optional = false,
        tracked = true,
        type = "Array",  -- placeholder: element layout not yet mapped
    }, -- ActiveTrigger
    ["previousPlayerIds"] = {
        id = "previousPlayerIds",
        offset = 0x890,
        optional = true,
        tracked = true,
        type = "Object"
    }, -- String
    ["currentFriendEvents"] = {
        id = "currentFriendEvents",
        offset = 0x8A8,
        optional = false,
        tracked = true,
        type = "Array",  -- placeholder: element layout not yet mapped
    }, -- CurrentFriendEvent
    ["nextBonusLevelRank"] = {
        id = "nextBonusLevelRank",
        offset = 0x8C0,
        optional = true,
        tracked = true,
        type = "Object"
    },
}
