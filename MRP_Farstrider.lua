-- MRP_Farstrider.lua
-- local _, MRP = ...

---@type FarstriderLibAPI
local defaults = {
    VERSION = 0,
    DATA = {
        VERSION = 0,
        WAYPOINTS = {},
        CONFIG = {
            ElevationOverrides = {},
            MapTypeOverrides = {},
            ContinentMapOverrides = {},
            IsolatedAreas = {},
            IsolatedContinents = {},
        },
        GetLocalizedString = function() return nil end,
        IsBindLocationSupported = function() return false end,
        GetHousingData = function() return nil end,
        UpdateHousingExitLocation = function() end,
        GetHelpfulItems = function() return {} end,
    },
    Rebuild = function() end,
    FindTrail = function() return nil, nil, nil end,
    FindTrailTo = function() return nil, nil, nil end,
}

---@type FarstriderLibAPI
MRP.Farstrider = setmetatable({}, {
    __index = function(_, k)
        local api = FarstriderLib_API
        if api and api[k] ~= nil then return api[k] end
        return defaults[k]
    end,
    __newindex = function(_, k, v)
        if not FarstriderLib_API then FarstriderLib_API = {} end
        FarstriderLib_API[k] = v
    end,
})
