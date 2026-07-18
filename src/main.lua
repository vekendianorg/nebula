--==================================================
-- main.lua
--==================================================
-- Nebula SDK entry point.
--
-- Unpacked (dev) use: run this file directly with GG's script
-- loader; loadModule() below resolves modules from disk relative
-- to this file.
--
-- Packed (release) use: run `python bundle.py` from the project
-- root. It strips the block below and replaces it with a
-- VFS-aware loadModule() backed by an embedded __vfs table, so
-- the exact same require-style calls in every module keep working
-- with zero edits.

local scriptDir = gg.getFile():match("(.*/)") or ""

function loadModule(name, soft)
    local path = scriptDir .. name
    local chunk, err = loadfile(path)
    if not chunk then
        if soft then return nil, err end
        gg.alert("Module load failed: " .. name .. "\n" .. tostring(err))
        os.exit()
    end
    if soft then
        local results = table.pack(pcall(chunk))
        if not results[1] then return nil, results[2] end
        return table.unpack(results, 2, results.n)
    end
    return chunk()
end

--==================================================
-- Nebula wiring
--==================================================

Nebula = Nebula or {}

-- Global logging switch. No per-operation :log() — see api/GameStatus.lua.
Nebula.log = false

-- Verbose, timed logging for every gg.getValues/setValues round-trip
-- — see core/Memory.lua's vlog(). Flip to true to see exactly where
-- time is going: number of calls, batch sizes, per-call duration.
Nebula.verbose = false

Nebula.GameStatus = loadModule("api/GameStatus.lua")

-- Expose the type registry and Memory layer for advanced/extension
-- use (e.g. a consumer registering a custom type via
-- Nebula.Type.register("MyType", impl)).
Nebula.Type   = loadModule("core/Type.lua")
Nebula.Memory = loadModule("core/Memory.lua")

Nebula.VERSION = "0.1.0"

--==================================================
-- Test: read every field with a known offset
--==================================================
-- Uses Nebula.GameStatus.meta() to enumerate fields rather than
-- hardcoding the list here, so this test stays correct as
-- metadata/GameStatus.lua gains more verified offsets over time.

local metadata = loadModule("metadata/GameStatus.lua")

-- Fixed order for readable output (metadata is a plain table, so
-- pairs() iteration order isn't guaranteed).
local fieldOrder = {}
for id in pairs(metadata) do
    fieldOrder[#fieldOrder + 1] = id
end
table.sort(fieldOrder)

print("========================================")
print(" Nebula field test — known offsets only")
print("========================================")

local passCount, failCount, skipCount = 0, 0, 0
local gameStatusFlagEnum = loadModule("metadata/enums/GameStatusFlag.lua")
local loopStart = os.clock()

for _, id in ipairs(fieldOrder) do
    local meta = Nebula.GameStatus.meta(id)

    if meta.known then
        if meta.type == "Object" then
            -- Object fields have known offsets but no reader yet —
            -- confirm get() rejects them cleanly instead of erroring.
            local value, err = Nebula.GameStatus.get(id)
            if value == nil and err and err:match("^unsupported_type") then
                print(string.format("[skip] %-24s (%s)  -- Object, no reader yet", id, meta.type))
                skipCount = skipCount + 1
            else
                print(string.format("[FAIL] %-24s (%s)  -- expected unsupported_type, got value=%s err=%s",
                    id, meta.type, tostring(value), tostring(err)))
                failCount = failCount + 1
            end
        else
            local value, err = Nebula.GameStatus.get(id)
            if value ~= nil then
                if meta.repeated then
                    print(string.format("[ OK ] %-24s (%-9s repeated) = %d element(s)", id, meta.type, #value))
                    local PRINT_LIMIT = 20
                    for i, element in ipairs(value) do
                        if i > PRINT_LIMIT then
                            print(string.format("        ... (%d more)", #value - PRINT_LIMIT))
                            break
                        end
                        if type(element) == "table" then
                            local parts = {}
                            for k, v in pairs(element) do
                                parts[#parts + 1] = string.format("%s=%s", k, tostring(v))
                            end
                            table.sort(parts)
                            print(string.format("        [%d] { %s }", i - 1, table.concat(parts, ", ")))
                        else
                            print(string.format("        [%d] %s", i - 1, tostring(element)))
                        end
                    end
                elseif meta.type == "BitMask" then
                    local active = {}
                    for name, flag in pairs(gameStatusFlagEnum) do
                        if value:has(name) then
                            active[#active + 1] = name
                        end
                    end
                    table.sort(active)
                    print(string.format("[ OK ] %-24s (%-9s) = { %s }", id, meta.type, table.concat(active, ", ")))
                else
                    print(string.format("[ OK ] %-24s (%-9s) = %s", id, meta.type, tostring(value)))
                end
                passCount = passCount + 1
            else
                print(string.format("[FAIL] %-24s (%-9s) error: %s", id, meta.type, tostring(err)))
                failCount = failCount + 1
            end
        end
    end
end

print("========================================")
print(string.format(" %d passed, %d failed, %d skipped (Object)", passCount, failCount, skipCount))
print(string.format(" total time: %.2fms", (os.clock() - loopStart) * 1000))
print("========================================")


--==================================================
-- BitMask usage demo
--==================================================
Nebula.GameStatus.set("safeCoins", 1000000)

Nebula.GameStatus.set("safeDiamonds", 1000000)


local flags, flagsErr = Nebula.GameStatus.get("flags")
if flags then
    
    flags:disable("ManuallyBanned")
    
    local ok, err = Nebula.GameStatus.set("flags", flags)
    print("flags write ok =", ok, "err =", err)
else
    print("flags read failed:", flagsErr)
end

--[[
--==================================================
-- has() / add() / sub() usage demo
--==================================================
-- add()/sub() use :dry() so this doesn't permanently mutate coins
-- on every test run — drop :dry() when you actually want to commit.

print("Nebula.GameStatus.has('device') =", Nebula.GameStatus.has("device"))
print("Nebula.GameStatus.has('playerId') =", Nebula.GameStatus.has("playerId"))
print("Nebula.GameStatus.has('coins') =", Nebula.GameStatus.has("coins"))

local addOk, addErr = Nebula.GameStatus.add("coins", 1000):dry()
print("add('coins', 1000) dry ok =", addOk, "err =", addErr)

local subOk, subErr = Nebula.GameStatus.sub("coins", 500):dry()
print("sub('coins', 500) dry ok =", subOk, "err =", subErr)

-- Type-gated rejection: playerName is a String, add() doesn't apply.
local badOk, badErr = Nebula.GameStatus.add("playerName", 1):dry()
print("add('playerName', 1) dry ok =", badOk, "err =", badErr)
--]]

return Nebula
