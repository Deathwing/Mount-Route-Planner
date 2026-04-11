-- MRP_Route.lua
-- local _, MRP = ...

local Route = {}
MRP.Route = Route

local continentCache = {}

--- Get the continent mapID for a given uiMapID by walking up the map hierarchy.
--- Results are cached per session since the map hierarchy never changes.
---@param mapId number
---@return number? continentMapId
function Route:GetContinentForMap(mapId)
    if continentCache[mapId] ~= nil then
        return continentCache[mapId] or nil
    end

    local info = C_Map.GetMapInfo(mapId)
    while info do
        if info.mapType == Enum.UIMapType.Continent then
            continentCache[mapId] = info.mapID
            return info.mapID
        end
        if not info.parentMapID or info.parentMapID == 0 then break end
        info = C_Map.GetMapInfo(info.parentMapID)
    end

    continentCache[mapId] = false
    return nil
end

--- Get the data entry (dungeon/raid/worldboss/openworld) for a step
---@param step Step
---@return table? entry
function Route:GetStepEntry(step)
    if step.source.type == MRP.FilterSourceType.Dungeon then
        return MRP.Data.dungeons[step.source.name]
    elseif step.source.type == MRP.FilterSourceType.Raid then
        return MRP.Data.raids[step.source.name]
    elseif step.source.type == MRP.FilterSourceType.WorldBoss then
        return MRP.Data.worldBosses[step.source.name]
    elseif step.source.type == MRP.FilterSourceType.OpenWorld
        or step.source.type == MRP.FilterSourceType.Quest
        or step.source.type == MRP.FilterSourceType.Treasure
        or step.source.type == MRP.FilterSourceType.Vendor then
        return MRP.Data.openWorld[step.source.name]
    end
    return nil
end

--- Check if the saved baseline route order covers all current steps.
--- Returns false if new steps were added (e.g. addon update) requiring recalculation.
---@return boolean isValid
function Route:IsRouteValid()
    if not MRP_CharacterSettings.routeOrder or #MRP_CharacterSettings.routeOrder == 0 then
        return false
    end

    local routeSet = {}
    for _, id in ipairs(MRP_CharacterSettings.routeOrder) do
        routeSet[id] = true
    end

    for _, step in ipairs(MRP.Steps) do
        if not routeSet[step.id] then
            return false
        end
    end

    return true
end

--- Reorder filteredSteps based on the saved baseline route order.
--- Called automatically by Filter:UpdateFilteredSteps() whenever filters change.
function Route:ApplyToFilteredSteps()
    if not MRP_CharacterSettings.routeOrder or #MRP_CharacterSettings.routeOrder == 0 then
        return
    end

    local steps = MRP.Filter.filteredSteps
    if #steps == 0 then return end

    local orderMap = {}
    for i, id in ipairs(MRP_CharacterSettings.routeOrder) do
        orderMap[id] = i
    end

    table.sort(steps, function(a, b)
        local posA = orderMap[a.id] or math.huge
        local posB = orderMap[b.id] or math.huge
        return posA < posB
    end)
end

--- Calculate optimized baseline route using nearest-neighbor heuristic grouped by continent.
--- Operates on ALL steps (MRP.Steps) to create an ordering independent of filters.
function Route:Calculate()
    local steps = MRP.Steps
    if #steps == 0 then
        MRP_CharacterSettings.routeOrder = nil
        return
    end

    -- Gather world positions and continent info for each step
    local continentGroups = {}
    local noLocSteps = {}

    for _, step in ipairs(steps) do
        local entry = self:GetStepEntry(step)
        if entry and entry.mapID then
            local continent = self:GetContinentForMap(entry.mapID)
            if continent then
                local _, worldPos = C_Map.GetWorldPosFromMapPos(entry.mapID, CreateVector2D(entry.x / 100, entry.y / 100))
                if worldPos then
                    if not continentGroups[continent] then
                        continentGroups[continent] = {}
                    end
                    continentGroups[continent][#continentGroups[continent] + 1] = {
                        step = step,
                        worldX = worldPos.x,
                        worldY = worldPos.y,
                    }
                else
                    noLocSteps[#noLocSteps + 1] = step
                end
            else
                noLocSteps[#noLocSteps + 1] = step
            end
        else
            noLocSteps[#noLocSteps + 1] = step
        end
    end

    -- Determine player's current continent and world position
    local playerLoc = MRP.Util.GetPlayerLocation()
    local playerContinent, playerWorldX, playerWorldY
    if playerLoc and playerLoc.mapId then
        playerContinent = self:GetContinentForMap(playerLoc.mapId)
        if playerContinent then
            local _, wPos = C_Map.GetWorldPosFromMapPos(playerLoc.mapId, CreateVector2D(playerLoc.pos.x, playerLoc.pos.y))
            if wPos then
                playerWorldX, playerWorldY = wPos.x, wPos.y
            end
        end
    end

    -- Order continents: player's current continent first, then by group size descending
    local continentList = {}
    for continent, group in pairs(continentGroups) do
        continentList[#continentList + 1] = { id = continent, count = #group }
    end
    table.sort(continentList, function(a, b)
        if a.id == b.id then return false end
        if a.id == playerContinent then return true end
        if b.id == playerContinent then return false end
        return a.count > b.count
    end)

    -- Build optimized route using nearest-neighbor within each continent
    local orderedSteps = {}
    local curX, curY = playerWorldX or 0, playerWorldY or 0

    for _, continentEntry in ipairs(continentList) do
        local group = continentGroups[continentEntry.id]
        local visited = {}

        -- When switching to a new continent, start from the group's centroid
        if continentEntry.id ~= playerContinent or not playerWorldX then
            local sumX, sumY = 0, 0
            for _, info in ipairs(group) do
                sumX = sumX + info.worldX
                sumY = sumY + info.worldY
            end
            curX = sumX / #group
            curY = sumY / #group
        end

        for _ = 1, #group do
            local bestIdx = nil
            local bestDist = math.huge

            for k, info in ipairs(group) do
                if not visited[k] then
                    local dx = curX - info.worldX
                    local dy = curY - info.worldY
                    local dist = dx * dx + dy * dy
                    if dist < bestDist then
                        bestDist = dist
                        bestIdx = k
                    end
                end
            end

            if bestIdx then
                visited[bestIdx] = true
                local info = group[bestIdx]
                orderedSteps[#orderedSteps + 1] = info.step
                curX, curY = info.worldX, info.worldY
            end
        end
    end

    -- Append steps without locations at the end
    for _, step in ipairs(noLocSteps) do
        orderedSteps[#orderedSteps + 1] = step
    end

    -- Save the baseline route order as array of step IDs
    local routeIds = {}
    for _, step in ipairs(orderedSteps) do
        routeIds[#routeIds + 1] = step.id
    end
    MRP_CharacterSettings.routeOrder = routeIds

    -- Apply to current filtered steps and reset position
    self:ApplyToFilteredSteps()
    MRP_CharacterSettings.currentStep = 1

    if MRP.UI then
        MRP.UI:UpdateDisplay()
    end
end
