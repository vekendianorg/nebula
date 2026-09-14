--==================================================
-- metadata/1.74/StringIntMap.lua
--==================================================
-- Shared element template for several RepeatedPtrField<StringIntMap>
-- arrays (POINTER-slot elements, default stride).
-- Dump: StringIntMap // Size 0x28, key string @0x18, value int32 @0x20
return {
    ["key"] = {
        offset = 0x18,
        type = "String"
    },
    ["value"] = {
        offset = 0x20,
        type = "Int32"
    },
}
