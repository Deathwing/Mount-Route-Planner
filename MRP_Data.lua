-- MRP_Data.lua
-- local _, MRP = ...

local L = MRP.L

---@class Dungeon
---@field x number the x coordinate of the dungeon entrance
---@field y number the y coordinate of the dungeon entrance
---@field mapName string the name of the map where the dungeon is located
---@field mapID number the uiMapID of the dungeon entrance
---@field instanceId number the instanceID (mapID)
---@field availableDifficultyIds number[] the available difficultyIDs for the dungeon
---@field expansionLevel number the expansionLevel of the dungeon

---@type { [string]: Dungeon }
local dungeons = {
    ["Stratholme"] = { x = 43.44, y = 18.32, mapName = "Eastern Plaguelands", mapID = 23, instanceId = 329, availableDifficultyIds = { 1, 24 }, expansionLevel = 0 },

    ["Sethekk Halls"] = { x = 44.47, y = 65.33, mapName = "Terokkar Forest", mapID = 108, instanceId = 556, availableDifficultyIds = { 1, 2 }, expansionLevel = 1 },
    ["Magisters' Terrace"] = { x = 61.03, y = 30.94, mapName = "Isle of Quel'Danas", mapID = 122, instanceId = 585, availableDifficultyIds = { 1, 2, 24 }, expansionLevel = 1 },

    ["Utgarde Pinnacle"] = { x = 57.22, y = 46.70, mapName = "Howling Fjord", mapID = 117, instanceId = 575, availableDifficultyIds = { 1, 2 }, expansionLevel = 2 },
    ["The Culling of Stratholme"] = { x = 60.16, y = 83.02, mapName = "Caverns of Time:75", mapID = 75, instanceId = 595, availableDifficultyIds = { 1, 2 }, expansionLevel = 2 },

    ["Zul'Aman"] = { x = 81.80, y = 64.79, mapName = "Ghostlands", mapID = 95, instanceId = 568, availableDifficultyIds = { 2 }, expansionLevel = 3 },
    ["The Vortex Pinnacle"] = { x = 76.75, y = 84.44, mapName = "Uldum:Kalimdor", mapID = 249, instanceId = 657, availableDifficultyIds = { 1, 2, 24 }, expansionLevel = 3 },
    ["The Stonecore"] = { x = 47.23, y = 52.26, mapName = "Deepholm", mapID = 207, instanceId = 725, availableDifficultyIds = { 1, 2, 24 }, expansionLevel = 3 },
    ["Zul'Gurub"] = { x = 71.96, y = 32.99, mapName = "Northern Stranglethorn", mapID = 50, instanceId = 859, availableDifficultyIds = { 2 }, expansionLevel = 3 },

    ["Return to Karazhan"] = { x = 46.71, y = 70.22, mapName = "Deadwind Pass", mapID = 42, instanceId = 1651, availableDifficultyIds = { 2, 23 }, expansionLevel = 6 },

    ["Freehold"] = { x = 84.32, y = 78.91, mapName = "Tiragarde Sound", mapID = 895, instanceId = 1754, availableDifficultyIds = { 1, 2, 23, 24 }, expansionLevel = 7 },
    ["King's Rest"] = { x = 37.51, y = 39.12, mapName = "Zuldazar", mapID = 862, instanceId = 1762, availableDifficultyIds = { 2, 23, 24 }, expansionLevel = 7 },
    ["The Underrot"] = { x = 51.43, y = 64.97, mapName = "Nazimir", mapID = 863, instanceId = 1841, availableDifficultyIds = { 1, 2, 23 }, expansionLevel = 7 },
    ["Operation: Mechagon"] = { x = 72.85, y = 36.48, mapName = "Mechagon Island", mapID = 1462, instanceId = 2097, availableDifficultyIds = { 2, 23 }, expansionLevel = 7 },

    ["The Necrotic Wake"] = { x = 39.79, y = 54.89, mapName = "Bastion", mapID = 1533, instanceId = 2286, availableDifficultyIds = { 1, 2, 23 }, expansionLevel = 8 },
    ["Tazavesh, the Veiled Market"] = { x = 31.15, y = 76.31, mapName = "The Shadowlands", mapID = 1550, instanceId = 2441, availableDifficultyIds = { 2, 23 }, expansionLevel = 8 },

    ["Dawn of the Infinite"] = { x = 61.15, y = 84.67, mapName = "Thaldraszus", mapID = 2025, instanceId = 2579, availableDifficultyIds = { 2, 23 }, expansionLevel = 9 },

    ["Darkflame Cleft"] = { x = 55.15, y = 21.83, mapName = "The Ringing Deeps", mapID = 2214, instanceId = 2651, availableDifficultyIds = { 1, 2, 23, 8 }, expansionLevel = 10 },
}

if WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
    for _, dungeon in pairs(dungeons) do
        for i = #dungeon.availableDifficultyIds, 1, -1 do
            if dungeon.availableDifficultyIds[i] == 23 or dungeon.availableDifficultyIds[i] == 24 then
                table.remove(dungeon.availableDifficultyIds, i)
            end
        end
    end
end

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
local raids = {
    ["Temple of Ahn'Qiraj"] = { x = 24.30, y = 87.12, mapName = "Silithus:Kalimdor", mapID = 81, instanceId = 531, availableDifficultyIds = { 9 }, expansionLevel = 0, areaId = 3429 },

    ["Karazhan"] = { x = 46.99, y = 75.05, mapName = "Deadwind Pass", mapID = 42, instanceId = 532, availableDifficultyIds = { 3 }, expansionLevel = 1, areaId = 3457 },
    ["The Eye"] = { x = 73.40, y = 63.89, mapName = "Netherstorm", mapID = 109, instanceId = 550, availableDifficultyIds = { 4 }, expansionLevel = 1, areaId = 3845 },

    ["Onyxia's Lair"] = { x = 52.15, y = 75.95, mapName = "Dustwallow Marsh", mapID = 70, instanceId = 249, availableDifficultyIds = { 3, 4 }, expansionLevel = 2, areaId = 2159 },
    ["Ulduar"] = { x = 41.59, y = 17.44, mapName = "The Storm Peaks", mapID = 120, instanceId = 603, availableDifficultyIds = { 14, 33 }, expansionLevel = 2, areaId = 4273 },
    ["The Obsidian Sanctum"] = { x = 59.95, y = 56.87, mapName = "Dragonblight", mapID = 115, instanceId = 615, availableDifficultyIds = { 3, 4 }, expansionLevel = 2, areaId = 4493 },
    ["The Eye of Eternity"] = { x = 27.55, y = 26.65, mapName = "Borean Tundra", mapID = 114, instanceId = 616, availableDifficultyIds = { 3, 4 }, expansionLevel = 2, areaId = 4500 },
    ["Vault of Archavon"] = { x = 49.87, y = 10.96, mapName = "Wintergrasp", mapID = 123, instanceId = 624, availableDifficultyIds = { 3, 4 }, expansionLevel = 2, areaId = 4603 },
    ["Icecrown Citadel"] = { x = 53.59, y = 87.12, mapName = "Icecrown", mapID = 118, instanceId = 631, availableDifficultyIds = { 3, 4, 5, 6 }, expansionLevel = 2, areaId = 4812 },

    ["Firelands"] = { x = 46.75, y = 78.65, mapName = "Mount Hijal", mapID = 198, instanceId = 720, availableDifficultyIds = { 14, 15, 33 }, expansionLevel = 3 },
    ["Throne of the Four Winds"] = { x = 38.42, y = 80.58, mapName = "Uldum:Kalimdor", mapID = 249, instanceId = 754, availableDifficultyIds = { 3, 4, 5, 6 }, expansionLevel = 3 },
    ["Dragon Soul"] = { x = 60.67, y = 20.39, mapName = "Caverns of Time:75", mapID = 75, instanceId = 967, availableDifficultyIds = { 3, 4, 5, 6, 7 }, expansionLevel = 3 },

    ["Mogu'shan Vaults"] = { x = 59.59, y = 38.94, mapName = "Kun-Lai Summit", mapID = 379, instanceId = 1008, availableDifficultyIds = { 3, 4, 5, 6, 7 }, expansionLevel = 4 },
    ["Throne of Thunder"] = { x = 63.67, y = 31.91, mapName = "Isle of Thunder", mapID = 504, instanceId = 1098, availableDifficultyIds = { 3, 4, 5, 6, 7 }, expansionLevel = 4 },
    ["Siege of Orgrimmar"] = { x = 73.64, y = 42.54, mapName = "Vale of Eternal Blossoms:Pandaria", mapID = 390, instanceId = 1136, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 4 },

    ["Blackrock Foundry"] = { x = 51.67, y = 26.80, mapName = "Gorgrond", mapID = 543, instanceId = 1205, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 5 },
    ["Hellfire Citadel"] = { x = 46.87, y = 52.91, mapName = "Tanaan Jungle", mapID = 534, instanceId = 1448, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 5 },

    ["The Nighthold"] = { x = 43.31, y = 62.28, mapName = "Suramar", mapID = 680, instanceId = 1530, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 6 },
    ["Tomb of Sargeras"] = { x = 64.03, y = 21.29, mapName = "Broken Shore", mapID = 646, instanceId = 1676, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 6 },
    ["Antorus, the Burning Throne"] = { x = 55.91, y = 63.77, mapName = "Antoran Waste", mapID = 885, instanceId = 1712, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 6 },

    ["Battle of Dazar'alor"] = { x = 70.16, y = 35.44, mapName = "Boralus", mapID = 1161, instanceId = 2070, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 7 },
    ["Battle of Dazar'alor (H)"] = { x = 54.11, y = 30.60, mapName = "Zuldazar", mapID = 862, instanceId = 2070, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 7 },
    ["Ny'alotha the Waking City"] = { x = 55.15, y = 43.55, mapName = "Uldum:1527", mapID = 1527, instanceId = 2217, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 7 },
    ["Ny'alotha the Waking City (VoEB)"] = { x = 40.18, y = 45.39, mapName = "Vale of Eternal Blossoms:1530", mapID = 1530, instanceId = 2217, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 7 },

    ["Sanctum of Domination"] = { x = 69.31, y = 30.94, mapName = "The Maw:The Shadowlands", mapID = 1543, instanceId = 2450, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 8 },
    ["Sepulcher of the First Ones"] = { x = 80.36, y = 53.63, mapName = "Zereth Mortis", mapID = 1970, instanceId = 2481, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 8 },

    ["Amirdrassil, the Dream's Hope"] = { x = 26.94, y = 31.55, mapName = "Emerald Dream", mapID = 2200, instanceId = 2549, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 9 },

    ["Nerub-ar Palace"] = { x = 43.51, y = 90.18, mapName = "Nerub-ar Palace", mapID = 2255, instanceId = 2657, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 10 },
    ["Liberation of Undermine"] = { x = 40.87, y = 48.77, mapName = "Undermine", mapID = 2346, instanceId = 2769, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 10 },
    ["Manaforge Omega"] = { x = 41.89, y = 21.57, mapName = "K'aresh", mapID = 2371, instanceId = 2810, availableDifficultyIds = { 14, 15, 16, 17 }, expansionLevel = 10 },
}

if WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
    for _, raid in pairs(raids) do
        for i = #raid.availableDifficultyIds, 1, -1 do
            if raid.availableDifficultyIds[i] == 33 then
                table.remove(raid.availableDifficultyIds, i)
            end
        end

        for i = #raid.availableDifficultyIds, 1, -1 do
            if raid.availableDifficultyIds[i] == 14 then
                table.remove(raid.availableDifficultyIds, i)
                table.insert(raid.availableDifficultyIds, 3)
                table.insert(raid.availableDifficultyIds, 4)
            elseif raid.availableDifficultyIds[i] == 15 then
                table.remove(raid.availableDifficultyIds, i)
                table.insert(raid.availableDifficultyIds, 5)
                table.insert(raid.availableDifficultyIds, 6)
            end
        end

        table.sort(raid.availableDifficultyIds, function(a, b)
            return a < b
        end)
    end
end

---@class WorldBoss
---@field x number the x coordinate of the world boss
---@field y number the y coordinate of the world boss
---@field mapName string the name of the map where the world boss is located
---@field mapID number the uiMapID of the world boss
---@field questID number the questID for the world boss completion tracking
---@field expansionLevel number the expansionLevel of the world boss

---@type { [string]: WorldBoss }
local worldBosses = {
    ["Salyis's Warband"] = { x = 71.36, y = 64.14, mapName = "Valley of the Four Winds", mapID = 376, questID = 32098, expansionLevel = 4 },
    ["Sha of Anger"] = { x = 54.55, y = 63.35, mapName = "Kun-Lai Summit", mapID = 379, questID = 32099, expansionLevel = 4 },
    ["Nalak, The Storm Lord"] = { x = 60.31, y = 37.68, mapName = "Isle of Thunder", mapID = 504, questID = 32518, expansionLevel = 4 },
    ["Oondasta"] = { x = 49.87, y = 54.42, mapName = "Isle of Giants", mapID = 507, questID = 32519, expansionLevel = 4 },

    ["Rukhmar"] = { x = 34.4, y = 39.0, mapName = "Spires of Arak", mapID = 542, questID = 37464, expansionLevel = 5 },
}

MRP.Data = {
    dungeons = dungeons,
    raids = raids,
    worldBosses = worldBosses,
    helpfulItems = {}
}

---@param id number
---@param from WaypointLocation
---@param to WaypointLocation
---@param bidirectional boolean
---@param cost number
local function addEntry(id, from, to, bidirectional, cost)
    local entry = { id = id, from = from, to = to, bidirectional = bidirectional, cost = cost } ---@type Waypoint
    table.insert(MRP.Waypoints, entry)
end

local flightpathCount = 0

local function addFlightpath(fromMapId, fromPos, fromIsUI, fromAreaId, toMapId, toPos, toIsUI, toAreaId, cost, condition)
    local from = { unknown1 = 0, flags = 0, loc = { mapId = fromMapId, pos = fromPos, isUI = fromIsUI }, condition = condition, type = 1, important = true, locaId = MRP.SpecialLocaId.FlightpathTo, locaArgs = function() return { C_Map.GetAreaInfo(toAreaId) or L["Area_" .. toAreaId] } end } ---@type WaypointLocation
    local to = { unknown1 = 0, flags = 0, loc = { mapId = toMapId, pos = toPos, isUI = toIsUI }, condition = condition, type = 1, important = true, locaId = MRP.SpecialLocaId.FlightpathTo, locaArgs = function() return { C_Map.GetAreaInfo(fromAreaId) or L["Area_" .. fromAreaId] } end } ---@type WaypointLocation
    addEntry(MRP.SpecialLocaId.FlightpathTo + flightpathCount, from, to, true, cost)
    flightpathCount = flightpathCount + 1
end

-- Shadowlands
if GetExpansionLevel() >= 8 then
    -- Both
    addFlightpath(2222, { x = -1902.4399414062, y = 1214.7600097656, z = 5450.8701171875 }, false, 10565, 2222, { x = -3387.6999511719, y = 5461.4599609375, z = 4275.7202148438 }, false, 10982, 10) -- Oribos to Pridefall Hamlet, Revendreth
    addFlightpath(2222, { x = -1902.4399414062, y = 1214.7600097656, z = 5450.8701171875 }, false, 10565, 2222, { x = -6143.7797851562, y = -207.12800598145, z = 5581.919921875 }, false, 11515, 10) -- Oribos to Tirna Vaal, Ardenweald
    addFlightpath(2222, { x = -1902.4399414062, y = 1214.7600097656, z = 5450.8701171875 }, false, 10565, 2222, { x = -4160.75, y = -4629.7700195312, z = 6534.1499023438 }, false, 11473, 10)        -- Oribos to Aspirant's Rest, Bastion
    addFlightpath(2222, { x = -1902.4399414062, y = 1214.7600097656, z = 5450.8701171875 }, false, 10565, 2222, { x = 2580.4699707031, y = -2520.7600097656, z = 3307.5200195312 }, false, 11465, 10) -- Oribos to Theater of Pain, Maldraxxus
    addFlightpath(2222, { x = -1902.4399414062, y = 1214.7600097656, z = 5450.8701171875 }, false, 10565, 2222, { x = -5895.6401367188, y = 4810.740234375, z = 4789.990234375 }, false, 13672, 10)   -- Oribos to Tazavesh, the Veiled Market
end

local boatCount = 0

local function addBoat(fromMapId, fromPos, fromIsUI, fromAreaId, toMapId, toPos, toIsUI, toAreaId, cost, condition)
    local from = { unknown1 = 0, flags = 0, loc = { mapId = fromMapId, pos = fromPos, isUI = fromIsUI }, condition = condition, type = 1, important = true, locaId = MRP.SpecialLocaId.BoatTo, locaArgs = function() return { C_Map.GetAreaInfo(fromAreaId) or L["Area_" .. fromAreaId], C_Map.GetAreaInfo(toAreaId) or L["Area_" .. toAreaId] } end }
    local to = { unknown1 = 0, flags = 0, loc = { mapId = toMapId, pos = toPos, isUI = toIsUI }, condition = condition, type = 1, important = true, locaId = MRP.SpecialLocaId.BoatTo, locaArgs = function() return { C_Map.GetAreaInfo(toAreaId) or L["Area_" .. toAreaId], C_Map.GetAreaInfo(fromAreaId) or L["Area_" .. fromAreaId] } end }
    addEntry(MRP.SpecialLocaId.BoatTo + boatCount, from, to, true, cost)
    boatCount = boatCount + 1
end

-- Cataclysm (Classic Only)
if GetExpansionLevel() >= 3 and WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
    -- Alliance
    if UnitFactionGroup("player") == "Alliance" then
        addBoat(0, { x = -8645.5400390625, y = 1308.25, z = 5.23483991623 }, false, 1519, 1, { x = 8177.5600585938, y = 1002.6599731445, z = 6.66929006577 }, false, 702, 600) -- Stormwind to Rut'theran Village
    end
end

local zeppelinCount = 0

local function addZeppelin(fromMapId, fromPos, fromIsUI, fromAreaId, toMapId, toPos, toIsUI, toAreaId, cost, condition)
    local from = { unknown1 = 0, flags = 0, loc = { mapId = fromMapId, pos = fromPos, isUI = fromIsUI }, condition = condition, type = 1, important = true, locaId = MRP.SpecialLocaId.ZeppelinTo, locaArgs = function() return { C_Map.GetAreaInfo(fromAreaId) or L["Area_" .. fromAreaId], C_Map.GetAreaInfo(toAreaId) or L["Area_" .. toAreaId] } end }
    local to = { unknown1 = 0, flags = 0, loc = { mapId = toMapId, pos = toPos, isUI = toIsUI }, condition = condition, type = 1, important = true, locaId = MRP.SpecialLocaId.ZeppelinTo, locaArgs = function() return { C_Map.GetAreaInfo(toAreaId) or L["Area_" .. toAreaId], C_Map.GetAreaInfo(fromAreaId) or L["Area_" .. fromAreaId] } end }
    addEntry(MRP.SpecialLocaId.ZeppelinTo + zeppelinCount, from, to, true, cost)
    zeppelinCount = zeppelinCount + 1
end

-- Cataclysm (Classic Only)
if GetExpansionLevel() >= 3 and WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
    -- Horde
    if UnitFactionGroup("player") == "Horde" then
        addZeppelin(0, { x = 2070.5122070312, y = 289.15798950195, z = 97.03157806396 }, false, 1497, 1, { x = 1842.1899414062, y = -4389.0400390625, z = 135.23300170898 }, false, 1637, 600) --  Undercity to Orgrimmar
        addZeppelin(0, { x = 2059.9340820312, y = 235.90972900391, z = 99.76524353027 }, false, 1497, 0, { x = -12396.400390625, y = 217.47999572754, z = 1.69035005569 }, false, 117, 600)    --  Undercity to Grom'gol Base Camp
        addZeppelin(0, { x = 2063.2448730469, y = 364.23959350586, z = 82.50442504883 }, false, 1497, 571, { x = 1950.8000488281, y = -6174.2299804688, z = 24.30380058289 }, false, 495, 600) --  Undercity to Howling Fjord
    end
end

local portalCount = 0

local function addPortal(bidirectional, fromMapId, fromPos, fromIsUI, fromAreaId, toMapId, toPos, toIsUI, toAreaId, cost, condition)
    local from = { unknown1 = 0, flags = 0, loc = { mapId = fromMapId, pos = fromPos, isUI = fromIsUI }, condition = condition, type = 1, important = true, locaId = MRP.SpecialLocaId.PortalTo, locaArgs = function() return { C_Map.GetAreaInfo(toAreaId) or L["Area_" .. toAreaId] } end }
    local to = { unknown1 = 0, flags = 0, loc = { mapId = toMapId, pos = toPos, isUI = toIsUI }, condition = bidirectional and condition or nil, type = 1, important = true, locaId = MRP.SpecialLocaId.PortalTo, locaArgs = function() return { C_Map.GetAreaInfo(fromAreaId) or L["Area_" .. fromAreaId] } end }
    addEntry(MRP.SpecialLocaId.PortalTo + portalCount, from, to, bidirectional, cost)
    portalCount = portalCount + 1
end

-- Wrath of the Lich King
if GetExpansionLevel() >= 2 then
    -- Both
    addPortal(true, 119, { x = 0.4035, y = 0.8309, z = 0 }, true, 4300, 78, { x = 0.5055, y = 0.0773, z = 0 }, true, 4381, 10, function() return C_QuestLog.IsQuestFlaggedCompleted(12546) end) -- Sholazar Basin to Un'Goro Crater
end

-- Pandaria (Retail Only)
if GetExpansionLevel() >= 4 and WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    -- Alliance
    if UnitFactionGroup("player") == "Alliance" then
        addPortal(true, 388, { x = 0.4975, y = 0.6866, z = 0 }, true, 5842, 504, { x = 0.6470, y = 0.7348, z = 0 }, true, 6507, 10) -- Townlong Steppes to Isle of Thunder
    end

    -- Horde
    if UnitFactionGroup("player") == "Horde" then
        addPortal(true, 388, { x = 0.5065, y = 0.7340, z = 0 }, true, 5842, 504, { x = 0.3315, y = 0.3285, z = 0 }, true, 6507, 10) -- Townlong Steppes to Isle of Thunder
    end
end

-- Pandaria (Classic Only)
if GetExpansionLevel() >= 4 and WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then
    -- Both
    addPortal(false, 125, { x = 0.2543, y = 0.5155, z = 661 }, true, 4613, 74, { x = 0.5460, y = 0.2830, z = 0 }, true, 2300, 10) -- Dalaran to Caverns of Time

    -- Alliance
    if UnitFactionGroup("player") == "Alliance" then
        addPortal(false, 103, { x = 0.4757, y = 0.6216, z = -138 }, true, 3557, 89, { x = 0.4347, y = 0.7868, z = 0 }, true, 1657, 10)                                                                  -- Exodar to Darnassus
        addPortal(false, 103, { x = 0.4815, y = 0.6302, z = -138 }, true, 3557, 17, { x = 0.5390, y = 0.4608, z = 0 }, true, 4, 10, function() return UnitLevel("player") >= 56 end)                    -- Exodar to Blasted Lands

        addPortal(false, 84, { x = 0.4897, y = 0.8736, z = 100 }, true, 1519, 17, { x = 0.5390, y = 0.4608, z = 0 }, true, 4, 10, function() return UnitLevel("player") >= 56 end)                      -- Stormwind to Blasted Lands
        addPortal(false, 84, { x = 0.6871, y = 0.1717, z = 117 }, true, 1519, 371, { x = 0.4624, y = 0.8517, z = 63 }, true, 6516, 10, function() return C_QuestLog.IsQuestFlaggedCompleted(29548) end) -- Stormwind to Paw'don Village

        addPortal(false, 87, { x = 0.2726, y = 0.0708, z = 501 }, true, 1537, 17, { x = 0.5390, y = 0.4608, z = 0 }, true, 4, 10, function() return UnitLevel("player") >= 56 end)                      -- Ironforge to Blasted Lands

        addPortal(false, 89, { x = 0.4399, y = 0.7814, z = 0 }, true, 1657, 103, { x = 0.2627, y = 0.4559, z = -138 }, true, 3557, 10)                                                                  -- Darnassus to Exodar
        addPortal(false, 89, { x = 0.4422, y = 0.7870, z = 0 }, true, 1657, 17, { x = 0.5390, y = 0.4608, z = 0 }, true, 4, 10, function() return UnitLevel("player") >= 56 end)                        -- Darnassus to Blasted Lands

        addPortal(false, 394, { x = 0.7086, y = 0.3040, z = 0 }, true, 6142, 103, { x = 0.2627, y = 0.4559, z = -138 }, true, 3557, 10)                                                                 -- Shrine of Seven Stars to Exodar
        addPortal(false, 394, { x = 0.7168, y = 0.3598, z = 0 }, true, 6142, 84, { x = 0.4867, y = 0.8815, z = 149 }, true, 1519, 10)                                                                   -- Shrine of Seven Stars to Stormwind
        addPortal(false, 394, { x = 0.7403, y = 0.4098, z = 0 }, true, 6142, 87, { x = 0.2551, y = 0.843, z = 501 }, true, 1537, 10)                                                                    -- Shrine of Seven Stars to Ironforge
        addPortal(false, 394, { x = 0.7724, y = 0.4350, z = 0 }, true, 6142, 89, { x = 0.4347, y = 0.7868, z = 0 }, true, 1657, 10)                                                                     -- Shrine of Seven Stars to Darnassus
        addPortal(false, 394, { x = 0.6848, y = 0.5298, z = 0 }, true, 6142, 111, { x = 0.5497, y = 0.4023, z = -12 }, true, 3703, 10)                                                                  -- Shrine of Seven Stars to Shattrath
        addPortal(false, 394, { x = 0.6165, y = 0.3960, z = 0 }, true, 6142, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 10)                                                                  -- Shrine of Seven Stars to Dalaran
    end

    -- Horde
    if UnitFactionGroup("player") == "Horde" then
        addPortal(false, 110, { x = 0.5870, y = 0.2052, z = 48 }, true, 3487, 17, { x = 0.5390, y = 0.4608, z = 0 }, true, 4, 10, function() return UnitLevel("player") >= 56 end)                      -- Silvermoon to Blasted Lands

        addPortal(false, 86, { x = 0.4648, y = 0.6689, z = 0 }, true, 1637, 17, { x = 0.5390, y = 0.4608, z = 0 }, true, 4, 10, function() return UnitLevel("player") >= 56 end)                        -- Orgrimmar to Blasted Lands
        addPortal(false, 85, { x = 0.6883, y = 0.4057, z = 40 }, true, 1637, 371, { x = 0.2851, y = 0.1402, z = 248 }, true, 6521, 10, function() return C_QuestLog.IsQuestFlaggedCompleted(29690) end) -- Orgrimmar to Honeydew Village

        addPortal(false, 88, { x = 0.2297, y = 0.1360, z = 111 }, true, 1638, 17, { x = 0.5390, y = 0.4608, z = 0 }, true, 4, 10, function() return UnitLevel("player") >= 56 end)                      -- Thunder Bluff to Blasted Lands

        addPortal(false, 998, { x = 0.8527, y = 0.1727, z = 0 }, true, 1497, 17, { x = 0.5390, y = 0.4608, z = 0 }, true, 4, 10, function() return UnitLevel("player") >= 56 end)                       -- Undercity to Blasted Lands

        addPortal(false, 392, { x = 0.7625, y = 0.5261, z = 0 }, true, 6141, 110, { x = 0.5635, y = 0.2183, z = 48 }, true, 3487, 10)                                                                   -- Shrine of Two Moons to Silvermoon
        addPortal(false, 392, { x = 0.7332, y = 0.4270, z = 0 }, true, 6141, 86, { x = 0.4891, y = 0.5435, z = 0 }, true, 1637, 10)                                                                     -- Shrine of Two Moons to Orgrimmar
        addPortal(false, 392, { x = 0.7382, y = 0.3656, z = 0 }, true, 6141, 88, { x = 0.2238, y = 0.1877, z = 111 }, true, 1638, 10)                                                                   -- Shrine of Two Moons to Thunder Bluff
        addPortal(false, 392, { x = 0.7429, y = 0.4786, z = 0 }, true, 6141, 998, { x = 0.8409, y = 0.1718, z = 0 }, true, 1497, 10)                                                                    -- Shrine of Two Moons to Undercity
        addPortal(false, 392, { x = 0.6336, y = 0.5747, z = 0 }, true, 6141, 111, { x = 0.5497, y = 0.4023, z = -12 }, true, 3703, 10)                                                                  -- Shrine of Two Moons to Shattrath
        addPortal(false, 392, { x = 0.6154, y = 0.3651, z = 0 }, true, 6141, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 10)                                                                  -- Shrine of Two Moons to Dalaran
    end
end

if GetExpansionLevel() >= 6 then
    -- Both
    addPortal(false, 627, { x = 0.7427, y = 0.4930, z = 739 }, true, 7505, 1669, { x = 500.28100585938, y = 1469.6800537109, z = 742.44201660156 }, false, 8714, 10) -- Dalaran to Argus
end

local itemCount = 0
local helpfulItems = {}

local function addItem(itemId, toMapId, toPos, toIsUI, toAreaId, cost, condition)
    local from = { actionOptions = { { type = "item", data = itemId } }, condition = function() return (not condition or condition()) and MRP.UI:CanUseItem(itemId) end, unknown1 = 0, dynLoc = function() return MRP.Util.GetPlayerLocation() end, flags = 8, type = 1, important = true, locaId = MRP.SpecialLocaId.ItemTo, locaArgs = function() return { MRP.Util.GetItemNameSafe(itemId), C_Map.GetAreaInfo(toAreaId) or L["Area_" .. toAreaId] } end }
    local to = { unknown1 = 0, flags = 0, loc = { mapId = toMapId, pos = toPos, isUI = toIsUI }, type = 2, locaId = MRP.SpecialLocaId.ItemTo, locaArgs = function() return { MRP.Util.GetItemNameSafe(itemId), C_Map.GetAreaInfo(toAreaId) } end }
    addEntry(MRP.SpecialLocaId.ItemTo + itemCount, from, to, false, cost)
    itemCount = itemCount + 1
    if not helpfulItems[itemId] then
        helpfulItems[itemId] = true
        table.insert(MRP.Data.helpfulItems, itemId)
    end
end

local function addDynamicItemWithMultipleIds(itemIds, dynLoc, dynLocaId, cost, condition)
    local finalActionOptions = {}
    for _, itemId in ipairs(itemIds) do
        table.insert(finalActionOptions, { type = "item", data = itemId, allowAny = true })
    end

    local finalCondition = function()
        if condition and not condition() then
            return false
        end

        for _, itemId in ipairs(itemIds) do
            if MRP.UI:CanUseItem(itemId) then
                return true
            end
        end

        return false
    end

    local from = { actionOptions = finalActionOptions, condition = finalCondition, unknown1 = 0, dynLoc = function() return MRP.Util.GetPlayerLocation() end, flags = 8, type = 1, important = true, locaId = MRP.SpecialLocaId.ItemTo, locaArgs = function() return { MRP.Util.GetItemNameSafe(itemIds[1]), dynLocaId() or L["Unknown Location"] } end }
    local to = { unknown1 = 0, flags = 0, dynLoc = dynLoc, type = 2, locaId = MRP.SpecialLocaId.ItemTo, locaArgs = function() return { MRP.Util.GetItemNameSafe(itemIds[1]), dynLocaId() or L["Unknown Location"] } end }
    addEntry(MRP.SpecialLocaId.ItemTo + itemCount, from, to, false, cost)
    itemCount = itemCount + 1

    for _, itemId in ipairs(itemIds) do
        if not helpfulItems[itemId] then
            helpfulItems[itemId] = true
            table.insert(MRP.Data.helpfulItems, itemId)
        end
    end
end

local spellCount = 0

local function addSpell(spellId, toMapId, toPos, toIsUI, toAreaId, cost, condition)
    local from = { actionOptions = { { type = "spell", data = spellId } }, condition = function() return (not condition or condition()) and MRP.UI:CanUseSpell(spellId) end, unknown1 = 0, dynLoc = function() return MRP.Util.GetPlayerLocation() end, flags = 8, type = 1, important = true, locaId = MRP.SpecialLocaId.SpellTo, locaArgs = function() return { MRP.Util.GetSpellNameSafe(spellId), C_Map.GetAreaInfo(toAreaId) or L["Area_" .. toAreaId] } end }
    local to = { unknown1 = 0, flags = 0, loc = { mapId = toMapId, pos = toPos, isUI = toIsUI }, type = 2, locaId = MRP.SpecialLocaId.SpellTo, locaArgs = function() return { MRP.Util.GetSpellNameSafe(spellId), C_Map.GetAreaInfo(toAreaId) } end }
    addEntry(MRP.SpecialLocaId.SpellTo + spellCount, from, to, false, cost)
    spellCount = spellCount + 1
end

local hearthstones = {}

local function addHearthstone(itemId)
    table.insert(hearthstones, itemId)
end

-- Vanilla
-- Both
addHearthstone(6948)                                                  -- Hearthstone
addItem(18984, 83, { x = 0.5985, y = 0.4976, z = 0 }, true, 2255, 60) -- Dimensional Ripper - Everlook
addItem(18986, 71, { x = 0.5151, y = 0.3025, z = 0 }, true, 976, 60)  -- Ultrasafe Transporter: Gadgetzan
addItem(22631, 42, { x = 0.4735, y = 0.7532, z = 0 }, true, 2562, 5)  -- Atiesh, Greatstaff of the Guardian
addHearthstone(54452)                                                 -- Ethereal Portal
addHearthstone(64488)                                                 -- The Innkeeper's Daughter
addHearthstone(172179)                                                -- Eternal Traveler's Hearthstone
addHearthstone(193588)                                                -- Timewalker's Hearthstone
addHearthstone(200630)                                                -- Ohn'ir Windsage's Hearthstone
addHearthstone(208704)                                                -- Deepdweller's Earthen Hearthstone
addHearthstone(209035)                                                -- Hearthstone of the Flame

-- Brawler's Guild items to capitals (fancy teleport toys/rings)
-- if UnitFactionGroup("player") == "Alliance" then
--     -- Stormwind City
--     addItem(95051, 84, { x = 0.4897, y = 0.8736, z = 100 }, true, 1519, 10)  -- The Brassiest Knuckle (Bizmo's Brawlpub)
--     addItem(118907, 84, { x = 0.4897, y = 0.8736, z = 100 }, true, 1519, 10) -- Pit Fighter's Punching Ring (Bizmo's)
--     addItem(144391, 84, { x = 0.4897, y = 0.8736, z = 100 }, true, 1519, 10) -- Pugilist's Powerful Punching Ring (Bizmo's)
-- end
-- if UnitFactionGroup("player") == "Horde" then
--     -- Orgrimmar
--     addItem(95050, 85, { x = 0.6883, y = 0.4057, z = 40 }, true, 1637, 10)  -- The Brassiest Knuckle (Brawl'gar Arena)
--     addItem(118908, 85, { x = 0.6883, y = 0.4057, z = 40 }, true, 1637, 10) -- Pit Fighter's Punching Ring (Brawl'gar)
--     addItem(144392, 85, { x = 0.6883, y = 0.4057, z = 40 }, true, 1637, 10) -- Pugilist's Powerful Punching Ring (Brawl'gar)
-- end

-- The Burning Crusade
if GetExpansionLevel() >= 1 then
    -- Both
    addItem(30542, 109, { x = 0.3355, y = 0.6767, z = 0 }, true, 3712, 60) -- Dimensional Ripper - Area 52
    addItem(30544, 105, { x = 0.6091, y = 0.7008, z = 0 }, true, 3918, 60) -- Ultrasafe Transporter: Toshley's Station
    addItem(32757, 104, { x = 0.6621, y = 0.4398, z = 0 }, true, 3840, 15) -- Blessed Medallion of Karabor
end

-- Wrath of the Lich King
if GetExpansionLevel() >= 2 then
    -- Both
    addItem(46874, 118, { x = 0.6938, y = 0.2264, z = 0 }, true, 4658, 30)   -- Argent Crusader's Tabard
    addItem(40585, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Signet of the Kirin Tor
    addItem(40586, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Band of the Kirin Tor
    addItem(44934, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Loop of the Kirin Tor
    addItem(44935, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Ring of the Kirin Tor
    addItem(45688, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Inscribed Band of the Kirin Tor
    addItem(45689, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Inscribed Loop of the Kirin Tor
    addItem(45690, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Inscribed Ring of the Kirin Tor
    addItem(45691, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Inscribed Signet of the Kirin Tor
    addItem(48954, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Etched Band of the Kirin Tor
    addItem(48955, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Etched Loop of the Kirin Tor
    addItem(48956, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Etched Ring of the Kirin Tor
    addItem(48957, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Etched Signet of the Kirin Tor
    addItem(50287, 224, { x = 0.3692, y = 0.7599, z = 9 }, true, 35, 30)     -- Boots of the Bay
    addItem(51557, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Runed Signet of the Kirin Tor
    addItem(51558, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Runed Loop of the Kirin Tor
    addItem(51559, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Runed Ring of the Kirin Tor
    addItem(51560, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Runed Band of the Kirin Tor
    addItem(52251, 125, { x = 0.5592, y = 0.4679, z = 661 }, true, 4613, 30) -- Jaina's Locket
end

-- Cataclysm
if GetExpansionLevel() >= 3 then
    -- Both
    addItem(58487, 207, { x = 0.4873, y = 0.5356, z = -48 }, true, 5042, 10) -- Potion of Deepholm

    -- Alliance
    if UnitFactionGroup("player") == "Alliance" then
        addItem(63206, 84, { x = 0.4637, y = 0.9028, z = 67 }, true, 1519, 30) -- Wrap of Unity
        addItem(63352, 84, { x = 0.4637, y = 0.9028, z = 67 }, true, 1519, 30) -- Shroud of Cooperation
        addItem(65360, 84, { x = 0.4637, y = 0.9028, z = 67 }, true, 1519, 30) -- Cloak of Coordination
    end

    -- Horde
    if UnitFactionGroup("player") == "Horde" then
        addItem(63207, 85, { x = 0.5710, y = 0.8981, z = 18 }, true, 1637, 30) -- Wrap of Unity
        addItem(63353, 85, { x = 0.5710, y = 0.8981, z = 18 }, true, 1637, 30) -- Shroud of Cooperation
        addItem(65274, 85, { x = 0.5710, y = 0.8981, z = 18 }, true, 1637, 30) -- Cloak of Coordination
    end
end

-- Mists of Pandaria
if GetExpansionLevel() >= 4 then
    -- Both
    addHearthstone(93672)                                                   -- Dark Portal
    addItem(103678, 554, { x = 0.3451, y = 0.5550, z = 0 }, true, 6757, 10) -- Time-Lost Artifact

    -- Alliance
    if UnitFactionGroup("player") == "Alliance" then
        addItem(95567, 504, { x = 0.6470, y = 0.7348, z = 0 }, true, 6507, 10) -- Kirin Tor Beacon
    end

    -- Horde
    if UnitFactionGroup("player") == "Horde" then
        addItem(95568, 504, { x = 0.3315, y = 0.3285, z = 0 }, true, 6507, 10) -- Sunreaver Beacon
    end
end

-- Warlords of Draenor
if GetExpansionLevel() >= 5 then
    -- Alliance
    if UnitFactionGroup("player") == "Alliance" then
        addItem(110560, 582, { x = 0.2992, y = 0.3392, z = 0 }, true, 6790, 30, function() return C_QuestLog.IsQuestFlaggedCompleted(34586) end) -- Garrison Hearthstone
    end

    -- Horde
    if UnitFactionGroup("player") == "Horde" then
        addItem(110560, 590, { x = 0.5, y = 0.5, z = 0 }, true, 7004, 30, function() return C_QuestLog.IsQuestFlaggedCompleted(34378) end) -- Garrison Hearthstone
    end
end

-- Legion
if GetExpansionLevel() >= 6 then
    -- Both
    addItem(139599, 627, { x = 0.6092, y = 0.4472, z = 739 }, true, 7502, 30)                                                                                                               -- Empowered Ring of the Kirin Tor
    addHearthstone(142298)                                                                                                                                                                  -- Astonishingly Scarlet Slippers
    addHearthstone(142542)                                                                                                                                                                  -- Tome of Town Portal
    addItem(140192, 627, { x = 0.6092, y = 0.4472, z = 739 }, true, 7502, 30, function() return C_QuestLog.IsQuestFlaggedCompleted(44184) or C_QuestLog.IsQuestFlaggedCompleted(44663) end) -- Dalaran Hearthstone
    addItem(142469, 42, { x = 0.4735, y = 0.7532, z = 0 }, true, 2562, 30)                                                                                                                  -- Violet Seal of the Grand Magus
end

-- Battle for Azeroth
if GetExpansionLevel() >= 7 then
    -- Both
    addHearthstone(168907) -- Holographic Digitalization Hearthstone

    -- Alliance
    if UnitFactionGroup("player") == "Alliance" then
        addItem(166560, 1161, { x = 0.668, y = 0.256, z = 0 }, true, 8718, 30) -- Captain's Signet of Command
    end

    -- Horde
    if UnitFactionGroup("player") == "Horde" then
        addItem(166559, 862, { x = 0.512, y = 0.952, z = 0 }, true, 8665, 30) -- Commander's Signet of Battle
    end
end

-- Shadowlands
if GetExpansionLevel() >= 8 then
    -- Both
    addHearthstone(188952) -- Dominated Hearthstone
    addHearthstone(190196) -- Enlightened Hearthstone
    -- addItem(184501, 1525, { x = 0.51, y = 0.78, z = 0 }, true, 6145, 10)  -- Revendreth: 184501 (The Mad Duke's Tea?) fixed destination
    -- addItem(190237, 1670, { x = 0.50, y = 0.50, z = 0 }, true, 10565, 10) -- Broker Translocation Matrix (Oribos)
    -- addItem(172924, 1550, { x = 0.5, y = 0.5, z = 0 }, true, 1550, 60)    -- Wormhole Generator: Shadowlands (The Shadowlands continent)
    -- addItem(184500, 1533, { x = 0.5, y = 0.5, z = 0 }, true, 1533, 10)    -- Attendant's Pocket Portal: Bastion
    -- addItem(184502, 1536, { x = 0.5, y = 0.5, z = 0 }, true, 1536, 10)    -- Attendant's Pocket Portal: Maldraxxus
    -- addItem(184503, 1565, { x = 0.5, y = 0.5, z = 0 }, true, 1565, 10)    -- Attendant's Pocket Portal: Ardenweald
    -- addItem(184504, 1670, { x = 0.5, y = 0.5, z = 0 }, true, 1670, 10)    -- Attendant's Pocket Portal: Oribos
end

-- The War Within
if GetExpansionLevel() >= 10 then
    -- Both
    addHearthstone(162973) -- Greatfather Winter's Hearthstone
    addHearthstone(163045) -- Headless Horseman's Hearthstone
    addHearthstone(165669) -- Lunar Elder's Hearthstone
    addHearthstone(165670) -- Peddlefeet's Lovely Hearthstone
    addHearthstone(165802) -- Noble Gardener's Hearthstone
    addHearthstone(166746) -- Fire Eater's Hearthstone
    addHearthstone(166747) -- Brewfest Reveler's Hearthstone
    addHearthstone(212337) -- Stone of the Hearth
    addHearthstone(228940) -- Notorious Thread's Hearthstone
    addHearthstone(235016) -- Redeployment Module
    addHearthstone(236687) -- Explosive Hearthstone
    addHearthstone(246565) -- Cosmic Hearthstone
    addHearthstone(245970) -- P.O.S.T. Master's Express Hearthstone

    -- Draenei and Lightforged Draenei
    if select(3, UnitRace("player")) == 11 or select(3, UnitRace("player")) == 30 then
        addHearthstone(210455) -- Draenic Hologem
    end
end

-- Misc fancy teleports (Classic/Draenor utility)
-- addItem(128353, 572, { x = 0.2992, y = 0.3392, z = 0 }, true, 6790, 30, function() return C_QuestLog.IsQuestFlaggedCompleted(34586) end)                                                                                         -- Admiral's Compass (to your garrison shipyard)
-- addItem(140324, 680, { x = 0.34, y = 0.51, z = 0 }, true, 761, 10)                                                                                                                                                               -- Mobile Telemancy Beacon (Suramar)
-- addItem(139590, 36, { x = 0.71, y = 0.46, z = 0 }, true, 0, 10)                                                                                                                                                                  -- Scroll of Teleport: Ravenholdt (approx. Ravenholdt Manor)
-- addItem(21711, 80, { x = 0.564, y = 0.466, z = 0 }, true, 493, 10)                                                                                                                                                               -- Lunar Festival Invitation (Moonglade)

addDynamicItemWithMultipleIds(hearthstones, MRP.Util.GetBindingLocation, GetBindLocation, (select(3, UnitRace("player")) == 1 and GetExpansionLevel() >= 10) and 12.5 or 30, function() return MRP.AreaL[GetBindLocation()] end) -- Hearthstones

table.sort(MRP.Data.helpfulItems, function(a, b) return a < b end)
