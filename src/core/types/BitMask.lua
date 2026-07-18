local BitMask = {}
BitMask.__index = BitMask

local function loadEnum(field)
    if type(field.enum) == "table" then
        return field.enum
    end

    return loadModule("metadata/enums/" .. field.enum .. ".lua")
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
    return BitMask.new(value, loadEnum(field))
end

function BitMask.set(base, field, value)
    if getmetatable(value) == BitMask then
        value = value:value()
    end

    local Int32 = Nebula.Type.resolve("Int32")
    return Int32.set(base, field, value)
end

return BitMask