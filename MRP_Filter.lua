-- MRP_Filter.lua
-- local _, MRP = ...

---@class FilterSettings
---@field expansions { [FilterExpansion] : boolean } The expansion levels that are shown.
---@field sourceTypes { [FilterSourceType] : boolean } The sources types that are shown.
---@field collectedStates { [FilterCollectedState] : boolean } The collected states that are shown.
---@field factions { [FilterFaction] : boolean } The factions that are shown.
---@field holidays { [FilterHoliday] : boolean } The holidays that are shown.

local Filter = {
    ---@type Step[]
    filteredSteps = {}
}

MRP.Filter = Filter

---@return Step? currentStep
function Filter:GetCurrentStep()
    if MRP_CharacterSettings.currentStep < 1 or MRP_CharacterSettings.currentStep > #self.filteredSteps then
        return nil
    end

    return self.filteredSteps[MRP_CharacterSettings.currentStep]
end

---@param expansion FilterExpansion
---@param value boolean
function Filter:SetExpansion(expansion, value)
    if value then
        if not MRP_CharacterSettings.filter.expansions[expansion] then
            MRP_CharacterSettings.filter.expansions[expansion] = true
            self:Apply()
        end
    else
        if MRP_CharacterSettings.filter.expansions[expansion] then
            MRP_CharacterSettings.filter.expansions[expansion] = false
            self:Apply()
        end
    end
end

---@param sourceType FilterSourceType
---@param value boolean
function Filter:SetSourceType(sourceType, value)
    if value then
        if not MRP_CharacterSettings.filter.sourceTypes[sourceType] then
            MRP_CharacterSettings.filter.sourceTypes[sourceType] = true
            self:Apply()
        end
    else
        if MRP_CharacterSettings.filter.sourceTypes[sourceType] then
            MRP_CharacterSettings.filter.sourceTypes[sourceType] = false
            self:Apply()
        end
    end
end

---@param collectedState FilterCollectedState
---@param value boolean
function Filter:SetCollectedState(collectedState, value)
    if value then
        if not MRP_CharacterSettings.filter.collectedStates[collectedState] then
            MRP_CharacterSettings.filter.collectedStates[collectedState] = true
            self:Apply()
        end
    else
        if MRP_CharacterSettings.filter.collectedStates[collectedState] then
            MRP_CharacterSettings.filter.collectedStates[collectedState] = false
            self:Apply()
        end
    end
end

function Filter:SetFaction(faction, value)
    if value then
        if not MRP_CharacterSettings.filter.factions[faction] then
            MRP_CharacterSettings.filter.factions[faction] = true
            self:Apply()
        end
    else
        if MRP_CharacterSettings.filter.factions[faction] then
            MRP_CharacterSettings.filter.factions[faction] = false
            self:Apply()
        end
    end
end

function Filter:SetHoliday(holiday, value)
    if value then
        if not MRP_CharacterSettings.filter.holidays[holiday] then
            MRP_CharacterSettings.filter.holidays[holiday] = true
            self:Apply()
        end
    else
        if MRP_CharacterSettings.filter.holidays[holiday] then
            MRP_CharacterSettings.filter.holidays[holiday] = false
            self:Apply()
        end
    end
end

---Gets the faction for a step based on its conditions, defaulting to Neutral if no faction-specific conditions are found.
---@param step Step
---@return FilterFaction
function Filter:GetStepFaction(step)
    local entry = MRP.Util.GetStepEntry(step)
    if entry and entry.conditions then
        for _, key in ipairs(entry.conditions) do
            if key == "horde_only" then
                return MRP.FilterFaction.Horde
            elseif key == "alliance_only" then
                return MRP.FilterFaction.Alliance
            end
        end
    end
    return MRP.FilterFaction.Neutral
end

---Gets the holiday condition key for a step based on its conditions, defaulting to None if no holiday conditions are found.
---@param step Step
---@return FilterHoliday
function Filter:GetStepHoliday(step)
    local entry = MRP.Util.GetStepEntry(step)
    if entry and entry.conditions then
        for _, key in ipairs(entry.conditions) do
            if key:find("^event_") then return key end
        end
    end
    return MRP.FilterHoliday.None
end

function Filter:BuildAvailability()
    self.availableExpansions = {}
    self.availableSourceTypes = {}
    self.availableFactions = {}
    self.availableHolidays = {}

    for _, step in ipairs(MRP.Data.STEPS) do
        if step.mounts and #step.mounts > 0 then
            if step.expansion then
                self.availableExpansions[step.expansion] = true
            end
            if step.source and step.source.type then
                self.availableSourceTypes[step.source.type] = true
            end
            self.availableFactions[self:GetStepFaction(step)] = true
            self.availableHolidays[self:GetStepHoliday(step)] = true
        end
    end
end

function Filter:UpdateFilteredSteps()
    self.filteredSteps = {}

    for _, step in ipairs(MRP.Data.STEPS) do
        if step.expansion and MRP_CharacterSettings.filter.expansions[step.expansion] then
            if step.source.type and MRP_CharacterSettings.filter.sourceTypes[step.source.type] then
                if MRP_CharacterSettings.filter.factions[self:GetStepFaction(step)] then
                    if MRP_CharacterSettings.filter.holidays[self:GetStepHoliday(step)] then
                        for _, mount in ipairs(step.mounts) do
                            local _, _, collected = MRP.Util.GetMountInfoSafe(mount)
                            if MRP_CharacterSettings.filter.collectedStates[collected] then
                                table.insert(self.filteredSteps, step)
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- Apply saved baseline route order if available
    if MRP.Route then
        MRP.Route:ApplyToFilteredSteps()
    end
end

function Filter:EnsureInBounds()
    if MRP_CharacterSettings.currentStep < 1 then
        MRP_CharacterSettings.currentStep = 1
    elseif MRP_CharacterSettings.currentStep > #self.filteredSteps then
        MRP_CharacterSettings.currentStep = #self.filteredSteps
    end
end

---@param onLoad boolean?
function Filter:Apply(onLoad)
    if onLoad then
        self:BuildAvailability()
        self:UpdateFilteredSteps()
        self:EnsureInBounds()

        if MRP.UI then
            MRP.UI:UpdateDisplay()
        end
        return
    end

    local oldStepLength = #self.filteredSteps
    local oldStepNumber = MRP_CharacterSettings.currentStep
    local oldStep = self:GetCurrentStep()

    self:UpdateFilteredSteps()

    if oldStep then
        for i, step in ipairs(self.filteredSteps) do
            if step == oldStep then
                MRP_CharacterSettings.currentStep = i
                break
            end
        end
    else
        if #self.filteredSteps > 0 and oldStepLength > 0 then
            MRP_CharacterSettings.currentStep = math.ceil((oldStepNumber / oldStepLength) * #self.filteredSteps)
        else
            MRP_CharacterSettings.currentStep = 1
        end
    end

    self:EnsureInBounds()

    if MRP.UI then
        MRP.UI:UpdateDisplay()
    end
end

Filter:Apply()
