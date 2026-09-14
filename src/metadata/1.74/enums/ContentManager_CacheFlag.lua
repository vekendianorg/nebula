---@class ContentManager_CacheFlag
-- Source (IL2CPP dump): ContentManager
-- Auto-generated from a bulk enum dump (enums.cs). Not
-- individually curated/cross-referenced like ChestType/TuningRarity/
-- UnlockType/GameStatusFlag — verify a given ID against on-device
-- behavior before relying on it for anything write-side.
return {
    byId = {
        [0] = "CacheFlagNone",
        [1] = "CacheFlagSave",
        [2] = "CacheFlagLoad",
        [4] = "CacheFlagForceUseLocalContent",
        [8] = "CacheFlagForceUseRemoteContent",
        [3] = "CacheFlagSaveLoad",
        [16] = "CacheFlagFallback",
    },
    byName = {
        CacheFlagNone = 0,
        CacheFlagSave = 1,
        CacheFlagLoad = 2,
        CacheFlagForceUseLocalContent = 4,
        CacheFlagForceUseRemoteContent = 8,
        CacheFlagSaveLoad = 3,
        CacheFlagFallback = 16,
    },
}
