--==================================================
-- metadata/1.73/Algorithm.lua
--==================================================
-- Element template for LevelDefinition.algorithm /
-- caveBottomAlgorithm / caveTopAlgorithm (pointer-slot members —
-- POINTERs, deref'd via Object containers).
--
-- Dump source (libcocos2dcpp.cs, 1.73 dump):
--   public class Algorithm // TypeDefIndex: 888 Size: 0x88
--       Confidence: exact
--       public AlgorithmType type;            // 0x0
--       public string id;                     // 0x8
--       public string expr;                   // 0x20
--       public cocos2d_Vec2 offset;           // 0x38
--       public cocos2d_Vec2 scale;            // 0x40
--       public float expr_x;                  // 0x48
--       public Expression<float> expr_terrain; // 0x50
--       public float[] expr_k;                // 0x58
--       public Utils_Random dailyRandom;      // 0x68
--       public Dictionary<int, float> validationPoints; // 0x70
--
-- This is a CLASS, not an enum — the LevelDefinition fields that
-- reference it are 8-byte-spaced pointer slots (0x108 → 0x110 →
-- 0x118), matching every other pointer-member layout in the dump.
-- (A prior version of LevelDefinition.lua wrongly declared these
-- as type = "Enum", enum = "Algorithm"; that name has no enum
-- file in either version snapshot and crashed Enum.lua's reader
-- with "attempt to index ? (a nil value) with key 'byId'".)
--
-- The sub-objects (Expression<float> @0x50, Utils_Random @0x68,
-- Dictionary<int,float> @0x70) have no supported representation —
-- left header-only, matching the repo's "known offset, kept
-- unreadable until mapped" convention.
return {
    ["type"] = {
        offset = 0x0,
        type = "Enum",
        enum = "AlgorithmType"
    },
    ["id"] = {
        offset = 0x8,
        type = "String"
    },
    ["expr"] = {
        offset = 0x20,
        type = "String"
    },
    ["offset"] = {
        offset = 0x38,
        type = "Vec2"
    },
    ["scale"] = {
        offset = 0x40,
        type = "Vec2"
    },
    ["expr_x"] = {
        offset = 0x48,
        type = "Float"
    },
    ["expr_terrain"] = {
        -- dump: Expression<float> // 0x50 — no supported reader
        offset = 0x50,
        type = "Object"
    },
    ["expr_k"] = {
        -- dump: float[] // 0x58 — C-style array (raw data pointer,
        -- no size header) — no supported reader
        offset = 0x58,
        type = "Object"
    },
    ["dailyRandom"] = {
        -- dump: Utils_Random // 0x68 — no metadata snapshot
        offset = 0x68,
        type = "Object"
    },
    ["validationPoints"] = {
        -- dump: Dictionary<int, float> // 0x70 — std::map ABI, no
        -- supported representation
        offset = 0x70,
        type = "Object"
    },
}
