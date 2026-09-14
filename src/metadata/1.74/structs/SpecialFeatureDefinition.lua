--==================================================
-- metadata/1.74/SpecialFeatureDefinition.lua
--==================================================
-- Struct-element template for SpecialFeatureDefinition
-- (EventDefinition.specialFeatures — List<SpecialFeatureDefinition>,
-- pointer-based elements).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class SpecialFeatureDefinition
--       // Size: 0x98  Confidence: exact
--       public string id;                    // 0x0
--       public string vehicleId;             // 0x18
--       public string icon;                  // 0x30
--       public string name;                  // 0x48
--       public string description;           // 0x60
--       public int startingLevel;            // 0x78
--       public int maxLevels;                // 0x7c
--       public int mode;                     // 0x80
--       public ValueSequence<float> amount;  // 0x88
--
-- vehicleId (0x18) is dump-confirmed and newly exposed.
-- amountX (0x90) and return (0x98) are legacy JSON-sourced reads
-- with NO dump counterpart — `return` at 0x98 is actually past
-- Size 0x98. Kept for compatibility; do not trust (candidates for
-- removal after on-device verification).

return {
    ["id"] = {
        offset = 0x0,
        type = "String"
    },
    ["vehicleId"] = {
        offset = 0x18,
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
        -- dump: ValueSequence<float> amount // 0x88 — read as the
        -- float head of the sequence (legacy behavior)
        offset = 0x88,
        type = "Float"
    },
    ["amountX"] = {
        -- NOT in dump. Legacy JSON field.
        offset = 0x90,
        type = "Float"
    },
    ["return"] = {
        -- NOT in dump. Legacy JSON field; offset == struct size,
        -- likely invalid.
        offset = 0x98,
        type = "Int32"
    }
}
