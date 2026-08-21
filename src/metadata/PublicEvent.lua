--==================================================
-- metadata/PublicEvent.lua
--==================================================
-- Field table for the PublicEvent
-- Sourced from each PublicEvent JSON(s)
-- cross-referenced with known offsets from the legacy flat
--
-- offset = 0xBAAD means the offset is NOT YET KNOWN. Do not
-- trust these fields until the placeholder is replaced by a
-- verified static offset.
--
-- contentVersion..pointsSystem is the header shared with
-- TeamEvent (see metadata/TeamEvent.lua). Fields past
-- fixedVehicles (0x4A0) are PublicEvent-only and must NOT be mirrored
-- onto TeamEvent as-is — TeamEvent has its own divergent tail.
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
-- Reward element template — shared by eventRewards,
-- mainEventRewards, premiumEventRewards, rotatingEventRewards.
-- All four use the same element layout.
--==================================================
local rewardElements = {
    ["rewardCondition"] = {
        offset = 0x4,
        type = "Float"
    },
    ["lootDefinition"] = {
        offset = 0x20,
        type = "Object",
        ["id"] = {
            offset = 0x0,
            type = "String"
        },
        ["rankAmount"] = {
            offset = 0x1C,
            type = "Float"
        },
        ["coinAmount"] = {
            offset = 0x20,
            type = "Int32"
        },
        ["gemAmount"] = {
            offset = 0x24,
            type = "Int32"
        },
        ["bonusXpAmount"] = {
            offset = 0x28,
            type = "Int32"
        },
        ["unlockVehicleLevel"] = {
            offset = 0x2C,
            type = "Int32"
        },
        ["unlockVehicles"] = {
            offset = 0x48,
            type = "Array",
            elementType = "String",
            elementStride = 0x18
        },
        ["unlockDriverAssets"] = {
            offset = 0x60,
            type = "Array",
            elementType = "String",
            elementStride = 0x18
        },
        ["unlockDriverAnimations"] = {
            offset = 0x78,
            type = "Array",
            elementType = "String",
            elementStride = 0x18
        },
        ["unlockAdventureMaps"] = {
            offset = 0xC0,
            type = "Array",
            elementType = "String",
            elementStride = 0x18
        },
        ["unlockEditorThemes"] = {
            offset = 0xD8,
            type = "Array",
            elementType = "String",
            elementStride = 0x18
        },
        ["chests"] = {
            offset = 0xF0,
            type = "Array",
            elementType = "Enum",
            elementStride = 4,
            enum = "ChestType"
        },
        ["unlockHomeBackgrounds"] = {
            offset = 0x198,
            type = "Array",
            elementType = "String",
            elementStride = 0x18
        },
        ["currencies"] = {
            offset = 0x120,
            type = "Array",
            elementStride = 0x20,
            elements = {
                ["currency"] = {
                    offset = 0x0,
                    type = "String"
                },
                ["amount"] = {
                    offset = 0x18,
                    type = "Int32"
                }
            }
        },
        ["tuningParts"] = {
            offset = 0x150,
            type = "Array",
            elementStride = 0x38,
            elements = {
                ["id"] = {
                    offset = 0x0,
                    type = "String"
                },
                ["vehicleId"] = {
                    offset = 0x18,
                    type = "String"
                },
                ["amount"] = {
                    offset = 0x30,
                    type = "Int32"
                },
                ["rarity"] = {
                    offset = 0x34,
                    type = "Enum",
                    enum = "TuningRarity"
                }
            }
        },
        ["unlockVehiclePaints"] = {
            offset = 0x90,
            type = "Array",
            elementStride = 0x30,
            elements = {
                ["paintId"] = {
                    offset = 0x0,
                    type = "String"
                },
                ["vehicleId"] = {
                    offset = 0x18,
                    type = "String"
                }
            }
        },
        ["unlockVehicleSpriteVariants"] = {
            offset = 0xA8,
            type = "Array",
            elementStride = 0x48,
            elements = {
                ["partId"] = {
                    offset = 0x0,
                    type = "String"
                },
                ["variantId"] = {
                    offset = 0x18,
                    type = "String"
                },
                ["vehicleId"] = {
                    offset = 0x30,
                    type = "String"
                }
            }
        },
        ["vehicleChests"] = {
            offset = 0x108,
            type = "Array",
            elementStride = 0x38,
            elements = {
                ["vehicleId"] = {
                    offset = 0x0,
                    type = "String"
                },
                ["chestId"] = {
                    offset = 0x18,
                    type = "Enum",
                    enum = "ChestType"
                },
                ["targetIndex"] = {
                    offset = 0x1C,
                    type = "Int32"
                }
            }
        },
        ["unlockHomeProps"] = {
            offset = 0x180,
            type = "Array",
            elementStride = 0x20,
            elements = {
                ["id"] = {
                    offset = 0x0,
                    type = "String"
                },
                ["amount"] = {
                    offset = 0x18,
                    type = "Int32"
                }
            }
        },
        ["customChests"] = {
            offset = 0x1B0,
            type = "Array",
            elementStride = 0x50,
            elements = {
                ["name"] = {
                    offset = 0x0,
                    type = "String"
                },
                ["chestImageOpen"] = {
                    offset = 0x18,
                    type = "String"
                },
                ["chestImageClosed"] = {
                    offset = 0x30,
                    type = "String"
                },
                ["gems"] = {
                    offset = 0x48,
                    type = "Int32"
                }
            }
        }
    },
    ["maxCollectAmount"] = {
        offset = 0x28,
        type = "Int32"
    }
}

return {
    ["contentVersion"] = {
        offset = 0x0,
        type = "Int32"
    },
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
    ["requiredPackages"] = {
        offset = 0x50,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["eventIcon"] = {
        offset = 0x80,
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
    ["unlockCurrentlyActiveSegment"] = {
        offset = 0x140,
        type = "Int32"
    },
    ["minTeamSizeToJoin"] = {
        offset = 0x144,
        type = "Int32"
    },
    ["startTime"] = {
        offset = 0x14C,
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
        ["numberOfParallelSessions"] = {
            offset = 0x174,
            type = "Int32"
        },
        ["maxSpecialTicketsPerMatch"] = {
            offset = 0x178,
            type = "Int32"
        }
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
        ["gameMode"] = {
            offset = 0xBAAD,
            type = "String"
        },
        ["maxSessionParticipants"] = {
            offset = 0x2D0,
            type = "Int32"
        },
        ["maxBotCount"] = {
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
            elementStride = 0x18
        },
        ["levelPool"] = {
            ["poolOrder"] = {
                offset = 0xBAAD,
                type = "String"
            },
            ["levelOrder"] = {
                offset = 0xBAAD,
                type = "String"
            },
            ["levelPools"] = {
                offset = 0x2F0,
                type = "Array",
                elementStride = 0x18,
                elements = {
                    ["levels"] = {
                        offset = 0x0,
                        type = "Array",
                        elementType = "String",
                        elementStride = 0x18
                    }
                }
            }
        },
        ["pointsSystem"] = {
            offset = 0x3E0,
            ["function"] = {
                offset = 0x400,
                type = "String"
            },
            ["type"] = {
                offset = 0xBAAD,
                type = "String"
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
        type = "Array"
    },
    ["fixedVehicles"] = {
        offset = 0x4A0,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["specialFeatures"] = {
        offset = 0x4D0,
        type = "Array",
        elements = {
            ["id"] = {
                offset = 0x0,
                type = "String"
            },
            ["name"] = {
                offset = 0x48,
                type = "String"
            },
            ["description"] = {
                offset = 0x60,
                type = "String"
            },
            ["icon"] = {
                offset = 0x30,
                type = "String"
            },
            ["startingLevel"] = {
                offset = 0x78,
                type = "Int32"
            },
            ["maxLevels"] = {
                offset = 0x7C,
                type = "Int32"
            },
            ["mode"] = {
                offset = 0x80,
                type = "Int32"
            },
            ["amount"] = {
                offset = 0x88,
                type = "Float"
            },
            ["amountX"] = {
                offset = 0x90,
                type = "Float"
            },
            ["return"] = {
                offset = 0x98,
                type = "Int32"
            }
        }
    },
    ["eventRewards"] = {
        offset = 0x528,
        type = "Array",
        elements = rewardElements
    },
    ["rotatingEventRewards"] = {
        offset = 0x558,
        type = "Array",
        elements = rewardElements
    },
    ["rotatingEventRewardsInterval"] = {
        offset = 0x570,
        type = "Int32"
    },
    ["mainEventRewards"] = {
        offset = 0x578,
        type = "Array",
        elements = rewardElements
    },
    ["premiumEventRewards"] = {
        offset = 0x590,
        type = "Array",
        elements = rewardElements
    }
}
