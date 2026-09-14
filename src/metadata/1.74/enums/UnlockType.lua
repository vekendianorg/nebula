---@class UnlockType
-- Hand-curated driver customization slot types
-- (DRIVER_HEAD/DRIVER_BODY/etc). See
-- metadata/1.74/enums/UnlockConditionType.lua's naming note: the
-- dump enum literally named "UnlockType" (TypeDefIndex 394) is a
-- different enum, renamed UnlockConditionType here. Used by the
-- `type` field of the Unlock struct (metadata/1.74/structs/Unlock.lua).

return {
    byId = {
        [0] = "DRIVER_HEAD",
        [1] = "DRIVER_BODY",
        [2] = "DRIVER_LEGS",
        [3] = "CAR_ATTACHMENT",
        [4] = "DRIVER_HAT",
        [5] = "CAR_SPRITE",
        [6] = "DRIVER_BACK_ATTACHMENT",
        [7] = "DRIVER_ANIMATION",
    },
    byName = {
        DRIVER_HEAD = 0,
        DRIVER_BODY = 1,
        DRIVER_LEGS = 2,
        CAR_ATTACHMENT = 3,
        DRIVER_HAT = 4,
        CAR_SPRITE = 5,
        DRIVER_BACK_ATTACHMENT = 6,
        DRIVER_ANIMATION = 7,
    },
}
