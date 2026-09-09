---@class SyncManager_SyncState
-- Source (IL2CPP dump): SyncManager
-- Auto-generated from a bulk enum dump (enums.cs). Not
-- individually curated/cross-referenced like ChestType/TuningRarity/
-- UnlockType/GameStatusFlag — verify a given ID against on-device
-- behavior before relying on it for anything write-side.
return {
    byId = {
        [0] = "NO_ACCOUNT",
        [1] = "ACCOUNT_BUT_NO_CLOUD_SAVE",
        [2] = "ACCOUNT_BUT_INVALID_CLOUD_SAVE",
        [3] = "CONNECTED_WITH_CLOUD_SAVE",
        [4] = "FETCHING_PLAYER_ID",
        [5] = "FETCHING_CAREER",
        [6] = "FETCHING_FRIENDS",
        [7] = "VERIFYING_CLOUD_SAVE",
        [8] = "MERGE_PROMPT",
        [9] = "CLOUD_CONNECT_CANCELLED",
        [10] = "FETCH_PRIVATE_DATA_FAILED",
        [11] = "PUSH_LOCAL_CAREER_FAILED",
    },
    byName = {
        NO_ACCOUNT = 0,
        ACCOUNT_BUT_NO_CLOUD_SAVE = 1,
        ACCOUNT_BUT_INVALID_CLOUD_SAVE = 2,
        CONNECTED_WITH_CLOUD_SAVE = 3,
        FETCHING_PLAYER_ID = 4,
        FETCHING_CAREER = 5,
        FETCHING_FRIENDS = 6,
        VERIFYING_CLOUD_SAVE = 7,
        MERGE_PROMPT = 8,
        CLOUD_CONNECT_CANCELLED = 9,
        FETCH_PRIVATE_DATA_FAILED = 10,
        PUSH_LOCAL_CAREER_FAILED = 11,
    },
}
