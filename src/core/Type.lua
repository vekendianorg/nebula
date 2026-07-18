--==================================================
-- core/Type.lua
--==================================================
-- Central registry mapping metadata `type` strings to their
-- get/set implementation modules. Adding a new type = add a file
-- to core/types/ and register it here.

local M = {}

local registry = {
    Int32       = loadModule("core/types/Int32.lua"),
    SafeInt32   = loadModule("core/types/SafeInt32.lua"),
    Bool        = loadModule("core/types/Bool.lua"),
    Float       = loadModule("core/types/Float.lua"),
    String      = loadModule("core/types/String.lua"),
    BitMask     = loadModule("core/types/BitMask.lua"),
    Achievement = loadModule("core/types/Achievement.lua"),
}

---@param typeName string
---@return table|nil implementation
function M.resolve(typeName)
    return registry[typeName]
end

---Register a new type implementation at runtime (for modules that
---want to extend Nebula without editing this file).
---@param typeName string
---@param implementation table @ must expose get(base, field) and set(base, field, value)
function M.register(typeName, implementation)
    registry[typeName] = implementation
end

return M
