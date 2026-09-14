--==================================================
-- metadata/1.74/GameData.lua
--==================================================
-- GameData metadata — supplied IL2CPP dump
-- Size: 0x548 | Confidence: exact
-- All compound GameData dependencies used below have concrete metadata.
-- Manifest is version-aware, so nested layouts follow the running game version.
local Manifest = loadModule("metadata/manifest.lua")

-- Cache nested schemas once. These are reused by multiple fields and
-- should not call Manifest.load() repeatedly while building the metadata table.
local LeagueDefinition             = Manifest.load("LeagueDefinition")
local AdventurerRankDefinition     = Manifest.load("AdventurerRankDefinition")
local TeamSeasonDivisionDefinition = Manifest.load("TeamSeasonDivisionDefinition")
local ReviewConditions             = Manifest.load("ReviewConditions")

return {
    ["contentVersion"] = {
        offset = 0x0,
        type = "Int32"
    },
    ["analyticsGroup"] = {
        offset = 0x8,
        type = "String"
    },
    ["partialJsonApplied"] = {
        offset = 0x20,
        type = "Bool"
    },
    ["seasonsEnabled"] = {
        offset = 0x21,
        type = "Bool"
    },
    ["seasonsUnlockRank"] = {
        offset = 0x24,
        type = "Float"
    },
    ["gdprVersion"] = {
        offset = 0x28,
        type = "Int32"
    },
    ["adventureUnlockRank"] = {
        offset = 0x2c,
        type = "Float"
    },
    ["scrapperUnlockRank"] = {
        offset = 0x30,
        type = "Float"
    },
    ["teamUnlockRank"] = {
        offset = 0x34,
        type = "Float"
    },
    ["featuredChallengeUnlockRank"] = {
        offset = 0x38,
        type = "Float"
    },
    ["distanceCollectibleUnlockRank"] = {
        offset = 0x3c,
        type = "Float"
    },
    ["homeCustomizationUnlockRank"] = {
        offset = 0x40,
        type = "Float"
    },
    ["creativeModeUnlockRank"] = {
        offset = 0x44,
        type = "Float"
    },
    ["dailyTasksUnlockRank"] = {
        offset = 0x48,
        type = "Float"
    },
    ["defaultCupPool"] = {
        offset = 0x50,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["collectibleHomingDistance"] = {
        offset = 0x68,
        type = "Float"
    },
    ["collectibleHomingSpeed"] = {
        offset = 0x6c,
        type = "Float"
    },
    ["defaultFirstCoinPosition"] = {
        offset = 0x70,
        type = "Float"
    },
    ["defaultCoinSpawnDistance"] = {
        offset = 0x74,
        type = "Float"
    },
    ["defaultCoinsPerSpawn"] = {
        offset = 0x78,
        type = "Float"
    },
    ["defaultBackwallDistance"] = {
        offset = 0x7c,
        type = "Float"
    },
    ["defaultBackwallStartDistance"] = {
        offset = 0x80,
        type = "Float"
    },
    ["collectibleDeletingDistance"] = {
        offset = 0x84,
        type = "Float"
    },
    ["maxFriendScoreMarkers"] = {
        offset = 0x88,
        type = "Int32"
    },
    ["coinsFromStar"] = {
        offset = 0x8c,
        type = "Int32"
    },
    ["startCountdown"] = {
        offset = 0x90,
        type = "Float"
    },
    ["fuelKillTime"] = {
        offset = 0x94,
        type = "Float"
    },
    ["gameOverTime"] = {
        offset = 0x98,
        type = "Float"
    },
    ["firstStartLevel"] = {
        offset = 0xa0,
        type = "String"
    },
    ["tutorialId"] = {
        offset = 0xb8,
        type = "String"
    },
    ["tutorialTipsEnabled"] = {
        offset = 0xd0,
        type = "Bool"
    },
    ["slowmoTutorialEnabled"] = {
        offset = 0xd1,
        type = "Bool"
    },
    ["slowmoTutorialInFirstCup"] = {
        offset = 0xd2,
        type = "Bool"
    },
    ["tutorialWinRequired"] = {
        offset = 0xd3,
        type = "Bool"
    },
    ["tutorialStopAirControl"] = {
        offset = 0xd4,
        type = "Bool"
    },
    ["tutorialGfx"] = {
        offset = 0xd8,
        type = "String"
    },
    ["tutorialVehicleId"] = {
        offset = 0xf0,
        type = "String"
    },
    ["tutorialVehicleUpgrades"] = {
        offset = 0x108,
        type = "Array",
        elementType = "Int32"
    },
    ["tutorialGhosts"] = {
        offset = 0x120,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["tutorialGroup"] = {
        offset = 0x138,
        type = "String"
    },
    ["tutorialRubberbanding"] = {
        offset = 0x150,
        type = "Bool"
    },
    ["tutorialAdjustRubberband"] = {
        offset = 0x151,
        type = "Bool"
    },
    ["tutorialRubberbandingType"] = {
        offset = 0x154,
        type = "Enum",
        enum = "GameData_RubberbandingType"
    },
    ["raceLockTimeS"] = {
        offset = 0x158,
        type = "Float"
    },
    ["wcUnlockDistance"] = {
        offset = 0x15c,
        type = "Int32"
    },
    ["ghostPositionZ"] = {
        offset = 0x160,
        type = "Float"
    },
    ["ghostMinOpacity"] = {
        offset = 0x164,
        type = "Float"
    },
    ["ghostMaxOpacity"] = {
        offset = 0x168,
        type = "Float"
    },
    ["ghostFadeDistance"] = {
        offset = 0x16c,
        type = "Float"
    },
    ["fadeDeadGhosts"] = {
        offset = 0x170,
        type = "Bool"
    },
    ["replaySkipAmount"] = {
        offset = 0x174,
        type = "Float"
    },
    ["capturePosDiffThreshold"] = {
        offset = 0x178,
        type = "Float"
    },
    ["captureAngularDiffThreshold"] = {
        offset = 0x17c,
        type = "Float"
    },
    ["airDragForce"] = {
        offset = 0x180,
        type = "Float"
    },
    ["airDragAngleForce"] = {
        offset = 0x184,
        type = "Float"
    },
    ["airDragStartVelocity"] = {
        offset = 0x188,
        type = "Float"
    },
    ["airDragStartVelocitySq"] = {
        offset = 0x18c,
        type = "Float"
    },
    ["airDragStartRamp"] = {
        offset = 0x190,
        type = "Float"
    },
    ["boostEnabled"] = {
        offset = 0x194,
        type = "Bool"
    },
    ["boostSpeedMultiplier"] = {
        offset = 0x198,
        type = "Float"
    },
    ["boostFuelConsumption"] = {
        offset = 0x19c,
        type = "Float"
    },
    ["playerCarSpawnOffset"] = {
        offset = 0x1a0,
        type = "Vec2"
    },
    ["forceDailySeed"] = {
        offset = 0x1a8,
        type = "Int32"
    },
    ["enableJsonReload"] = {
        offset = 0x1ac,
        type = "Bool"
    },
    ["initialCameraPan"] = {
        offset = 0x1b0,
        type = "Vec2"
    },
    ["initialCameraZoom"] = {
        offset = 0x1b8,
        type = "Float"
    },
    ["cameraZoomScreenshot"] = {
        offset = 0x1bc,
        type = "Float"
    },
    ["cameraZoomGameOver"] = {
        offset = 0x1c0,
        type = "Float"
    },
    ["cameraZoomSpeed"] = {
        offset = 0x1c4,
        type = "Float"
    },
    ["cameraZoomFromVelocity"] = {
        offset = 0x1c8,
        type = "Float"
    },
    ["cameraDistance"] = {
        offset = 0x1cc,
        type = "Float"
    },
    ["camera"] = {
        offset = 0x1d0,
        type = "Float"
    },
    ["cameraSmoothing"] = {
        offset = 0x1d4,
        type = "Vec2"
    },
    ["cameraOffsetSmoothingTime"] = {
        offset = 0x1dc,
        type = "Float"
    },
    ["defaultCarScreenPos"] = {
        offset = 0x1e0,
        type = "Float"
    },
    ["minVisibleRange"] = {
        offset = 0x1e4,
        type = "Float"
    },
    ["maxVisibleRange"] = {
        offset = 0x1e8,
        type = "Float"
    },
    ["showMoreGhostsMode"] = {
        offset = 0x1ec,
        type = "Bool"
    },
    ["showGroundBelowScreenPosY"] = {
        offset = 0x1f0,
        type = "Float"
    },
    ["showGroundBelowMasterMultiplier"] = {
        offset = 0x1f4,
        type = "Float"
    },
    ["showGroundBelowClampVelFactor"] = {
        offset = 0x1f8,
        type = "Float"
    },
    ["fuelFloaterVisibleDistance"] = {
        offset = 0x1fc,
        type = "Float"
    },
    ["personalBestGhostsAmount"] = {
        offset = 0x200,
        type = "Int32"
    },
    ["personalBestGhostsInAdventureAmount"] = {
        offset = 0x204,
        type = "Int32"
    },
    ["friendsGhostsInAdventureAmount"] = {
        offset = 0x208,
        type = "Int32"
    },
    ["useCupPlayerMatching"] = {
        offset = 0x20c,
        type = "Bool"
    },
    ["sendFrameDataInPersonalBests"] = {
        offset = 0x20d,
        type = "Bool"
    },
    ["rankPerPosition"] = {
        offset = 0x210,
        type = "Float"
    },
    ["rankBoostMaxRank"] = {
        offset = 0x214,
        type = "Float"
    },
    ["rankBoostFactor"] = {
        offset = 0x218,
        type = "Float"
    },
    ["fixedCachedRankDeltas"] = {
        offset = 0x220,
        type = "Array",
        elementType = "Float"
    },
    ["rubberbandThresholds"] = {
        offset = 0x238,
        type = "Array",
        elementType = "Float"
    },
    ["maxRubberbandOffset"] = {
        offset = 0x250,
        type = "Array",
        elementType = "Float"
    },
    ["rubberbandVelocityFactors"] = {
        offset = 0x268,
        type = "Array",
        elementType = "Float"
    },
    ["priceTextColor"] = {
        offset = 0x280,
        type = "Color3B"
    },
    ["priceTextColorNotEnoughMoney"] = {
        offset = 0x283,
        type = "Color3B"
    },
    ["maxBlockExtraDistance"] = {
        offset = 0x288,
        type = "Float"
    },
    ["vehicles"] = {
        offset = 0x290,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["vehiclesHidden"] = {
        offset = 0x2a8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["tournamentPoints"] = {
        offset = 0x2c0,
        type = "Array",
        elementType = "Int32"
    },
    ["legacyVehicleOrder"] = {
        offset = 0x2d8,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["levelTierRanks"] = {
        offset = 0x2f0,
        type = "Array",
        elementType = "Int32"
    },
    ["leagueDefinitions"] = {
        offset = 0x308,
        type = "Array",
        elementStride = 0x8,
        elements = LeagueDefinition
    },
    ["seasonLeagueDefinitions"] = {
        offset = 0x320,
        type = "Array",
        elementStride = 0x8,
        elements = LeagueDefinition
    },
    ["adventurerRankDefinitions"] = {
        offset = 0x338,
        type = "Array",
        elementStride = 0x8,
        elements = AdventurerRankDefinition
    },
    ["tournamentTeamWinBonus"] = {
        offset = 0x350,
        type = "Int32"
    },
    ["maxDailyMissionRepicks"] = {
        offset = 0x354,
        type = "Int32"
    },
    ["maxDailyMissions"] = {
        offset = 0x358,
        type = "Int32"
    },
    ["killCamZoom"] = {
        offset = 0x35c,
        type = "Float"
    },
    ["killCamGameSpeed"] = {
        offset = 0x360,
        type = "Float"
    },
    ["boostInAir"] = {
        offset = 0x364,
        type = "Bool"
    },
    ["requireWinForCupReward"] = {
        offset = 0x365,
        type = "Bool"
    },
    ["askRatingAfterCupReward"] = {
        offset = 0x368,
        type = "Array",
        elementType = "Int32"
    },
    ["reviewConditions"] = {
        offset = 0x380,
        type = "Object",
        elements = ReviewConditions
    },
    ["askSaveNowRankInterval"] = {
        offset = 0x3c0,
        type = "Float"
    },
    ["androidReleaseSignaturePart2"] = {
        offset = 0x3c8,
        type = "String"
    },
    ["androidDevelopmentSignaturePart2"] = {
        offset = 0x3e0,
        type = "String"
    },
    ["androidInternalAppSharingSignaturePart2"] = {
        offset = 0x3f8,
        type = "String"
    },
    ["amazonStoreSignaturePart2"] = {
        offset = 0x410,
        type = "String"
    },
    ["mygamezSignaturePart2"] = {
        offset = 0x428,
        type = "String"
    },
    ["mygamezSignature2Part2"] = {
        offset = 0x440,
        type = "String"
    },
    ["chinaMobileSignaturePart2"] = {
        offset = 0x458,
        type = "String"
    },
    ["unicomSignaturePart2"] = {
        offset = 0x470,
        type = "String"
    },
    ["useSingleButtonMode"] = {
        offset = 0x488,
        type = "Bool"
    },
    ["onlyTimeTrialNormalCups"] = {
        offset = 0x489,
        type = "Bool"
    },
    ["unrankedNormalCups"] = {
        offset = 0x48a,
        type = "Bool"
    },
    ["friendsRefreshInterval"] = {
        offset = 0x48c,
        type = "Int32"
    },
    ["friendlyRaceResultsPollInterval"] = {
        offset = 0x490,
        type = "Int32"
    },
    ["cloudSaveSkipIfBgDuration"] = {
        offset = 0x494,
        type = "Int32"
    },
    ["maxRecentChallenges"] = {
        offset = 0x498,
        type = "Int32"
    },
    ["showRankPointsAfterRank"] = {
        offset = 0x49c,
        type = "Int32"
    },
    ["activeEventsCacheTime"] = {
        offset = 0x4a0,
        type = "Int32"
    },
    ["offersCacheTime"] = {
        offset = 0x4a4,
        type = "Int32"
    },
    ["offersSegmentedCacheTime"] = {
        offset = 0x4a8,
        type = "Int32"
    },
    ["shopConfigCacheTime"] = {
        offset = 0x4ac,
        type = "Int32"
    },
    ["maxNameChanges"] = {
        offset = 0x4b0,
        type = "Int32"
    },
    ["maxActivePopupOffers"] = {
        offset = 0x4b4,
        type = "Int32"
    },
    ["masteryXpRequiredPerLevel"] = {
        -- dump: JSONSafeInt masteryXpRequiredPerLevel // 0x4b8
        offset = 0x4b8,
        type = "JSONSafeInt"
    },
    ["masteryCostPerLevel"] = {
        -- dump: JSONSafeInt masteryCostPerLevel // 0x4d8
        offset = 0x4d8,
        type = "JSONSafeInt"
    },
    ["breakableObjectInvulnerabilityTime"] = {
        offset = 0x4f8,
        type = "Float"
    },
    ["hashlist"] = {
        offset = 0x500,
        type = "Array",
        elementType = "Int32"
    },
    ["hashStringList"] = {
        offset = 0x518,
        type = "String"
    },
    ["teamSeasonDivisions"] = {
        offset = 0x530,
        type = "Array",
        elementStride = 0x8,
        elements = TeamSeasonDivisionDefinition
    },
}
