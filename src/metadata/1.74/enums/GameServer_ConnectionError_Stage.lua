---@class GameServer_ConnectionError_Stage
-- Source (IL2CPP dump): GameServer::ConnectionError
-- Auto-generated from a bulk enum dump (enums.cs). Not
-- individually curated/cross-referenced like ChestType/TuningRarity/
-- UnlockType/GameStatusFlag — verify a given ID against on-device
-- behavior before relying on it for anything write-side.
return {
    byId = {
        [0] = "NONE",
        [1] = "GETADDRINFO",
        [2] = "CREATE_SOCKET",
        [3] = "SET_NONBLOCKING",
        [4] = "CONNECT",
        [5] = "SET_BLOCKING",
        [6] = "CREATE_SSL",
        [7] = "SET_SSL_SOCKET",
        [8] = "CONNECT_SSL",
        [9] = "VALIDATE_CERT",
    },
    byName = {
        NONE = 0,
        GETADDRINFO = 1,
        CREATE_SOCKET = 2,
        SET_NONBLOCKING = 3,
        CONNECT = 4,
        SET_BLOCKING = 5,
        CREATE_SSL = 6,
        SET_SSL_SOCKET = 7,
        CONNECT_SSL = 8,
        VALIDATE_CERT = 9,
    },
}
