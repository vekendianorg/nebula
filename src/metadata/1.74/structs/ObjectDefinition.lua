--==================================================
-- metadata/1.74/ObjectDefinition.lua
--==================================================
-- Base-class template for ObjectDefinition (inherited by
-- CollectibleDefinition, whose own fields start @0x110).
-- Size 0x110 (vptr @0x0). The three clipper::Point members
-- (size @0x98, colliderSize @0xa0, colliderOffset @0xac) each hold
-- two doubles — no reader exists, so they stay unmapped.
-- additionalSprites (List<AdditionalSprite> @0x38),
-- components (List<ComponentDefinition> @0xb8) and floaterOffset
-- (List<float> @0xf0) stay header-only: AdditionalSprite and
-- ComponentDefinition are abstract/vptr-only bases in the dump and
-- List<float> has no mapped element reader.
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class ObjectDefinition
--       // Size: 0x110  Confidence: exact

return {
    ["sprite"] = {
        offset = 0x8,
        type = "String"
    },
    ["floaterSprite"] = {
        offset = 0x20,
        type = "String"
    },
    ["fullSprite"] = {
        offset = 0x50,
        type = "String"
    },
    ["spriteSheet"] = {
        offset = 0x68,
        type = "String"
    },
    ["animationFile"] = {
        offset = 0x80,
        type = "String"
    },
    ["colliderScale"] = {
        offset = 0xAC,
        type = "Float"
    },
    ["shape"] = {
        offset = 0xD0,
        type = "Int32"
    },
    ["density"] = {
        offset = 0xD4,
        type = "Float"
    },
    ["linearDamping"] = {
        offset = 0xD8,
        type = "Float"
    },
    ["angularDamping"] = {
        offset = 0xDC,
        type = "Float"
    },
    ["gravity"] = {
        offset = 0xE0,
        type = "Float"
    },
    ["restitution"] = {
        offset = 0xE4,
        type = "Float"
    },
    ["floaterIconScale"] = {
        offset = 0xE8,
        type = "Float"
    },
    ["verticalFlip"] = {
        offset = 0x108,
        type = "Bool"
    },
    ["sensor"] = {
        offset = 0x109,
        type = "Bool"
    },
}
