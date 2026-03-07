-- MRP_Quest.lua
-- Quest pathfinding integration
-- local _, MRP = ...

local L = MRP.L

local Quest = {}
MRP.Quest = Quest

local questFrame = nil
local isShowing = false

-- Try multiple methods to get quest location
function Quest:GetQuestLocation(questID)
    -- Method 1: GetNextWaypoint (works for quests with specific waypoint objectives)
    local mapID, x, y = C_QuestLog.GetNextWaypoint(questID)
    if mapID and x and y then
        print("|cff888888[MRP Debug]|r Found via GetNextWaypoint: map " .. mapID)
        return mapID, x, y
    end

    -- Method 2: GetQuestUiMapID - this is what Blizzard's quest log uses!
    -- It's a C function that properly resolves the quest's destination map
    local questMapID = GetQuestUiMapID(questID)
    if questMapID and questMapID > 0 then
        print("|cff888888[MRP Debug]|r Quest map via GetQuestUiMapID: " .. questMapID)

        -- Try to get coords on this map via TaskQuest API
        if C_TaskQuest and C_TaskQuest.GetQuestLocation then
            x, y = C_TaskQuest.GetQuestLocation(questID, questMapID)
            if x and y and x > 0 and y > 0 then
                print("|cff888888[MRP Debug]|r Found coords via TaskQuest: " .. string.format("%.2f, %.2f", x, y))
                return questMapID, x, y
            end
        end

        -- Try QuestPOIGetSecondaryLocations for quest markers on this map
        if C_QuestLog.GetNextWaypointForMap then
            local wx, wy = C_QuestLog.GetNextWaypointForMap(questID, questMapID)
            if wx and wy then
                print("|cff888888[MRP Debug]|r Found coords via GetNextWaypointForMap: " .. string.format("%.2f, %.2f", wx, wy))
                return questMapID, wx, wy
            end
        end

        -- Try to get quest POI blob position
        if C_QuestLog.GetNextWaypointText then
            local waypointText = C_QuestLog.GetNextWaypointText(questID)
            if waypointText then
                print("|cff888888[MRP Debug]|r Waypoint text: " .. waypointText)
            end
        end

        -- No coords - find an existing waypoint node on this map from the pathfinder
        -- This is better than using 0.5, 0.5 which won't match any node
        if WPT and WPT.Pathfinding and WPT.Pathfinding.allNodes then
            for _, navNode in pairs(WPT.Pathfinding.allNodes) do
                local loc = navNode:getLocation()
                if loc and loc.mapId == questMapID then
                    print("|cff888888[MRP Debug]|r Found existing waypoint node on map: " .. string.format("%.2f, %.2f", loc.pos.x, loc.pos.y))
                    return questMapID, loc.pos.x, loc.pos.y
                end
            end
        end

        -- Last resort: use center as fallback
        print("|cff888888[MRP Debug]|r Using map center as fallback (may not work)")
        return questMapID, 0.5, 0.5
    end

    -- Method 3: Try TaskQuest on player's map (for world quests in current zone)
    if C_TaskQuest and C_TaskQuest.GetQuestLocation then
        local playerMapID = C_Map.GetBestMapForUnit("player")
        if playerMapID then
            x, y = C_TaskQuest.GetQuestLocation(questID, playerMapID)
            if x and y and x > 0 and y > 0 then
                print("|cff888888[MRP Debug]|r Found via TaskQuest on player map " .. playerMapID)
                return playerMapID, x, y
            end
        end
    end

    -- Method 4: Try getting quest zone ID as last resort
    if C_QuestLog.GetQuestZoneID then
        local zoneID = C_QuestLog.GetQuestZoneID(questID)
        if zoneID and zoneID > 0 then
            print("|cff888888[MRP Debug]|r Quest zone ID: " .. zoneID .. " (returning as map)")
            return zoneID, 0.5, 0.5
        end
    end

    print("|cff888888[MRP Debug]|r Could not find quest location")
    return nil, nil, nil
end

-- Get the current super-tracked quest info
function Quest:GetTrackedQuestInfo()
    local questID = C_SuperTrack.GetSuperTrackedQuestID()
    if not questID or questID == 0 then
        return nil
    end

    local title = C_QuestLog.GetTitleForQuestID(questID)
    local mapID, x, y = self:GetQuestLocation(questID)

    print("|cff888888[MRP Debug]|r Quest ID: " .. questID)
    print("|cff888888[MRP Debug]|r Title: " .. (title or "nil"))
    print("|cff888888[MRP Debug]|r MapID: " .. tostring(mapID) .. ", x: " .. tostring(x) .. ", y: " .. tostring(y))

    return {
        questID = questID,
        title = title,
        mapID = mapID,
        x = x,
        y = y
    }
end

-- Navigate to the current tracked quest
function Quest:NavigateToTrackedQuest()
    local info = self:GetTrackedQuestInfo()

    if not info then
        print("|cffffcc00[MRP]|r No super-tracked quest found. Track a quest first!")
        return nil
    end

    if not info.mapID or not info.x or not info.y then
        print("|cffffcc00[MRP]|r Quest '" .. (info.title or "Unknown") .. "' has no waypoint location.")
        return nil
    end

    ---@diagnostic disable-next-line: undefined-global
    if not NavigateTo then
        print("|cffffcc00[MRP]|r Pathfinding not available (WaypointTest addon required).")
        return nil
    end

    print("|cff00ff00[MRP]|r Navigating to: " .. (info.title or "Unknown"))
    print("|cff00ff00[MRP]|r UI Map " .. info.mapID .. " at " .. string.format("%.1f, %.1f", info.x * 100, info.y * 100))

    -- Convert UI Map coords to world/instance coords for the pathfinder
    local worldMapId, worldPos = C_Map.GetWorldPosFromMapPos(info.mapID, CreateVector2D(info.x, info.y))
    if not worldMapId or not worldPos then
        print("|cffff6600[MRP]|r Could not convert UI map " .. info.mapID .. " to world position.")
        return nil
    end

    print("|cff888888[MRP Debug]|r World map ID: " .. worldMapId .. " at world coords " .. string.format("%.1f, %.1f", worldPos.x, worldPos.y))

    ---@diagnostic disable-next-line: undefined-global
    local path = NavigateTo(info.mapID, info.x / 100, info.y / 100, 0)

    if path and #path > 0 then
        print("|cff00ff00[MRP]|r Found path with " .. #path .. " steps!")
        -- Show first step
        local firstStep = path[1]
        if firstStep.loca then
            print("|cff00ff00[MRP]|r Next: " .. firstStep.loca)
        end

        -- Set waypoint for first step
        local loc = firstStep.loc
        if loc then
            local uiLoc = loc
            if not loc.isUI then
                local localUIMapId, localMapPos = C_Map.GetMapPosFromWorldPos(loc.mapId, CreateVector2D(loc.pos.x, loc.pos.y))
                if localUIMapId and localMapPos then
                    uiLoc = { mapId = localUIMapId, pos = { x = localMapPos.x, y = localMapPos.y }, isUI = true }
                end
            end

            if uiLoc.mapId and C_Map.CanSetUserWaypointOnMap(uiLoc.mapId) then
                local coords = UiMapPoint.CreateFromCoordinates(uiLoc.mapId, uiLoc.pos.x, uiLoc.pos.y)
                if coords then
                    C_Map.SetUserWaypoint(coords)
                    C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                    print("|cff00ff00[MRP]|r Waypoint set!")
                end
            end
        end

        return path
    else
        print("|cffff6600[MRP]|r Could not find a path to this quest.")
        return nil
    end
end

-- Register slash command
SLASH_MRPQUEST1 = "/mrpquest"
SLASH_MRPQUEST2 = "/mrpq"
SlashCmdList["MRPQUEST"] = function(msg)
    MRP.Quest:NavigateToTrackedQuest()
end

print("|cff00ff00[MRP]|r Quest pathfinding loaded! Use /mrpquest or /mrpq")
