--==================================================
-- core/types/SafeInt32.lua
--==================================================
-- Type-dispatcher wrapper around the SafeInt32 protobuf struct.
--
-- IMPORTANT: unlike Int32/Bool/Float, a SafeInt32 *field* on
-- GameStatus (e.g. currentWinStreak, safeCoins) holds a POINTER at
-- baseAddress + field.offset. The struct itself lives at that
-- pointer, laid out as:
--   ptr + 0x18  safeValue  (int32)
--   ptr + 0x1C  key        (int32)
--   ptr + 0x20  checksum   (int32)
--   ptr + 0x24  keyChecksum (int32)
--
-- Confirmed from account.lua M.changeWinStreak, which reads
-- currentPtr/bestPtr via flags=32 (pointer) at the field offset,
-- then writes the four sub-fields at ptr+0x18..0x24.
--
-- The static XOR key is a single account-wide int32 living at
-- GameStatus.safeIntStaticKey (base + 0x6AC, per changeWinStreak).
-- Individual metadata fields don't need to declare
-- staticKeyOffset — it's fixed and resolved internally.

local Memory = loadModule("core/Memory.lua")

---@class SafeInt32
SafeInt32 = setmetatable({
    safeValue   = 0;
    key         = 0;
    checksum    = 0;
    keyChecksum = 0;
    __index = function(t, k) return SafeInt32[k] end
}, {
    __call = function(cls, ...) return cls:__new() end
}
)

IntUtils = {}

function IntUtils:toInt32(x)
    if x >= 0x80000000 then
        return x - 0x100000000
    end

    return x
end

---@param value integer @hash of safeInt.key and staticKey or safeInt.safeValue
---@return integer
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
    local instance = setmetatable({}, self);
    return instance;
end

---@param staticKey integer
---@return integer
function SafeInt32:decode(staticKey)
    return staticKey ~ self.safeValue ~ self.key
end

---@param staticKey integer
---@param value integer
---@param key integer
---@return integer
function SafeInt32:encode(staticKey, value, key)
    return staticKey ~ value ~ key;
end

---@param safeInt table (class:SafeInt32)
---@return nil
function SafeInt32:set(safeInt)
    self.safeValue   = safeInt.safeValue;
    self.key         = safeInt.key;
    self.checksum    = safeInt.checksum;
    self.keyChecksum = safeInt.keyChecksum;
end

---@param self table
---@param value integer?
---@param staticKey integer
---@return table (class:SafeInt32)
function SafeInt32:new(value, staticKey)
    if value ~= nil then
        local safeInt = SafeInt32:__new();
        safeInt.key         = math.random(0, 0x7fffffff);
        safeInt.safeValue   = self:encode(staticKey, value, safeInt.key);
        safeInt.checksum    = self:__hash(value ~ safeInt.key);
        safeInt.keyChecksum = self:__hash(staticKey ~ safeInt.key);

        return safeInt;
    end

    local safeInt = SafeInt32:__new();
    value               = math.random(0, 0x7fffffff);
    safeInt.key         = math.random(0, 0x7fffffff);
    safeInt.safeValue   = self:encode(staticKey, value, safeInt.key);
    safeInt.checksum    = self:__hash(value ~ safeInt.key);
    safeInt.keyChecksum = self:__hash(staticKey ~ safeInt.key);

    return safeInt;
end

---@param value integer
---@param staticKey integer
---@return nil
function SafeInt32:update(value, staticKey)
    local safeInt = self:new(value, staticKey);
    self:set(safeInt);
end

---@param staticKey integer
---@return boolean
function SafeInt32:isValid(staticKey)

    if self.checksum ~= self:__hash(self:decode(staticKey) ~ self.key) then
        return false;
    end

    if self.keyChecksum ~= self:__hash(staticKey ~ self.key) then
        return false;
    end

    return true;
end

---@param value integer
---@param staticKey integer
---@return boolean
function SafeInt32:verifyAndCheckSafeValue(value, staticKey)

    local decoded = self:decode(staticKey);

    if value ~= decoded then
        return false;
    end

    if self:isValid(staticKey) then

        if self.checksum ~= self:__hash(value ~ self.key) then
            return false;
        end

        return true;
    end

    return false;
end


---@param staticKey integer
---@return nil
function SafeInt32:print(staticKey)
    local safeInt = string.format("[\t\n\x20safeValue=(%d);\n key=(%d);\n checksum=(%d);\n keyChecksum=(%d);\t\n]", IntUtils:toInt32(self.safeValue), IntUtils:toInt32(self.key), IntUtils:toInt32(self.checksum), IntUtils:toInt32(self.keyChecksum));
    local info    = string.format("[\t\n\x20decoded=(%d);\n staticKey=(%d);\n isValid=(%s)\t\n]", IntUtils:toInt32(self:decode(staticKey)), IntUtils:toInt32(staticKey), self:isValid(staticKey))
    print(string.format("[SafeInt32::print] -> SafeInt : %s\n Info : %s\n", safeInt, info))
end

--==================================================
-- Type dispatcher (Nebula-facing get/set)
--==================================================

local M = {}

-- Sub-field byte offsets within the SafeInt32 struct, relative to
-- the struct pointer (not the GameStatus base). Confirmed via
-- account.lua M.changeWinStreak.
local STRUCT_SAFEVALUE_OFF   = 0x18
local STRUCT_KEY_OFF         = 0x1C
local STRUCT_CHECKSUM_OFF    = 0x20
local STRUCT_KEYCHECKSUM_OFF = 0x24

-- Fixed account-wide static key offset (base + this = safeIntStaticKey).
local STATIC_KEY_OFFSET = 0x6AC

---Resolve the account-wide static XOR key.
---@param baseAddress integer
---@return integer staticKey
local function resolveStaticKey(baseAddress)
    return Memory.read(baseAddress + STATIC_KEY_OFFSET, Memory.FLAGS.INT32) or 0
end

---Read the raw 4-field struct from the pointer target into a
---SafeInt32 instance.
---@param structPtr integer
---@return table instance
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

---@param baseAddress integer
---@param field table @ { offset, ... }
---@return integer|nil value, string|nil error
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

---@param baseAddress integer
---@param field table
---@param value integer
---@return boolean ok
function M.set(baseAddress, field, value)
    if type(value) ~= "number" then
        return false
    end

    local structPtr, err = Memory.deref(baseAddress, field.offset)
    if not structPtr then
        return false
    end

    local staticKey = resolveStaticKey(baseAddress)
    local instance = SafeInt32:new(math.floor(value), staticKey)

    return Memory.writeBatch({
        { address = structPtr + STRUCT_SAFEVALUE_OFF,   flags = Memory.FLAGS.INT32, value = instance.safeValue },
        { address = structPtr + STRUCT_KEY_OFF,         flags = Memory.FLAGS.INT32, value = instance.key },
        { address = structPtr + STRUCT_CHECKSUM_OFF,    flags = Memory.FLAGS.INT32, value = instance.checksum },
        { address = structPtr + STRUCT_KEYCHECKSUM_OFF, flags = Memory.FLAGS.INT32, value = instance.keyChecksum },
    })
end

return M
