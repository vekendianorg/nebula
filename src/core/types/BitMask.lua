--==================================================
-- core/types/BitMask.lua
--==================================================

local BitMask = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula ~= nil and Nebula.log then
        Logfile.log("[BitMask]", ...)
    end
end

BitMask.__index = BitMask

local Manifest = loadModule("metadata/manifest.lua")

local function loadEnum(field)
    if type(field.enum) == "table" then
        return field.enum
    end

    return Manifest.loadEnum(field.enum)
end

function BitMask.new(value, enum)
    return setmetatable({
        _value = value or 0,
        _enum = enum,
    }, BitMask)
end

function BitMask:value()
    return self._value
end

function BitMask:has(name)
    local flag = self._enum[name]
    assert(flag, ("Unknown flag '%s'"):format(name))

    return (self._value & flag) ~= 0
end

function BitMask:enable(name)
    local flag = self._enum[name]
    assert(flag, ("Unknown flag '%s'"):format(name))

    self._value = self._value | flag
    return self
end

function BitMask:disable(name)
    local flag = self._enum[name]
    assert(flag, ("Unknown flag '%s'"):format(name))

    self._value = self._value & (~flag)
    return self
end

function BitMask:toggle(name)
    local flag = self._enum[name]
    assert(flag, ("Unknown flag '%s'"):format(name))

    self._value = self._value ~ flag
    return self
end

function BitMask.get(base, field)
    local Int32 = Nebula.Type.resolve("Int32")
    local value = Int32.get(base, field)
    if value == nil then
        log(string.format("[get] at 0x%X offset=0x%X: underlying Int32 read failed", base, field.offset))
        return BitMask.new(0, loadEnum(field))
    end
    return BitMask.new(value, loadEnum(field))
end

function BitMask.set(base, field, value)
    if getmetatable(value) == BitMask then
        value = value:value()
    elseif type(value) ~= "number" then
        log(string.format("[set] REJECTED at 0x%X offset=0x%X: value is neither BitMask nor number (%s)",
            base, field.offset, type(value)))
        return false
    end

    local Int32 = Nebula.Type.resolve("Int32")
    return Int32.set(base, field, value)
end

return BitMask