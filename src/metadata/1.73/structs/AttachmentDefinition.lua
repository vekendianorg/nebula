--==================================================
-- metadata/1.73/AttachmentDefinition.lua
--==================================================
-- Element template for List<AttachmentDefinition>
-- (CollectibleDefinition.attachments @0x150, INLINE elements,
-- elementStride = sizeof(AttachmentDefinition) = 0xf8).
--
-- cocos2d::Vec2 members (offset @0x50, anchor @0x58, delegateOffset
-- @0xe4, previewOffset @0xec) are by-value {float x, float y}
-- pairs — modeled as two Floats each (proof of by-value storage:
-- delegateScale@0xe0 float and delegateOffset@0xe4 sit at
-- 4-byte-unaligned offsets, impossible for pointers).
-- field_0004 (byte @0x4) is a named byte field with no reader.
--
-- Dump source (temp/libcocos2dcpp.cs):
--   public class AttachmentDefinition
--       // Size: 0xf8  Confidence: exact

return {
    ["type"] = {
        offset = 0x0,
        type = "Int32"
    },
    ["node"] = {
        offset = 0x8,
        type = "String"
    },
    ["source"] = {
        offset = 0x20,
        type = "String"
    },
    ["rootBody"] = {
        offset = 0x38,
        type = "String"
    },
    ["offsetX"] = {
        offset = 0x50,
        type = "Float"
    },
    ["offsetY"] = {
        offset = 0x54,
        type = "Float"
    },
    ["anchorX"] = {
        offset = 0x58,
        type = "Float"
    },
    ["anchorY"] = {
        offset = 0x5C,
        type = "Float"
    },
    ["scale"] = {
        offset = 0x60,
        type = "Float"
    },
    ["rotation"] = {
        offset = 0x64,
        type = "Float"
    },
    ["hideHead"] = {
        offset = 0x68,
        type = "Bool"
    },
    ["hatOnTop"] = {
        offset = 0x69,
        type = "Bool"
    },
    ["weldHead"] = {
        offset = 0x6A,
        type = "Bool"
    },
    ["animated"] = {
        offset = 0x6B,
        type = "Bool"
    },
    ["framePath"] = {
        offset = 0x70,
        type = "String"
    },
    ["frameCount"] = {
        offset = 0x88,
        type = "Int32"
    },
    ["frameDelay"] = {
        offset = 0x8C,
        type = "Float"
    },
    ["customShader"] = {
        offset = 0x90,
        type = "Bool"
    },
    ["shaderName"] = {
        offset = 0x98,
        type = "String"
    },
    ["shaderInLooksMenu"] = {
        offset = 0xB0,
        type = "Bool"
    },
    ["breakable"] = {
        offset = 0xB1,
        type = "Bool"
    },
    ["breakForce"] = {
        offset = 0xB4,
        type = "Float"
    },
    ["rotate"] = {
        offset = 0xB8,
        type = "Bool"
    },
    ["zOrderOffset"] = {
        offset = 0xBC,
        type = "Int32"
    },
    ["detachTarget"] = {
        offset = 0xC0,
        type = "Bool"
    },
    ["parentToChassisInGhost"] = {
        offset = 0xC1,
        type = "Bool"
    },
    ["targetBody"] = {
        offset = 0xC8,
        type = "String"
    },
    ["delegateScale"] = {
        offset = 0xE0,
        type = "Float"
    },
    ["delegateOffsetX"] = {
        offset = 0xE4,
        type = "Float"
    },
    ["delegateOffsetY"] = {
        offset = 0xE8,
        type = "Float"
    },
    ["previewOffsetX"] = {
        offset = 0xEC,
        type = "Float"
    },
    ["previewOffsetY"] = {
        offset = 0xF0,
        type = "Float"
    },
}
