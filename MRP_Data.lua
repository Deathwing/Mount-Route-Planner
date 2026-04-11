-- MRP_Data.lua
-- local _, MRP = ...

---@class Dungeon
---@field x number the x coordinate of the dungeon entrance
---@field y number the y coordinate of the dungeon entrance
---@field mapName string the name of the map where the dungeon is located
---@field mapID number the uiMapID of the dungeon entrance
---@field instanceId number the instanceID (mapID)
---@field availableDifficultyIds number[] the available difficultyIDs for the dungeon
---@field expansionLevel number the expansionLevel of the dungeon

---@type { [string]: Dungeon }
local dungeons = {}

---@class Raid
---@field x number the x coordinate of raid entrance
---@field y number the y coordinate of raid entrance
---@field mapName string the name of the map where the raid is located
---@field mapID number the uiMapID of the raid entrance
---@field instanceId number the instanceID (mapID)
---@field availableDifficultyIds number[] the available difficultyIDs for the raid
---@field expansionLevel number the expansionLevel of the raid
---@field areaId number? the areaID of the raid

---@type { [string]: Raid }
local raids = {}

---@class WorldBoss
---@field x number the x coordinate of the world boss
---@field y number the y coordinate of the world boss
---@field mapName string the name of the map where the world boss is located
---@field mapID number the uiMapID of the world boss
---@field questID number the questID for the world boss completion tracking
---@field expansionLevel number the expansionLevel of the world boss
---@field npcID number? the NPC ID for nearby detection and targeting
---@field targetName string? the exact targetable NPC name when it differs from the encounter/source name

---@type { [string]: WorldBoss }
local worldBosses = {}

---@class OpenWorld
---@field x number the x coordinate of the open world source
---@field y number the y coordinate of the open world source
---@field mapName string the name of the map where the source is located
---@field mapID number the uiMapID of the source
---@field questID number the questID for lockout tracking (0 = always farmable)
---@field expansionLevel number the expansionLevel of the source
---@field mechanic string the mechanic type ("kill", "click", "interact")
---@field npcID number? the NPC ID for targeting (nil or 0 for non-NPC sources)
---@field note string? an optional note about the source
---@field condition string? an optional condition key for phase gating
---@field waypoints OpenWorldWaypoint[]? additional map locations to highlight
---@field routeType string? visualization type ("patrol" = connected route, "spawns" = individual markers)
---@field routes OpenWorldRoute[]? multiple patrol routes, each drawn in a distinct color

---@class OpenWorldRoute
---@field waypoints OpenWorldWaypoint[] ordered waypoints forming this patrol route

---@class OpenWorldWaypoint
---@field x number the x coordinate (0-100 map percent)
---@field y number the y coordinate (0-100 map percent)
---@field mapID number? optional mapID if different from the main entry's mapID

---@type { [string]: OpenWorld }
local openWorld = {}

if MRPData then
    for k, v in pairs(MRPData.dungeons) do dungeons[k] = v end
    for k, v in pairs(MRPData.raids) do raids[k] = v end
    for k, v in pairs(MRPData.worldBosses) do worldBosses[k] = v end
    for k, v in pairs(MRPData.openWorld) do openWorld[k] = v end
end

MRP.Data = {
    dungeons = dungeons,
    raids = raids,
    worldBosses = worldBosses,
    openWorld = openWorld,
}
