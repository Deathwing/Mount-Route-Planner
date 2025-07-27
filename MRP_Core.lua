-- MRP_Core.lua
-- local _, MRP = ...

local L = MRP.L

local Core = {}
MRP.Core = Core

function Core:Reset()
    MRP_CharacterSettings.currentStep = 1
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
    until not (MRP_Settings.autoSkip and step and self:ShouldSkipStep(step))

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

function IsCurrentEncouterDefeated()
    local step = MRP.Filter:GetCurrentStep()
    if not step then
        return {}
    end

    local results = {}
    for _, mount in ipairs(step.mounts) do
        results[mount.id] = Core:IsEncounterDefeated(mount, step.source)
    end
    return results
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

        local worldBoss = MRP.Data.worldBosses[source.name]
        if not worldBoss then
            print(string.format(L["|cffff0000[MRP]|r Unknown world boss: %s"], source.name))
            return false
        end

        if worldBoss.questID then
            return C_QuestLog.IsQuestFlaggedCompleted(worldBoss.questID)
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
        if not select(11, C_MountJournal.GetMountInfoByID(mount.id)) then
            for _, difficultyId in ipairs(mount.source.allowedDifficultyIds) do
                if not self:IsEncounterDefeated(mount, step.source, difficultyId) then
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

---@param step Step
---@return number[] difficultyIds
---@return { [number]: number }? mountsPerDifficulty
function Core:GetMostSuitableDifficultyIdsForLegacyRaids(step)
    if not step then
        return {}, nil
    end

    ---@type { [number]: number }
    local mountsPerDifficultyId = {}

    for _, mount in ipairs(step.mounts) do
        if not select(11, C_MountJournal.GetMountInfoByID(mount.id)) and not self:IsEncounterDefeated(mount, step.source, nil) then
            for _, difficultyId in ipairs(mount.source.allowedDifficultyIds) do
                if not mountsPerDifficultyId[difficultyId] then
                    mountsPerDifficultyId[difficultyId] = 0
                end
                mountsPerDifficultyId[difficultyId] = mountsPerDifficultyId[difficultyId] + 1
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

---@param step Step
---@return number[] difficultyIds
---@return { [number]: number }? mountsPerDifficulty
function Core:GetMostSuitableDifficultyIdsWithLegacyRaidCheck(step)
    if not step then
        return {}, nil
    end

    local instance = step.source.type == MRP.FilterSourceType.Dungeon and MRP.Data.dungeons[step.source.name] or step.source.type == MRP.FilterSourceType.Raid and MRP.Data.raids[step.source.name] or nil
    if instance then
        for _, difficultyId in ipairs(instance.availableDifficultyIds) do
            if self:IsLegacyRaidDifficulty(difficultyId) then
                return self:GetMostSuitableDifficultyIdsForLegacyRaids(step)
            end
        end
    end

    return self:GetMostSuitableDifficultyIds(step)
end

---@param step Step
---@return boolean shouldSkip
function Core:ShouldSkipStep(step)
    if not step then
        return false
    end

    local bestDifficulties = MRP.Core:GetMostSuitableDifficultyIdsWithLegacyRaidCheck(step)
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
    if step and (force or (MRP_Settings.autoAdvance and self:ShouldSkipStep(step))) then
        self:NextStep()
    end
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

---@param event string
function Core:CheckForDisplayUpdate(event)
    if not (event == "NEW_MOUNT_ADDED" or event == "UPDATE_INSTANCE_INFO" or event == "PLAYER_DIFFICULTY_CHANGED" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA") then
        return
    end

    MRP.UI:UpdateDisplay()
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
    if not step or step.source.type == MRP.FilterSourceType.WorldBoss then
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

    local mostSuitableDifficultyIds = self:GetMostSuitableDifficultyIdsForLegacyRaids(step)
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

    for _, step in ipairs(MRP.Steps) do
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

    for _, dungeon in pairs(MRP.Data.dungeons) do
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

    for _, raid in pairs(MRP.Data.raids) do
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

    if MRP_Settings.autoSkip == nil then
        MRP_Settings.autoSkip = true
    end

    if MRP_Settings.autoAdvance == nil then
        MRP_Settings.autoAdvance = true
    end

    if MRP_Settings.useTomTom == nil then
        MRP_Settings.useTomTom = true
    end

    if MRP_Settings.showDifficultyWarning == nil then
        MRP_Settings.showDifficultyWarning = true
    end

    if not MRP_CharacterSettings then
        MRP_CharacterSettings = {}
    end

    if MRP_CharacterSettings.currentStep == nil then
        MRP_CharacterSettings.currentStep = 1
    end

    if MRP_CharacterSettings.filter == nil then
        MRP_CharacterSettings.filter = {
            expansions = {},
            sourceTypes = {},
            collectedStates = {}
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
end

local watcher = CreateFrame("Frame")
watcher:RegisterEvent("BAG_UPDATE_DELAYED")
watcher:RegisterEvent("ENCOUNTER_END")
watcher:RegisterEvent("HEARTHSTONE_BOUND")
watcher:RegisterEvent("NEW_MOUNT_ADDED")
watcher:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
watcher:RegisterEvent("PLAYER_LEAVE_COMBAT")
watcher:RegisterEvent("UPDATE_INSTANCE_INFO")
watcher:RegisterEvent("ZONE_CHANGED")
watcher:RegisterEvent("ZONE_CHANGED_INDOORS")
watcher:RegisterEvent("ZONE_CHANGED_NEW_AREA")
watcher:SetScript("OnEvent", function(_, event)
    Core:CheckRaidInfo(event)
    Core:CheckForPathfindingWarnings(event)
    Core:CheckForDisplayUpdate(event)
    Core:CheckDifficultyWarning(event)
    Core:CheckCurrentStepComplete(false)
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    Core:InitializeSettings()
    Core:FilterTimewalkingSteps()
    MRP.Filter:Apply(true)
    Core:CheckCurrentStepComplete(false)

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
        MRP.Options:Show()
    elseif cmd == "tomtom" and (arg1 == "on" or arg1 == "off") then
        MRP_Settings.useTomTom = (arg1 == "on")
        print(string.format(L["|cff00ff00[MRP]|r TomTom usage is now: %s"], (MRP_Settings.useTomTom and L["|cff00ff00ENABLED|r"] or L["|cffff0000DISABLED|r"])))
    elseif cmd == "updatedisplaydelayed" then
        C_Timer.After(tonumber(arg1) or 0.25, function() MRP.UI:UpdateDisplay() end)
    else
        print(L["|cffffd200Usage:|r"])
        print(L[" - /mrp → Toggle Mount Route Planner UI"])
        print(L[" - /mrp reset → Clears current progress and steps"])
        print(L[" - /mrp settings → Open addon settings"])
        print(L[" - /mrp tomtom on|off → Enable or disable TomTom integration"])
        print(L[" - /mrp updatedisplaydelayed <number> → Force update of the display after a delay (default: 0.25 seconds)"])
    end
end

SLASH_MOUNTROUTEPLANNER1 = "/mrp"
SlashCmdList["MOUNTROUTEPLANNER"] = function(msg)
    Core:HandleSlashCommand(msg)
end
