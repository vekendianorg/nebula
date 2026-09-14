--==================================================
-- metadata/1.74/FeaturedChallenge.lua
--==================================================
-- Element template for GameStatus.featuredChallenges
-- (RepeatedPtrField<FeaturedChallenge>, POINTER-slot elements, default stride).
return {
    ["challengeId"] = {
        offset = 0x18,
        type = "String"
    },
    ["expirationTimestamp"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["unlimitedTries"] = {
        offset = 0x24,
        type = "Bool"
    },
    ["challengeWon"] = {
        offset = 0x25,
        type = "Bool"
    },
    ["rewardClaimed"] = {
        offset = 0x26,
        type = "Bool"
    },
    ["videoRetriesRemaining"] = {
        offset = 0x28,
        type = "Int32"
    },
}
