-- MRP_Filter.lua
-- local _, MRP = ...

---@class FilterSettings
---@field expansions { [FilterExpansion] : boolean } The expansion levels that are shown.
---@field sourceTypes { [FilterSourceType] : boolean } The sources types that are shown.
---@field collectedStates { [FilterCollectedState] : boolean } The collected states that are shown.

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

function Filter:GetStepFaction(step)
    local entry = MRP.Data.OPEN_WORLD[step.source.name]
    local condition = entry and entry.condition or nil
    if condition == "horde_only" then
        return MRP.FilterFaction.Horde
    elseif condition == "alliance_only" then
        return MRP.FilterFaction.Alliance
    else
        return MRP.FilterFaction.Neutral
    end
end

function Filter:UpdateFilteredSteps()
    self.filteredSteps = {}

    for _, step in ipairs(MRP.Data.STEPS) do
        if step.expansion and MRP_CharacterSettings.filter.expansions[step.expansion] then
            if step.source.type and MRP_CharacterSettings.filter.sourceTypes[step.source.type] then
                if MRP_CharacterSettings.filter.factions[self:GetStepFaction(step)] then
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
