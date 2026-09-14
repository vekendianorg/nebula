--==================================================
-- metadata/1.74/PlayerInfo.lua
--==================================================
-- Complete metadata snapshot for the PlayerInfo struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file —
-- this file is PlayerInfo only.
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class PlayerInfo // TypeDefIndex: 1777 Size: 0x838
--   Confidence: exact
--
-- Every offset and type below matches that dump exactly. No layout,
-- size, stride, pointer representation, or schema is guessed.
-- Private fields are included because metadata represents memory
-- layout.
--
-- Field-name normalization (camelCase): a leading `m` is stripped
-- and the next character lowercased (mRealGarageSelectedCar ->
-- realGarageSelectedCar, mGameStatus -> gameStatus, mSessionDiamonds
-- -> sessionDiamonds, mCwaf -> cwaf); fields without the `m` prefix
-- keep their dump names unchanged (onChanged, vipStatusChanged,
-- pendingFlipAchievementUpdate, ...).
--
-- Representable fields only:
--   int -> Int32, bool -> Bool, string -> String (inline
--   std::string, same as EventDefinition — the api layer shadows
--   with stringDirect), StartupStatus -> Enum
--   (enum = "PlayerInfo_StartupStatus"), Pointer<Single> to a struct
--   with existing metadata -> Object with elements (deref'd at read
--   time):
--     ["gameStatus"] = { offset = 0x148, type = "Object",
--                        elements = GameStatus }
--     ["currentRace"] = { offset = 0x40, type = "Object",
--                         elements = RaceInfo }
--
-- Inline SessionTracker instances (PlayerInfo embeds three INLINE at
-- 0x160 / 0x188 / 0x1B0; start-to-start spacing is exactly the dump
-- class size 0x28):
--   Dump: SessionTracker // TypeDefIndex: 3575, Size: 0x28,
--   Confidence: exact — { startObf int @+0x0, deltaObf int @+0x4,
--   initialized bool @+0x8, source string @+0x10 }.
--   Each tracker below is a namespace container (no `type`; children
--   carry ABSOLUTE offsets = instance base + relative, same
--   convention as EventDefinition.sessionEntry/gameMode and
--   FixedVehicleDefinition.vehicleUpgradePriceCurve). Verified
--   against metadata/1.74/structs/PlayerInfo_SessionTracker.lua
--   (which records the 0x160 instance's absolutes); the 0x188/0x1B0
--   instances are derived the same way (base + relative) and inlined
--   here because one absolute-offset file cannot serve three bases.
--
-- Intentionally NOT metadata (no supported representation — omitted,
-- not guessed):
--   - mLastRaceTimestamps Dictionary<string,float> @0x130,
--     mSessionCurrencies Dictionary<string,PlayerInfo_SessionTracker>
--     @0x1D8, mActiveMissions
--     Dictionary<string,Pointer<MissionStatus>> @0x798,
--     mCarCustomizations Dictionary<string,Dictionary<string,string>>
--     @0x7B0 (std::map ABI, no supported representation — same
--     reason PlayerInfo_SessionTracker.lua documents the 0x1D8 slot
--     as NOT metadata)
--   - mSentCurrencyTrackerHackerEvents HashSet<string> @0x820
--     (HashSet ABI, no supported representation)
--   - 29 inline FSEvent instances @0x1F0-0x75F (onChanged @0x1F0,
--     onPlayerNameChanged @0x220, onPlayerNameApprovalStateChanged
--     @0x250, onDriverCustomizationChanged @0x280, onAddCoins @0x2B0,
--     onCoinAmountChanged @0x2E0, onAddGems @0x310, onGemAmountChanged
--     @0x340, onAddScrap @0x370, onScrapAmountChanged @0x3A0,
--     onAddSpecialTickets @0x3D0, onAddEventPoints @0x400,
--     onCurrencyAmountChanged @0x430, onAddCurrency @0x460,
--     onSpecialTicketsAmountChanged @0x490, onAddWorld @0x4C0,
--     onMasteryBonusXpAmountChanged @0x4F0, onAdFreeTimeChanged @0x520,
--     onSignatureChallengeChanged @0x550, onAddCurrencyAny @0x580,
--     onUseCurrencyAny @0x5B0, onAddTuningPart @0x5E0,
--     onFeaturedChallengesAdded @0x610, onRecentChallengeAdded @0x640,
--     onEventsChanged @0x670, vipStatusChanged @0x6A0,
--     onVehiclePurchased @0x6D0, onFlagChanged @0x700,
--     onMaxWCRankUpdated @0x730; each Size 0x30) — inline instances
--     resolve to the FSEvent layout (mHandlers @+0x0,
--     mConditionalHandlers @+0x18); inner List<T> has no supported
--     representation (see FSEvent.lua)
--   - mPlayerNameApprovalRequest cocos2d_network_HttpRequest @0x7E0
--     (cocos2d network type, no verified metadata snapshot)
--
-- Reused existing snapshots (not duplicated): GameStatus
-- (mGameStatus @0x148), RaceInfo (mCurrentRace @0x40, new snapshot
-- in this change), PlayerInfo_SessionTracker (layout verified for
-- the three inline instances), FSEvent (layout verified for
-- the 29 inline events), enum PlayerInfo_StartupStatus
-- (mStartupStatus @0xF8). MissionStatus was inspected
-- (MissionStatus.lua exists) but NOT referenced: the only
-- MissionStatus-typed PlayerInfo member is the mActiveMissions
-- Dictionary, which has no supported container representation.

local Manifest = loadModule("metadata/manifest.lua")

local GameStatus = Manifest.load("GameStatus")
local RaceInfo   = Manifest.load("RaceInfo")

return {
    ["realGarageSelectedCar"] = {
        offset = 0x0,
        type = "Int32"
    },
    ["selectedTab"] = {
        offset = 0x4,
        type = "Int32"
    },
    ["realGarageSelectedCarId"] = {
        offset = 0x8,
        type = "String"
    },
    ["lastPickedAdventureCar"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["lastPickedAdventureCarId"] = {
        offset = 0x28,
        type = "String"
    },
    ["currentRace"] = {
        -- dump: public Pointer<RaceInfo> mCurrentRace // 0x40
        offset = 0x40,
        type = "Object",
        elements = RaceInfo
    },
    ["pendingRewardsForTeamSeasonId"] = {
        offset = 0x50,
        type = "String"
    },
    ["tutorialABGroup"] = {
        offset = 0x68,
        type = "String"
    },
    ["cheaterReason"] = {
        offset = 0x80,
        type = "String"
    },
    ["cheaterDetails"] = {
        offset = 0x98,
        type = "String"
    },
    ["sceneName"] = {
        offset = 0xB0,
        type = "String"
    },
    ["startupCount"] = {
        offset = 0xC8,
        type = "Int32"
    },
    ["configurationCompleted"] = {
        offset = 0xCC,
        type = "Bool"
    },
    ["facebookLikeRewarded"] = {
        offset = 0xCD,
        type = "Bool"
    },
    ["facebookLoginRewarded"] = {
        offset = 0xCE,
        type = "Bool"
    },
    ["videoAdsEnabled"] = {
        offset = 0xD0,
        type = "Int32"
    },
    ["everyplayEnabled"] = {
        offset = 0xD4,
        type = "Int32"
    },
    ["autoSignInGameServices"] = {
        offset = 0xD8,
        type = "Bool"
    },
    ["soundEnabled"] = {
        offset = 0xD9,
        type = "Bool"
    },
    ["musicEnabled"] = {
        offset = 0xDA,
        type = "Bool"
    },
    ["debugModeEnabled"] = {
        offset = 0xDB,
        type = "Bool"
    },
    ["cheatUnlockAll"] = {
        offset = 0xDC,
        type = "Bool"
    },
    ["keepLevel"] = {
        offset = 0xDD,
        type = "Bool"
    },
    ["previousNumberOfFriends"] = {
        offset = 0xE0,
        type = "Int32"
    },
    ["firstStartupTimestamp"] = {
        offset = 0xE4,
        type = "Int32"
    },
    ["dirty"] = {
        offset = 0xE8,
        type = "Bool"
    },
    ["showAllSpecialOffers"] = {
        offset = 0xE9,
        type = "Bool"
    },
    ["showHiddenVehicles"] = {
        offset = 0xEA,
        type = "Bool"
    },
    ["tutorialPedalPressed"] = {
        offset = 0xEB,
        type = "Bool"
    },
    ["tutorialDistance5m"] = {
        offset = 0xEC,
        type = "Bool"
    },
    ["tutorialDistance50m"] = {
        offset = 0xED,
        type = "Bool"
    },
    ["tutorialDistance100m"] = {
        offset = 0xEE,
        type = "Bool"
    },
    ["tutorialDistance150m"] = {
        offset = 0xEF,
        type = "Bool"
    },
    ["tutorialDistance200m"] = {
        offset = 0xF0,
        type = "Bool"
    },
    ["tutorialDistance250m"] = {
        offset = 0xF1,
        type = "Bool"
    },
    ["tutorialDistance300m"] = {
        offset = 0xF2,
        type = "Bool"
    },
    ["tutorialDistance350m"] = {
        offset = 0xF3,
        type = "Bool"
    },
    ["doneStartupChecks"] = {
        offset = 0xF4,
        type = "Bool"
    },
    ["startupStatus"] = {
        -- dump: public StartupStatus mStartupStatus // 0xF8
        offset = 0xF8,
        type = "Enum",
        enum = "PlayerInfo_StartupStatus"
    },
    ["tempPlayerId"] = {
        offset = 0x100,
        type = "String"
    },
    ["tempSecret"] = {
        offset = 0x118,
        type = "String"
    },
    ["gameStatus"] = {
        offset = 0x148,
        type = "Object",
        elements = GameStatus,
        stringDirect = false
    },
    ["sessionSalt"] = {
        offset = 0x158,
        type = "Int32"
    },
    ["sessionDiamonds"] = {
        -- dump: public PlayerInfo_SessionTracker mSessionDiamonds // 0x160
        -- instance base 0x160 + SessionTracker relatives (0x0/0x4/0x8/0x10)
        ["startObf"] = {
            offset = 0x160,
            type = "Int32"
        },
        ["deltaObf"] = {
            offset = 0x164,
            type = "Int32"
        },
        ["initialized"] = {
            offset = 0x168,
            type = "Bool"
        },
        ["source"] = {
            offset = 0x170,
            type = "String"
        },
    },
    ["sessionCoins"] = {
        -- dump: public PlayerInfo_SessionTracker mSessionCoins // 0x188
        -- instance base 0x188 + SessionTracker relatives
        ["startObf"] = {
            offset = 0x188,
            type = "Int32"
        },
        ["deltaObf"] = {
            offset = 0x18C,
            type = "Int32"
        },
        ["initialized"] = {
            offset = 0x190,
            type = "Bool"
        },
        ["source"] = {
            offset = 0x198,
            type = "String"
        },
    },
    ["sessionScrap"] = {
        -- dump: public PlayerInfo_SessionTracker mSessionScrap // 0x1B0
        -- instance base 0x1B0 + SessionTracker relatives
        ["startObf"] = {
            offset = 0x1B0,
            type = "Int32"
        },
        ["deltaObf"] = {
            offset = 0x1B4,
            type = "Int32"
        },
        ["initialized"] = {
            offset = 0x1B8,
            type = "Bool"
        },
        ["source"] = {
            offset = 0x1C0,
            type = "String"
        },
    },
    ["selectedCar"] = {
        -- dump: private int mSelectedCar // 0x760
        offset = 0x760,
        type = "Int32"
    },
    ["selectedDistanceCar"] = {
        -- dump: private int mSelectedDistanceCar // 0x764
        offset = 0x764,
        type = "Int32"
    },
    ["selectedCarId"] = {
        -- dump: private string mSelectedCarId // 0x768
        offset = 0x768,
        type = "String"
    },
    ["selectedDistanceCarId"] = {
        -- dump: private string mSelectedDistanceCarId // 0x780
        offset = 0x780,
        type = "String"
    },
    ["pendingFlipAchievementUpdate"] = {
        -- dump: private bool pendingFlipAchievementUpdate // 0x7C8
        offset = 0x7C8,
        type = "Bool"
    },
    ["pendingBackFlipAchievementUpdate"] = {
        -- dump: private bool pendingBackFlipAchievementUpdate // 0x7C9
        offset = 0x7C9,
        type = "Bool"
    },
    ["pendingNeckFlipAchievementUpdate"] = {
        -- dump: private bool pendingNeckFlipAchievementUpdate // 0x7CA
        offset = 0x7CA,
        type = "Bool"
    },
    ["currentTeamRankInDivision"] = {
        -- dump: private int mCurrentTeamRankInDivision // 0x7CC
        offset = 0x7CC,
        type = "Int32"
    },
    ["watchedReplay"] = {
        -- dump: private bool mWatchedReplay // 0x7D0
        offset = 0x7D0,
        type = "Bool"
    },
    ["cwaf"] = {
        -- dump: private int mCwaf // 0x7D4
        offset = 0x7D4,
        type = "Int32"
    },
    ["pendingEventBonus"] = {
        -- dump: private int mPendingEventBonus // 0x7D8
        offset = 0x7D8,
        type = "Int32"
    },
    ["countryCode"] = {
        -- dump: private string mCountryCode // 0x7E8
        -- NOT a plain inline string: the slot holds a POINTER to a
        -- heap wrapper object (observed on-device 1.74: {ptr, ptr,
        -- hasbits}), with the real std::string at wrapper+0x28.
        -- Reading it as String yields garbage — needs a dedicated
        -- wrapper type before it is readable. known = false keeps
        -- it out of fields() until then.
        offset = 0x7E8,
        type = "String",
        known = false
    },
    ["sendingTeamChestContributionHandle"] = {
        -- dump: private int mSendingTeamChestContributionHandle // 0x800
        offset = 0x800,
        type = "Int32"
    },
    ["currencyTrackerPlayerId"] = {
        -- dump: private string mCurrencyTrackerPlayerId // 0x808
        offset = 0x808,
        type = "String"
    },
}
