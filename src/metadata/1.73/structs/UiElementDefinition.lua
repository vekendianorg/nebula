--==================================================
-- metadata/1.73/UiElementDefinition.lua
--==================================================
-- Element template for List<UiElementDefinition>
-- (EventDefinition.uiElements @0x5a8, INLINE elements,
-- elementStride = sizeof(UiElementDefinition) = 0xa0, derived from
-- field extents: trigger@0x70 + sizeof(UiElementTriggerDefinition)
-- 0x30). The trigger (UiElementTriggerDefinition = { gamemodes
-- List<string> @0x0, scenes List<string> @0x18 }) is inlined at
-- 0x70/0x88.
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class UiElementDefinition
--       // Size: 0xa0  Confidence: exact
--       public string id;             // 0x0
--       public string file;           // 0x18
--       public string actionTimeline; // 0x30
--       public bool loopAction;       // 0x48
--       public string parentNode;     // 0x50
--       public int showTimes;         // 0x68
--       public UiElementTriggerDefinition trigger; // 0x70

return {
    ["id"] = {
        offset = 0x0,
        type = "String"
    },
    ["file"] = {
        offset = 0x18,
        type = "String"
    },
    ["actionTimeline"] = {
        offset = 0x30,
        type = "String"
    },
    ["loopAction"] = {
        offset = 0x48,
        type = "Bool"
    },
    ["parentNode"] = {
        offset = 0x50,
        type = "String"
    },
    ["showTimes"] = {
        offset = 0x68,
        type = "Int32"
    },
    ["triggerGamemodes"] = {
        -- UiElementTriggerDefinition.gamemodes @0x70 (List<string>,
        -- inline std::vector<std::string>, string stride 0x18)
        offset = 0x70,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
    ["triggerScenes"] = {
        -- UiElementTriggerDefinition.scenes @0x88
        offset = 0x88,
        type = "Array",
        elementType = "String",
        elementStride = 0x18
    },
}
