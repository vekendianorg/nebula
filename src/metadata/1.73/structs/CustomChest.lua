--==================================================
-- metadata/1.73/CustomChest.lua
--==================================================
-- Element template for List<CustomChest> (LootDefinition.customChests).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class CustomChest
--       // Size: 0x150  Confidence: exact
--       public string chestImageClosed; // 0x0
--       public int partsRerollPrice;    // 0x18
--       public List<int> coins;         // 0x20
--       public List<int> gems;          // 0x38
--       public string name;             // 0x50
--       public string vehicleId;        // 0x68
--       public float homePropProbability;                  // 0x80
--       public List<float> customizationsProbability;      // 0x88
--       public List<float> tuningPartsProbability;         // 0xa0
--       public TuningPartsMultiplierType tuningPartsMultiplierType;          // 0xb8
--       public List<List<int>> customizationsRarityWeightInts;               // 0xc0
--       public List<WeightedList<Rarity>> customizationsRarityWeights;       // 0xd8
--       public List<List<int>> tuningPartsRarityWeightInts;                  // 0xf0
--       public List<WeightedList<Rarity>> tuningPartsRarityWeights;          // 0x108
--       public List<RangeDefinition> tuningPartsAmountsPerRarity;            // 0x120
--       public List<string> tuningPartsBlacklist;                            // 0x138
--
-- Full 16-field layout.
--
-- !! ELEMENT STRIDE !! Inline std::vector<CustomChest> elements
-- (stride > 0x8 => the reader walks arrayPtr + (i-1)*stride).
-- The stride is sizeof(CustomChest) DERIVED FROM THE FIELD
-- EXTENTS: last field tuningPartsBlacklist@0x138 is a std::vector
-- (0x18 bytes) -> 0x138 + 0x18 = 0x150, padded to 8 -> 0x150.
-- The dump class-line "Size: 0x150" annotation is NOT the element
-- stride and must never be copied as one — derive it from the
-- fields, and note that protobuf RepeatedPtrField<...> arrays are
-- pointer-slot arrays (stride <= 0x8) instead.


local Manifest = loadModule("metadata/manifest.lua")
return {
    ["chestImageClosed"] = {
        offset = 0x0,
        type = "String"
    },
    ["partsRerollPrice"] = {
        offset = 0x18,
        type = "Int32"
    },
    ["coins"] = {
        offset = 0x20,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
    ["gems"] = {
        offset = 0x38,
        type = "Array",
        elementType = "Int32",
        elementStride = 0x4
    },
    ["name"] = {
        offset = 0x50,
        type = "String"
    },
    ["vehicleId"] = {
        offset = 0x68,
        type = "String"
    },
    ["homePropProbability"] = {
        offset = 0x80,
        type = "Float"
    },
    ["customizationsProbability"] = {
        offset = 0x88,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4
    },
    ["tuningPartsProbability"] = {
        offset = 0xA0,
        type = "Array",
        elementType = "Float",
        elementStride = 0x4
    },
    ["tuningPartsMultiplierType"] = {
        offset = 0xB8,
        type = "Int32"
    },
    ["customizationsRarityWeightInts"] = {
        -- List<List<int>> — exposed as a header-only array of Int32 arrays
        offset = 0xC0,
        type = "Array",
        elements = {
            ["items"] = { offset = 0x18, type = "Array", elementType = "Int32", elementStride = 0x4 }
        }
    },
    ["customizationsRarityWeights"] = {
        -- List<WeightedList<Rarity>> — header-only (WeightedList<T> layout unmapped)
        offset = 0xD8,
        type = "Array"
    },
    ["tuningPartsRarityWeightInts"] = {
        -- List<List<int>> — header-only array of Int32 arrays
        offset = 0xF0,
        type = "Array",
        elements = {
            ["items"] = { offset = 0x18, type = "Array", elementType = "Int32", elementStride = 0x4 }
        }
    },
    ["tuningPartsRarityWeights"] = {
        -- List<WeightedList<Rarity>> — header-only (WeightedList<T> layout unmapped)
        offset = 0x108,
        type = "Array"
    },
    ["tuningPartsAmountsPerRarity"] = {
        -- List<RangeDefinition> @0x120 — dump RangeDefinition =
        -- { rangeMin int @0x0, rangeMax int @0x4 } (Size 0x8),
        -- INLINE elements (stride 0x8).
        offset = 0x120,
        type = "Array",
        elementStride = 0x8,
        elements = Manifest.load("RangeDefinition")
    },
    ["tuningPartsBlacklist"] = {
        offset = 0x138,
        type = "Array",
        elementType = "String"
    }
}
