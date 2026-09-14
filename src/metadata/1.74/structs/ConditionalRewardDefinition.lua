--==================================================
-- metadata/1.74/ConditionalRewardDefinition.lua
--==================================================
-- Struct-element template for ConditionalRewardDefinition, shared
-- by every reward array on EventDefinition: eventRewards,
-- eventSpecials, rotatingEventRewards, mainEventRewards and
-- premiumEventRewards (all List<ConditionalRewardDefinition> in
-- the IL2CPP dump, pointer-based elements).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class ConditionalRewardDefinition
--       // Size: 0x30  Confidence: exact
--       public RewardCondition rewardCondition; // 0x0
--       public LootDefinition lootDefinition;   // 0x20
--       public int maxCollectAmount;            // 0x28
--
-- rewardCondition is modeled as Float at 0x4 rather than an
-- Object: RewardCondition is { WinCondition type @0x0,
-- float criteria @0x4, List<int> criteriaCurve @0x8 }, and the
-- on-device-verified read has always been the float `criteria`
-- member. A full RewardCondition sub-template can be added later
-- without moving these offsets.
--
-- Elements are pointer-backed (List<T> → Pointer<T>, stride 0x8
-- default) — the caller sets the container/stride context.

local Manifest = loadModule("metadata/manifest.lua")

local LootDefinition = Manifest.load("LootDefinition")

local M = {
    ["rewardCondition"] = {
        offset = 0x4,
        type = "Float"
    },
    ["lootDefinition"] = {
        offset = 0x20,
        type = "Object",
        elements = LootDefinition
    },
    ["maxCollectAmount"] = {
        offset = 0x28,
        type = "Int32"
    }
}

return M
