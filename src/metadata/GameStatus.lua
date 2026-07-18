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
-- type = "Object" marks repeated/message fields that need
-- their own nested metadata + Object type before Nebula can
-- read/write them structurally. api/GameStatus.lua rejects
-- get/set for these until Object.lua exists.
--
-- SafeInt32 fields: `offset` points to a POINTER to the
-- struct (not an inline struct). The static XOR key is
-- fixed account-wide at safeIntStaticKey and resolved
-- internally by core/types/SafeInt32.lua — no per-field
-- staticKeyOffset needed.

return {
    ["playerId"] = {
        offset = 0x30,
        repeated = false,
        type = "String"
    },
    ["playerName"] = {
        offset = 0x38,
        repeated = false,
        type = "String"
    },
    ["flag"] = {
        offset = 0x40,
        repeated = false,
        type = "String"
    },
    ["coins"] = {
        offset = 0x48,
        repeated = false,
        type = "Int32"
    },
    ["totalCoinsEarned"] = {
        offset = 0x4C,
        repeated = false,
        type = "Int32"
    },
    ["totalNeckFlips"] = {
        offset = 0x50,
        repeated = false,
        type = "Int32"
    },
    ["totalBackFlips"] = {
        offset = 0x54,
        repeated = false,
        type = "Int32"
    },
    ["totalFlips"] = {
        offset = 0x58,
        repeated = false,
        type = "Int32"
    },
    ["totalFuelCanistersCollected"] = {
        offset = 0x5C,
        repeated = false,
        type = "Int32"
    },
    ["totalCoinsCollected"] = {
        offset = 0x60,
        repeated = false,
        type = "Int32"
    },
    ["totalDistance"] = {
        offset = 0x64,
        repeated = false,
        type = "Float"
    },
    ["totalPlayTime"] = {
        offset = 0x68,
        repeated = false,
        type = "Float"
    },
    ["lastRaceTimestamp"] = {
        offset = 0x6C,
        repeated = false,
        type = "Float"
    },
    ["completedMissions"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- MissionStatus
    ["activeLevelMissions"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- MissionStatusMap
    ["qualifyBests"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- QualifyTime
    ["vehicleStatus"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- VehicleStatus
    ["totalChampionshipPoints"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["currentDailyBestPoints"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["dailyBestPoints"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- RacePoints
    ["tournamentRaceBests"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- LeaderboardItemData
    ["activeTournaments"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- TournamentPlayerStatus
    ["diamonds"] = {
        offset = 0x120,
        repeated = false,
        type = "Int32"
    },
    ["ladderPoints"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["playerXp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["dailyMissionsFilledTimeStamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["dailyMissionChangesFilledTimeStamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["availableDailyMissionChanges"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["completedDailyMissions"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- MissionStatus
    ["activeDailyMissions"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- MissionStatus
    ["driver"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    }, -- DriverCustomization
    ["levelStars"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- StringIntMap
    ["unlocks"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- Unlock
    ["chips"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalAirtime"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalWheelieTime"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalRacesFinished"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["myDivisions"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- StringIntMap
    ["selectedLevel"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["WCRank"] = {
        offset = 0x1CC,
        repeated = false,
        type = "Float"
    },
    ["ownedWorlds"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["AllowedLevelTier"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalDistanceStarts"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalRaceStarts"] = {
        offset = 0x238,
        repeated = false,
        type = "Int32"
    },
    ["totalRaceVictories"] = {
        offset = 0x1F4,
        repeated = false,
        type = "Int32"
    },
    ["rewardManagerStatus"] = {
        offset = 0x350,
        repeated = false,
        type = "Object"
    },
    ["maxWCRank"] = {
        offset = 0x200,
        repeated = false,
        type = "Float"
    },
    ["nextFreeUpgradeTimestamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["unlockedRaces"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["totalTime"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["unlockedVehicles"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["totalGemsEarned"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["recentChallenges"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["achievements"] = {
        offset = 0x258,
        repeated = true,
        type = "Achievement"
    },
    ["totalCupVictories"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["cloudSaveVersion"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },  -- NOTE: was 0x540, but live test returned -1179343104 (implausible for a version counter). Reverted to unverified pending re-check.
    ["ratingsAsked"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["ratingEventCounter"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["tutorialState"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalCupsFinished"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["adFree"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Bool"
    },
    ["purchasedSpecialOffers"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["teamId"] = {
        offset = 0x2A0,
        repeated = false,
        type = "String"
    },
    ["activeFriendlyRaces"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- FriendlyRace
    ["cheater"] = {
        offset = 0x3DD,
        repeated = false,
        type = "Bool"
    },
    ["currentCupId"] = {
        offset = 0x2C0,
        repeated = false,
        type = "String"
    },
    ["deviceSignature"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["deviceHash"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["currentSpecialEventId"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["contentVersion"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["seasonStatus"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- SeasonStatus
    ["purchasedIaps"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- IapPurchaseEvent
    ["acsPlayerGuid"] = {
        offset = 0x2C8,
        repeated = false,
        type = "String"
    },
    ["challengesWon"] = {
        offset = 0x304,
        repeated = false,
        type = "Int32"
    },
    ["featuredChallengesWon"] = {
        offset = 0x310,
        repeated = false,
        type = "Int32"
    },
    ["totalRank"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Float"
    },
    ["nameChanges"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["nextFreeTuningPartUpgradeTimestamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["activeEventStatus"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- EventStatus
    ["flags"] = {
        offset = 0x328,
        repeated = false,
        type = "BitMask",
        enum = "GameStatusFlag"
    },
    ["ownedVehicles"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["nextVehicleChestTimestamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["vehicleChestsPurchased"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["gachaNewVehicleCounter"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["purchasedPopupOffers"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["activePopupOffer"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["activePopupOfferEndTimestamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["expiredPopupOffers"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["pendingChests"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- PendingChest
    ["libHash"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["vipStatus"] = {
        offset = 0x3A8,
        repeated = false,
        type = "Object"
    },
    ["totalEventsJoined"] = {
        offset = 0x3B0,
        repeated = false,
        type = "Int32"
    },
    ["totalEventPoints"] = {
        offset = 0x3B4,
        repeated = false,
        type = "Int32"
    },
    ["totalEventRaces"] = {
        offset = 0x3B8,
        repeated = false,
        type = "Int32"
    },
    ["totalEarnedTickets"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalSpentTickets"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["device"] = {
        offset = 0x3C0,
        repeated = false,
        type = "String"
    },
    ["os"] = {
        offset = 0x3D0,
        repeated = false,
        type = "String"
    },
    ["totalEventRacesWon"] = {
        offset = 0x3CC,
        repeated = false,
        type = "Int32"
    },
    ["rentedVehicles"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- RentalStatus
    ["unlockedWorlds"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["segmentId"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["playerSegments"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["checkinReward"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- CheckinReward
    ["seasonRank"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Float"
    },
    ["totalSeasonRank"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Float"
    },
    ["bestSeasonRank"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Float"
    },
    ["currentSeasonId"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["totalEventRaceStarts"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["createTimestamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["deals"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- DealStatus
    ["scrap"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["scrapperStatus"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- ScrapperStatus
    ["totalScrapEarned"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["oldSeasons"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- SeasonStatus
    ["targetedAdsConsent"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["acceptedEulaVersion"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["activePopupOffers"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- ActivePopupOffer
    ["activeTeamEventStatus"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- EventStatus
    ["teamStatus"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- TeamStatus
    ["specialTickets"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalEarnedSpecialTickets"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["totalSpentSpecialTickets"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["kickedTeamStatus"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- KickedTeamStatus
    ["teamEventOfferShown"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["weeklyEventOfferShown"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["playerNameApprovalState"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["distanceTickets"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- DistanceTicket
    ["previousEventStatuses"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- EventStatus
    ["garagePower"] = {
        offset = 0x4F4,
        repeated = false,
        type = "Int32"
    },
    ["premiumWCUnlocked"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Bool"
    },
    ["receivedWCRewards"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["animatedWCRank"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Float"
    },
    ["adventurerRank"] = {
        offset = 0x538,
        repeated = false,
        type = "Int32"
    },  -- NOTE: proto type is float, legacy metadata had Int32 -- verify before use
    ["receivedAdventurerRewards"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated int32, needs array support
    ["secret"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["animatedAdventurerRank"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Float"
    },
    ["banData"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- BanData
    ["banReviewed"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Bool"
    },
    ["teamSeasonStatus"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- TeamSeasonStatus
    ["nonRewardedTeamSeasons"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["activeDailyBonusTasks"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- DailyTask
    ["activeDailyTasks"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- DailyTask
    ["nextDailyTaskTimeStamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["nextDailyTaskRerollTimeStamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["dailyTaskRerollsRemaining"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["shownGDPRVersion"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["dailyTaskRerollsWithVideoRemaining"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["pendingofferid"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["pendingOfferIds"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- IapPurchaseEvent
    ["dailyTaskRefillsRemaining"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated int32, needs array support
    ["currencies"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- Currency
    ["publishedLevels"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["featuredChallenges"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- FeaturedChallenge
    ["featuredChallengeIndex"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["nextFreeFeaturedChallengeTimestamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["lastPlayerNameChangedTimestamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["firstPlayerNameChange"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Bool"
    },
    ["distanceCollectibles"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- DistanceCollectibleStatus
    ["activeCommunityEventStatus"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- EventStatus
    ["currentPublicLevels"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["unlockedEditorThemes"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["FSHomeProfileID"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["home"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- Home
    ["ownedHomeProps"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- HomeCosmeticsOwnership
    ["ownedHomeBackgrounds"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- HomeCosmeticsOwnership
    ["megaAdChestRewards"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- MegaAdChestRewardStatus
    ["activeLeagueTasks"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- LeagueTask
    ["communityEvent"] = {
        offset = 0x6E8,
        repeated = false,
        type = "Object"
    },
    ["masteryBonusXp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeIntStaticKey"] = {
        offset = 0x6AC,
        repeated = false,
        type = "Int32"
    },
    ["adFreeEndTimestamp"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeCoins"] = {
        offset = 0x728,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeDiamonds"] = {
        offset = 0x730,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeScrap"] = {
        offset = 0x738,
        repeated = false,
        type = "SafeInt32"
    },
    ["megaAdChestMultiplier"] = {
        offset = 0x740,
        repeated = false,
        type = "Int32"
    },
    ["safeUnlocks"] = {
        offset = 0x748,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeUnlockedVehicles"] = {
        offset = 0x750,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeOwnedVehicles"] = {
        offset = 0x758,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeOwnedWorlds"] = {
        offset = 0x760,
        repeated = false,
        type = "SafeInt32"
    },
    ["currentWinStreak"] = {
        offset = 0x768,
        repeated = false,
        type = "SafeInt32"
    },
    ["bestWinStreak"] = {
        offset = 0x770,
        repeated = false,
        type = "SafeInt32"
    },
    ["pendingWinStreakRestore"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Bool"
    },
    ["rankedCupOngoing"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Bool"
    },
    ["rankedCupVehicle"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["supportHmac"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["megaAdChestProgress"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- MegaAdChestProgress
    ["signatureChallengeId"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "String"
    },
    ["activeTutorialVersion"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["adviews"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- AdViewsMap
    ["premiumTierWCUnlocked"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["premiumProgressWCClaimed"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Bool"
    },
    ["currentGachaProgress"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- CurrentGachaProgress
    ["claimedResearchRewardAmount"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "SafeInt32"
    },
    ["claimedResearchDonationAmount"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "SafeInt32"
    },
    ["currentFriendEvent"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Object"
    },  -- CurrentFriendEvent
    ["teamDonationTrack"] = {
        offset = 0xBAAD,
        repeated = false,
        type = "Int32"
    },
    ["displayedInfoPopups"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated int32, needs array support
    ["teamSupportChestTransactions"] = {
        offset = 0xBAAD,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
}
