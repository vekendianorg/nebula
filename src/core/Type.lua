--==================================================
-- core/Type.lua
--==================================================

local M = {}

local registry = {
    Int32       = loadModule("core/types/Int32.lua"),
    SafeInt32   = loadModule("core/types/SafeInt32.lua"),
    SafeInt     = loadModule("core/types/SafeInt.lua"),
    JSONSafeInt = loadModule("core/types/SafeInt.lua"),
    Int64       = loadModule("core/types/Int64.lua"),
    Bool        = loadModule("core/types/Bool.lua"),
    Float       = loadModule("core/types/Float.lua"),
    String      = loadModule("core/types/String.lua"),
    BitMask     = loadModule("core/types/BitMask.lua"),
    Enum        = loadModule("core/types/Enum.lua"),
    Vec2        = loadModule("core/types/Vec2.lua"),
    Color3B     = loadModule("core/types/Color3B.lua"),
}

local Logfile = loadModule("core/Logfile.lua")

local function log(...)
    if Nebula and Nebula.log then
        Logfile.log("[Type]", ...)
    end
end

function M.resolve(typeName)
    local impl = registry[typeName]
    if not impl then
        log(string.format("resolve FAILED: unknown type '%s'", tostring(typeName)))
    end
    return impl
end

function M.register(typeName, implementation)
    log(string.format("register type '%s'", tostring(typeName)))
    registry[typeName] = implementation
end

return M
