-- MRPData~Finalizer.lua
-- local _, MRPData = ...

if not MRPData.Internal then return end

MRPData.Internal = nil

---@type MRPDataAPI
MRPData_API = {
    VERSION = MRPData.VERSION,
    DUNGEONS = MRPData.dungeons,
    RAIDS = MRPData.raids,
    WORLD_BOSSES = MRPData.worldBosses,
    OPEN_WORLD = MRPData.openWorld,
    STEPS = MRPData.Steps,
}

-- legacy support for direct access, will be removed in a future update
_G.MRPData = MRPData
