--==================================================
-- metadata/1.74/EventDefinition.lua
--==================================================
-- Complete metadata snapshot for the EventDefinition struct at
-- game version 1.74 (see metadata/manifest.lua for how a running
-- game version resolves to this file). This is the single
-- authoritative field layout backing Nebula.PublicEvent,
-- Nebula.TeamEvent and Nebula.CommunityEvent — all three are bound
-- to struct = "EventDefinition" via Nebula.defineApi() and expose
-- every field below with no per-event-type filtering. See
-- core/defineApi.lua.
--
-- Originally sourced from each PublicEvent JSON(s), cross-referenced
-- with known offsets from the legacy flat metadata, then unioned
-- with the TeamEvent-only tail (multiRaceGameModes,
-- winningTeamReward) confirmed by the IL2CPP dump: PublicEvent,
-- TeamEvent and CommunityEvent are all backed by the SAME
-- EventDefinition struct (Size 0x5D8, Confidence: exact) —
-- Dictionary<string, Pointer<EventDefinition>> — so this file is
-- the union of every field observed across all three, not just the
-- subset any single event type happens to use.
--
-- offset = 0xBAAD means the offset is NOT YET KNOWN. Do not
-- trust these fields until the placeholder is replaced by a
-- verified static offset.
--
-- Cross-referenced against a confirmed exact-confidence IL2CPP
-- struct dump of EventDefinition (Size 0x5D8) —
-- every offset below matches that dump. The dump also settles what
-- was previously an assumed naming conflict at 0x140/0x144: these
-- are two DIFFERENT real fields — minRankToJoin (0x140) and
-- minTeamSizeToJoin (0x144) — not one field disputed between event
-- types. The struct also has several fields no event-API module
-- previously read at all (notificationMessage, eventResultCsb,
-- eventsTabButtonIcon, eventMusic, eventGarageBackground,
-- rankBrackets, eventSeed, erodeSurface, isCommunityTrackEvent,
-- bonusVehiclePoints, bonusVehiclePool, scripts, boosterSessionInterval,
-- uiElements, collectiblesOverride) — all now fully mapped from the
-- dump, including the previously header-only element templates
-- (EventsTabButtonIcon, LevelScript, UiElementDefinition,
-- CollectibleDefinition incl. its ObjectDefinition base and
-- AttachmentDefinition children).
--
-- Every leaf field's offset is absolute (from the struct base) — no
-- offset accumulates through parent containers. Pure namespace
-- containers like sessionEntry/gameMode carry no offset of their
-- own, just absolute-offset children. A container CAN have both an
-- offset of its own (e.g. pointsSystem) and typed children (e.g.
-- pointsSystem.function) — those children's offsets are still
-- absolute, already computed from struct base, not from the
-- parent's offset.
--
-- Array fields use one of:
--   elements = { ... }        → per-element struct template
--   elementType = "String"    → simple typed inline elements
--   elementStride = N            (stride N, no pointer dereference)
--   (neither)                 → vector header only, not readable
--
-- Empty arrays are suppressed from output (not shown as {}).

--==================================================
-- Shared struct-element templates
--==================================================
-- Element templates are no longer inlined here. Every repeated
-- field whose elements are a real C++ class is bound to its own
-- versioned metadata snapshot — metadata/<Class>/<version>.lua,
-- registered in manifest.lua's VERSIONS and resolved for the
-- running game's version exactly like GameStatus and
-- EventDefinition themselves. Every file is cross-verified
-- against the IL2CPP dump (temp/libcocos2dcpp.cs, class name +
-- Size cited in its header):
--
--   ConditionalRewardDefinition  ← eventRewards, eventSpecials,
--                                   rotatingEventRewards,
--                                   mainEventRewards,
--                                   premiumEventRewards
--   FixedVehicleDefinition       ← fixedVehicles (inline, 0x118)
--   SpecialFeatureDefinition     ← specialFeatures
--
-- LootDefinition and its sub-element templates (CurrencyAmount,
-- TuningPartLoot, UnlockablePaint, UnlockableSpriteVariant,
-- VehicleChest, HomePropLoot, CustomChest) are chained
-- transitively through ConditionalRewardDefinition.
--==================================================

local Manifest = loadModule("metadata/manifest.lua")

local ConditionalRewardDefinition = Manifest.load("ConditionalRewardDefinition")
local FixedVehicleDefinition      = Manifest.load("FixedVehicleDefinition")
local SpecialFeatureDefinition    = Manifest.load("SpecialFeatureDefinition")

-- Reference the shared per-class element templates.
local LevelScript                 = Manifest.load("LevelScript")
local UiElementDefinition         = Manifest.load("UiElementDefinition")
local CollectibleDefinition       = Manifest.load("CollectibleDefinition")


return {
    ["contentVersion"] = {
        -- dump: int contentVersion // 0x0
        offset = 0x0,
        type = "Int32"
    },
    ["id"] = {
        -- dump: string id // 0x8
        offset = 0x8,
        type = "String"
    },
    ["name"] = {
        -- dump: string name // 0x20
        offset = 0x20,
        type = "String"
    },
    ["description"] = {
        -- dump: string description // 0x38
        offset = 0x38,
        type = "String"
    },
    ["requiredPackages"] = {
        offset = 0x50,
        type = "Array",
        elementType = "String",
        elementStride = 0x18 -- std::vector<std::string>, inline elements
    },
    ["notificationMessage"] = {
        offset = 0x68,
        type = "String"
    },
    ["eventIcon"] = {
        offset = 0x80,
        type = "String"
    },
    ["eventResultCsb"] = {
        offset = 0x98,
        type = "String"
    },
    ["eventBackground"] = {
        offset = 0xB0,
        type = "String"
    },
    ["eventButtonBackground"] = {
        offset = 0xC8,
        type = "String"
    },
    ["eventsTabButtonIcon"] = {
        -- dump: EventsTabButtonIcon // 0xE0, INLINE member (next
        -- field eventMusic@0x110 -> gap 0x30 = sizeof
        -- (EventsTabButtonIcon)). Children carry ABSOLUTE offsets.
        ["activeIcon"] = {
            offset = 0xE0,
            type = "String"
        },
        ["inactiveIcon"] = {
            offset = 0xF8,
            type = "String"
        },
    },
    ["eventMusic"] = {
        offset = 0x110,
        type = "String"
    },
    ["eventGarageBackground"] = {
        offset = 0x128,
        type = "String"
    },
    ["minRankToJoin"] = {
        offset = 0x140,
        type = "Int32"
    },
    ["minTeamSizeToJoin"] = {
        offset = 0x144,
        type = "Int32"
    },
    ["rankBrackets"] = {
        offset = 0x148,
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
    ["eventSeed"] = {
        offset = 0x158,
        type = "Int32"
    },
    ["erodeSurface"] = {
        offset = 0x15C,
        type = "Bool"
    },
    ["isCommunityTrackEvent"] = {
        offset = 0x15D,
        type = "Bool"
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
        ["numberOfParallelSessions"] = {
            -- !! DISCREPANCY !! The dump's EntryDefinition names 0x14
            -- (absolute 0x174) `int entryFeeSpecialTickets`, not
            -- numberOfParallelSessions. Legacy JSON name kept — needs
            -- an on-device check to settle which semantic is right.
            offset = 0x174,
            type = "Int32"
        },
        ["maxSpecialTicketsPerMatch"] = {
            offset = 0x178,
            type = "Int32"
        }
    },
    ["bonusVehiclePoints"] = {
        offset = 0x17C,
        type = "Int32"
    },
    ["bonusVehiclePool"] = {
        offset = 0x180,
        type = "Array",
        elementType = "String",
        elementStride = 0x18 -- std::vector<std::string>, inline elements
    },
    ["gameMode"] = {
        -- Inline GameModeDefinition (base 0x198, dump Size 0x350).
        -- `fixedVehicles` (0x198+0x308=0x4A0) and `specialFeatures`
        -- (0x198+0x338=0x4D0) are exposed as top-level entries below.
        -- === previously mapped ===
        ["duration"] = {
            offset = 0x21C,
            type = "Int32"
        },
        ["joinWindow"] = {
            offset = 0x220,
            type = "Int32"
        },
        -- === dump GameModeDefinition members added in the full-field
        -- === audit (base 0x198; offsets absolute) ===
        ["title"] = {
            offset = 0x1A0,
            type = "String"
        },
        ["description"] = {
            offset = 0x1B8,
            type = "String"
        },
        ["finishMessage"] = {
            offset = 0x1D0,
            type = "String"
        },
        ["didNotFinishMessage"] = {
            offset = 0x1E8,
            type = "String"
        },
        ["resultIcon"] = {
            offset = 0x200,
            type = "String"
        },
        ["raceType"] = {
            offset = 0x218,
            type = "Int32"
        },
        ["wheelieMode"] = {
            offset = 0x224,
            type = "Bool"
        },
        ["driverJumpMode"] = {
            offset = 0x225,
            type = "Bool"
        },
        ["autoEjectOnDriverJump"] = {
            offset = 0x226,
            type = "Bool"
        },
        ["driverJumpJetpack"] = {
            offset = 0x227,
            type = "Bool"
        },
        ["driverJumpPerfectLandingDistanceBonus"] = {
            offset = 0x228,
            type = "Int32"
        },
        ["driverJumpVehicleLandingDistanceBonus"] = {
            offset = 0x22C,
            type = "Int32"
        },
        ["penaltyBar"] = {
            offset = 0x230,
            type = "Int32"
        },
        ["targetDistanceObject"] = {
            offset = 0x238,
            type = "String"
        },
        ["targetDistanceIcon"] = {
            offset = 0x250,
            type = "String"
        },
        ["bonusTargetDefinition"] = {
            offset = 0x268,
            type = "Object"
        },
        ["showCountdown"] = {
            offset = 0x2D8,
            type = "Bool"
        },
        ["allowPointsAfterFinish"] = {
            offset = 0x2D9,
            type = "Bool"
        },
        ["disablePlayerTuningParts"] = {
            offset = 0x2DA,
            type = "Bool"
        },
        ["maxAllowedTuningParts"] = {
            offset = 0x2DC,
            type = "Int32"
        },
        ["tricksMode"] = {
            offset = 0x2E0,
            type = "Int32"
        },
        ["rounds"] = {
            offset = 0x3F8,
            type = "Object"
        },
        ["sessionRewards"] = {
            offset = 0x420,
            type = "Array",
            elements = ConditionalRewardDefinition
        },
        ["sessionScripts"] = {
            -- GameModeDefinition.scripts @0x2A0 (0x198+0x2A0=0x438);
            -- top-level `scripts` @0x4E8 is EventDefinition.scripts.
            -- List<LevelScript>, INLINE elements (stride 0x10).
            offset = 0x438,
            type = "Array",
            elementStride = 0x10,
            elements = LevelScript
        },
        ["defaultRunCountLimit"] = {
            offset = 0x450,
            type = "Int32"
        },
        ["bannedVehicles"] = {
            offset = 0x488,
            type = "Array",
            elementType = "String",
            elementStride = 0x18
        },
        ["tuningPartsOverride"] = {
            offset = 0x4B8,
            type = "String"
        },
        ["joinWindow"] = {
            offset = 0x220,
            type = "Int32"
        },
        ["gameMode"] = {
            offset = 0x198,
            type = "Int32" -- GameMode enum
        },
        ["maxSessionParticipants"] = {
            offset = 0x2D0,
            type = "Int32"
        },
        ["maxBotCount"] = {
            -- NOT FOUND in GameModeDefinition dump. Field does not exist
            -- between maxSessionParticipants (0x138) and initialFuelTank (0x13c).
            -- May have been removed or renamed. Do not trust.
            offset = 0xBAAD,
            type = "Int32"
        },
        ["initialFuelTank"] = {
            offset = 0x2D4,
            type = "Float"
        },
        ["perVehicleRunCountLimits"] = {
            offset = 0x458,
            type = "Array",
            elementType = "Int32",
            elementStride = 4
        },
        ["allowedVehicles"] = {
            offset = 0x470,
            type = "Array",
            elementType = "String",
            elementStride = 0x18 -- std::vector<std::string>, inline elements
        },
        ["levelPool"] = {
            ["poolOrder"] = {
                offset = 0x2E8,
                type = "Int32" -- LevelPoolType enum
            },
            ["levelOrder"] = {
                offset = 0x2EC,
                type = "Int32" -- LevelPoolType enum
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
            }
        },
        ["pointsSystem"] = {
            offset = 0x3E0,
            ["function"] = {
                offset = 0x400,
                type = "Object" -- ValueSequence<float>, no reader yet
            },
            ["type"] = {
                offset = 0x3C0,
                type = "Int32" -- PointsSystemType enum
            },
            ["gemsToPointsConversion"] = {
                offset = 0x3F0,
                type = "Int32"
            },
            ["conversionDuration"] = {
                offset = 0x3F4,
                type = "Int32"
            }
        }
    },

    ["eventSpecials"] = {
        offset = 0x540,
        type = "Array",
        -- dump: List<ConditionalRewardDefinition> // 0x540 — same
        -- element type as eventRewards; previously a bare
        -- vector-header-only field, now readable.
        elements = ConditionalRewardDefinition
    },
    -- TeamEvent-only fields (confirmed via IL2CPP dump against the
    -- same EventDefinition struct backing PublicEvent). Not used by
    -- PublicEvent's resolver, but present in the physical struct —
    -- and therefore accessible through any API bound to this
    -- metadata, including Nebula.PublicEvent and
    -- Nebula.CommunityEvent, per the no-filtering rule above.
    ["scripts"] = {
        -- dump: List<LevelScript> // 0x4e8, INLINE elements
        -- (stride 0x10).
        offset = 0x4E8,
        type = "Array",
        elementStride = 0x10,
        elements = LevelScript
    },
    ["multiRaceGameModes"] = {
        offset = 0x500,
        type = "Array"
    },
    ["boosterSessionInterval"] = {
        offset = 0x518,
        type = "Int32"
    },
    ["winningTeamReward"] = {
        offset = 0x520,
        -- dump: ConditionalRewardDefinition winningTeamReward // 0x520
        -- (INLINE member, Size 0x30 — not a pointer). Its children
        -- would live at absolute 0x520/0x524/0x540/0x548, but the
        -- Object reader dereferences pointer-backed children, so no
        -- reader is attached yet. Known offset, kept unreadable
        -- until inline-Object support lands.
        type = "Object"
    },
    ["fixedVehicles"] = {
        offset = 0x4A0,
        type = "Array",
        -- Inline std::vector<FixedVehicleDefinition> elements;
        -- stride = sizeof(FixedVehicleDefinition) = 0x118 derived
        -- from field extents (allowCustomization@0x114 + pad) —
        -- not from the dump class-line Size annotation.
        elementStride = 0x118,
        elements = FixedVehicleDefinition
    },
    ["specialFeatures"] = {
        offset = 0x4D0,
        type = "Object",
        elements = SpecialFeatureDefinition
    },
    ["eventRewards"] = {
        offset = 0x528,
        type = "Array",
        elements = ConditionalRewardDefinition
    },
    ["rotatingEventRewards"] = {
        offset = 0x558,
        type = "Array",
        elements = ConditionalRewardDefinition
    },
    ["rotatingEventRewardInterval"] = {
        offset = 0x570,
        type = "Int32"
    },
    ["mainEventRewards"] = {
        offset = 0x578,
        type = "Array",
        elements = ConditionalRewardDefinition
    },
    ["premiumEventRewards"] = {
        offset = 0x590,
        type = "Array",
        elements = ConditionalRewardDefinition
    },
    ["uiElements"] = {
        -- dump: List<UiElementDefinition> // 0x5a8, INLINE elements
        -- (stride = sizeof(UiElementDefinition) = 0xa0 from field
        -- extents: trigger@0x70 + sizeof(UiElementTriggerDefinition)
        -- 0x30). UiElementTriggerDefinition = { gamemodes
        -- List<string> @0x0, scenes List<string> @0x18 }, inlined at
        -- 0x70 with absolute-in-element offsets 0x70/0x88.
        offset = 0x5A8,
        type = "Array",
        elementStride = 0xA0,
        elements = UiElementDefinition
    },
    ["collectiblesOverride"] = {
        -- dump: List<CollectibleDefinition> // 0x5c0, INLINE elements
        -- (stride = sizeof(CollectibleDefinition) = 0x1a0). The
        -- 0x0-0x108 range is the inherited ObjectDefinition base
        -- (sprite/floaterSprite/additionalSprites/fullSprite/
        -- spriteSheet/animationFile/size/colliderSize/colliderScale/
        -- colliderOffset/components/shape/density/linearDamping/
        -- angularDamping/gravity/restitution/floaterIconScale/
        -- floaterOffset/verticalFlip/sensor); the derived fields
        -- start at 0x110.
        offset = 0x5C0,
        type = "Array",
        elementStride = 0x1A0,
        elements = CollectibleDefinition
    }
}
