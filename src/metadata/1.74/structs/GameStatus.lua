--==================================================
-- metadata/1.74/GameStatus.lua
--==================================================
-- GameStatus metadata — version 1.74
-- Cross-verified against the IL2CPP dump (temp/libcocos2dcpp.cs):
-- GameStatus itself is a protobuf message (Size 0x8c8,
-- exact); all nested element templates below match
-- their dump classes (MissionStatus, SeasonResult,
-- DistanceHighscore, TimeTrialHighscore, IapPurchaseEvent,
-- PendingChest, RentalStatus, DealItem/DealStatus, SeasonStatus,
-- ActivePopupOffer, FriendlyRace, DailyTask, ActiveTrigger,
-- CurrentFriendEvent, BanData, DistanceTicket, FeaturedChallenge,
-- EventStatus, DistanceCollectibleStatus, LevelCollectibleStatus,
-- LeaderboardItemData, TournamentPlayerStatus, RewardStatus, Room,
-- HomeProp, HomeCosmeticsOwnership, MegaAdChest*, LeagueTask,
-- UpgradeStatus, ActiveBooster, VehicleStatus, SafeInt32 — all
-- "Confidence: exact"). Every dump field is mapped; the few
-- remaining header-only entries and any residual placeholders are
-- flagged inline.

-- COMPLETE metadata snapshot for the GameStatus struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). Each file under
-- metadata/GameStatus/ is a full snapshot, not a diff — a new
-- version file is only added when the struct's layout actually
-- changes.
--
-- Field table for the top-level GameStatus proto2 message.
-- Sourced from descriptor.proto (field numbers / proto types)
-- cross-referenced with known offsets from the legacy flat
-- GameStatus.lua and account.lua ops.
--
-- Offsets and element layouts cross-validated against an
-- exact-confidence struct dump of libcocos2dcpp.so
-- (temp/libcocos2dcpp.cs, DWARF-recovered field names). Every
-- previously verified offset matches the dump. The former
-- 0xBAAD placeholders and header-only element templates have been
-- filled from it and will need on-device spot checks before being
-- treated as fully trusted.
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
-- <TemplateName> for struct-element arrays, where <TemplateName>
-- is a dump-named snapshot file under metadata/<Class>/<version>.lua
-- loaded through the manifest (see the template aliases below — no
-- inline element templates live in this file anymore).
-- Placeholder arrays (no elementType/elements) fail gracefully
-- until the element layout is mapped.
--
-- SafeInt32 fields: `offset` points to a POINTER to the
-- struct (not an inline struct). The static XOR key is
-- fixed account-wide at safeIntStaticKey and resolved
-- internally by core/types/SafeInt32.lua — no per-field
-- staticKeyOffset needed.

local Manifest = loadModule("metadata/manifest.lua")

--==================================================
-- Element templates — dump-named snapshot files
--==================================================
-- Every nested element template this snapshot uses lives in its own
-- metadata/<Class>/<version>.lua file, named for the IL2CPP dump /
-- proto class (StringIntMap, MissionStatus, EventStatus, ... — the
-- old inline "stringIntMapElements"-style locals are gone). Aliased
-- locally the same way metadata/1.74/VehicleStatus.lua aliases its
-- templates; Manifest.load() resolves each through the registry and
-- the module cache guarantees a single shared instance.

local StringIntMap              = Manifest.load("StringIntMap")
local MissionStatus             = Manifest.load("MissionStatus")
local MissionStatusMap          = Manifest.load("MissionStatusMap")
local QualifyTime               = Manifest.load("QualifyTime")
local RacePoints                = Manifest.load("RacePoints")
local LeaderboardItemData       = Manifest.load("LeaderboardItemData")
local TournamentPlayerStatus    = Manifest.load("TournamentPlayerStatus")
local RewardStatus              = Manifest.load("RewardStatus")
local FriendlyRace              = Manifest.load("FriendlyRace")
local IapPurchaseEvent          = Manifest.load("IapPurchaseEvent")
local PendingChest              = Manifest.load("PendingChest")
local RentalStatus              = Manifest.load("RentalStatus")
local DealStatus                = Manifest.load("DealStatus")
local SeasonStatus              = Manifest.load("SeasonStatus")
local ActivePopupOffer          = Manifest.load("ActivePopupOffer")
local UpgradeStatus             = Manifest.load("UpgradeStatus")
local ActiveBooster             = Manifest.load("ActiveBooster")
local DistanceTicket            = Manifest.load("DistanceTicket")
local EventStatus               = Manifest.load("EventStatus")
local BanData                   = Manifest.load("BanData")
local DailyTask                 = Manifest.load("DailyTask")
local FeaturedChallenge         = Manifest.load("FeaturedChallenge")
local DistanceCollectibleStatus = Manifest.load("DistanceCollectibleStatus")
local HomeCosmeticsOwnership    = Manifest.load("HomeCosmeticsOwnership")
local MegaAdChestRewardStatus   = Manifest.load("MegaAdChestRewardStatus")
local LeagueTask                = Manifest.load("LeagueTask")
local MegaAdChestProgress       = Manifest.load("MegaAdChestProgress")
local AdViewsMap                = Manifest.load("AdViewsMap")
local ActiveTrigger             = Manifest.load("ActiveTrigger")
local CurrentFriendEvent        = Manifest.load("CurrentFriendEvent")
local Room                      = Manifest.load("Room")
local Unlock                    = Manifest.load("Unlock")
local Achievement               = Manifest.load("Achievement")
local Currency                  = Manifest.load("Currency")

--==================================================
-- Singular submessage members — dump-named snapshots
-- via Object injection
--==================================================
-- Same pattern as vehicleStatsObj in metadata/VehicleStatus/
-- 1.74.lua: each member keeps its own offset/type (POINTER,
-- deref'd at read time) and receives its class snapshot's
-- fields. No inline child layouts live in this file anymore.

local Driver                    = Manifest.load("Driver")
local RewardManagerStatus       = Manifest.load("RewardManagerStatus")
local VipStatus                 = Manifest.load("VipStatus")
local CheckinReward             = Manifest.load("CheckinReward")
local ScrapperStatus            = Manifest.load("ScrapperStatus")
local TeamStatus                = Manifest.load("TeamStatus")
local KickedTeamStatus          = Manifest.load("KickedTeamStatus")
local TeamSeasonStatus          = Manifest.load("TeamSeasonStatus")
local Home                      = Manifest.load("Home")
local CommunityEvent            = Manifest.load("CommunityEvent")
local CurrentGachaProgress      = Manifest.load("CurrentGachaProgress")
local WinStreakEvent            = Manifest.load("WinStreakEvent")
local VehicleStatus             = Manifest.load("VehicleStatus")

return {
    ["playerId"] = {
        offset = 0x30,
        optional = false,
        tracked = true,
        type = "String"},
    ["playerName"] = {
        offset = 0x38,
        optional = false,
        tracked = true,
        type = "String"},
    ["flag"] = {
        offset = 0x40,
        optional = true,
        tracked = true,
        type = "String"},
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
        elements = MissionStatus
    },  -- MissionStatus
    ["activeLevelMissions"] = {
        offset = 0x88, -- was 0x80 (Timerise); dump says 0x88
        type = "Array",
        elements = MissionStatusMap
    },  -- MissionStatusMap
    ["qualifyBests"] = {
        offset = 0xA0,
        type = "Array",
        elements = QualifyTime
    },  -- QualifyTime
    ["vehicleStatus"] = {
        offset = 0xB8,
        type = "Array",
        -- POINTER-slot proto elements; element template chained from
        -- its own snapshot (metadata/1.74/VehicleStatus.lua).
        elements = VehicleStatus
    },
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
        elements = RacePoints
    },  -- RacePoints
    ["tournamentRaceBests"] = {
        offset = 0xF0,
        type = "Array",
        elements = LeaderboardItemData
    },  -- LeaderboardItemData
    ["activeTournaments"] = {
        offset = 0x108,
        type = "Array",
        elements = TournamentPlayerStatus
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
        elements = MissionStatus
    },  -- MissionStatus
    ["activeDailyMissions"] = {
        offset = 0x150,
        type = "Array",
        elements = MissionStatus
    },  -- MissionStatus
    ["driver"] = {
        offset = 0x168,
        type = "Object",
        elements = Driver
    },
    ["levelStars"] = {
        offset = 0x170,
        type = "Array",
        elements = StringIntMap
    },
    ["unlocks"] = {
        offset = 0x188,
        type = "Array",
        elements = Unlock
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
        elements = StringIntMap
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
        elementType = "String"
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
        elements = RewardManagerStatus
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
        elementType = "String"
    },
    ["totalTime"] = {
        offset = 0x238,
        type = "Int32"
    },
    ["unlockedVehicles"] = {
        offset = 0x220,
        type = "Array",
        elementType = "String"
    },
    ["totalGemsEarned"] = {
        offset = 0x23C,
        type = "Int32"
    },
    ["recentChallenges"] = {
        offset = 0x240,
        type = "Array",
        elementType = "String"
    },
    ["achievements"] = {
        offset = 0x258,
        type = "Array",
        elements = Achievement
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
        type = "Enum",
        enum = "Tutorial_State"
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
        elementType = "String"
    },
    ["teamId"] = {
        offset = 0x2A0,
        type = "String"},
    ["activeFriendlyRaces"] = {
        offset = 0x2A8,
        type = "Array",
        elements = FriendlyRace
    },  -- FriendlyRace
    ["cheater"] = {
        offset = 0x3DD,
        type = "Bool"
    },
    ["currentCupId"] = {
        offset = 0x2C0,
        type = "String"},
    ["deviceSignature"] = {
        offset = 0x2C8,
        type = "String"},
    ["deviceHash"] = {
        offset = 0x2D0, -- was 0x2C8; dump: devicesignature_ 0x2c8, devicehash_ 0x2d0
        type = "String"},
    ["currentSpecialEventId"] = {
        offset = 0x2D8,
        type = "String"},
    ["contentVersion"] = {
        offset = 0x300,
        type = "Int32"
    },
    ["seasonStatus"] = {
        offset = 0x2E0,
        type = "Object",
        elements = SeasonStatus
    },  -- SeasonStatus
    ["purchasedIaps"] = {
        offset = 0x2E8,
        type = "Array",
        elements = IapPurchaseEvent
    },  -- IapPurchaseEvent
    ["acsPlayerGuid"] = {
        offset = 0x308,
        type = "String"},
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
        elements = EventStatus
    },  -- EventStatus
    ["flags"] = {
        offset = 0x328,
        type = "BitMask",
        enum = "GameStatusFlag"
    },
    ["ownedVehicles"] = {
        offset = 0x330,
        type = "Array",
        elementType = "String"
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
        elementType = "String"
    },
    ["activePopupOffer"] = {
        offset = 0x370,
        type = "String"},
    ["activePopupOfferEndTimestamp"] = {
        offset = 0x36C,
        type = "Int32"
    },
    ["expiredPopupOffers"] = {
        offset = 0x378,
        type = "Array",
        elementType = "String"
    },
    ["pendingChests"] = {
        offset = 0x390,
        type = "Array",
        elements = PendingChest
    },  -- PendingChest
    ["libHash"] = {
        offset = 0x3B0,
        type = "Int32"
    },
    ["vipStatus"] = {
        offset = 0x3A8,
        type = "Object",
        elements = VipStatus
    },  -- VipStatus
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
        type = "String"},
    ["os"] = {
        offset = 0x3D0,
        type = "String"},
    ["totalEventRacesWon"] = {
        offset = 0x3D8,
        type = "Int32"
    },
    ["rentedVehicles"] = {
        offset = 0x3E0,
        type = "Array",
        elements = RentalStatus
    },  -- RentalStatus
    ["unlockedWorlds"] = {
        offset = 0x3F8,
        type = "Array",
        elementType = "String"
    },
    ["segmentId"] = {
        offset = 0x410,
        type = "String"},
    ["playerSegments"] = {
        offset = 0x418,
        type = "String"},
    ["checkinReward"] = {
        offset = 0x420,
        type = "Object",
        elements = CheckinReward
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
        type = "String"},
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
        elements = DealStatus
    },  -- DealStatus
    ["scrap"] = {
        offset = 0x45C,
        type = "Int32"
    },
    ["scrapperStatus"] = {
        offset = 0x460,
        type = "Object",
        elements = ScrapperStatus
    },  -- ScrapperStatus
    ["totalScrapEarned"] = {
        offset = 0x480,
        type = "Int32"
    },
    ["oldSeasons"] = {
        offset = 0x468,
        type = "Array",
        elements = SeasonStatus
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
        elements = ActivePopupOffer
    },  -- ActivePopupOffer
    ["activeTeamEventStatus"] = {
        offset = 0x4A0,
        type = "Object",
        elements = EventStatus
    },  -- EventStatus
    ["teamStatus"] = {
        offset = 0x4B0,
        type = "Object",
        elements = TeamStatus
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
        elements = KickedTeamStatus
    },  -- KickedTeamStatus
    ["teamEventOfferShown"] = {
        offset = 0x4C8,
        type = "String"},
    ["weeklyEventOfferShown"] = {
        offset = 0x4D0,
        type = "String"},
    ["playerNameApprovalState"] = {
        offset = 0x4F0,
        type = "Int32",
        enum = "PlayerNameApprovalState"
    },
    ["distanceTickets"] = {
        offset = 0x4D8,
        type = "Array",
        elements = DistanceTicket
    },  -- DistanceTicket
    ["previousEventStatuses"] = {
        offset = 0x4F8,
        type = "Array",
        elements = EventStatus
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
        elementType = "String"
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
        elementStride = 0x4 -- RepeatedField<int> packs elements at 4 bytes
    },
    ["secret"] = {
        offset = 0x540,
        type = "String"},
    ["animatedAdventurerRank"] = {
        offset = 0x568,
        type = "Float"
    },
    ["banData"] = {
        offset = 0x548,
        type = "Array",
        elements = BanData
    },  -- BanData
    ["banReviewed"] = {
        offset = 0x3DF,
        type = "Bool"
    },
    ["teamSeasonStatus"] = {
        offset = 0x560,
        type = "Object",
        elements = TeamSeasonStatus
    },  -- TeamSeasonStatus
    ["nonRewardedTeamSeasons"] = {
        offset = 0x570,
        type = "Array",
        elementType = "String"
    },
    ["activeDailyBonusTasks"] = {
        offset = 0x588,
        type = "Array",
        elements = DailyTask
    },  -- DailyTask
    ["activeDailyTasks"] = {
        offset = 0x5A0,
        type = "Array",
        elements = DailyTask
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
        type = "String"},
    ["pendingOfferIds"] = {
        offset = 0x5D0,
        type = "Array",
        elements = IapPurchaseEvent
    },  -- IapPurchaseEvent
    ["dailyTaskRefillsRemaining"] = {
        offset = 0x5E8,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4 -- RepeatedField<int> packs elements at 4 bytes
    },
    ["currencies"] = {
        offset = 0x5F8,
        type = "Array",
        elements = Currency
    },  -- Currency
    ["publishedLevels"] = {
        offset = 0x610,
        type = "Array",
        elementType = "String"
    },
    ["featuredChallenges"] = {
        offset = 0x628,
        type = "Array",
        elements = FeaturedChallenge
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
        elements = DistanceCollectibleStatus
    },  -- DistanceCollectibleStatus
    ["activeCommunityEventStatus"] = {
        offset = 0x660,
        type = "Object",
        elements = EventStatus
    },  -- EventStatus
    ["currentPublicLevels"] = {
        offset = 0x668,
        type = "Array",
        elementType = "String"
    },
    ["unlockedEditorThemes"] = {
        offset = 0x680,
        type = "Array",
        elementType = "String"
    },
    ["FSHomeProfileID"] = {
        offset = 0x698,
        type = "String"},
    ["home"] = {
        offset = 0x6A0,
        type = "Object",
        elements = Home
    },  -- Home
    ["ownedHomeProps"] = {
        offset = 0x6B0,
        type = "Array",
        elements = HomeCosmeticsOwnership
    },  -- HomeCosmeticsOwnership
    ["ownedHomeBackgrounds"] = {
        offset = 0x6C8,
        type = "Array",
        elements = HomeCosmeticsOwnership
    },  -- HomeCosmeticsOwnership
    ["megaAdChestRewards"] = {
        offset = 0x6E0,
        type = "Array",
        elements = MegaAdChestRewardStatus
    },  -- MegaAdChestRewardStatus
    ["activeLeagueTasks"] = {
        offset = 0x6F8,
        type = "Array",
        elements = LeagueTask
    },  -- LeagueTask
    ["communityEvent"] = {
        offset = 0x710,
        type = "Object",
        elements = CommunityEvent
    },  -- CommunityEvent
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
        type = "String"},
    ["supportHmac"] = {
        offset = 0x780,
        type = "String"},
    ["megaAdChestProgress"] = {
        offset = 0x788,
        type = "Array",
        elements = MegaAdChestProgress
    },  -- MegaAdChestProgress
    ["signatureChallengeId"] = {
        offset = 0x7A0,
        type = "String"},
    ["activeTutorialVersion"] = {
        offset = 0x7C0,
        type = "Int32"
    },
    ["adviews"] = {
        offset = 0x7A8,
        type = "Array",
        elements = AdViewsMap
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
        elements = CurrentGachaProgress
    },  -- CurrentGachaProgress
    ["claimedResearchRewardAmount"] = {
        offset = 0x7D0,
        type = "Array",
        elementType = "SafeInt32"
    },
    ["claimedResearchDonationAmount"] = {
        offset = 0x7E8,
        type = "SafeInt32"
    },
    ["currentFriendEvent"] = {
        offset = 0x7F0,
        type = "Object",
        elements = CurrentFriendEvent
    },  -- CurrentFriendEvent
    ["teamDonationTrack"] = {
        offset = 0x808,
        type = "Int32"
    },
    ["displayedInfoPopups"] = {
        offset = 0x7F8,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4 -- RepeatedField<int> packs elements at 4 bytes
    },
    ["teamSupportChestTransactions"] = {
        offset = 0x810,
        type = "Array",
        elementType = "String"
    },
    ["showOnlineStatus"] = {
        -- dump field name is "showolinestatus_" (missing 'n' in the
        -- IL2CPP symbol) — same field, same offset 0x80C.
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
        type = "String"},
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
        elementType = "String"
    },
    ["claimedInboxMessages"] = {
        id = "claimedInboxMessages",
        offset = 0x848,
        optional = false,
        tracked = false,
        type = "Array",
        elementType = "String"
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
        elements = WinStreakEvent
    },  --WinStreakEvent
    ["activeTriggers"] = {
        id = "activeTriggers",
        offset = 0x878,
        optional = false,
        tracked = true,
        type = "Array",
        elements = ActiveTrigger
    }, -- ActiveTrigger
    ["previousPlayerIds"] = {
        id = "previousPlayerIds",
        offset = 0x890,
        optional = true,
        tracked = true,
        type = "Array",
        elementType = "String"
    }, -- String (was Object; dump: RepeatedPtrField<string>)
    ["currentFriendEvents"] = {
        id = "currentFriendEvents",
        offset = 0x8A8,
        optional = false,
        tracked = true,
        type = "Array",
        elements = CurrentFriendEvent
    }, -- CurrentFriendEvent
    ["nextBonusLevelRank"] = {
        id = "nextBonusLevelRank",
        offset = 0x8C0,
        optional = true,
        tracked = true,
        type = "Float" -- was Object; dump: float nextbonuslevelrank_
    },
}
