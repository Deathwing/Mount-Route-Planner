-- MRP_Data.lua
-- local _, MRP = ...

---@type MRPDataAPI
local defaults = {
    VERSION = 0,
    DUNGEONS = {},
    RAIDS = {},
    WORLD_BOSSES = {},
    OPEN_WORLD = {},
    STEPS = {},
}

---@type MRPDataAPI
MRP.Data = setmetatable({}, {
    __index = function(_, k)
        local api = MRPData_API
        if api and api[k] ~= nil then return api[k] end
        return defaults[k]
    end,
    __newindex = function(_, k, v)
        if not MRPData_API then MRPData_API = {} end
        MRPData_API[k] = v
    end,
})
