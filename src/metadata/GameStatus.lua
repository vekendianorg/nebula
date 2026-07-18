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
        optional = false,
        tracked = true,
        type = "String"
    },
    ["playerName"] = {
        offset = 0x38,
        repeated = false,
        optional = false,
        tracked = true,
        type = "String"
    },
    ["flag"] = {
        offset = 0x40,
        repeated = false,
        optional = true,
        tracked = true,
        type = "String"
    },
    ["coins"] = {
        offset = 0x48,
        repeated = false,
        optional = true,
        tracked = true,
        type = "Int32"
    },
    ["totalCoinsEarned"] = {
        offset = 0x4C,
        repeated = false,
        optional = true,
        tracked = true,
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
        offset = 0x70, -- Timerise
        repeated = true,
        type = "Object"
    },  -- MissionStatus
    ["activeLevelMissions"] = {
        offset = 0x80, -- Timerise
        repeated = true,
        type = "Object"
    },  -- MissionStatusMap
    ["qualifyBests"] = {
        offset = 0xA0,
        repeated = true,
        type = "Object"
    },  -- QualifyTime
    ["vehicleStatus"] = {
        offset = 0xB8,
        repeated = true,
        type = "Object"
    },  -- VehicleStatus
    ["totalChampionshipPoints"] = {
        offset = 0xD0,
        repeated = false,
        type = "Int32"
    },
    ["currentDailyBestPoints"] = {
        offset = 0xD4,
        repeated = false,
        type = "Int32"
    },
    ["dailyBestPoints"] = {
        offset = 0xD8,
        repeated = true,
        type = "Object"
    },  -- RacePoints
    ["tournamentRaceBests"] = {
        offset = 0xF0,
        repeated = true,
        type = "Object"
    },  -- LeaderboardItemData
    ["activeTournaments"] = {
        offset = 0x108,
        repeated = true,
        type = "Object"
    },  -- TournamentPlayerStatus
    ["diamonds"] = {
        offset = 0x120,
        repeated = false,
        type = "Int32"
    },
    ["ladderPoints"] = {
        offset = 0x124,
        repeated = false,
        type = "Int32"
    },
    ["playerXp"] = {
        offset = 0x128,
        repeated = false,
        type = "Int32"
    },
    ["dailyMissionsFilledTimeStamp"] = {
        offset = 0x12C,
        repeated = false,
        type = "Int32"
    },
    ["dailyMissionChangesFilledTimeStamp"] = {
        offset = 0x130,
        repeated = false,
        type = "Int32"
    },
    ["availableDailyMissionChanges"] = {
        offset = 0x134,
        repeated = false,
        type = "Int32"
    },
    ["completedDailyMissions"] = {
        offset = 0x138,
        repeated = true,
        type = "Object"
    },  -- MissionStatus
    ["activeDailyMissions"] = {
        offset = 0x150,
        repeated = true,
        type = "Object"
    },  -- MissionStatus
    ["driver"] = {
        offset = 0x168,
        repeated = false,
        type = "Object"
    }, -- DriverCustomization
    ["levelStars"] = {
        offset = 0x170,
        repeated = true,
        type = "Object"
    },  -- StringIntMap
    ["unlocks"] = {
        offset = 0x188,
        repeated = true,
        type = "Object"
    },  -- Unlock
    ["chips"] = {
        offset = 0x1A0,
        repeated = false,
        type = "Int32"
    },
    ["totalAirtime"] = {
        offset = 0x1A4,
        repeated = false,
        type = "Int32"
    },
    ["totalWheelieTime"] = {
        offset = 0x1A8,
        repeated = false,
        type = "Int32"
    },
    ["totalRacesFinished"] = {
        offset = 0x1AC,
        repeated = false,
        type = "Int32"
    },
    ["myDivisions"] = {
        offset = 0x1B0,
        repeated = true,
        type = "Object"
    },  -- StringIntMap
    ["selectedLevel"] = {
        offset = 0x1C8,
        repeated = false,
        type = "Int32"
    },
    ["WCRank"] = {
        offset = 0x1CC,
        repeated = false,
        optional = true,
        type = "Float"
    },
    ["ownedWorlds"] = {
        offset = 0x1D0,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["AllowedLevelTier"] = {
        offset = 0x1E8,
        repeated = false,
        type = "Int32"
    },
    ["totalDistanceStarts"] = {
        offset = 0x1EC,
        repeated = false,
        type = "Int32"
    },
    ["totalRaceStarts"] = {
        offset = 0x1F0,
        repeated = false,
        type = "Int32"
    },
    ["totalRaceVictories"] = {
        offset = 0x1F4,
        repeated = false,
        type = "Int32"
    },
    ["rewardManagerStatus"] = {
        offset = 0x1F8,
        repeated = false,
        type = "Object"
    },
    ["maxWCRank"] = {
        offset = 0x200,
        repeated = false,
        type = "Float"
    },
    ["nextFreeUpgradeTimestamp"] = {
        offset = 0x204,
        repeated = false,
        type = "Int32"
    },
    ["unlockedRaces"] = {
        offset = 0x208,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
        ["totalTime"] = {
        offset = 0x238,
        repeated = false,
        type = "Int32"
    },
    ["unlockedVehicles"] = {
        offset = 0x220,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["totalGemsEarned"] = {
        offset = 0x23C,
        repeated = false,
        type = "Int32"
    },
    ["recentChallenges"] = {
        offset = 0x240,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["achievements"] = {
        offset = 0x258,
        repeated = true,
        type = "Achievement"
    },
    ["totalCupVictories"] = {
        offset = 0x270,
        repeated = false,
        type = "Int32"
    },
    ["cloudSaveVersion"] = {
        offset = 0x274,
        repeated = false,
        type = "Int32"
    },  -- NOTE: was 0x540, but live test returned -1179343104 (implausible for a version counter). Reverted to unverified pending re-check.
    ["ratingsAsked"] = {
        offset = 0x278,
        repeated = false,
        type = "Int32"
    },
    ["ratingEventCounter"] = {
        offset = 0x27C,
        repeated = false,
        type = "Int32"
    },
    ["tutorialState"] = {
        offset = 0x280,
        repeated = false,
        type = "Int32"
    },
    ["totalCupsFinished"] = {
        offset = 0x284,
        repeated = false,
        type = "Int32"
    },
    ["adFree"] = {
        offset = 0x3DC,
        repeated = false,
        type = "Bool"
    },
    ["purchasedSpecialOffers"] = {
        offset = 0x288,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["teamId"] = {
        offset = 0x2A0,
        repeated = false,
        type = "String"
    },
    ["activeFriendlyRaces"] = {
        offset = 0x2A8,
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
        offset = 0x2C8,
        repeated = false,
        type = "String"
    },
    ["currentSpecialEventId"] = {
        offset = 0x2D8,
        repeated = false,
        type = "String"
    },
    ["contentVersion"] = {
        offset = 0x300,
        repeated = false,
        type = "Int32"
    },
    ["seasonStatus"] = {
        offset = 0x2E0,
        repeated = false,
        type = "Object"
    },  -- SeasonStatus
    ["purchasedIaps"] = {
        offset = 0x2E8,
        repeated = true,
        type = "Object"
    },  -- IapPurchaseEvent
    ["acsPlayerGuid"] = {
        offset = 0x308,
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
        offset = 0x314,
        repeated = false,
        type = "Float"
    },
    ["nameChanges"] = {
        offset = 0x318,
        repeated = false,
        type = "Int32"
    },
    ["nextFreeTuningPartUpgradeTimestamp"] = {
        offset = 0x31C,
        repeated = false,
        type = "Int32"
    },
    ["activeEventStatus"] = {
        offset = 0x320,
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
        offset = 0x330,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["nextVehicleChestTimestamp"] = {
        offset = 0x348,
        repeated = false,
        type = "Int32"
    },
    ["vehicleChestsPurchased"] = {
        offset = 0x34C,
        repeated = false,
        type = "Int32"
    },
    ["gachaNewVehicleCounter"] = {
        offset = 0x368,
        repeated = false,
        type = "Int32"
    },
    ["purchasedPopupOffers"] = {
        offset = 0x350,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["activePopupOffer"] = {
        offset = 0x370,
        repeated = false,
        type = "String"
    },
    ["activePopupOfferEndTimestamp"] = {
        offset = 0x36C,
        repeated = false,
        type = "Int32"
    },
    ["expiredPopupOffers"] = {
        offset = 0x378,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["pendingChests"] = {
        offset = 0x390,
        repeated = true,
        type = "Object"
    },  -- PendingChest
    ["libHash"] = {
        offset = 0x3B0,
        repeated = false,
        type = "Int32"
    },
    ["vipStatus"] = {
        offset = 0x3A8,
        repeated = false,
        type = "Object"
    },
    ["totalEventsJoined"] = {
        offset = 0x3B4,
        repeated = false,
        type = "Int32"
    },
    ["totalEventPoints"] = {
        offset = 0x3B8,
        repeated = false,
        type = "Int32"
    },
    ["totalEventRaces"] = {
        offset = 0x3BC,
        repeated = false,
        type = "Int32"
    },
    ["totalEarnedTickets"] = {
        offset = 0x3C0,
        repeated = false,
        type = "Int32"
    },
    ["totalSpentTickets"] = {
        offset = 0x3C4,
        repeated = false,
        type = "Int32"
    },
    ["device"] = {
        offset = 0x3C8,
        repeated = false,
        type = "String"
    },
    ["os"] = {
        offset = 0x3D0,
        repeated = false,
        type = "String"
    },
    ["totalEventRacesWon"] = {
        offset = 0x3D8,
        repeated = false,
        type = "Int32"
    },
    ["rentedVehicles"] = {
        offset = 0x3E0,
        repeated = true,
        type = "Object"
    },  -- RentalStatus
    ["unlockedWorlds"] = {
        offset = 0x3F8,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["segmentId"] = {
        offset = 0x410,
        repeated = false,
        type = "String"
    },
    ["playerSegments"] = {
        offset = 0x418,
        repeated = false,
        type = "String"
    },
    ["checkinReward"] = {
        offset = 0x420,
        repeated = false,
        type = "Object"
    },  -- CheckinReward
    ["seasonRank"] = {
        offset = 0x428,
        repeated = false,
        type = "Float"
    },
    ["totalSeasonRank"] = {
        offset = 0x42C,
        repeated = false,
        type = "Float"
    },
    ["bestSeasonRank"] = {
        offset = 0x438,
        repeated = false,
        type = "Float"
    },
    ["currentSeasonId"] = {
        offset = 0x430,
        repeated = false,
        type = "String"
    },
    ["totalEventRaceStarts"] = {
        offset = 0x43C,
        repeated = false,
        type = "Int32"
    },
    ["createTimestamp"] = {
        offset = 0x458,
        repeated = false,
        type = "Int32"
    },
    ["deals"] = {
        offset = 0x440,
        repeated = true,
        type = "Object"
    },  -- DealStatus
    ["scrap"] = {
        offset = 0x45C,
        repeated = false,
        type = "Int32"
    },
    ["scrapperStatus"] = {
        offset = 0x460,
        repeated = false,
        type = "Object"
    },  -- ScrapperStatus
    ["totalScrapEarned"] = {
        offset = 0x480,
        repeated = false,
        type = "Int32"
    },
    ["oldSeasons"] = {
        offset = 0x468,
        repeated = true,
        type = "Object"
    },  -- SeasonStatus
    ["targetedAdsConsent"] = {
        offset = 0x484,
        repeated = false,
        type = "Int32"
    },
    ["acceptedEulaVersion"] = {
        offset = 0x4A8,
        repeated = false,
        type = "Int32"
    },
    ["activePopupOffers"] = {
        offset = 0x488,
        repeated = true,
        type = "Object"
    },  -- ActivePopupOffer
    ["activeTeamEventStatus"] = {
        offset = 0x4A0,
        repeated = false,
        type = "Object"
    },  -- EventStatus
    ["teamStatus"] = {
        offset = 0x4B0,
        repeated = false,
        type = "Object"
    },  -- TeamStatus
    ["specialTickets"] = {
        offset = 0x4AC,
        repeated = false,
        type = "Int32"
    },
    ["totalEarnedSpecialTickets"] = {
        offset = 0x4B8,
        repeated = false,
        type = "Int32"
    },
    ["totalSpentSpecialTickets"] = {
        offset = 0x4BC,
        repeated = false,
        type = "Int32"
    },
    ["kickedTeamStatus"] = {
        offset = 0x4C0,
        repeated = false,
        type = "Object"
    },  -- KickedTeamStatus
    ["teamEventOfferShown"] = {
        offset = 0x4C8,
        repeated = false,
        type = "String"
    },
    ["weeklyEventOfferShown"] = {
        offset = 0x4D0,
        repeated = false,
        type = "String"
    },
    ["playerNameApprovalState"] = {
        offset = 0x4F0,
        repeated = false,
        type = "Int32",
        enum = "PlayerNameApprovalState"
    },
    ["distanceTickets"] = {
        offset = 0x4D8,
        repeated = true,
        type = "Object"
    },  -- DistanceTicket
    ["previousEventStatuses"] = {
        offset = 0x4F8,
        repeated = true,
        type = "Object"
    },  -- EventStatus
    ["garagePower"] = {
        offset = 0x4F4,
        repeated = false,
        type = "Int32"
    },
    ["premiumWCUnlocked"] = {
        offset = 0x3DE,
        repeated = false,
        type = "Bool"
    },
    ["receivedWCRewards"] = {
        offset = 0x510,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["animatedWCRank"] = {
        offset = 0x528,
        repeated = false,
        type = "Float"
    },
    ["adventurerRank"] = {
        offset = 0x52C,
        repeated = false,
        type = "Int32"
    },  -- NOTE: proto type is float, legacy metadata had Int32 -- verify before use
    ["receivedAdventurerRewards"] = {
        offset = 0x530,
        repeated = true,
        type = "Object"
    },  -- repeated int32, needs array support
    ["secret"] = {
        offset = 0x540,
        repeated = false,
        type = "String"
    },
    ["animatedAdventurerRank"] = {
        offset = 0x568,
        repeated = false,
        type = "Float"
    },
    ["banData"] = {
        offset = 0x548,
        repeated = true,
        type = "Object"
    },  -- BanData
    ["banReviewed"] = {
        offset = 0x3DF,
        repeated = false,
        type = "Bool"
    },
    ["teamSeasonStatus"] = {
        offset = 0x560,
        repeated = false,
        type = "Object"
    },  -- TeamSeasonStatus
    ["nonRewardedTeamSeasons"] = {
        offset = 0x570,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["activeDailyBonusTasks"] = {
        offset = 0x588,
        repeated = true,
        type = "Object"
    },  -- DailyTask
    ["activeDailyTasks"] = {
        offset = 0x5A0,
        repeated = true,
        type = "Object"
    },  -- DailyTask
    ["nextDailyTaskTimeStamp"] = {
        offset = 0x56C,
        repeated = false,
        type = "Int32"
    },
    ["nextDailyTaskRerollTimeStamp"] = {
        offset = 0x5B8,
        repeated = false,
        type = "Int32"
    },
    ["dailyTaskRerollsRemaining"] = {
        offset = 0x5BC,
        repeated = false,
        type = "Int32"
    },
    ["shownGDPRVersion"] = {
        offset = 0x5C0,
        repeated = false,
        type = "Int32"
    },
    ["dailyTaskRerollsWithVideoRemaining"] = {
        offset = 0x5C4,
        repeated = false,
        type = "Int32"
    },
    ["pendingofferid"] = {
        offset = 0x5C8,
        repeated = false,
        type = "String"
    },
    ["pendingOfferIds"] = {
        offset = 0x5D0,
        repeated = true,
        type = "Object"
    },  -- IapPurchaseEvent
    ["dailyTaskRefillsRemaining"] = {
        offset = 0x5E8,
        repeated = true,
        type = "Object"
    },  -- repeated int32, needs array support
    ["currencies"] = {
        offset = 0x5F8,
        repeated = true,
        type = "Object"
    },  -- Currency
    ["publishedLevels"] = {
        offset = 0x610,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["featuredChallenges"] = {
        offset = 0x628,
        repeated = true,
        type = "Object"
    },  -- FeaturedChallenge
    ["featuredChallengeIndex"] = {
        offset = 0x640,
        repeated = false,
        type = "Int32"
    },
    ["nextFreeFeaturedChallengeTimestamp"] = {
        offset = 0x644,
        repeated = false,
        type = "Int32"
    },
    ["lastPlayerNameChangedTimestamp"] = {
        offset = 0x6A8,
        repeated = false,
        type = "Int32"
    },
    ["firstPlayerNameChange"] = {
        offset = 0x754,
        repeated = false,
        type = "Bool"
    },
    ["distanceCollectibles"] = {
        offset = 0x648,
        repeated = true,
        type = "Object"
    },  -- DistanceCollectibleStatus
    ["activeCommunityEventStatus"] = {
        offset = 0x660,
        repeated = false,
        type = "Object"
    },  -- EventStatus
    ["currentPublicLevels"] = {
        offset = 0x668,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["unlockedEditorThemes"] = {
        offset = 0x680,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["FSHomeProfileID"] = {
        offset = 0x698,
        repeated = false,
        type = "String"
    },
    ["home"] = {
        offset = 0x6A0,
        repeated = false,
        type = "Object"
    },  -- Home
    ["ownedHomeProps"] = {
        offset = 0x6B0,
        repeated = true,
        type = "Object"
    },  -- HomeCosmeticsOwnership
    ["ownedHomeBackgrounds"] = {
        offset = 0x6C8,
        repeated = true,
        type = "Object"
    },  -- HomeCosmeticsOwnership
    ["megaAdChestRewards"] = {
        offset = 0x6E0,
        repeated = true,
        type = "Object"
    },  -- MegaAdChestRewardStatus
    ["activeLeagueTasks"] = {
        offset = 0x6F8,
        repeated = true,
        type = "Object"
    },  -- LeagueTask
    ["communityEvent"] = {
        offset = 0x710,
        repeated = false,
        type = "Object"
    },
    ["masteryBonusXp"] = {
        offset = 0x718,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeIntStaticKey"] = {
        offset = 0x6AC,
        repeated = false,
        type = "Int32"
    },
    ["adFreeEndTimestamp"] = {
        offset = 0x720,
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
        offset = 0x750,
        repeated = false,
        type = "Int32"
    },
    ["safeUnlocks"] = {
        offset = 0x740,
        repeated = false,
        type = "SafeInt32"
    },
    ["safeUnlockedVehicles"] = {
        offset = 0x748,
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
        offset = 0x755,
        repeated = false,
        type = "Bool"
    },
    ["rankedCupOngoing"] = {
        offset = 0x756,
        repeated = false,
        type = "Bool"
    },
    ["rankedCupVehicle"] = {
        offset = 0x778,
        repeated = false,
        type = "String"
    },
    ["supportHmac"] = {
        offset = 0x780,
        repeated = false,
        type = "String"
    },
    ["megaAdChestProgress"] = {
        offset = 0x788,
        repeated = true,
        type = "Object"
    },  -- MegaAdChestProgress
    ["signatureChallengeId"] = {
        offset = 0x7A0,
        repeated = false,
        type = "String"
    },
    ["activeTutorialVersion"] = {
        offset = 0x7C0,
        repeated = false,
        type = "Int32"
    },
    ["adviews"] = {
        offset = 0x7A8,
        repeated = true,
        type = "Object"
    },  -- AdViewsMap
    ["premiumTierWCUnlocked"] = {
        offset = 0x7C4,
        repeated = false,
        type = "Int32"
    },
    ["premiumProgressWCClaimed"] = {
        offset = 0x757,
        repeated = false,
        type = "Bool"
    },
    ["currentGachaProgress"] = {
        offset = 0x7C8,
        repeated = false,
        type = "Object"
    },  -- CurrentGachaProgress
    ["claimedResearchRewardAmount"] = {
        offset = 0x7D0,
        repeated = true,
        type = "SafeInt32"
    },
    ["claimedResearchDonationAmount"] = {
        offset = 0x7E8,
        repeated = false,
        type = "SafeInt32"
    },
    ["currentFriendEvent"] = {
        offset = 0x7F0,
        repeated = false,
        type = "Object"
    },  -- CurrentFriendEvent
    ["teamDonationTrack"] = {
        offset = 0x808,
        repeated = false,
        type = "Int32"
    },
    ["displayedInfoPopups"] = {
        offset = 0x7F8,
        repeated = true,
        type = "Object"
    },  -- repeated int32, needs array support
    ["teamSupportChestTransactions"] = {
        offset = 0x810,
        repeated = true,
        type = "Object"
    },  -- repeated string, needs array support
    ["showOnlineStatus"] = {
        id = "showOnlineStatus",
        offset = 0x80C,
        repeated = false,
        optional = true,
        tracked = true,
        type = "Bool"
    },
    ["eventPointUnlockVehicle"] = {
        id = "eventPointUnlockVehicle",
        offset = 0x828,
        repeated = false,
        optional = true,
        tracked = true,
        type = "String"
    },
    ["eventPointUnlockProgress"] = {
        id = "eventPointUnlockProgress",
        offset = 0x860,
        repeated = false,
        optional = true,
        tracked = true,
        type = "Int32"
    },
    ["purchasedIapGifts"] = {
        id = "purchasedIapGifts",
        offset = 0x830,
        repeated = true,
        optional = false,
        tracked = false,
        type = "Object" -- repeated_ptr String
    },
    ["claimedInboxMessages"] = {
        id = "claimedInboxMessages",
        offset = 0x848,
        repeated = true,
        optional = false,
        tracked = false,
        type = "Object" -- repeated_ptr String
    },
    ["currentWinStreakAdRestores"] = {
        id = "currentWinStreakAdRestores",
        offset = 0x868,
        repeated = false,
        optional = true,
        tracked = true,
        type = "SafeInt32"
    },
    ["winStreakSpecialShield"] = {
        id = "winStreakSpecialShield",
        offset = 0x864,
        repeated = false,
        optional = true,
        tracked = true,
        type = "Int32"
    },
    ["winStreakEvent"] = {
        id = "winStreakEvent",
        offset = 0x870,
        repeated = false,
        optional = true,
        tracked = true,
        type = "Object"
    }, --WinStreakEvent
    ["activeTriggers"] = {
        id = "activeTriggers",
        offset = 0x878,
        repeated = true,
        optional = false,
        tracked = true,
        type = "Object"
    }, -- ActiveTrigger
    ["previousPlayerIds"] = {
        id = "previousPlayerIds",
        offset = 0x890,
        repeated = false,
        optional = true,
        tracked = true,
        type = "Object"
    }, -- String
    ["currentFriendEvents"] = {
        id = "currentFriendEvents",
        offset = 0x8A8,
        repeated = true,
        optional = false,
        tracked = true,
        type = "Object"
    }, -- CurrentFriendEvent
    ["nextBonusLevelRank"] = {
        id = "nextBonusLevelRank",
        offset = 0x8C0,
        repeated = false,
        optional = true,
        tracked = true,
        type = "Object"
    },
}
