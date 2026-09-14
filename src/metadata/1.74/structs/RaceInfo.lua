--==================================================
-- metadata/1.74/RaceInfo.lua
--==================================================
-- Complete metadata snapshot for the RaceInfo struct at game
-- version 1.74 (see metadata/manifest.lua for how a running game
-- version resolves to this file). One class definition per file —
-- this file is RaceInfo only.
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class RaceInfo // TypeDefIndex: 1836 Size: 0x3A0
--   Confidence: exact
--
-- Every offset and type below matches that dump exactly. No layout,
-- size, stride, pointer representation, or schema is guessed.
--
-- Field-name normalization (camelCase): a leading `m` is stripped
-- and the next character lowercased (mSeed -> seed, mLevelId ->
-- levelId, mIsBoostedVehicle -> isBoostedVehicle); fields without
-- the `m` prefix keep their dump names unchanged (raceInfoState,
-- coinsBeforeRace, cupGuid, ...).
--
-- Representable fields only:
--   int -> Int32, bool -> Bool, float -> Float, string -> String
--   (inline std::string, same as EventDefinition — the api layer
--   shadows with stringDirect), enum -> Enum (enum file cited),
--   Pointer<Single> / plain reference to a struct with existing
--   metadata -> Object with elements (deref'd at read time, same
--   convention as GameStatus.driver @0x168).
--
-- Intentionally NOT metadata (no supported representation — omitted,
-- not guessed; see header notes in the cited files):
--   - _vptr_RaceInfo @0x0 (vptr)
--   - raceReplays Pointer<List<Pointer<Replay>>> @0x8 (Pointer<List>
--     ABI unverified; Replay has no metadata snapshot)
--   - onStateChanged FSEvent<RaceInfoState> @0x20, onRaceStarted
--     FSEvent @0x50, mPlayerNameApprovalHandler
--     FSEvent<PlayerNameApprovalState> @0x388 (inline FSEvent Size
--     0x30 instances; inner List<T> has no supported
--     representation — see FSEvent.lua)
--   - collectedLoot Dictionary<string,int> @0x80, trickAmounts
--     Dictionary<TrickType,int> @0xD0 (std::map ABI, no supported
--     representation — same reason PlayerInfo dictionaries are
--     omitted)
--   - gainedMasteryXp JSONSafeInt @0x110,
--     gainedMasteryXpCupResult JSONSafeInt @0x130 (JSONSafeInt reader
--     not verified — see GameData.lua:592-595, fields left commented
--     out there for the same reason)
--   - vehicleSpecificRecords List<VehicleRecord> @0x168,
--     collectedDistanceCollectibles List<KeyValuePair<int,int>>
--     @0x188, mCupRaceFinishRanks List<float> @0x350,
--     mCupRaceFinishSeasonRanks List<float> @0x368 (IL2CPP List<T>
--     header ABI unverified for these owners — not mapped as Array
--     to avoid guessing container/stride)
--   - specialEvent SpecialEventDefinition @0x200, bossDriver
--     BossDriverDefinition @0x208, mLevelDefinition LevelDefinition
--     @0x238, mPreviousLevel LevelDefinition @0x240, mWorldDefinition
--     WorldDefinition @0x248, mRaceEventStatus
--     Pointer<RaceEventStatus> @0x270, mRaceEventDefinition
--     RaceEventDefinition @0x280, mEventSessionStatus
--     Pointer<EventSessionStatus> @0x288, mChallenge Pointer<Challenge>
--     @0x2A8, mDivisionStatus Pointer<DivisionStatus> @0x2F8,
--     mWcRace Pointer<WCRace> @0x310, mGhostCups
--     Pointer<List<Pointer<Cup>>> @0x320, mCurrentCup Pointer<Cup>
--     @0x330, mCurrentCupReplays Pointer<List<Pointer<Replay>>>
--     @0x340 (targets have no verified metadata snapshots; not
--     created here — one class per file, no transitive explosion)
--   - mFetchHandle AsyncHandle @0x2EC, mPlayerGarageFetchHandle
--     AsyncHandle @0x2F0, mStoreWcRaceHandle AsyncHandle @0x308
--     (AsyncHandle has no class/struct definition in the dump —
--     layout cannot be verified without guessing)
--
-- Reused existing snapshots (not duplicated): LeagueDefinition
-- (mLeagueDefinition @0x230), EventDefinition (mEventDefinition
-- @0x298), VehicleStatus (mVehicleStatus @0x390); enums RaceInfoState,
-- WinStreakShieldType, GameMode, eRaceType.

local Manifest = loadModule("metadata/manifest.lua")

local LeagueDefinition = Manifest.load("LeagueDefinition")
local EventDefinition  = Manifest.load("EventDefinition")
local VehicleStatus    = Manifest.load("VehicleStatus")

return {
    ["raceInfoState"] = {
        -- dump: RaceInfoState raceInfoState // 0x18
        offset = 0x18,
        type = "Enum",
        enum = "RaceInfoState"
    },
    ["coinsBeforeRace"] = {
        offset = 0x98,
        type = "Int32"
    },
    ["trickBonusCoins"] = {
        offset = 0x9C,
        type = "Int32"
    },
    ["collectedCoins"] = {
        offset = 0xA0,
        type = "Int32"
    },
    ["collectedCoinsBase"] = {
        offset = 0xA4,
        type = "Int32"
    },
    ["coinCollectibleMultiplier"] = {
        offset = 0xA8,
        type = "Int32"
    },
    ["collectedCoinObjects"] = {
        offset = 0xAC,
        type = "Int32"
    },
    ["collectedGems"] = {
        offset = 0xB0,
        type = "Int32"
    },
    ["collectedTuningParts"] = {
        offset = 0xB4,
        type = "Int32"
    },
    ["collectedTriggers"] = {
        offset = 0xB8,
        type = "Int32"
    },
    ["finishBonusCoins"] = {
        offset = 0xBC,
        type = "Int32"
    },
    ["airtimeBonusCoins"] = {
        offset = 0xC0,
        type = "Int32"
    },
    ["bigAirtimeTicks"] = {
        offset = 0xC4,
        type = "Int32"
    },
    ["flipBonusCoins"] = {
        offset = 0xC8,
        type = "Int32"
    },
    ["wheelieBonusCoins"] = {
        offset = 0xCC,
        type = "Int32"
    },
    ["finishTimeBonus"] = {
        offset = 0xE8,
        type = "Float"
    },
    ["finishTimeBonusPoints"] = {
        offset = 0xEC,
        type = "Float"
    },
    ["collectedDailyRewards"] = {
        offset = 0xF0,
        type = "Int32"
    },
    ["racePoints"] = {
        offset = 0xF4,
        type = "Int32"
    },
    ["collectedXp"] = {
        offset = 0xF8,
        type = "Int32"
    },
    ["respawnCount"] = {
        offset = 0xFC,
        type = "Int32"
    },
    ["respawnAdsWatched"] = {
        offset = 0x100,
        type = "Int32"
    },
    ["respawnGracePeriodUsed"] = {
        offset = 0x104,
        type = "Bool"
    },
    ["usingLocalCachedCups"] = {
        offset = 0x105,
        type = "Bool"
    },
    ["masteryBonusXpValue"] = {
        offset = 0x108,
        type = "Float"
    },
    ["masteryBonusXpCounter"] = {
        offset = 0x10C,
        type = "Int32"
    },
    ["gainedMasteryXp"] = {
        -- dump: JSONSafeInt gainedMasteryXp // 0x110
        offset = 0x110,
        type = "JSONSafeInt"
    },
    ["gainedMasteryXpCupResult"] = {
        -- dump: JSONSafeInt gainedMasteryXpCupResult // 0x130
        offset = 0x130,
        type = "JSONSafeInt"
    },
    ["skippedFuelCanisters"] = {
        offset = 0x150,
        type = "Int32"
    },
    ["breakableObjectsDestroyed"] = {
        offset = 0x154,
        type = "Int32"
    },
    ["distanceBonus"] = {
        offset = 0x158,
        type = "Float"
    },
    ["destroyBonus"] = {
        offset = 0x15C,
        type = "Float"
    },
    ["oldRecord"] = {
        offset = 0x160,
        type = "Float"
    },
    ["collectedDistanceCollectibleAmount"] = {
        offset = 0x180,
        type = "Int32"
    },
    ["collectedDistanceCollectibleCount"] = {
        offset = 0x184,
        type = "Int32"
    },
    ["oldVehicleRecord"] = {
        offset = 0x1A0,
        type = "Float"
    },
    ["oldStars"] = {
        offset = 0x1A4,
        type = "Int32"
    },
    ["oldDivision"] = {
        offset = 0x1A8,
        type = "Int32"
    },
    ["oldRankingInDiv"] = {
        offset = 0x1AC,
        type = "Int32"
    },
    ["oldWcRank"] = {
        offset = 0x1B0,
        type = "Float"
    },
    ["consumedRankDoublers"] = {
        offset = 0x1B4,
        type = "Int32"
    },
    ["round"] = {
        offset = 0x1B8,
        type = "Int32"
    },
    ["startDistance"] = {
        offset = 0x1BC,
        type = "Float"
    },
    ["autoStartRace"] = {
        offset = 0x1C0,
        type = "Bool"
    },
    ["isAdventureFeatured"] = {
        offset = 0x1C1,
        type = "Bool"
    },
    ["hasDoubleAdventureTokenReward"] = {
        offset = 0x1C2,
        type = "Bool"
    },
    ["isBoostedVehicle"] = {
        -- dump: bool mIsBoostedVehicle // 0x1C3
        offset = 0x1C3,
        type = "Bool"
    },
    ["cupGuid"] = {
        offset = 0x1C8,
        type = "String"
    },
    ["raceGuid"] = {
        offset = 0x1E0,
        type = "String"
    },
    ["usedWinStreakShield"] = {
        -- dump: WinStreakShieldType usedWinStreakShield // 0x1F8
        offset = 0x1F8,
        type = "Enum",
        enum = "WinStreakShieldType"
    },
    ["seed"] = {
        -- dump: private int mSeed // 0x210
        offset = 0x210,
        type = "Int32"
    },
    ["levelId"] = {
        -- dump: private string mLevelId // 0x218
        offset = 0x218,
        type = "String"
    },
    ["leagueDefinition"] = {
        -- dump: private LeagueDefinition mLeagueDefinition // 0x230
        -- 8-byte reference slot (next field @0x238); POINTER, deref'd
        -- via Object — same convention as GameStatus.driver @0x168.
        offset = 0x230,
        type = "Object",
        elements = LeagueDefinition
    },
    ["vehicleId"] = {
        -- dump: private string mVehicleId // 0x250
        offset = 0x250,
        type = "String"
    },
    ["gameMode"] = {
        -- dump: private GameMode mGameMode // 0x268 (GameMode is an
        -- enum, TypeDefIndex 191, Size 0x4)
        offset = 0x268,
        type = "Enum",
        enum = "GameMode"
    },
    ["eventDefinition"] = {
        -- dump: private Pointer<EventDefinition> mEventDefinition // 0x298
        offset = 0x298,
        type = "Object",
        elements = EventDefinition
    },
    ["friendlyRaceId"] = {
        -- dump: private string mFriendlyRaceId // 0x2B8
        offset = 0x2B8,
        type = "String"
    },
    ["sessionId"] = {
        -- dump: private string mSessionId // 0x2D0
        offset = 0x2D0,
        type = "String"
    },
    ["tournamentRaceIndex"] = {
        -- dump: private int mTournamentRaceIndex // 0x2E8
        offset = 0x2E8,
        type = "Int32"
    },
    ["sendFullReplays"] = {
        -- dump: private bool mSendFullReplays // 0x380
        offset = 0x380,
        type = "Bool"
    },
    ["isChallengeFeatured"] = {
        -- dump: private bool mIsChallengeFeatured // 0x381
        offset = 0x381,
        type = "Bool"
    },
    ["isSignatureChallenge"] = {
        -- dump: private bool mIsSignatureChallenge // 0x382
        offset = 0x382,
        type = "Bool"
    },
    ["raceType"] = {
        -- dump: private eRaceType mRaceType // 0x384
        offset = 0x384,
        type = "Enum",
        enum = "eRaceType"
    },
    ["vehicleStatus"] = {
        -- dump: private Pointer<VehicleStatus> mVehicleStatus // 0x390
        offset = 0x390,
        type = "Object",
        elements = VehicleStatus
    },
}
