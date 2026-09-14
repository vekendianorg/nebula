--==================================================
-- metadata/1.73/ActiveBooster.lua
--==================================================
-- ActiveBooster (dump Size 0x28, exact):
--   boosterid_ 0x18, endtimestamp_ 0x20, cumulativeamount_ 0x24
--==================================================
-- Element template for EventStatus.activeBoosters and other
-- RepeatedPtrField<ActiveBooster> arrays (POINTER-slot elements,
-- default stride).
return {
    ["boosterId"] = {
        offset = 0x18,
        type = "String"
    },
    ["endTimestamp"] = {
        offset = 0x20,
        type = "Int32"
    },
    ["cumulativeAmount"] = {
        offset = 0x24,
        type = "Float"
    },
}
