--==================================================
-- core/types/SafeInt.lua
--==================================================

local Memory = loadModule("core/Memory.lua")

SafeInt = setmetatable({
    safeValue   = 0;
    key         = 0;
    checksum    = 0;
    keyChecksum = 0;
    tag         = 0;
    __index = function(t, k) return SafeInt[k] end
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

function SafeInt:__hash(value)
    local x = value & 0xFFFFFFFF
    x = x ~ (x >> 16)
    x = (x * 0x045d9f3b) & 0xFFFFFFFF
    x = x ~ (x >> 16)
    x = (x * 0x045d9f3b) & 0xFFFFFFFF
    x = x ~ (x >> 16)
    return IntUtils:toInt32(x)
end

function SafeInt:__new()
    local instance = setmetatable({}, self)
    return instance
end

function SafeInt:decode(staticKey)
    return staticKey ~ self.safeValue ~ self.key
end

function SafeInt:encode(staticKey, value, key)
    return staticKey ~ value ~ key
end

function SafeInt:set(safeInt)
    self.safeValue   = safeInt.safeValue
    self.key         = safeInt.key
    self.checksum    = safeInt.checksum
    self.keyChecksum = safeInt.keyChecksum
    self.tag         = safeInt.tag
end

function SafeInt:new(value, staticKey)
    if value ~= nil then
        local safeInt = SafeInt:__new()
        safeInt.key         = math.random(0, 0x7fffffff)
        safeInt.safeValue   = self:encode(staticKey, value, safeInt.key)
        safeInt.checksum    = self:__hash(value ~ safeInt.key)
        safeInt.keyChecksum = self:__hash(staticKey ~ safeInt.key)
        return safeInt
    end

    local safeInt = SafeInt:__new()
    value               = math.random(0, 0x7fffffff)
    safeInt.key         = math.random(0, 0x7fffffff)
    safeInt.safeValue   = self:encode(staticKey, value, safeInt.key)
    safeInt.checksum    = self:__hash(value ~ safeInt.key)
    safeInt.keyChecksum = self:__hash(staticKey ~ safeInt.key)
    return safeInt
end

function SafeInt:update(value, staticKey)
    local safeInt = self:new(value, staticKey)
    self:set(safeInt)
end

function SafeInt:isValid(staticKey)
    if self.checksum ~= self:__hash(self:decode(staticKey) ~ self.key) then
        return false
    end
    if self.keyChecksum ~= self:__hash(staticKey ~ self.key) then
        return false
    end
    return true
end

function SafeInt:verifyAndCheckSafeValue(value, staticKey)
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

function SafeInt:print(staticKey)
    local safeInt = string.format("[\t\n\x20safeValue=(%d);\n key=(%d);\n checksum=(%d);\n keyChecksum=(%d);\n tag=(%d);\t\n]", IntUtils:toInt32(self.safeValue), IntUtils:toInt32(self.key), IntUtils:toInt32(self.checksum), IntUtils:toInt32(self.keyChecksum), IntUtils:toInt32(self.tag))
    local info    = string.format("[\t\n\x20decoded=(%d);\n staticKey=(%d);\n isValid=(%s)\t\n]", IntUtils:toInt32(self:decode(staticKey)), IntUtils:toInt32(staticKey), self:isValid(staticKey))
    print(string.format("[SafeInt::print] -> SafeInt : %s\n Info : %s\n", safeInt, info))
end

local M = {}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula and Nebula.log then
        Logfile.log("[SafeInt]", ...)
    end
end



local STRUCT_SAFEVALUE_OFF   = 0x08
local STRUCT_KEY_OFF         = 0x0C
local STRUCT_CHECKSUM_OFF    = 0x10
local STRUCT_KEYCHECKSUM_OFF = 0x14
local STRUCT_TAG_OFF         = 0x18
local STRUCT_SIZE = 0x20

local STATIC_KEY_OFFSET = 0x6AC
local JSON_KEY = 0x7A3B5C2D -- 2050710573

local cachedStaticKey = nil
local cachedGameStatusBase = nil

local function resolveStaticKey(baseAddress)
    if cachedStaticKey ~= nil then
        return cachedStaticKey
    end
    if cachedGameStatusBase == nil then
        -- GameStatus is PlayerInfo's child (mGameStatus @0x148,
        -- metadata/<version>/structs/PlayerInfo.lua): when no base
        -- was passed in, descend from the PlayerInfo base
        -- (api/PlayerInfo.lua owns the signature scan + cache).
        if Nebula and Nebula.PlayerInfo and Nebula.PlayerInfo.resolveBase then
            local piBase = Nebula.PlayerInfo.resolveBase()
            if piBase then
                cachedGameStatusBase = Memory.deref(piBase, 0x148)
            end
        end
    end
    local gsBase = cachedGameStatusBase or baseAddress
    cachedStaticKey = Memory.read(gsBase + STATIC_KEY_OFFSET, Memory.FLAGS.INT32) or 0
    log(string.format("staticKey resolved: gsBase=0x%X key=%d", gsBase, cachedStaticKey))
    return cachedStaticKey
end

local function readStruct(structPtr)
    local specs = {
        { address = structPtr + STRUCT_SAFEVALUE_OFF,   flags = Memory.FLAGS.INT32 },
        { address = structPtr + STRUCT_KEY_OFF,         flags = Memory.FLAGS.INT32 },
        { address = structPtr + STRUCT_CHECKSUM_OFF,    flags = Memory.FLAGS.INT32 },
        { address = structPtr + STRUCT_KEYCHECKSUM_OFF, flags = Memory.FLAGS.INT32 },
        { address = structPtr + STRUCT_TAG_OFF,         flags = Memory.FLAGS.INT32 },
    }
    local results = Memory.readBatch(specs)
    local instance = SafeInt:__new()
    if results then
        instance.safeValue   = results[1] and results[1].value or 0
        instance.key         = results[2] and results[2].value or 0
        instance.checksum    = results[3] and results[3].value or 0
        instance.keyChecksum = results[4] and results[4].value or 0
        instance.tag         = results[5] and results[5].value or 0
    end
    return instance
end

local function resolveInline(baseAddress, field)
    return baseAddress + field.offset
end

local function resolveSafeIntKey(baseAddress, field, instance)
    -- JSONSafeInt has only been confirmed with the shared JSON key.
    if field.type == "JSONSafeInt" then
        if instance:isValid(JSON_KEY) then
            return JSON_KEY
        end
        return nil
    end

    -- SafeInt: currently try the JSON key first, then the
    -- GameStatus static key until getStaticKey(bool) is reversed.
    if instance:isValid(JSON_KEY) then
        return JSON_KEY
    end

    local staticKey = resolveStaticKey(baseAddress)

    if staticKey ~= JSON_KEY and instance:isValid(staticKey) then
        return staticKey
    end

    return nil
end

function M.get(baseAddress, field)
    local structPtr = resolveInline(baseAddress, field)
    local instance = readStruct(structPtr)
    local staticKey = resolveSafeIntKey(baseAddress, field, instance)

    if not staticKey then
        log(string.format("[get] REJECTED at structPtr=0x%X (base=0x%X offset=0x%X): checksum_invalid (safeValue=%d key=%d checksum=%d keyChecksum=%d tag=%d)",
            structPtr, baseAddress, field.offset,
            instance.safeValue, instance.key, instance.checksum, instance.keyChecksum, instance.tag))
        return nil, "checksum_invalid"
    end

    local decoded = instance:decode(staticKey)
    log(string.format("[get] structPtr=0x%X decoded=%d staticKey=%d type=%s", structPtr, decoded, staticKey, tostring(field.type)))
    return decoded
end

function M.set(baseAddress, field, value)
    if type(value) ~= "number" then
        return false
    end

    local structPtr = resolveInline(baseAddress, field)

    local staticKey

    if field.type == "JSONSafeInt" then
        staticKey = JSON_KEY
    else
        staticKey = resolveStaticKey(baseAddress)
    end

    local instance = SafeInt:new(math.floor(value), staticKey)

    local writes = {
        { address = structPtr + STRUCT_SAFEVALUE_OFF,   flags = Memory.FLAGS.INT32, value = instance.safeValue },
        { address = structPtr + STRUCT_KEY_OFF,         flags = Memory.FLAGS.INT32, value = instance.key },
        { address = structPtr + STRUCT_CHECKSUM_OFF,    flags = Memory.FLAGS.INT32, value = instance.checksum },
        { address = structPtr + STRUCT_KEYCHECKSUM_OFF, flags = Memory.FLAGS.INT32, value = instance.keyChecksum },
    }

    return Memory.writeBatch(writes)
end

function M.collectWrite(baseAddress, field, value, writes)
    -- true/false contract — see Int32.collectWrite for why nil broke set().
    if type(value) ~= "number" then
        log(string.format("[set] collectWrite REJECTED at 0x%X offset=0x%X: non-number value (%s)",
            baseAddress, field.offset, type(value)))
        return false
    end

    local structPtr = resolveInline(baseAddress, field)

    local staticKey

    if field.type == "JSONSafeInt" then
        staticKey = JSON_KEY
    else
        staticKey = resolveStaticKey(baseAddress)
    end

    local instance = SafeInt:new(math.floor(value), staticKey)

    writes[#writes + 1] = { address = structPtr + STRUCT_SAFEVALUE_OFF, flags = Memory.FLAGS.INT32, value = instance.safeValue }
    writes[#writes + 1] = { address = structPtr + STRUCT_KEY_OFF,         flags = Memory.FLAGS.INT32, value = instance.key }
    writes[#writes + 1] = { address = structPtr + STRUCT_CHECKSUM_OFF,    flags = Memory.FLAGS.INT32, value = instance.checksum }
    writes[#writes + 1] = { address = structPtr + STRUCT_KEYCHECKSUM_OFF, flags = Memory.FLAGS.INT32, value = instance.keyChecksum }

    return true
end

return M