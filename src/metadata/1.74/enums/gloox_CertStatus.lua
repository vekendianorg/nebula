---@class gloox_CertStatus
-- Source (IL2CPP dump): gloox
-- Auto-generated from a bulk enum dump (enums.cs). Not
-- individually curated/cross-referenced like ChestType/TuningRarity/
-- UnlockType/GameStatusFlag — verify a given ID against on-device
-- behavior before relying on it for anything write-side.
return {
    byId = {
        [0] = "CertOk",
        [1] = "CertInvalid",
        [2] = "CertSignerUnknown",
        [4] = "CertRevoked",
        [8] = "CertExpired",
        [16] = "CertNotActive",
        [32] = "CertWrongPeer",
        [64] = "CertSignerNotCa",
    },
    byName = {
        CertOk = 0,
        CertInvalid = 1,
        CertSignerUnknown = 2,
        CertRevoked = 4,
        CertExpired = 8,
        CertNotActive = 16,
        CertWrongPeer = 32,
        CertSignerNotCa = 64,
    },
}
