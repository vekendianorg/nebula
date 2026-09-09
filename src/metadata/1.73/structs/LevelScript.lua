--==================================================
-- metadata/1.73/LevelScript.lua
--==================================================
-- Element template for List<LevelScript>
-- (EventDefinition.scripts @0x4e8 and inline
-- GameModeDefinition.scripts -> EventDefinition.sessionScripts
-- @0x438, INLINE elements, elementStride = sizeof(LevelScript) =
-- 0x10). The vptr @0x0 is not mappable.
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class LevelScript
--       // Size: 0x10  Confidence: exact
--       public function _vptr_LevelScript; // 0x0
--       public bool runEarly;              // 0x8

return {
    ["runEarly"] = { offset = 0x8, type = "Bool" },
}
