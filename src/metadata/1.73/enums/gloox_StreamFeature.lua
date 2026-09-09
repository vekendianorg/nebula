---@class gloox_StreamFeature
-- Source (IL2CPP dump): gloox
-- Auto-generated from a bulk enum dump (enums.cs). Not
-- individually curated/cross-referenced like ChestType/TuningRarity/
-- UnlockType/GameStatusFlag — verify a given ID against on-device
-- behavior before relying on it for anything write-side.
return {
    byId = {
        [1] = "StreamFeatureBind",
        [2] = "StreamFeatureUnbind",
        [4] = "StreamFeatureSession",
        [8] = "StreamFeatureStartTls",
        [16] = "StreamFeatureIqRegister",
        [32] = "StreamFeatureIqAuth",
        [64] = "StreamFeatureCompressZlib",
        [128] = "StreamFeatureCompressDclz",
        [256] = "StreamFeatureStreamManagement",
        [512] = "StreamFeatureClientStateIndication",
    },
    byName = {
        StreamFeatureBind = 1,
        StreamFeatureUnbind = 2,
        StreamFeatureSession = 4,
        StreamFeatureStartTls = 8,
        StreamFeatureIqRegister = 16,
        StreamFeatureIqAuth = 32,
        StreamFeatureCompressZlib = 64,
        StreamFeatureCompressDclz = 128,
        StreamFeatureStreamManagement = 256,
        StreamFeatureClientStateIndication = 512,
    },
}
