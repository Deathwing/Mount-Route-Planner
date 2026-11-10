-- MRPData~Finalizer.lua
-- local _, MRPData = ...

if not MRPData.Internal then return end

MRPData.Internal = nil

---@type MRPDataAPI
local lib = MRPData_API
if lib and lib.Internal then lib.Internal = nil end
lib.DUNGEONS = MRPData.dungeons
lib.RAIDS = MRPData.raids
lib.WORLD_BOSSES = MRPData.worldBosses
lib.OPEN_WORLD = MRPData.openWorld
lib.STEPS = MRPData.Steps

-- legacy support for direct access, will be removed in a future update
_G.MRPData = MRPData
