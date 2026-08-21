local Memory = loadModule("core/Memory.lua")
local ZeroPage = loadModule("core/ZeroPage.lua")

SafeInt32 = setmetatable({
    safeValue   = 0;
    key         = 0;
    checksum    = 0;
    keyChecksum = 0;
    __index = function(t, k) return SafeInt32[k] end
}, {
    __call = function(cls, ...) return cls:__new() end
})

IntUtils = {}

function IntUtils:toInt32(x)
    if x >= 0x80000000 then
        return x - 0x100000000
    end
    return x
end

function SafeInt32:__hash(value)
    local x = value & 0xFFFFFFFF
    x = x ~ (x >> 16)
    x = (x * 0x045d9f3b) & 0xFFFFFFFF
    x = x ~ (x >> 16)
    x = (x * 0x045d9f3b) & 0xFFFFFFFF
    x = x ~ (x >> 16)
    return IntUtils:toInt32(x)
end

function SafeInt32:__new()
    local instance = setmetatable({}, self)
    return instance
end

function SafeInt32:decode(staticKey)
    return staticKey ~ self.safeValue ~ self.key
end

function SafeInt32:encode(staticKey, value, key)
    return staticKey ~ value ~ key
end

function SafeInt32:set(safeInt)
    self.safeValue   = safeInt.safeValue
    self.key         = safeInt.key
    self.checksum    = safeInt.checksum
    self.keyChecksum = safeInt.keyChecksum
end

function SafeInt32:new(value, staticKey)
    if value ~= nil then
        local safeInt = SafeInt32:__new()
        safeInt.key         = math.random(0, 0x7fffffff)
        safeInt.safeValue   = self:encode(staticKey, value, safeInt.key)
        safeInt.checksum    = self:__hash(value ~ safeInt.key)
        safeInt.keyChecksum = self:__hash(staticKey ~ safeInt.key)
        return safeInt
    end

    local safeInt = SafeInt32:__new()
    value               = math.random(0, 0x7fffffff)
    safeInt.key         = math.random(0, 0x7fffffff)
    safeInt.safeValue   = self:encode(staticKey, value, safeInt.key)
    safeInt.checksum    = self:__hash(value ~ safeInt.key)
    safeInt.keyChecksum = self:__hash(staticKey ~ safeInt.key)
    return safeInt
end

function SafeInt32:update(value, staticKey)
    local safeInt = self:new(value, staticKey)
    self:set(safeInt)
end

function SafeInt32:isValid(staticKey)
    if self.checksum ~= self:__hash(self:decode(staticKey) ~ self.key) then
        return false
    end
    if self.keyChecksum ~= self:__hash(staticKey ~ self.key) then
        return false
    end
    return true
end

function SafeInt32:verifyAndCheckSafeValue(value, staticKey)
    local decoded = self:decode(staticKey)
    if value ~= decoded then
        return false
    end
    if self:isValid(staticKey) then
        if self.checksum ~= self:__hash(value ~ self.key) then
            return false
        end
        return true
    end
    return false
end

function SafeInt32:print(staticKey)
    local safeInt = string.format("[\t\n\x20safeValue=(%d);\n key=(%d);\n checksum=(%d);\n keyChecksum=(%d);\t\n]", IntUtils:toInt32(self.safeValue), IntUtils:toInt32(self.key), IntUtils:toInt32(self.checksum), IntUtils:toInt32(self.keyChecksum))
    local info    = string.format("[\t\n\x20decoded=(%d);\n staticKey=(%d);\n isValid=(%s)\t\n]", IntUtils:toInt32(self:decode(staticKey)), IntUtils:toInt32(staticKey), self:isValid(staticKey))
    print(string.format("[SafeInt32::print] -> SafeInt : %s\n Info : %s\n", safeInt, info))
end

local M = {}

local function log(...)
    if Nebula and Nebula.verbose then
        print("[core.types.SafeInt32]", ...)
    end
end



local STRUCT_SAFEVALUE_OFF   = 0x18
local STRUCT_KEY_OFF         = 0x1C
local STRUCT_CHECKSUM_OFF    = 0x20
local STRUCT_KEYCHECKSUM_OFF = 0x24
local STATIC_KEY_OFFSET = 0x6AC
local STRUCT_SIZE = 0x28

local cachedStaticKey = nil
local cachedGameStatusBase = nil

local function resolveStaticKey(baseAddress)
    if cachedStaticKey ~= nil then
        return cachedStaticKey
    end
    if cachedGameStatusBase == nil then
        if Nebula and Nebula.GameStatus and Nebula.GameStatus.resolveBase then
            cachedGameStatusBase = Nebula.GameStatus.resolveBase()
        end
    end
    local gsBase = cachedGameStatusBase or baseAddress
    cachedStaticKey = Memory.read(gsBase + STATIC_KEY_OFFSET, Memory.FLAGS.INT32) or 0
    return cachedStaticKey
end

local function readStruct(structPtr)
    local specs = {
        { address = structPtr + STRUCT_SAFEVALUE_OFF,   flags = Memory.FLAGS.INT32 },
        { address = structPtr + STRUCT_KEY_OFF,         flags = Memory.FLAGS.INT32 },
        { address = structPtr + STRUCT_CHECKSUM_OFF,    flags = Memory.FLAGS.INT32 },
        { address = structPtr + STRUCT_KEYCHECKSUM_OFF, flags = Memory.FLAGS.INT32 },
    }
    local results = Memory.readBatch(specs)
    local instance = SafeInt32:__new()
    if results then
        instance.safeValue   = results[1] and results[1].value or 0
        instance.key         = results[2] and results[2].value or 0
        instance.checksum    = results[3] and results[3].value or 0
        instance.keyChecksum = results[4] and results[4].value or 0
    end
    return instance
end

function M.get(baseAddress, field)
    local structPtr, err = Memory.deref(baseAddress, field.offset)
    if not structPtr then
        return nil, err
    end

    local instance = readStruct(structPtr)
    local staticKey = resolveStaticKey(baseAddress)

    if not instance:isValid(staticKey) then
        return nil, "checksum_invalid"
    end

    return instance:decode(staticKey)
end

function M.set(baseAddress, field, value)
    if type(value) ~= "number" then
        return false
    end

    local structPtr, err = Memory.deref(baseAddress, field.offset)
    local needsAlloc = not structPtr or structPtr == 0

    if needsAlloc then
        structPtr = ZeroPage.allocate(STRUCT_SIZE)
        if not structPtr then
            return false
        end
    end

    local staticKey = resolveStaticKey(baseAddress)
    local instance = SafeInt32:new(math.floor(value), staticKey)

    local writes = {
        { address = structPtr + STRUCT_SAFEVALUE_OFF,   flags = Memory.FLAGS.INT32, value = instance.safeValue },
        { address = structPtr + STRUCT_KEY_OFF,         flags = Memory.FLAGS.INT32, value = instance.key },
        { address = structPtr + STRUCT_CHECKSUM_OFF,    flags = Memory.FLAGS.INT32, value = instance.checksum },
        { address = structPtr + STRUCT_KEYCHECKSUM_OFF, flags = Memory.FLAGS.INT32, value = instance.keyChecksum },
    }

    if needsAlloc then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT64, value = structPtr }
    end

    return Memory.writeBatch(writes)
end

function M.collectWrite(baseAddress, field, value, writes)
    if type(value) ~= "number" then return end
    local structPtr, err = Memory.deref(baseAddress, field.offset)
    local needsAlloc = not structPtr or structPtr == 0

    if needsAlloc then
        structPtr = ZeroPage.allocate(STRUCT_SIZE)
        if not structPtr then return end
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT64, value = structPtr }
    end

    local staticKey = resolveStaticKey(baseAddress)
    local instance = SafeInt32:new(math.floor(value), staticKey)
    writes[#writes + 1] = { address = structPtr + STRUCT_SAFEVALUE_OFF, flags = Memory.FLAGS.INT32, value = instance.safeValue }
    writes[#writes + 1] = { address = structPtr + STRUCT_KEY_OFF, flags = Memory.FLAGS.INT32, value = instance.key }
    writes[#writes + 1] = { address = structPtr + STRUCT_CHECKSUM_OFF, flags = Memory.FLAGS.INT32, value = instance.checksum }
    writes[#writes + 1] = { address = structPtr + STRUCT_KEYCHECKSUM_OFF, flags = Memory.FLAGS.INT32, value = instance.keyChecksum }

    if needsAlloc then
        writes[#writes + 1] = { address = baseAddress + field.offset, flags = Memory.FLAGS.INT64, value = structPtr }
    end
end

return M
