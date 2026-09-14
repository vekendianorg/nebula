--==================================================
-- metadata/1.73/CollectibleDefinition.lua
--==================================================
-- Element template for List<CollectibleDefinition>
-- (EventDefinition.collectiblesOverride @0x398, INLINE elements,
-- elementStride = sizeof(CollectibleDefinition) = 0x1a0, derived
-- from field extents: particles@0x188 + 0x18).
--
-- Inherits ObjectDefinition at 0x0 (Size 0x110) — its fields are
-- merged into this template at the inherited offsets (fields are
-- read at parent-relative absolute offsets, matching how the
-- reader walks the element base).
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class CollectibleDefinition : ObjectDefinition
--       // Size: 0x1a0  Confidence: exact

local Manifest = loadModule("metadata/manifest.lua")

local M                    = Manifest.load("ObjectDefinition")
local AttachmentDefinition = Manifest.load("AttachmentDefinition")

-- Derived CollectibleDefinition fields (base occupies 0x0-0x10f)
M["id"] = {
    offset = 0x110,
    type = "String"
}
M["type"] = {
    offset = 0x128,
    type = "Int32"
}
M["amount"] = {
    offset = 0x12C,
    type = "Int32"
}
M["multiplier"] = {
    offset = 0x130,
    type = "Float"
}
M["sound"] = {
    offset = 0x138,
    type = "String"
}
-- attachments @0x150 -> List<AttachmentDefinition>, INLINE elements
-- (stride = sizeof(AttachmentDefinition) = 0xf8)
M["attachments"] = {
    offset = 0x150,
    type = "Array",
    elementStride = 0xF8,
    elements = AttachmentDefinition
}
M["rarity"] = {
    offset = 0x168,
    type = "Enum",
    enum = "Rarity"
}
M["weight"] = {
    offset = 0x16C,
    type = "Float"
}
M["name"] = {
    offset = 0x170,
    type = "String"
}
M["particles"] = {
    offset = 0x188,
    type = "String"
}

return M
