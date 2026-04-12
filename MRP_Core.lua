-- MRP_Core.lua
-- local _, MRP = ...

local L = MRP.L

local Core = {}
MRP.Core = Core

function Core:Reset()
    MRP_CharacterSettings.currentStep = 1
    MRP.UI:UpdateDisplay()
end

function Core:SetCurrentStep(stepIdx)
    if #MRP.Filter.filteredSteps == 0 then
        return
    end

    MRP_CharacterSettings.currentStep = math.max(1, math.min(stepIdx, #MRP.Filter.filteredSteps))

    MRP.UI:UpdateDisplay()
end

function Core:PreviousStep()
    if #MRP.Filter.filteredSteps == 0 then
        return
    end

    if MRP_CharacterSettings.currentStep <= 1 then
        return
    end

    MRP_CharacterSettings.currentStep = MRP_CharacterSettings.currentStep - 1
    MRP.UI:UpdateDisplay()
end

function Core:NextStep()
    if #MRP.Filter.filteredSteps == 0 then
        return
    end

    if MRP_CharacterSettings.currentStep >= #MRP.Filter.filteredSteps then
        return
    end

    repeat
        MRP_CharacterSettings.currentStep = MRP_CharacterSettings.currentStep + 1
        local step = MRP.Filter:GetCurrentStep()
    until not (MRP_CharacterSettings.autoSkip and step and self:ShouldSkipStep(step))

    MRP.UI:UpdateDisplay()
end

---@param difficultyId number
---@return boolean isDungeonDifficulty
function Core:IsDungeonDifficulty(difficultyId)
    return difficultyId == 1 or difficultyId == 2 or difficultyId == 8 or difficultyId == 19 or difficultyId == 23 or difficultyId == 24 or difficultyId == 150 or difficultyId == 205 or difficultyId == 216 or difficultyId == 236 or difficultyId == 232
end

---@param difficultyId number
---@return boolean isLegacyRaidDifficulty
function Core:IsLegacyRaidDifficulty(difficultyId)
    return difficultyId == 3 or difficultyId == 4 or difficultyId == 5 or difficultyId == 6 or difficultyId == 9
end

---@param difficultyId number
---@return boolean isRaidDifficulty
function Core:IsRaidDifficulty(difficultyId)
    return difficultyId == 7 or difficultyId == 14 or difficultyId == 15 or difficultyId == 16 or difficultyId == 17 or difficultyId == 18 or difficultyId == 33 or difficultyId == 151 or difficultyId == 220
end

---@param difficultyId number
---@return boolean isLFRDifficulty
function Core:IsLFRDifficulty(difficultyId)
    return difficultyId == 7 or difficultyId == 17 or difficultyId == 151
end

---@param mount Mount
---@return boolean isAllowed
function Core:IsMountFactionAllowed(mount)
    if not mount or not mount.source then
        return false
    end

    local factionMask = mount.source.factionMask
    if factionMask == nil or factionMask == 0 or factionMask == -1 then
        return true
    end

    local factionGroup = UnitFactionGroup("player")
    if factionMask == -2 then
        return factionGroup == "Alliance"
    end

    if factionMask == -3 then
        return factionGroup == "Horde"
    end

    return false
end

function Core:IsInPvp()
    local inInstance, instanceType = IsInInstance()
    return inInstance and (instanceType == "pvp" or instanceType == "arena")
end

function Core:IsEntranceOnMap(mapId, instanceId)
    for _, data in pairs(C_EncounterJournal.GetDungeonEntrancesForMap(mapId)) do
        if data.journalInstanceID == instanceId then
            return true
        end
    end
    return false
end

---@param mount Mount
---@param source StepSource
---@param difficultyId number?
---@return boolean defeated
function Core:IsEncounterDefeated(mount, source, difficultyId)
    if source.type == MRP.FilterSourceType.WorldBoss then
        if mount.source.journalEncounter then
            local expectedEncounterName = EJ_GetEncounterInfo(mount.source.journalEncounter.id)
            if expectedEncounterName then
                for i = 1, GetNumSavedWorldBosses() do
                    local encounterName = GetSavedWorldBossInfo(i)
                    if encounterName == expectedEncounterName then
                        return true
                    end
                end
            end
        end

        local worldBoss = MRP.Data.WORLD_BOSSES[source.name]
        if not worldBoss then
            print(string.format(L["|cffff0000[MRP]|r Unknown world boss: %s"], source.name))
            return false
        end

        if worldBoss.questID then
            return C_QuestLog.IsQuestFlaggedCompleted(worldBoss.questID)
        end

        return false
    end

    if source.type == MRP.FilterSourceType.OpenWorld or source.type == MRP.FilterSourceType.Quest or source.type == MRP.FilterSourceType.Treasure or source.type == MRP.FilterSourceType.Vendor then
        local entry = MRP.Data.OPEN_WORLD[source.name]
        if not entry then
            print(string.format(L["|cffff0000[MRP]|r Unknown world boss: %s"], source.name))
            return false
        end

        if entry.questID and entry.questID > 0 then
            return C_QuestLog.IsQuestFlaggedCompleted(entry.questID)
        end

        return false
    end

    if source.type == MRP.FilterSourceType.Raid or source.type == MRP.FilterSourceType.Dungeon then
        if mount.source.dungeonEncounter then
            return C_RaidLocks.IsEncounterComplete(mount.source.dungeonEncounter.mapId, mount.source.dungeonEncounter.id, difficultyId)
        end

        if mount.source.journalEncounter then
            for i = 1, GetNumSavedInstances() do
                local _, _, _, savedDifficultyId, locked, _, _, _, _, _, numEncounters, encounterProgress, _, instanceId = GetSavedInstanceInfo(i)
                if instanceId == mount.source.mapId and (not difficultyId or savedDifficultyId == difficultyId) then
                    if not locked then
                        return false
                    end

                    if encounterProgress >= numEncounters then
                        return true
                    end

                    local expectedEncounterName = EJ_GetEncounterInfo(mount.source.journalEncounter.id)
                    if expectedEncounterName then
                        for j = 1, numEncounters do
                            local encounterName, _, isKilled = GetSavedInstanceEncounterInfo(i, j)
                            if encounterName == expectedEncounterName then
                                return isKilled
                            end
                        end
                    end

                    return false
                end
            end
        end

        if mount.source.specialEncounter then
            for i = 1, GetNumSavedInstances() do
                local _, _, _, savedDifficultyId, locked, _, _, _, _, _, numEncounters, encounterProgress, _, instanceId = GetSavedInstanceInfo(i)
                if instanceId == mount.source.mapId and (not difficultyId or savedDifficultyId == difficultyId) then
                    if not locked then
                        return false
                    end

                    if encounterProgress >= numEncounters then
                        return true
                    end

                    return false
                end
            end
        end

        return false
    end

    return false
end

---@param mount Mount
---@param source StepSource
---@param difficultyId number
---@return boolean defeated
---@return boolean onLegacyRaidDifficulty
function Core:IsEncounterDefeatedWithLegacyRaidCheck(mount, source, difficultyId)
    local defeated = self:IsEncounterDefeated(mount, source, difficultyId)
    if defeated then
        return true, false
    end

    if not defeated and self:IsLegacyRaidDifficulty(difficultyId) then
        local legacyDefeated = self:IsEncounterDefeated(mount, source, nil)
        if legacyDefeated then
            return true, true
        end
    end

    return false, false
end

---@param step Step
---@return number[] difficultyIds
---@return { [number]: number }? mountsPerDifficulty
function Core:GetMostSuitableDifficultyIds(step)
    if not step then
        return {}, nil
    end

    ---@type { [number]: number }
    local mountsPerDifficultyId = {}

    for _, mount in ipairs(step.mounts) do
        local _, _, isCollected = MRP.Util.GetMountInfoSafe(mount)
        if not isCollected and self:IsMountFactionAllowed(mount) then
            for _, difficultyId in ipairs(MRP.Core:GetRelevantDifficultyIds(mount)) do
                local usedDifficultyId = self:IsLegacyRaidDifficulty(difficultyId) and -1 or difficultyId
                if not self:IsEncounterDefeated(mount, step.source, usedDifficultyId >= 0 and usedDifficultyId or nil) then
                    if not mountsPerDifficultyId[difficultyId] then
                        mountsPerDifficultyId[difficultyId] = 0
                    end
                    mountsPerDifficultyId[difficultyId] = mountsPerDifficultyId[difficultyId] + 1
                end
            end
        end
    end

    local bestDifficultyIds = {}
    local maxMounts = 0

    for difficultyId, mountCount in pairs(mountsPerDifficultyId) do
        if mountCount > maxMounts then
            maxMounts = mountCount
            bestDifficultyIds = { difficultyId }
        elseif mountCount == maxMounts then
            table.insert(bestDifficultyIds, difficultyId)
        end
    end

    return bestDifficultyIds, mountsPerDifficultyId
end

--- Evaluate an open world condition string.
--- Returns true if the condition is met (or absent), false if not.
---@param condition string?
---@return boolean
function Core:EvaluateCondition(condition)
    if not condition then return true end

    if condition == "horde_only" then
        return UnitFactionGroup("player") == "Horde"
    end

    if condition == "alliance_only" then
        return UnitFactionGroup("player") == "Alliance"
    end

    if condition == "warfront_arathi" or condition == "warfront_darkshore" then
        -- Warfront rares are only available when your faction controls the zone.
        -- Check for active world quests on the warfront map as a proxy.
        local mapID = (condition == "warfront_arathi") and 14 or 62
        if C_QuestLog and C_QuestLog.GetQuestsOnMap then
            local quests = C_QuestLog.GetQuestsOnMap(mapID)
            return quests ~= nil and #quests > 0
        end
        return false
    end

    -- Reputation conditions: rep_<factionId>_<standing>
    -- standing: 4=Friendly, 5=Honored, 6=Revered, 7=Exalted, 8=Renown
    local factionId, requiredStanding = condition:match("^rep_(%d+)_(%d+)$")
    if factionId then
        factionId = tonumber(factionId)
        requiredStanding = tonumber(requiredStanding)
        local factionData = C_Reputation and C_Reputation.GetFactionDataByID and C_Reputation.GetFactionDataByID(factionId)
        if factionData then
            return factionData.currentStanding >= requiredStanding
        end
        return false
    end

    return true
end

--- Check if a step's condition is currently met.
---@param step Step
---@return boolean
function Core:IsStepConditionMet(step)
    local condition = self:GetStepCondition(step)
    if not condition then return true end
    return self:EvaluateCondition(condition)
end

--- Return the condition string for a step, or nil.
---@param step Step
---@return string?
function Core:GetStepCondition(step)
    local t = step.source.type
    if t ~= MRP.FilterSourceType.OpenWorld and t ~= MRP.FilterSourceType.Quest and t ~= MRP.FilterSourceType.Treasure and t ~= MRP.FilterSourceType.Vendor then return nil end
    local entry = MRP.Data.OPEN_WORLD[step.source.name]
    if not entry then return nil end
    return entry.condition
end

--- Return a human-readable message for an unmet condition.
---@param condition string
---@return string
function Core:GetConditionMessage(condition)
    -- Reputation conditions: rep_<factionId>_<standing>
    local factionId, requiredStanding = condition:match("^rep_(%d+)_(%d+)$")
    if factionId then
        factionId = tonumber(factionId)
        local factionData = C_Reputation and C_Reputation.GetFactionDataByID and C_Reputation.GetFactionDataByID(factionId)
        local factionName = factionData and factionData.name or tostring(factionId)
        local standingNames = { [4] = FACTION_STANDING_LABEL4, [5] = FACTION_STANDING_LABEL5, [6] = FACTION_STANDING_LABEL6, [7] = FACTION_STANDING_LABEL7, [8] = FACTION_STANDING_LABEL8 }
        local standingName = standingNames[tonumber(requiredStanding)] or requiredStanding
        return format(L["Requires %s reputation with %s."], standingName, factionName)
    end

    return L["condition_" .. condition]
end

---@param step Step
---@return boolean shouldSkip
function Core:ShouldSkipStep(step)
    if not step then
        return false
    end

    -- Skip steps whose condition is not met (e.g. warfront not active)
    if not self:IsStepConditionMet(step) then
        return true
    end

    local bestDifficulties = MRP.Core:GetMostSuitableDifficultyIds(step)
    if #bestDifficulties > 0 then
        return false
    end

    return true
end

---@param force boolean
function Core:CheckCurrentStepComplete(force)
    if #MRP.Filter.filteredSteps == 0 then
        return
    end

    local step = MRP.Filter:GetCurrentStep()
    if step and (force or (MRP_CharacterSettings.autoAdvance and self:ShouldSkipStep(step))) then
        self:NextStep()
    end
end

---@param mount Mount
function Core:GetRelevantDifficultyIds(mount)
    if mount.source.relevantDifficultyIds then
        return mount.source.relevantDifficultyIds
    end

    local relevantDifficultyIds = {}
    for _, difficultyId in ipairs(mount.source.allowedDifficultyIds) do
        if not MRP_Settings.ignoreLFRDifficulty or not self:IsLFRDifficulty(difficultyId) then
            table.insert(relevantDifficultyIds, difficultyId)
        end
    end
    mount.source.relevantDifficultyIds = relevantDifficultyIds

    return relevantDifficultyIds
end

---@class TrashItItem
---@field bag number
---@field slot number
---@field item ItemMixin

---@return TrashItItem[] itemsToSell
function Core:GatherTrashItData()
    local expansionLevel = GetExpansionLevel()
    local itemsToSell = {}

    for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemId = C_Container.GetContainerItemID(bag, slot)
            if itemId then
                local item = Item:CreateFromBagAndSlot(bag, slot)
                if item then
                    local inventoryType = item:GetInventoryType()
                    if inventoryType and inventoryType >= Enum.InventoryType.IndexHeadType and inventoryType <= Enum.InventoryType.Index2HweaponType then
                        local itemQuality = item:GetItemQuality()
                        if itemQuality and itemQuality >= Enum.ItemQuality.Rare and itemQuality <= Enum.ItemQuality.Epic then
                            local expansionID = select(15, C_Item.GetItemInfo(itemId))
                            if expansionID and expansionID < expansionLevel then
                                table.insert(itemsToSell, { bag = bag, slot = slot, item = item })
                            end
                        end
                    end
                end
            end
        end
    end

    return itemsToSell
end

function Core:CanPossiblyTrashIt()
    if not MerchantFrame or not MerchantFrame:IsShown() then
        return false
    end

    if GetMerchantNumItems() == 0 then
        return false
    end

    return true
end

function Core:TrashItFromData(itemsToSell)
    if not self:CanPossiblyTrashIt() then
        print(L["|cffffd200[MRP]|r Trashing items is not possible at the moment."])
        C_Timer.After(0.5, function() MRP.UI:UpdateDisplay() end)
        return
    end

    if #itemsToSell == 0 then
        print(L["|cffffd200[MRP]|r No items to trash"])
        C_Timer.After(0.5, function() MRP.UI:UpdateDisplay() end)
        return
    end

    local function SellNext(index)
        if index > #itemsToSell then
            print(L["|cffffd200[MRP]|r All items trashed."])
            C_Timer.After(0.5, function() MRP.UI:UpdateDisplay() end)
            return
        end

        if not MerchantFrame or not MerchantFrame:IsShown() then
            print(L["|cffffd200[MRP]|r Merchant frame is not open. Please open it to trash items."])
            C_Timer.After(0.5, function() MRP.UI:UpdateDisplay() end)
            return
        end

        local data = itemsToSell[index]
        if data then
            C_Container.UseContainerItem(data.bag, data.slot)
            print(format(L["|cffffd200[MRP]|r Trashed item: %s"], data.item:GetItemName()))
            C_Timer.After(0.1, function() SellNext(index + 1) end)
        end
    end

    SellNext(1)
end

function Core:TrashIt()
    self:TrashItFromData(self:GatherTrashItData())
end

---@param event string
function Core:CheckRaidInfo(event)
    if not (event == "ENCOUNTER_END") then
        return
    end

    RequestRaidInfo()
end

---@param event string
function Core:CheckForPathfindingWarnings(event)
    if not (event == "BAG_UPDATE_DELAYED" or event == "HEARTHSTONE_BOUND") then
        return
    end

    MRP.UI:ShowPathfindingWarnings()
end

local setupAddonNameColors = {
    ["__MRPData__"] = "|cff6fd3ffMount Route Planner Data|r",
    ["__FarstriderLibData__"] = "|cff8bffb5FarstriderLib Data|r",
    ["__FarstriderLib__"] = "|cffffc56fFarstriderLib|r",
}

---@param text string?
---@return string?
function Core:HighlightSetupAddonNames(text)
    if not text then
        return nil
    end

    for placeholder, coloredName in pairs(setupAddonNameColors) do
        text = text:gsub(placeholder, coloredName)
    end

    return text
end

local addon_issue_checkers = {
    [MRP.RequiredAddon.MRPData] = {
        check = function() return not MRP.Util.HasData() end,
        message = Core:HighlightSetupAddonNames(L["Addon '__MRPData__' or another data source is not installed. Route data is required for MRP to function."]),
    },
    [MRP.RequiredAddon.FarstriderLib] = {
        check = function() return not MRP.Util.HasFarstrider() end,
        message = Core:HighlightSetupAddonNames(L["Addon '__FarstriderLib__' or another farstrider library is not installed. Pathfinding features will be unavailable."]),
    },
    [MRP.RequiredAddon.FarstriderLibData] = {
        check = function() return not MRP.Util.HasFarstriderData() end,
        message = Core:HighlightSetupAddonNames(L["Addon '__FarstriderLibData__' or another farstrider data source is not installed. Pathfinding features will be unavailable."]),
    },
}

---@return { key: string, message: string }[]
function Core:GetSetupIssues()
    local issues = {}

    for key, checker in pairs(addon_issue_checkers) do
        if checker.check() then
            table.insert(issues, { key = key, message = checker.message })
        end
    end

    return issues
end

---@return string
function Core:GetNoStepMessage()
    if addon_issue_checkers[MRP.RequiredAddon.MRPData].check() then
        return addon_issue_checkers[MRP.RequiredAddon.MRPData].message
    end

    return L["No step found.\nAdjust your filter."]
end

---@return string?
function Core:GetNoOptimizedPathMessage()
    if addon_issue_checkers[MRP.RequiredAddon.FarstriderLib].check() then
        return addon_issue_checkers[MRP.RequiredAddon.FarstriderLib].message
    end

    if addon_issue_checkers[MRP.RequiredAddon.FarstriderLibData].check() then
        return addon_issue_checkers[MRP.RequiredAddon.FarstriderLibData].message
    end

    return L["You can't reach this destination.\nFurther advancement in the Campaign might be required."]
end

local setupWarningsShown = false

function Core:PrintSetupWarnings()
    if setupWarningsShown then
        return
    end

    setupWarningsShown = true

    for _, issue in ipairs(self:GetSetupIssues()) do
        print("|cffffcc00[MRP]|r " .. issue.message)
    end
end

---@param event string
function Core:CheckForDisplayUpdate(event)
    if not (event == "MERCHANT_CLOSED" or event == "NEW_MOUNT_ADDED" or event == "UPDATE_INSTANCE_INFO" or event == "PLAYER_DIFFICULTY_CHANGED" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
        return
    end

    MRP.UI:UpdateDisplay()
end

---@param event string
function Core:CheckForTrashItInfo(event)
    if not (event == "MERCHANT_SHOW") then
        return
    end

    MRP.UI:ShowActionTrashIt()
end

---@param event string
function Core:CheckDifficultyWarning(event)
    if not (event == "PLAYER_ENTERING_WORLD") then
        return
    end

    if not MRP_Settings.showDifficultyWarning or not IsInInstance() then
        MRP.UI:HideDifficultyWarning()
        return
    end

    local step = MRP.Filter:GetCurrentStep()
    if not step or step.source.type == MRP.FilterSourceType.WorldBoss or step.source.type == MRP.FilterSourceType.OpenWorld or step.source.type == MRP.FilterSourceType.Quest or step.source.type == MRP.FilterSourceType.Treasure or step.source.type == MRP.FilterSourceType.Vendor then
        MRP.UI:HideDifficultyWarning()
        return
    end

    local difficultyId, _, _, _, _, instanceId = select(3, GetInstanceInfo())
    local anyMountWithinMap = false
    for _, mount in ipairs(step.mounts) do
        if mount.source.mapId == instanceId then
            anyMountWithinMap = true
            break
        end
    end

    if not anyMountWithinMap or not self:IsLegacyRaidDifficulty(difficultyId) then
        MRP.UI:HideDifficultyWarning()
        return
    end

    local mostSuitableDifficultyIds = self:GetMostSuitableDifficultyIds(step)
    if #mostSuitableDifficultyIds > 0 and not tContains(mostSuitableDifficultyIds, difficultyId) then
        MRP.UI:ShowDifficultyWarning(mostSuitableDifficultyIds)
    else
        MRP.UI:HideDifficultyWarning()
    end
end

---@type { [number]: { expansion: FilterExpansion, spellId: number }[] }
local timewalkingSpellIds = {
    { expansion = MRP.FilterExpansion.Classic,            spellId = 452307 },
    { expansion = MRP.FilterExpansion.TheBurningCrusade,  spellId = 335148 },
    { expansion = MRP.FilterExpansion.WrathOfTheLichKing, spellId = 335149 },
    { expansion = MRP.FilterExpansion.Cataclysm,          spellId = 335150 },
    { expansion = MRP.FilterExpansion.MistsOfPandaria,    spellId = 335151 },
    { expansion = MRP.FilterExpansion.WarlordsOfDraenor,  spellId = 335152 },
    { expansion = MRP.FilterExpansion.Legion,             spellId = 359082 },
    { expansion = MRP.FilterExpansion.BattleForAzeroth,   spellId = 1223878 },
}

---@return { [number]: boolean} activeTimewalkingMap
function Core:GetActiveTimewalkingMap()
    local activeTimewalkingMap = {}

    for _, data in ipairs(timewalkingSpellIds) do
        if C_UnitAuras.GetPlayerAuraBySpellID(data.spellId) then
            activeTimewalkingMap[data.expansion] = true
        end
    end

    return activeTimewalkingMap
end

function Core:FilterTimewalkingSteps()
    local activeTimewalkingMap = self:GetActiveTimewalkingMap()

    for _, step in ipairs(MRP.Data.STEPS) do
        if not activeTimewalkingMap[step.expansion] then
            for _, mount in ipairs(step.mounts) do
                local newAllowedDifficultyIds = {}
                for _, difficultyId in ipairs(mount.source.allowedDifficultyIds) do
                    if difficultyId ~= 24 and difficultyId ~= 33 then
                        table.insert(newAllowedDifficultyIds, difficultyId)
                    end
                end
                mount.source.allowedDifficultyIds = newAllowedDifficultyIds
            end
        end
    end

    for _, dungeon in pairs(MRP.Data.DUNGEONS) do
        if not activeTimewalkingMap[dungeon.expansionLevel] then
            local newAllowedDifficultyIds = {}
            for _, difficultyId in ipairs(dungeon.availableDifficultyIds) do
                if difficultyId ~= 24 and difficultyId ~= 33 then
                    table.insert(newAllowedDifficultyIds, difficultyId)
                end
            end
            dungeon.availableDifficultyIds = newAllowedDifficultyIds
        end
    end

    for _, raid in pairs(MRP.Data.RAIDS) do
        if not activeTimewalkingMap[raid.expansionLevel] then
            local newAllowedDifficultyIds = {}
            for _, difficultyId in ipairs(raid.availableDifficultyIds) do
                if difficultyId ~= 24 and difficultyId ~= 33 then
                    table.insert(newAllowedDifficultyIds, difficultyId)
                end
            end
            raid.availableDifficultyIds = newAllowedDifficultyIds
        end
    end
end

function Core:InitializeSettings()
    if not MRP_Settings then
        MRP_Settings = {}
    end

    if MRP_Settings.useTomTom == nil then
        MRP_Settings.useTomTom = true
    end

    if MRP_Settings.showDifficultyWarning == nil then
        MRP_Settings.showDifficultyWarning = true
    end

    if MRP_Settings.ignoreLFRDifficulty == nil then
        MRP_Settings.ignoreLFRDifficulty = false
    end

    if MRP_Settings.showRareAlert == nil then
        MRP_Settings.showRareAlert = true
    end

    if MRP_Settings.alertPopupPoint == nil then
        MRP_Settings.alertPopupPoint = "TOP"
    end

    if MRP_Settings.alertPopupRelativePoint == nil then
        MRP_Settings.alertPopupRelativePoint = "TOP"
    end

    if MRP_Settings.alertPopupOffsetX == nil then
        MRP_Settings.alertPopupOffsetX = 0
    end

    if MRP_Settings.alertPopupOffsetY == nil then
        MRP_Settings.alertPopupOffsetY = -80
    end

    if MRP_Settings.showRouteOnMap == nil then
        MRP_Settings.showRouteOnMap = true
    end

    if MRP_Settings.showRouteConnectionsOnMap == nil then
        MRP_Settings.showRouteConnectionsOnMap = false
    end

    if MRP_Settings.showPathfindingLinesOnMap == nil then
        MRP_Settings.showPathfindingLinesOnMap = true
    end

    if MRP_Settings.showOpenWorldOverlayOnMap == nil then
        MRP_Settings.showOpenWorldOverlayOnMap = true
    end

    if MRP_Settings.maxStepsAhead == nil then
        MRP_Settings.maxStepsAhead = 5
    end

    if MRP_Settings.unlimitedStepsAhead == nil then
        MRP_Settings.unlimitedStepsAhead = false
    end

    if MRP_Settings.maxStepsBehind == nil then
        MRP_Settings.maxStepsBehind = 1
    end

    if MRP_Settings.unlimitedStepsBehind == nil then
        MRP_Settings.unlimitedStepsBehind = false
    end

    if not MRP_CharacterSettings then
        MRP_CharacterSettings = {}
    end

    if MRP_CharacterSettings.autoSkip == nil then
        MRP_CharacterSettings.autoSkip = true
    end

    if MRP_CharacterSettings.autoAdvance == nil then
        MRP_CharacterSettings.autoAdvance = true
    end

    if MRP_CharacterSettings.currentStep == nil then
        MRP_CharacterSettings.currentStep = 1
    end

    if MRP_CharacterSettings.filter == nil then
        MRP_CharacterSettings.filter = {
            expansions = {},
            sourceTypes = {},
            collectedStates = {},
            factions = {}
        }
    end

    for _, expansionKey in ipairs(MRP.FilterExpansionOrder) do
        local expansion = MRP.FilterExpansion[expansionKey]
        if MRP_CharacterSettings.filter.expansions[expansion] == nil then
            MRP_CharacterSettings.filter.expansions[expansion] = true
        end
    end

    for _, sourceTypeKey in ipairs(MRP.FilterSourceTypeOrder) do
        local sourceType = MRP.FilterSourceType[sourceTypeKey]
        if MRP_CharacterSettings.filter.sourceTypes[sourceType] == nil then
            MRP_CharacterSettings.filter.sourceTypes[sourceType] = true
        end
    end

    for _, collectedStateKey in ipairs(MRP.FilterCollectedStateOrder) do
        local collectedState = MRP.FilterCollectedState[collectedStateKey]
        if MRP_CharacterSettings.filter.collectedStates[collectedState] == nil then
            ---@diagnostic disable-next-line: need-check-nil
            MRP_CharacterSettings.filter.collectedStates[collectedState] = not collectedState
        end
    end

    -- Faction filter: auto-detect on first load (old saves won't have this)
    if MRP_CharacterSettings.filter.factions == nil then
        local playerFaction = UnitFactionGroup("player")
        MRP_CharacterSettings.filter.factions = {
            [MRP.FilterFaction.Neutral] = true,
            [MRP.FilterFaction.Alliance] = (playerFaction == "Alliance"),
            [MRP.FilterFaction.Horde] = (playerFaction == "Horde"),
        }
    end
    -- Backfill Neutral for saves that have factions but predate the Neutral option
    if MRP_CharacterSettings.filter.factions[MRP.FilterFaction.Neutral] == nil then
        MRP_CharacterSettings.filter.factions[MRP.FilterFaction.Neutral] = true
    end

    if MRP_CharacterSettings.ignoredHelpfulItems == nil then
        MRP_CharacterSettings.ignoredHelpfulItems = {}
    end
end

function Core:Rebuild()
    MRP.Farstrider.Rebuild()
    MRP.Filter:Apply(true)
    MRP.Route:Calculate()
    if MRP.Alert and MRP_Settings.showRareAlert then
        MRP.Alert:Enable()
    end
    if MRP.UI then
        MRP.UI:UpdateDisplay()
    end
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("BAG_UPDATE_DELAYED")
watcher:RegisterEvent("ENCOUNTER_END")
watcher:RegisterEvent("HEARTHSTONE_BOUND")
watcher:RegisterEvent("MERCHANT_CLOSED")
watcher:RegisterEvent("MERCHANT_SHOW")
watcher:RegisterEvent("NEW_MOUNT_ADDED")
watcher:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("PLAYER_LEAVE_COMBAT")
watcher:RegisterEvent("UPDATE_INSTANCE_INFO")
watcher:RegisterEvent("ZONE_CHANGED")
watcher:RegisterEvent("ZONE_CHANGED_INDOORS")
watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
watcher:SetScript("OnEvent", function(_, event)
    Core:CheckForPathfindingWarnings(event)
    Core:CheckRaidInfo(event)
    Core:CheckForDisplayUpdate(event)
    Core:CheckForTrashItInfo(event) -- MRP_REMOVE_LINE
    Core:CheckDifficultyWarning(event)
    Core:CheckCurrentStepComplete(false)

    if (event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA") and MRP.Alert then
        MRP.Alert:OnZoneChanged()
    end
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    Core:InitializeSettings()
    Core:FilterTimewalkingSteps()
    MRP.Filter:Apply(true)

    if not MRP.Route:IsRouteValid() then
        MRP.Route:Calculate()
    end

    Core:CheckCurrentStepComplete(false)
    MRP.Options:InitializeIgnoredHelpfulItems()
    Core:PrintSetupWarnings()

    if MRP.Alert and MRP_Settings.showRareAlert then
        MRP.Alert:Enable()
    end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if C_Housing then
            C_Housing.GetPlayerOwnedHouses()
        end
    end

    if MRP.Changelog then
        MRP.Changelog:CheckShowOnLogin()
    end

    if DevTool then                                                     -- MRP_REMOVE_LINE
        DevTool:AddData(MRP, "MRP")                                     -- MRP_REMOVE_LINE
        DevTool:AddData(MRP_Settings, "MRP_Settings")                   -- MRP_REMOVE_LINE
        DevTool:AddData(MRP_CharacterSettings, "MRP_CharacterSettings") -- MRP_REMOVE_LINE
    end                                                                 -- MRP_REMOVE_LINE
end)

function Core:HandleSlashCommand(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word:lower())
    end

    local cmd = args[1]
    local arg1 = args[2]

    if not cmd or cmd == "" then
        MRP.UI:Toogle()
    elseif cmd == "reset" then
        Core:Reset()
    elseif cmd == "settings" then
        if InCombatLockdown() then
            print(ERR_NOT_IN_COMBAT)
            return
        end
        MRP.Options:Show()
    elseif cmd == "tomtom" and (arg1 == "on" or arg1 == "off") then
        MRP_Settings.useTomTom = (arg1 == "on")
        print(string.format(L["|cff00ff00[MRP]|r TomTom usage is now: %s"], (MRP_Settings.useTomTom and L["|cff00ff00ENABLED|r"] or L["|cffff0000DISABLED|r"])))
    elseif cmd == "changelog" then
        if MRP.Changelog then
            MRP.Changelog:Show()
        end
    elseif cmd == "trashit" then -- MRP_REMOVE_LINE
        Core:TrashIt()           -- MRP_REMOVE_LINE
    elseif cmd == "route" then
        MRP.Route:Calculate()
        print(L["|cff00ff00[MRP]|r Route recalculated."])
    elseif cmd == "updatedisplaydelayed" then
        C_Timer.After(tonumber(arg1) or 0.25, function() MRP.UI:UpdateDisplay() end)
    else
        print(L["|cffffd200Usage:|r"])
        print(L[" - /mrp → Toggle Mount Route Planner UI"])
        print(L[" - /mrp reset → Clears current progress and steps"])
        print(L[" - /mrp settings → Open addon settings"])
        print(L[" - /mrp tomtom on|off → Enable or disable TomTom integration"])
        print(L[" - /mrp changelog → Open the latest changelog popup"])
        print(L[" - /mrp route → Recalculate the optimized route"])
        print(L[" - /mrp updatedisplaydelayed <number> → Force update of the display after a delay (default: 0.25 seconds)"])
    end
end

SLASH_MOUNTROUTEPLANNER1 = "/mrp"
SlashCmdList["MOUNTROUTEPLANNER"] = function(msg)
    Core:HandleSlashCommand(msg)
end
