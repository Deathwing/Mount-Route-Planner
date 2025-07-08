-- MRP.lua
local _, MRP = ...

local L = MRP.L

function MRP_Clear()
    MRP.parsedSteps = {}
    MRP.currentIndex = 0

    if UnitFactionGroup("player") == "Alliance" then
        MRP_DB.parsedSteps_A = {}
        MRP_DB.currentIndex_A = 0
    else
        MRP_DB.parsedSteps_H = {}
        MRP_DB.currentIndex_H = 0
    end

    MRP.UI:UpdateDisplay()
end

function MRP_Parse(text)
    local steps = MRP.Parser:Parse(text)
    MRP.parsedSteps = steps
    MRP.currentIndex = 0

    if UnitFactionGroup("player") == "Alliance" then
        MRP_DB.parsedSteps_A = steps
        MRP_DB.currentIndex_A = 0
    else
        MRP_DB.parsedSteps_H = steps
        MRP_DB.currentIndex_H = 0
    end

    MRP_NextStep()
end

function MRP_PreviousStep()
    if not MRP.parsedSteps or #MRP.parsedSteps == 0 then
        return
    end

    if MRP.currentIndex <= 1 then
        return
    end

    MRP.currentIndex = MRP.currentIndex - 1
    if UnitFactionGroup("player") == "Alliance" then
        MRP_DB.currentIndex_A = MRP.currentIndex
    else
        MRP_DB.currentIndex_H = MRP.currentIndex
    end

    MRP.UI:UpdateDisplay()
end

function MRP_NextStep()
    if not MRP.parsedSteps or #MRP.parsedSteps == 0 then
        return
    end

    if MRP.currentIndex >= #MRP.parsedSteps then
        return
    end

    repeat
        MRP.currentIndex = MRP.currentIndex + 1
        local step = MRP.parsedSteps[MRP.currentIndex]
    until not (MRP_DB.autoSkip
            and step
            and MRP_ShouldSkipStep(step))

    if UnitFactionGroup("player") == "Alliance" then
        MRP_DB.currentIndex_A = MRP.currentIndex
    else
        MRP_DB.currentIndex_H = MRP.currentIndex
    end

    MRP.UI:UpdateDisplay()
end

local specialMountIds = {
    ["Deathcharger's Reins"] = 69,
    ["Blue Qiraji Crystal"] = 117,
    ["Red Qiraji Crystal"] = 118,
    ["Yellow Qiraji Crystal"] = 119,
    ["Green Qiraji Crystal"] = 120,
    ["Fiery Warhorse's Reins"] = 168,
    ["Ashes of Al'ar"] = 183,
    ["Raven Lord"] = 185,
    ["Swift White Hawkstrider"] = 213,
    ["Azure Drake"] = 246,
    ["Blue Drake"] = 247,
    ["Bronze Drake"] = 248,
    ["Twilight Drake"] = 250,
    ["Black Drake"] = 253,
    ["Blue Proto-Drake"] = 264,
    ["Mimiron's Head"] = 304,
    ["Onyxian Drake"] = 349,
    ["Invincible's Reins"] = 363,
    ["Drake of the North Wind"] = 395,
    ["Drake of the South Wind"] = 396,
    ["Vitreous Stone Drake"] = 397,
    ["Armored Razzashi Raptor"] = 410,
    ["Swift Zulian Panther"] = 411,
    ["Egg of Millagazor"] = 415,
    ["Amani Battle Bear"] = 419,
    ["Flametalon of Alysrazor"] = 425,
    ["Blazing Drake"] = 442,
    ["Life-Binder's Handmaiden"] = 444,
    ["Experiment 12-B"] = 445,
    ["Reins of the Heavenly Onyx Cloud Serpent"] = 473,
    ["Reins of the Astral Cloud Serpent"] = 478,
    ["Son of Galleon's Saddle"] = 515,
    ["Spawn of Horridon"] = 531,
    ["Reins of the Cobalt Primordial Direhorn"] = 533,
    ["Reins of the Thundering Cobalt Cloud Serpent"] = 542,
    ["Clutch of Ji-Kun"] = 543,
    ["Kor'kron Juggernaut"] = 559,
    ["Ironhoof Destroyer"] = 613,
    ["Fiendish Hellfire Core"] = 633,
    ["Solar Spirehawk"] = 634,
    ["Felsteel Annihilator"] = 751,
    ["Infinite Timereaver"] = 781,
    ["Living Infernal Core"] = 791,
    ["Midnight's Eternal Reins"] = 875,
    ["Smoldering Ember Wyrm"] = 883,
    ["Abyss Worm"] = 899,
    ["Shackled Ur'zul"] = 954,
    ["Antoran Charhound"] = 971,
    ["Sharkbait's Favorite Crackers"] = 995,
    ["Mummified Raptor Skull"] = 1040,
    ["Underrot Crawg Harness"] = 1053,
    ["G.M.O.D."] = 1217,
    ["Glacial Tidestorm"] = 1219,
    ["Aerial Unit R-21/X"] = 1227,
    ["Mechagon Peacekeeper"] = 1252,
    ["Ny'alotha Allseer"] = 1293,
    ["Marrowfang"] = 1406,
    ["Vengeance"] = 1471,
    ["Cartel Master's Gearglider"] = 1481,
    ["Sanctum Gloomcharger"] = 1500,
    ["Zereth Overseer"] = 1587,
    ["Anu'relos, Flame's Guidance"] = 1818,
    ["Stonevault Mechsuit"] = 2119,
    ["Wick"] = 2204,
    ["Sureki Skyrazor"] = 2219,
    ["Ascendant Skyrazor"] = 2223,
    ["The Big G"] = 2487,
    ["Prototype A.S.M.R."] = 2507
}

local specialFactionMountIds = {
    ["Alliance"] = {
        ["Grand Black War Mammoth"] = 286,
    },
    ["Horde"] = {
        ["Grand Black War Mammoth"] = 287
    }
}

local mountIconCache = {}
local mountMissingReportedCache = {}

function MRP_GetSpecialMountId(name)
    if specialMountIds[name] then
        return specialMountIds[name]
    end

    local faction = UnitFactionGroup("player")
    if faction and specialFactionMountIds[faction] and specialFactionMountIds[faction][name] then
        return specialFactionMountIds[faction][name]
    end

    return nil
end

function MRP_GetMountIconByName(name)
    if not name then return nil end

    if mountIconCache[name] then
        return mountIconCache[name]
    end

    local specialMountId = MRP_GetSpecialMountId(name)
    if specialMountId then
        local icon = select(3, C_MountJournal.GetMountInfoByID(specialMountId))
        if icon then
            mountIconCache[name] = icon
            return icon
        end
    end

    local mountIds = C_MountJournal.GetMountIDs()

    for i = 1, #mountIds do
        local mountName, _, icon = C_MountJournal.GetMountInfoByID(mountIds[i])
        if mountName and (mountName == name or mountName:lower():find(name:lower())) then
            mountIconCache[name] = icon
            return icon
        end
    end

    if not mountMissingReportedCache[name] then
        mountMissingReportedCache[name] = true
        print(("|cffffcc00[MRP]|r " .. format(L["Mount not found: '%s', please report it."], name or "")))
    end

    mountIconCache[name] = nil
    return nil
end

function MRP_GetMountCollectedByName(name)
    if not name then return nil end

    local specialMountId = MRP_GetSpecialMountId(name)
    if specialMountId then
        return select(11, C_MountJournal.GetMountInfoByID(specialMountId))
    end

    local mountIds = C_MountJournal.GetMountIDs()

    for i = 1, #mountIds do
        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountIds[i])
        if mountName and (mountName == name or mountName:lower():find(name:lower())) then
            return collected
        end
    end

    if not mountMissingReportedCache[name] then
        mountMissingReportedCache[name] = true
        print(("|cffffcc00[MRP]|r " .. format(L["Mount not found: '%s', please report it."], name or "")))
    end

    return nil
end

function MRP_IsBossDead(boss, instance)
    if not boss then return false end
    local bossName = boss:lower()

    if instance then
        local instanceNameTarget = instance:lower()
        for i = 1, GetNumSavedInstances() do
            local instanceName, _, _, _, locked, _, _, _, _, _, _, _ = GetSavedInstanceInfo(i)
            if instanceName and locked and instanceName:lower():find(instanceNameTarget) then
                local numEncounters = select(9, GetSavedInstanceInfo(i))
                for j = 1, numEncounters do
                    local encounterName, _, isKilled = GetSavedInstanceEncounterInfo(i, j)
                    if encounterName and (encounterName == bossName or encounterName:lower() == bossName) then
                        return isKilled
                    end
                end
            end
        end
    end

    for i = 1, GetNumSavedWorldBosses() do
        local worldBossName = GetSavedWorldBossInfo(i)
        if worldBossName and (worldBossName == bossName or worldBossName:lower() == bossName) then
            return true
        end
    end

    return false
end

function MRP_IsCorrectDifficulty(neededDiffString)
    if IsInInstance() then
        local _, _, currentDiffID = GetInstanceInfo()
        return MRP_MatchesDifficulty(neededDiffString, currentDiffID)
    else
        local selectedDiffID = nil

        if IsInGroup() or IsInRaid() then
            selectedDiffID = GetRaidDifficultyID()
        else
            selectedDiffID = GetDungeonDifficultyID()
        end

        if not selectedDiffID or selectedDiffID == 0 then
            selectedDiffID = GetLegacyRaidDifficultyID()
        end

        return MRP_MatchesDifficulty(neededDiffString, selectedDiffID)
    end
end

function MRP_MatchesDifficulty(neededDiffString, diffID)
    -- This function checks whether the current difficulty ID (number) matches the request text.
    -- We use string.find() so that it also works if there is more text in the note.

    if neededDiffString:find("Heroic 25 only") then
        -- Especially for WotLK mounts like Invincible.
        -- ID 6 = 25-Player Heroic
        return diffID == 6

    elseif neededDiffString:find("Heroic only") then
        -- Covers ALL types of “Heroic”.
        -- ID 2 = Dungeon Heroic
        -- ID 5 = 10-player Raid Heroic (WotLK/Cata)
        -- ID 6 = 25-player Raid Heroic (WotLK/Cata)
        -- ID 15 = Heroic Raid (Flex, from MoP)
        return diffID == 2 or diffID == 5 or diffID == 6 or diffID == 15

    elseif neededDiffString:find("Mythic only") then
        -- Covers ALL types of “Mythic”.
        -- ID 16 = Mythic Raid
        -- ID 23 = Mythic Dungeon
        return diffID == 16 or diffID == 23
    end

    -- If no specific requirement is found in the note (e.g. for normal mounts),
    -- we return ‘true’, as the difficulty is then irrelevant.
    return true
end

function MRP_ShouldSkipStep(step)
    if not step then
        return false
    end

    local function inZone(zoneIdOrName)
        local mapID = C_Map.GetBestMapForUnit("player")
        if not mapID then
            return false
        end

        if MRP.Data.mapNamesToIds[zoneIdOrName] then
            return MRP.Data.mapNamesToIds[zoneIdOrName] == mapID
        end

        if type(zoneIdOrName) == "number" then
            return mapID == zoneIdOrName
        end

        local mapInfo = C_Map.GetMapInfo(mapID)
        return mapInfo and mapInfo.name and zoneIdOrName and (mapInfo.name == zoneIdOrName or mapInfo.name:lower():find(zoneIdOrName:lower()))
    end

    if step.linkedStep and MRP_ShouldSkipStep(step.linkedStep) then
        return true
    end

    if step.rewards then
        local deadImportantBosses = {}

        for _, reward in ipairs(step.rewards) do
            if reward.mount and reward.boss then
                if not MRP_GetMountCollectedByName(reward.mount) then
                    deadImportantBosses[reward.boss] = MRP_IsBossDead(reward.boss, step.instance)
                end
            end
        end

        local allImportantDead = true
        for boss, isDead in pairs(deadImportantBosses) do
            if not isDead then
                allImportantDead = false
                break
            end
        end

        return allImportantDead
    elseif step.item or step.flyTo or step.flightPath or step.portal or step.walkTo or step.teleport or step.hearthstone then
        return inZone(step.item or step.flyTo or step.flightPath or step.portal or step.walkTo or step.teleport or
            step.hearthstone)
    end

    return false
end

function MRP_CheckCurrentStepComplete(force)
    if MRP.parsedSteps == nil or #MRP.parsedSteps == 0 then
        return
    end

    local step = MRP.parsedSteps[MRP.currentIndex]
    if step and (force or (MRP_DB.autoAdvance and MRP_ShouldSkipStep(step))) then
        MRP_NextStep()
    end
end

local StepWatcher = CreateFrame("Frame")
-- We are now listening for ALL relevant zone events to be sure.
StepWatcher:RegisterEvent("ZONE_CHANGED")
StepWatcher:RegisterEvent("ZONE_CHANGED_INDOORS")
StepWatcher:RegisterEvent("ZONE_CHANGED_NEW_AREA") 
StepWatcher:RegisterEvent("BAG_UPDATE_COOLDOWN")
StepWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
StepWatcher:RegisterEvent("NEW_MOUNT_ADDED")
StepWatcher:RegisterEvent("UPDATE_INSTANCE_INFO")
StepWatcher:RegisterEvent("PLAYER_LEAVE_COMBAT")

-- New helper function to check the difficulty
function MRP_CheckDifficultyWarning(event)
    -- Check only if the triggered event is a zone change
    if not (event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA") then
        return -- Exit the function if it is not a zone change
    end

    -- Hide the warning when we are not (or no longer) in an instance.
    if not IsInInstance() then
        MRP.UI:HideDifficultyWarning()
        return -- End the function here, as further checks are pointless.
    end

    local step = MRP.parsedSteps and MRP.parsedSteps[MRP.currentIndex]
    if step and step.instance then
        local unmetRequirements = {}
        -- Check all rewards in the current step
        for _, reward in ipairs(step.rewards or {}) do
            if not MRP_GetMountCollectedByName(reward.mount) and reward.note and reward.note ~= "" then
                local neededDiffString = nil
                
                if reward.note:find("Mythic only") then
                    neededDiffString = "Mythic only"
                elseif reward.note:find("Heroic 25 only") then
                    neededDiffString = "Heroic 25 only"
                elseif reward.note:find("Heroic only") then
                    neededDiffString = "Heroic only"
                end

                if neededDiffString and not MRP_IsCorrectDifficulty(neededDiffString) then
                    local diffText = neededDiffString
                    if diffText == "Heroic 25 only" then
                        diffText = L["Heroic 25"]
                    else
                        diffText = diffText:gsub(" only", "")
                    end
                    unmetRequirements[diffText] = true
                end
            end
        end

        local warningString = ""
        for req, _ in pairs(unmetRequirements) do
            warningString = warningString .. req .. ", "
        end

        if warningString ~= "" then
            warningString = warningString:sub(1, -3) -- Remove last comma
            MRP.UI:ShowDifficultyWarning(warningString)
        else
            MRP.UI:HideDifficultyWarning()
        end
    end
end

StepWatcher:SetScript("OnEvent", function(_, event)
    MRP_CheckDifficultyWarning(event)
    MRP_CheckCurrentStepComplete(false)
end)

local panel = CreateFrame("Frame", nil, UIParent)
panel.name = "MRP"

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText(L["Mount Route Planner - Settings"])

local tomtomCheckbox = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
tomtomCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
tomtomCheckbox.Text:SetText(L["Use TomTom for waypoints"])

tomtomCheckbox:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Enable this to use TomTom for waypoint navigation."])
    GameTooltip:AddLine(L["This will create waypoints for each step in your route."], 1, 1, 1)
    GameTooltip:AddLine(L["You must have TomTom installed for this to work."], 1, 0.5, 0.5)
    GameTooltip:AddLine(L["You can toggle this setting at any time."], 0.5, 1, 0.5)
    GameTooltip:Show()
end)

tomtomCheckbox:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

MRP_DB = MRP_DB or {}
tomtomCheckbox:SetChecked(MRP_DB.useTomTom)

tomtomCheckbox:SetScript("OnClick", function(self)
    MRP_DB.useTomTom = self:GetChecked()
end)

local category = Settings.RegisterCanvasLayoutCategory(panel, "MRP")
Settings.RegisterAddOnCategory(category)

function MRP_OpenSettings()
    Settings.OpenToCategory(category:GetID())
end

SLASH_MOUNTROUTEPLANNER1 = "/mrp"
SlashCmdList["MOUNTROUTEPLANNER"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word:lower())
    end

    local cmd = args[1]
    local arg1 = args[2]

    if not cmd or cmd == "" then
        MRP.UI:ShowHide()
    elseif cmd == "reset" then
        MRP_Clear()
    elseif cmd == "settings" then
        MRP_OpenSettings()
    elseif cmd == "tomtom" and (arg1 == "on" or arg1 == "off") then
        MRP_DB = MRP_DB or {}
        MRP_DB.useTomTom = (arg1 == "on")
        print(string.format(L["|cff00ff00[MRP]|r TomTom usage is now: %s"], (MRP_DB.useTomTom and L["|cff00ff00ENABLED|r"] or L["|cffff0000DISABLED|r"])))
    else
        print(L["|cffffd200Usage:|r"])
        print(L[" - /mrp → Toggle Mount Route Planner UI"])
        print(L[" - /mrp reset → Clears current progress and steps"])
        print(L[" - /mrp settings → Open addon settings"])
        print(L[" - /mrp tomtom on|off → Enable or disable TomTom integration"])
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    tomtomCheckbox:SetChecked(MRP_DB.useTomTom)
    if UnitFactionGroup("player") == "Alliance" then
        if MRP_DB.parsedSteps_A then
            MRP.parsedSteps = MRP_DB.parsedSteps_A
            MRP.currentIndex = MRP_DB.currentIndex_A or 1
            MRP_CheckCurrentStepComplete(false)
        end
    else
        if MRP_DB.parsedSteps_H then
            MRP.parsedSteps = MRP_DB.parsedSteps_H
            MRP.currentIndex = MRP_DB.currentIndex_H or 1
            MRP_CheckCurrentStepComplete(false)
        end
    end
end)
