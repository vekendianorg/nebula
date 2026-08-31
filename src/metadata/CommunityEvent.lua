--==================================================
-- metadata/CommunityEvent.lua
--==================================================
-- Field table for the CommunityShowcase event struct.
--
-- Cross-referenced with the shared header offsets from
-- PublicEvent/TeamEvent (id, name, startTime, endTime,
-- sessionEntry fields, duration, joinWindow, etc. are at the
-- same absolute offsets). Verified against the IL2CPP dump:
-- CommunityEvent is also backed by the shared EventDefinition
-- struct (Size 0x5D8, Confidence: exact), so the header offsets
-- id 0x8 / name 0x20 / description 0x38 / eventIcon 0x80 /
-- minRankToJoin 0x140 / startTimeLive 0x14C / startTime 0x150 /
-- endTime 0x154 / sessionEntry 0x160 and the gameMode children
-- all match exactly.
--
-- This is a SIMPLER struct than PublicEvent/TeamEvent:
--   - No contentVersion field (resolution uses string search,
--     not byte-signature scanning, so there's no signature to
--     version-check against)
--   - No eventRewards / lootDefinition / rotatingEventRewards /
--     mainEventRewards / premiumEventRewards
--   - No gemsToPointsConversion / conversionDuration
--   - No fixedVehicles / specialFeatures / eventSpecials
--   - No requiredPackages
--
-- Unique field vs PublicEvent/TeamEvent:
--   - minRankToJoin (0x140) — PublicEvent has
--     unlockCurrentlyActiveSegment there, TeamEvent has
--     minTeamSizeToJoin. CommunityEvent has minRankToJoin.
--
-- Resolution is string-based (see core/Memory.lua's
-- resolveActiveCommunityEventBase), not AOB — the search target
-- is the event's own name field ("community Showcase"), so the
-- "signature" is the event identity itself, not a config constant.
--
-- String fields use the same ABI as PublicEvent/TeamEvent —
-- inlined C++ strings, no pointer indirection. The shadowStringDirect()
-- helper in api/CommunityEvent.lua handles this, same as the other
-- event modules.
--
-- offset = 0xBAAD means the offset is NOT YET KNOWN.

return {
    ["id"] = {
        offset = 0x8,
        type = "String"
    },
    ["name"] = {
        offset = 0x20,
        type = "String"
    },
    ["description"] = {
        offset = 0x38,
        type = "String"
    },
    ["eventIcon"] = {
        offset = 0x80,
        type = "String"
    },
    ["minRankToJoin"] = {
        offset = 0x140,
        type = "Int32"
    },
    ["startTimeLive"] = {
        offset = 0x14C,
        type = "Int32"
    },
    ["startTime"] = {
        offset = 0x150,
        type = "Int32"
    },
    ["endTime"] = {
        offset = 0x154,
        type = "Int32"
    },
    ["sessionEntry"] = {
        ["entryFeeTickets"] = {
            offset = 0x160,
            type = "Int32"
        },
        ["maxEventTickets"] = {
            offset = 0x164,
            type = "Int32"
        },
        ["eventTicketRefillTime"] = {
            offset = 0x168,
            type = "Int32"
        },
        ["eventTicketRefillAmount"] = {
            offset = 0x16C,
            type = "Int32"
        },
        ["eventTicketRefillCost"] = {
            offset = 0x170,
            type = "Int32"
        },
    },
    ["gameMode"] = {
        ["duration"] = {
            offset = 0x21C,
            type = "Int32"
        },
        ["joinWindow"] = {
            offset = 0x220,
            type = "Int32"
        },
        ["maxSessionParticipants"] = {
            offset = 0x2D0,
            type = "Int32"
        },
        ["levelPools"] = {
            offset = 0x2F0,
            type = "Array",
            -- std::vector<std::vector<std::string>>: outer elements
            -- are vector<string> objects (0x18 each), inline
            elementStride = 0x18,
            elements = {
                ["levels"] = {
                    offset = 0x0,
                    type = "Array",
                    elementType = "String",
                    elementStride = 0x18 -- inline std::string elements
                }
            }
        },
        ["pointsSystem"] = {
            offset = 0x3E0,
            type = "Object" -- known offset, no reader yet
        },
    },
}
