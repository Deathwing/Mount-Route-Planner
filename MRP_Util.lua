-- MRP.lua
-- local _, MRP = ...

local Util = {}
MRP.Util = Util

---@generic T
---@generic U
---@param arr T[]
---@param selector fun(currentValue: T, index: number, arr: T[]):U
---@return U[] array
function Util.Map(arr, selector)
    local result = {}
    for i, v in ipairs(arr) do
        result[i] = selector(v, i, arr)
    end
    return result
end

---@return Location playerLocation
function Util.GetPlayerLocation()
    local uiMapId = C_Map.GetBestMapForUnit("player")
    local uiMapCoords = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player")

    if not uiMapCoords then
        local parentMapId = C_Map.GetMapInfo(uiMapId).parentMapID
        if parentMapId then
            uiMapId = parentMapId

            local instanceId = EJ_GetInstanceForMap(uiMapId)
            local dungeonEntrances = C_EncounterJournal.GetDungeonEntrancesForMap(parentMapId)

            for _, entrance in ipairs(dungeonEntrances) do
                if entrance.journalInstanceID == instanceId then
                    uiMapId = parentMapId
                    uiMapCoords = entrance.position
                    break
                end
            end
        end
    end

    if not uiMapCoords then
        uiMapCoords = { x = 0.5, y = 0.5 }
    end

    return { mapId = uiMapId, pos = { x = uiMapCoords.x, y = uiMapCoords.y, z = 0 }, isUI = true }
end

---@return Location
function Util.GetBindingLocation()
    local loc = MRP.Areas[MRP.AreaL[GetBindLocation()]]
    return { mapId = loc.mapId, pos = { x = loc.pos.x, y = loc.pos.y, z = loc.pos.z }, isUI = false }
end
