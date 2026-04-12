-- MRP_UI.lua
-- local _, MRP = ...

local L = MRP.L

local UI = {}
MRP.UI = UI

local function CreateIconButton(parent, iconName)
    local btn = CreateFrame("Button", nil, parent, "UIPanelCloseButton")
    btn:SetNormalTexture("Interface\\AddOns\\MountRoutePlanner\\Assets\\" .. iconName .. ".tga")
    btn:SetPushedTexture("Interface\\AddOns\\MountRoutePlanner\\Assets\\P_" .. iconName .. ".tga")
    btn:SetHighlightTexture("Interface\\AddOns\\MountRoutePlanner\\Assets\\" .. iconName .. ".tga")
    btn:SetSize(24, 24)
    return btn
end

local function CreateTextButton(parent, text)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetNormalTexture("Interface\\AddOns\\MountRoutePlanner\\Assets\\Frame.tga")
    btn:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
    btn:SetPushedTexture("Interface\\AddOns\\MountRoutePlanner\\Assets\\P_Frame.tga")
    btn:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
    btn:SetHighlightTexture("Interface\\AddOns\\MountRoutePlanner\\Assets\\Frame.tga")
    btn:GetHighlightTexture():SetTexCoord(0, 1, 0, 1)
    btn:SetSize(60, 24)
    btn:SetText(text)
    btn:SetPushedTextOffset(0, 0)
    return btn
end

local function CreateToggleWithLabelAndTooltip(parent, text, description)
    local toggle = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    toggle:SetSize(24, 24)
    toggle.text = toggle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    toggle.text:SetPoint("LEFT", toggle, "RIGHT", 4, 0)
    toggle.text:SetText(text)
    toggle:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(text)
        GameTooltip:AddLine(description, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    toggle:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    return toggle
end

local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
frame:SetSize(400, 260)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {
        left = 11,
        right = 12,
        top = 12,
        bottom = 11
    }
})
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

local closeBtn = CreateIconButton(frame, "Frame_Close")
closeBtn:SetPoint("TOPRIGHT", -14, -14)

local settingsBtn = CreateIconButton(frame, "Frame_Settings")
settingsBtn:SetPoint("TOPRIGHT", closeBtn, "TOPLEFT", 0, 0)

settingsBtn:SetScript("OnClick", function()
    if not InCombatLockdown() then
        MRP.Options:Show()
    end
end)

settingsBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Settings"])
    GameTooltip:AddLine(L["Open the MRP settings panel"], 1, 1, 1)
    UI:AddPossibleInCombatWarning()
    GameTooltip:Show()
end)
settingsBtn:SetScript("OnLeave", GameTooltip_Hide)

local resetBtn = CreateIconButton(frame, "Frame_Reset")
resetBtn:SetPoint("TOPRIGHT", settingsBtn, "TOPLEFT", 0, 0)
resetBtn:SetScript("OnClick", function()
    MRP.Core:Reset()
end)

resetBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Reset Steps"])
    GameTooltip:AddLine(L["Clears current progress and steps"], 1, 1, 1)
    GameTooltip:Show()
end)

resetBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local filterBtn = CreateTextButton(frame, L["Filter"])
filterBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, -14)

local dropdown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")

filterBtn:SetScript("OnClick", function()
    ToggleDropDownMenu(1, nil, dropdown, filterBtn, 0, 0)
end)

local function AddDropdownCheckboxButton(level, text, checked, func)
    local info = UIDropDownMenu_CreateInfo()
    info.text = text
    info.keepShownOnClick = true
    info.isNotRadio = true
    info.checked = checked
    info.func = func
    return UIDropDownMenu_AddButton(info, level)
end

local function AddDropdownCheckboxButton_FilterCollectedState(level, k)
    local v = MRP.FilterCollectedState[k]
    return AddDropdownCheckboxButton(level, L["CollectedState_" .. k], MRP_CharacterSettings.filter.collectedStates[v], function(_, _, _, checked)
        MRP.Filter:SetCollectedState(v, checked)
    end)
end

local function AddDropdownCheckboxButton_FilterExpansion(level, k)
    local v = MRP.FilterExpansion[k]
    return AddDropdownCheckboxButton(level, _G["EXPANSION_NAME" .. v], MRP_CharacterSettings.filter.expansions[v], function(_, _, _, checked)
        MRP.Filter:SetExpansion(v, checked)
    end)
end

local function AddDropdownCheckboxButton_FilterSourceType(level, k)
    local v = MRP.FilterSourceType[k]
    return AddDropdownCheckboxButton(level, L["SourceType_" .. k], MRP_CharacterSettings.filter.sourceTypes[v], function(_, _, _, checked)
        MRP.Filter:SetSourceType(v, checked)
    end)
end

local function AddDropdownCheckboxButton_FilterFaction(level, k)
    local v = MRP.FilterFaction[k]
    return AddDropdownCheckboxButton(level, L[v], MRP_CharacterSettings.filter.factions[v], function(_, _, _, checked)
        MRP.Filter:SetFaction(v, checked)
    end)
end

local function AddDropdownMenuButton(level, text, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.text = text
    info.hasArrow = true
    info.keepShownOnClick = true
    info.notCheckable = true
    info.menuList = menuList
    return UIDropDownMenu_AddButton(info, level)
end

UIDropDownMenu_Initialize(dropdown, function(_, level, menuList)
    if level == 1 then
        for _, k in ipairs(MRP.FilterCollectedStateOrder) do
            AddDropdownCheckboxButton_FilterCollectedState(level, k)
        end
        UIDropDownMenu_AddSeparator(level)
        AddDropdownMenuButton(level, L["Factions"], "FACTION_MENU")
        AddDropdownMenuButton(level, L["Expansions"], "EXPANSION_MENU")
        AddDropdownMenuButton(level, L["SourceTypes"], "SOURCE_TYPE_MENU")
    elseif level == 2 then
        if menuList == "FACTION_MENU" then
            for _, k in ipairs(MRP.FilterFactionOrder) do
                AddDropdownCheckboxButton_FilterFaction(level, k)
            end
        elseif menuList == "EXPANSION_MENU" then
            for _, k in ipairs(MRP.FilterExpansionOrder) do
                if GetExpansionLevel() >= MRP.FilterExpansion[k] then
                    AddDropdownCheckboxButton_FilterExpansion(level, k)
                end
            end
        elseif menuList == "SOURCE_TYPE_MENU" then
            for _, k in ipairs(MRP.FilterSourceTypeOrder) do
                AddDropdownCheckboxButton_FilterSourceType(level, k)
            end
        end
    end
end, "MENU")

local discordBtn = CreateIconButton(frame, "Frame_Discord")
discordBtn:SetPoint("TOPLEFT", filterBtn, "TOPRIGHT", 2, 0)
discordBtn:SetScript("OnClick", function()
    if not StaticPopupDialogs["MRP_DISCORD_COPY_LINK"] then
        StaticPopupDialogs["MRP_DISCORD_COPY_LINK"] = {
            text = L["Feedback? Questions? Join our Discord!"],
            button1 = OKAY,
            button2 = nil,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,

            hasEditBox = true,
            editBoxWidth = 300,

            OnShow = function(self)
                self.EditBox:SetText("https://discord.gg/TrJFGcah7z")
                self.EditBox:HighlightText(0)
                self.EditBox:SetFocus()
            end,

            EditBoxOnEnterPressed = function(self)
                self:GetParent():Hide()
            end,
            EditBoxOnEscapePressed = function(self)
                self:GetParent():Hide()
            end,
        }
    end
    StaticPopup_Show("MRP_DISCORD_COPY_LINK")
end)

local prevBtn = CreateTextButton(frame, L["<< Prev"])
prevBtn:SetSize(60, 24)
prevBtn:SetPoint("BOTTOMLEFT", 14, 12)
prevBtn:SetScript("OnClick", function()
    MRP.Core:PreviousStep()
end)

local nextBtn = CreateTextButton(frame, L["Next >>"])
nextBtn:SetSize(60, 24)
nextBtn:SetPoint("BOTTOMRIGHT", -14, 12)
nextBtn:SetScript("OnClick", function()
    MRP.Core:NextStep()
end)

local autoAdvanceToggle = CreateToggleWithLabelAndTooltip(frame, L["Auto-Advance Steps"], L["Automatically advances to the next step after completing the current one."])
autoAdvanceToggle:SetPoint("BOTTOMLEFT", prevBtn, "TOPLEFT", 0, 0)

autoAdvanceToggle:SetScript("OnClick", function(self)
    MRP_CharacterSettings.autoAdvance = self:GetChecked()
end)

local autoSkipToggle = CreateToggleWithLabelAndTooltip(frame, L["Auto-Skip Steps"], L["Automatically skips steps that are already completed."])
autoSkipToggle:SetPoint("BOTTOMLEFT", autoAdvanceToggle, "TOPLEFT", 0, 0)

autoSkipToggle:SetScript("OnClick", function(self)
    MRP_CharacterSettings.autoSkip = self:GetChecked()
end)

local actionBtn = CreateFrame("Button", nil, frame, "InsecureActionButtonTemplate")
actionBtn:SetSize(40, 40)
actionBtn:SetPoint("BOTTOMRIGHT", nextBtn, "TOPRIGHT", -4, 4)
actionBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
actionBtn:SetPushedTexture("Interface\\Icons\\INV_Misc_QuestionMark")
actionBtn:GetPushedTexture():SetVertexColor(0.6, 0.6, 0.6, 1)
actionBtn:SetHighlightTexture("Interface\\Icons\\INV_Misc_QuestionMark")
actionBtn:SetAttribute("type", "macro")
actionBtn:RegisterForClicks("AnyUp", "AnyDown")
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
    actionBtn:RegisterForClicks("AnyUp")
end
actionBtn:Hide()

function UI:SetGlowOverlay(button, show)
    if not ActionButtonSpellAlertManager then return end
    if show then
        ActionButtonSpellAlertManager:ShowAlert(button)
    else
        ActionButtonSpellAlertManager:HideAlert(button)
    end
end

function UI:AddPossibleInCombatWarning()
    if InCombatLockdown() then
        GameTooltip:AddLine(" ")
        GameTooltip_AddErrorLine(GameTooltip, ERR_NOT_IN_COMBAT);
    end
end

local function ResetActionBtnToMacro()
    actionBtn:SetAttribute("type", "macro")
    actionBtn:SetAttribute("house-neighborhood-guid", nil)
    actionBtn:SetAttribute("house-guid", nil)
    actionBtn:SetAttribute("house-plot-id", nil)
end

function UI:ShowActionUseSpell(spellId)
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if spellInfo then
        ResetActionBtnToMacro()
        actionBtn:SetNormalTexture(spellInfo.iconID)
        actionBtn:SetHighlightTexture(spellInfo.iconID)
        actionBtn:SetPushedTexture(spellInfo.iconID)

        actionBtn:SetAttribute("macrotext", "/cast " .. spellInfo.name)
        actionBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetSpellByID(spellId)
            UI:AddPossibleInCombatWarning()
            GameTooltip:Show()
        end)
        actionBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        actionBtn:Show()
        UI:SetGlowOverlay(actionBtn, true)
    end
end

function UI:ShowActionUseItem(itemId)
    ResetActionBtnToMacro()
    local item = MRP.Util.GetItem(itemId)
    local name = item:GetItemName()
    if name then
        local icon = item:GetItemIcon()
        if icon then
            actionBtn:SetNormalTexture(icon)
            actionBtn:SetHighlightTexture(icon)
            actionBtn:SetPushedTexture(icon)
        else
            actionBtn:SetNormalTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            actionBtn:SetHighlightTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            actionBtn:SetPushedTexture("Interface\\Icons\\INV_Misc_QuestionMark")
        end

        local macro = "/use " .. name
        if C_Item.GetItemInventoryTypeByID(itemId) > 0 then
            macro = "/equip " .. name .. "\n" .. macro
        end

        actionBtn:SetAttribute("macrotext", macro)
        actionBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if C_ToyBox.GetToyInfo(itemId) then
                GameTooltip:SetToyByItemID(itemId)
            else
                if InCombatLockdown() then
                    GameTooltip:SetHyperlink("item:" .. itemId)
                else
                    GameTooltip:SetItemByID(itemId)
                end
            end
            UI:AddPossibleInCombatWarning()
            GameTooltip:Show()
        end)
        actionBtn:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
        actionBtn:Show()
        UI:SetGlowOverlay(actionBtn, true)
    end
end

function UI:ShowActionTrashIt()
    ResetActionBtnToMacro()
    local itemsToSell = MRP.Core:GatherTrashItData()
    if #itemsToSell == 0 then
        return
    end

    local itemsWithCount = {}
    for _, info in ipairs(itemsToSell) do
        local item = info.item
        local name = item:GetItemName()
        if name then
            if not itemsWithCount[name] then
                itemsWithCount[name] = { count = 0, item = item }
            end
            itemsWithCount[name].count = itemsWithCount[name].count + item:GetStackCount()
        end
    end

    actionBtn:SetNormalTexture("Interface\\Icons\\Ability_Repair")
    actionBtn:SetHighlightTexture("Interface\\Icons\\Ability_Repair")
    actionBtn:SetPushedTexture("Interface\\Icons\\Ability_Repair")

    local macro = "/mrp trashit"

    actionBtn:SetAttribute("macrotext", macro)
    actionBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Trash It!"], 1, 1, 1)
        for _, info in pairs(itemsWithCount) do
            local item = info.item
            local name = item:GetItemName()
            if name then
                local r, g, b = C_Item.GetItemQualityColor(item:GetItemQuality())
                GameTooltip:AddLine(format("|T%s:16:16:0:0|t %s (%dx)", item:GetItemIcon() or "Interface\\Icons\\INV_Misc_QuestionMark", name, info.count), r, g, b)
            end
        end
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L["Click to trash all items listed above."], 0.6, 0.6, 0.6)
        UI:AddPossibleInCombatWarning()
        GameTooltip:Show()
    end)
    actionBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    actionBtn:Show()
    UI:SetGlowOverlay(actionBtn, true)
end

local difficultyConfig = {
    {
        check = function(difficultyId) return MRP.Core:IsDungeonDifficulty(difficultyId) end,
        texture = "interface/icons/inv_helmet_06",
        api = "SetDungeonDifficultyID",
        name = L["dungeon"]
    },
    {
        check = function(difficultyId) return MRP.Core:IsLegacyRaidDifficulty(difficultyId) end,
        texture = "interface/icons/inv_helmet_06",
        api = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and "SetLegacyRaidDifficultyID" or "SetRaidDifficultyID",
        name = L["legacy raid"]
    },
    {
        check = function(difficultyId) return MRP.Core:IsRaidDifficulty(difficultyId) end,
        texture = "interface/icons/inv_helmet_06",
        api = "SetRaidDifficultyID",
        name = L["raid"]
    },
}

function UI:ShowActionSwitchDifficulty(difficultyId)
    ResetActionBtnToMacro()
    if MRP.Core:IsLFRDifficulty(difficultyId) then
        return
    end

    local config = nil
    for _, c in ipairs(difficultyConfig) do
        if c.check(difficultyId) then
            config = c
            break
        end
    end

    if not config then
        print("|cffffcc00[MRP]|r " .. format(L["Difficulty not found: '%s', please report it."], difficultyId))
        return
    end

    local macro = "/script " .. config.api .. "(" .. difficultyId .. ")"
    if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
        macro = macro .. "\n/mrp updatedisplaydelayed"
    end

    actionBtn:SetNormalTexture(config.texture)
    actionBtn:SetHighlightTexture(config.texture)
    actionBtn:SetPushedTexture(config.texture)
    actionBtn:SetAttribute("macrotext", macro)
    actionBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(format(L["Switch to '%s' difficulty"], GetDifficultyInfo(difficultyId)), 1, 1, 1)
        GameTooltip:AddLine(format(L["Click to switch the %s difficulty."], config.name), 0.6, 0.6, 0.6)
        UI:AddPossibleInCombatWarning()
        GameTooltip:Show()
    end)
    actionBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    actionBtn:Show()
    UI:SetGlowOverlay(actionBtn, true)
end

function UI:HideCenterAction()
    UI:SetGlowOverlay(actionBtn, false)
    actionBtn:Hide()
end

function UI:ShowActionResetInstances()
    ResetActionBtnToMacro()
    actionBtn:SetNormalTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield")
    actionBtn:SetHighlightTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield")
    actionBtn:SetPushedTexture("Interface\\Icons\\Spell_Shadow_SacrificialShield")
    actionBtn:SetAttribute("macrotext", "/script ResetInstances()")
    actionBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Reset Instances"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to reset all instances."], 0.6, 0.6, 0.6)
        UI:AddPossibleInCombatWarning()
        GameTooltip:Show()
    end)
    actionBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    actionBtn:Show()
end

function UI:ShowActionHousingTeleport()
    local house = MRP.Farstrider.DATA.GetHousingData()
    if not house then return false end

    actionBtn:SetAttribute("type", "teleporthome")
    actionBtn:SetAttribute("house-neighborhood-guid", house.neighborhoodGUID)
    actionBtn:SetAttribute("house-guid", house.houseGUID)
    actionBtn:SetAttribute("house-plot-id", house.plotID)
    actionBtn:SetAttribute("macrotext", nil)

    actionBtn:SetScript("PreClick", function(self)
        if self:GetAttribute("type") == "teleporthome" then
            MRP.Farstrider.DATA.UpdateHousingExitLocation()
        end
    end)

    actionBtn:SetNormalAtlas("dashboard-panel-homestone-teleport-button")
    actionBtn:SetHighlightAtlas("dashboard-panel-homestone-teleport-button")
    actionBtn:SetPushedAtlas("dashboard-panel-homestone-teleport-button")
    actionBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Teleport to Plot"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to teleport to your housing plot."], 0.6, 0.6, 0.6)
        UI:AddPossibleInCombatWarning()
        GameTooltip:Show()
    end)
    actionBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    actionBtn:Show()
    UI:SetGlowOverlay(actionBtn, true)
    return true
end

function UI:ShowActionHousingReturn()
    actionBtn:SetAttribute("type", "returnhome")
    actionBtn:SetAttribute("macrotext", nil)

    actionBtn:SetNormalAtlas("dashboard-panel-homestone-teleport-button")
    actionBtn:SetHighlightAtlas("dashboard-panel-homestone-teleport-button")
    actionBtn:SetPushedAtlas("dashboard-panel-homestone-teleport-button")
    actionBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(L["Return from Plot"], 1, 1, 1)
        GameTooltip:AddLine(L["Click to return to your previous location."], 0.6, 0.6, 0.6)
        UI:AddPossibleInCombatWarning()
        GameTooltip:Show()
    end)
    actionBtn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    actionBtn:Show()
    UI:SetGlowOverlay(actionBtn, true)
end

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOP", 0, -14)
frame.title:SetHeight(24)
frame.title:SetText(L["Mount Route Planner"])

frame.titleButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
frame.titleButton:SetPoint("RIGHT", frame.title, "CENTER", (frame.title:GetWidth() / 2) + 32, 0)
frame.titleButton:SetSize(32, 32)
frame.titleButton:SetNormalTexture("Interface\\common\\help-i")
frame.titleButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
frame.titleButton:SetPushedTexture("Interface\\common\\help-i")
frame.titleButton:Hide()
frame.titleButton:SetScript("OnClick", nil)
frame.titleButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

frame.stepText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
frame.stepText:SetPoint("TOP", frame.title, "BOTTOM", 0, -10)
frame.stepText:SetText("")

frame.stepInfoButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
frame.stepInfoButton:SetPoint("RIGHT", frame.stepText, "CENTER", (frame.stepText:GetWidth() / 2) + 24, 0)
frame.stepInfoButton:SetSize(24, 24)
frame.stepInfoButton:SetNormalTexture("Interface\\common\\help-i")
frame.stepInfoButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
frame.stepInfoButton:SetPushedTexture("Interface\\common\\help-i")
frame.stepInfoButton:Hide()
frame.stepInfoButton:SetScript("OnClick", nil)
frame.stepInfoButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine(L["This step is repeatable*"], 1, 1, 1)
    GameTooltip:AddLine(L["You can run this step as often as you want."], 0.6, 0.6, 0.6)
    GameTooltip:AddLine(L["This step will not advance automatically."], 0.6, 0.6, 0.6)
    GameTooltip:AddLine(format(L["You can use the '%s' button to advance to the next step manually."], nextBtn:GetText()), 0.6, 0.6, 0.6)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["*Normal difficulty dungeons can be run up to 10 times per hour"], 0.6, 0.6, 1)
    GameTooltip:Show()
end)
frame.stepInfoButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

frame.stepPathfindingText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
frame.stepPathfindingText:SetWidth(360)
frame.stepPathfindingText:SetPoint("TOP", frame.stepText, "BOTTOM", 0, 0)
frame.stepPathfindingText:SetText("")

frame.noteText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
frame.noteText:SetSize(360, 54)
frame.noteText:SetPoint("BOTTOM", 0, 80)
frame.noteText:SetText("")
frame.noteText:SetWordWrap(true)

frame.progress = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.progress:SetPoint("BOTTOM", 0, 14)
frame.progress:SetHeight(20)
frame.progress:SetText(L["Step 0 of 0"])

frame.progressBarBG = frame:CreateTexture(nil, "BACKGROUND")
frame.progressBarBG:SetColorTexture(0, 0, 0, 0.5)
frame.progressBarBG:SetSize(200, 20)
frame.progressBarBG:SetPoint("CENTER", frame.progress, "CENTER")

frame.progressBar = frame:CreateTexture(nil, "ARTWORK")
frame.progressBar:SetColorTexture(0.2, 0.8, 0.2, 0.8)
frame.progressBar:SetSize(0, 20)
frame.progressBar:SetPoint("LEFT", frame.progressBarBG, "LEFT", 0, 0)

function UI:IsShown()
    return frame:IsShown()
end

function UI:Toogle()
    if not frame:IsShown() then
        if not C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
            C_AddOns.LoadAddOn("Blizzard_Collections")
        end
        if not C_AddOns.IsAddOnLoaded("Blizzard_EncounterJournal") then
            C_AddOns.LoadAddOn("Blizzard_EncounterJournal")
        end
        autoSkipToggle:SetChecked(MRP_CharacterSettings.autoSkip)
        autoAdvanceToggle:SetChecked(MRP_CharacterSettings.autoAdvance)

        frame:Show()
        self:ShowPathfindingWarnings()
        self:UpdateDisplay()
    else
        frame:Hide()
        MRP.Map:ClearOverlay()
    end
end

local tomtomIds = {}
local hasSuperTrackedUserWaypoint = false
local lastStep

function UI:ShowPathfindingWarnings()
    if not frame:IsShown() then
        return
    end

    local setupIssues = MRP.Core:GetSetupIssues()

    local missingItems = {}
    local helpfulItems = MRP.Farstrider.DATA.GetHelpfulItems()
    if #helpfulItems > 0 then
        for _, itemId in ipairs(helpfulItems) do
            if not C_ToyBox.GetToyInfo(itemId) and not MRP_CharacterSettings.ignoredHelpfulItems[itemId] and not self:CanUseItem(itemId) and C_Item.GetItemCount(itemId) == 0 then
                if C_Item.GetItemCount(itemId, true, true, true, true) > 0 then
                    table.insert(missingItems, itemId)
                end
            end
        end
    end

    local isBindLocationSupported = MRP.Farstrider.DATA.IsBindLocationSupported()

    if #setupIssues > 0 or #missingItems > 0 or not isBindLocationSupported then
        frame.titleButton:Show()
        frame.titleButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")

            if #setupIssues > 0 then
                GameTooltip:AddLine(L["Missing addon packages detected:"], 1, 0.82, 0)
                for _, issue in ipairs(setupIssues) do
                    GameTooltip:AddLine(issue.message, 1, 0.6, 0.6, true)
                end
            end

            if #missingItems > 0 then
                if #setupIssues > 0 then
                    GameTooltip:AddLine(" ")
                end
                GameTooltip:AddLine(L["Missing helpful items from your inventory:"], 1, 1, 1)
                for _, itemId in ipairs(missingItems) do
                    local item = MRP.Util.GetItem(itemId)
                    local name = item:GetItemName()
                    if name then
                        local r, g, b = C_Item.GetItemQualityColor(item:GetItemQuality())
                        GameTooltip:AddLine(format("|T%s:16:16:0:0|t %s", item:GetItemIcon() or "Interface\\Icons\\INV_Misc_QuestionMark", name), r, g, b)
                    end
                end
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L["You can ignore these items in the settings."], 0.5, 1, 0.5)
                GameTooltip:AddLine(L["Pathfinding will not use these items until you have them in your inventory."], 0.6, 0.6, 1)
            end

            if not isBindLocationSupported then
                if #missingItems > 0 then GameTooltip:AddLine(" ") end
                GameTooltip:AddLine(format(L["Hearthstone location '%s' not supported, please report it"], GetBindLocation()), 1, 0.6, 0.6)
            end

            GameTooltip:Show()
        end)
    else
        frame.titleButton:Hide()
    end
end

function UI:UpdateDisplay()
    if not frame:IsShown() then
        MRP.Map:UpdateOverlay()
        return
    end

    local steps = MRP.Filter.filteredSteps
    local idx = MRP_CharacterSettings.currentStep
    local step = steps[idx]

    self:HideCenterAction()

    if TomTom and TomTom["RemoveWaypoint"] then
        for _, id in ipairs(tomtomIds) do
            TomTom:RemoveWaypoint(id)
        end
        tomtomIds = {}
    end

    if hasSuperTrackedUserWaypoint then
        C_Map.ClearUserWaypoint()
        C_SuperTrack.SetSuperTrackedUserWaypoint(false)
        hasSuperTrackedUserWaypoint = false
    end

    if frame.rewardIcons then
        for _, icon in ipairs(frame.rewardIcons) do
            icon:Hide()
            if icon.checkmark then
                icon.checkmark:Hide()
            end
        end
    end
    frame.rewardIcons = {}

    if not step then
        frame.stepText:SetText("")
        frame.stepInfoButton:Hide()
        frame.stepPathfindingText:SetTextColor(1, 0.6, 0.6)
        frame.stepPathfindingText:SetText(MRP.Core:GetNoStepMessage())
        frame.noteText:SetText("")
        frame.progress:SetText(L["Step 0 of 0"])
        frame.progressBar:SetWidth(0)
        MRP.Map:UpdateOverlay()
        return
    end

    local isAlliance = UnitFactionGroup("player") == "Alliance"
    local isHorde = UnitFactionGroup("player") == "Horde"

    local totalIconsForStep = 0
    for _, mount in ipairs(step.mounts) do
        local relevantDifficultyIds = MRP.Core:GetRelevantDifficultyIds(mount)
        if #relevantDifficultyIds > 0 and MRP.Core:IsMountFactionAllowed(mount) then
            totalIconsForStep = totalIconsForStep + 1
        end
    end
    local rows = totalIconsForStep > 0 and (1 + math.floor((totalIconsForStep - 1) / 8)) or 0
    frame.noteText:SetPoint("TOP", frame.stepText, "BOTTOM", 0, -40 - (rows - 1) * 18)

    local index = 1
    for _, mount in ipairs(step.mounts) do
        local relevantDifficultyIds = MRP.Core:GetRelevantDifficultyIds(mount)
        if #relevantDifficultyIds > 0 and MRP.Core:IsMountFactionAllowed(mount) then
            local name, icon, isCollected = MRP.Util.GetMountInfoSafe(mount)

            local defeatedMap = {}
            local allAreDefeated = true
            for _, difficultyId in ipairs(relevantDifficultyIds) do
                local defeated, onLegacyRaidDifficulty = MRP.Core:IsEncounterDefeatedWithLegacyRaidCheck(mount, step.source, difficultyId)
                defeatedMap[difficultyId] = { defeated = defeated, onLegacyRaidDifficulty = onLegacyRaidDifficulty }
                if not defeated then
                    allAreDefeated = false
                end
            end

            local mountBtn = CreateFrame("Button", nil, frame, "InsecureActionButtonTemplate")
            mountBtn:SetSize(32, 32)
            do
                -- local row = math.floor((index - 1) / 8)
                local row = math.min(1, math.floor((index - 1) / 8))
                -- local col = (index - 1) % 8
                local col = index <= 8 and (index - 1) or (index - 9)
                -- local iconsInRow = row % 2 == 0 and math.min(8, totalIconsForStep - row * 8) or math.min(9, totalIconsForStep - row * 8)
                local iconsInRow = row == 0 and math.min(8, totalIconsForStep) or (totalIconsForStep - 8)
                local frameWidth = frame:GetWidth()
                local startX = (frameWidth - (iconsInRow * 36)) / 2
                mountBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", startX + col * 36, -84 - row * 36)
            end
            mountBtn:SetNormalTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            mountBtn:SetHighlightTexture(icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            mountBtn:GetNormalTexture():SetDesaturated(allAreDefeated or isCollected)

            if mount.source.note then
                local noteIcon = mountBtn:CreateTexture(nil, "OVERLAY")
                noteIcon:SetSize(16, 16)
                noteIcon:SetPoint("TOPRIGHT", mountBtn, "TOPRIGHT", 4, 4)
                noteIcon:SetTexture("Interface\\common\\help-i")
            end

            local navMapId = mount.source.uiMapIds and mount.source.uiMapIds[1] or nil
            -- Interior dungeon/raid maps require the Encounter Journal, introduced per-type:
            --   Raid maps: available from Cataclysm (expansion 3+)
            --   Dungeon maps: available from Mists of Pandaria (expansion 4+)
            -- On older Classic clients, fall back to the entrance zone map from MRP.Data.
            local sType = step.source.type
            if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
                local expLevel = GetExpansionLevel()
                local needsFallback = not navMapId
                    or (sType == MRP.FilterSourceType.Raid and expLevel < 3)
                    or (sType == MRP.FilterSourceType.Dungeon and expLevel < 4)
                if needsFallback and (sType == MRP.FilterSourceType.Dungeon or sType == MRP.FilterSourceType.Raid) then
                    local inst = sType == MRP.FilterSourceType.Dungeon and MRP.Data.DUNGEONS[step.source.name] or MRP.Data.RAIDS[step.source.name]
                    if inst then navMapId = inst.mapID end
                end
            elseif not navMapId then
                if sType == MRP.FilterSourceType.Dungeon or sType == MRP.FilterSourceType.Raid then
                    local inst = sType == MRP.FilterSourceType.Dungeon and MRP.Data.DUNGEONS[step.source.name] or MRP.Data.RAIDS[step.source.name]
                    if inst then navMapId = inst.mapID end
                end
            end
            local allowLeftClick = navMapId and C_Map.GetMapInfo(navMapId) ~= nil
            local allowRightClick = (mount.source.journalEncounter and EJ_GetInstanceInfo(mount.source.journalEncounter.instanceId)) ~= nil
                or ((sType == MRP.FilterSourceType.Dungeon or sType == MRP.FilterSourceType.Raid or sType == MRP.FilterSourceType.WorldBoss) and mount.source.uiMapIds[1] and (EJ_GetInstanceForMap(mount.source.uiMapIds[1]) or 0) > 0)
            local allowShiftLeftClick = SetCollectionsJournalShown and MountJournal_SetSelected

            mountBtn:SetScript("OnEnter", function()
                ---@diagnostic disable-next-line: param-type-mismatch
                GameTooltip:SetOwner(mountBtn, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self:GetLocalizedBossName(mount), 1, 1, 1)
                GameTooltip:AddLine(format(L["Mount: %s"], name or mount.name, 0.6, 1, 0.6))
                if isCollected then
                    GameTooltip:AddLine(L["You have collected this mount"], 1, 1, 0.6)
                end
                for _, difficultyId in ipairs(relevantDifficultyIds) do
                    local state = defeatedMap[difficultyId]
                    local sType = step.source.type
                    if difficultyId == -1 or difficultyId == 0 then
                        if sType == MRP.FilterSourceType.Vendor then
                            if state.defeated then
                                GameTooltip:AddLine(L["This vendor has been visited"], 1, 0.6, 0.6)
                            else
                                GameTooltip:AddLine(L["This vendor is available"], 0.6, 1, 0.6)
                            end
                        elseif sType == MRP.FilterSourceType.Quest then
                            if state.defeated then
                                GameTooltip:AddLine(L["This quest is completed"], 1, 0.6, 0.6)
                            else
                                GameTooltip:AddLine(L["This quest is not yet completed"], 0.6, 0.6, 1)
                            end
                        elseif sType == MRP.FilterSourceType.Treasure then
                            if state.defeated then
                                GameTooltip:AddLine(L["This treasure has been looted"], 1, 0.6, 0.6)
                            else
                                GameTooltip:AddLine(L["This treasure has not been looted"], 0.6, 0.6, 1)
                            end
                        else
                            if state.defeated then
                                if state.onLegacyRaidDifficulty then
                                    GameTooltip:AddLine(L["This boss is dead (through legacy lockout)"], 1, 0.6, 1)
                                else
                                    GameTooltip:AddLine(L["This boss is dead"], 1, 0.6, 0.6)
                                end
                            else
                                GameTooltip:AddLine(L["This boss is still alive"], 0.6, 0.6, 1)
                            end
                        end
                    else
                        local difficultyText = GetDifficultyInfo(difficultyId)
                        if sType == MRP.FilterSourceType.Vendor then
                            if state.defeated then
                                GameTooltip:AddLine(format(L["%s: This vendor has been visited"], difficultyText), 1, 0.6, 0.6)
                            else
                                GameTooltip:AddLine(format(L["%s: This vendor is available"], difficultyText), 0.6, 1, 0.6)
                            end
                        elseif sType == MRP.FilterSourceType.Quest then
                            if state.defeated then
                                GameTooltip:AddLine(format(L["%s: This quest is completed"], difficultyText), 1, 0.6, 0.6)
                            else
                                GameTooltip:AddLine(format(L["%s: This quest is not yet completed"], difficultyText), 0.6, 0.6, 1)
                            end
                        elseif sType == MRP.FilterSourceType.Treasure then
                            if state.defeated then
                                GameTooltip:AddLine(format(L["%s: This treasure has been looted"], difficultyText), 1, 0.6, 0.6)
                            else
                                GameTooltip:AddLine(format(L["%s: This treasure has not been looted"], difficultyText), 0.6, 0.6, 1)
                            end
                        else
                            if state.defeated then
                                if state.onLegacyRaidDifficulty then
                                    GameTooltip:AddLine(format(L["%s: This boss is dead (through legacy lockout)"], difficultyText), 1, 0.6, 1)
                                else
                                    GameTooltip:AddLine(format(L["%s: This boss is dead"], difficultyText), 1, 0.6, 0.6)
                                end
                            else
                                GameTooltip:AddLine(format(L["%s: This boss is still alive"], difficultyText), 0.6, 0.6, 1)
                            end
                        end
                    end
                end

                local costs = mount.source.costs or (mount.source.cost and { mount.source.cost }) or nil
                if costs and #costs > 0 then
                    local parts = {}
                    for _, c in ipairs(costs) do
                        local part
                        if c.type == "gold" then
                            part = C_CurrencyInfo.GetCoinTextureString(c.amount)
                        elseif c.type == "currency" and c.currencyId then
                            local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(c.currencyId)
                            if currencyInfo then
                                part = format("%s |T%s:0|t %s", c.amount, currencyInfo.iconFileID, currencyInfo.name)
                            else
                                part = tostring(c.amount)
                            end
                        elseif c.type == "item" and c.itemId then
                            local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(c.itemId)
                            if name and icon then
                                part = format("%s |T%s:0|t %s", c.amount, icon, name)
                            elseif name then
                                part = c.amount .. " " .. name
                            else
                                part = tostring(c.amount)
                            end
                        end
                        if part then
                            parts[#parts + 1] = part
                        end
                    end
                    if #parts > 0 then
                        GameTooltip:AddLine(format(L["Cost: %s"], table.concat(parts, " + ")), 1, 1, 1)
                    end
                end

                if mount.source.questChain and #mount.source.questChain > 0 then
                    local totalSteps = #mount.source.questChain
                    local currentStep = totalSteps + 1
                    local currentQuestName = nil
                    for qi, qStep in ipairs(mount.source.questChain) do
                        if not C_QuestLog.IsQuestFlaggedCompleted(qStep.questID) then
                            currentStep = qi
                            currentQuestName = qStep.name
                            break
                        end
                    end
                    if currentStep > totalSteps then
                        GameTooltip:AddLine(L["Quest chain completed!"], 0.6, 1, 0.6)
                    else
                        GameTooltip:AddLine(format(L["Quest chain: Step %d of %d"], currentStep, totalSteps), 1, 0.82, 0)
                        if currentQuestName then
                            GameTooltip:AddLine(format(L["Current quest: %s"], currentQuestName), 1, 1, 1)
                        end
                    end
                end

                GameTooltip:AddLine(" ")

                if allowLeftClick then
                    GameTooltip:AddLine(L["Left-click to view on Map"], 1, 1, 1)
                end
                if allowRightClick then
                    GameTooltip:AddLine(L["Right-click to view in Encounter Journal"], 1, 1, 1)
                end
                if allowShiftLeftClick then
                    GameTooltip:AddLine(L["Shift + Left-click to view in Mount Journal"], 1, 1, 1)
                end

                local sourceNote = self:GetLocalizedSourceNote(mount)
                if sourceNote then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(L["Note:"], 1, 1, 1)
                    GameTooltip:AddLine(sourceNote, nil, nil, nil, true)
                end

                UI:AddPossibleInCombatWarning()

                GameTooltip:Show()
            end)
            mountBtn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            local callbacks = {}
            if allowLeftClick or allowShiftLeftClick then
                table.insert(callbacks, "LeftButtonUp")
            end
            if allowRightClick then
                table.insert(callbacks, "RightButtonUp")
            end

            if #callbacks > 0 then
                mountBtn:RegisterForClicks(unpack(callbacks))
            end
            mountBtn:SetScript("OnClick", function(self, button)
                if InCombatLockdown() then
                    UIErrorsFrame:OnEvent("UI_ERROR_MESSAGE", 525, ERR_NOT_IN_COMBAT)
                    return
                end

                if button == "LeftButton" and allowLeftClick then
                    if IsModifiedClick("SHIFT") and allowShiftLeftClick then
                        SetCollectionsJournalShown(true, COLLECTIONS_JOURNAL_TAB_INDEX_MOUNTS)
                        MountJournal_SetSelected(mount.id, mount.spellId)
                    else
                        if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
                            OpenWorldMap(navMapId)
                        else
                            WorldMapFrame:SetShown(true)
                            local ok = pcall(WorldMapFrame.SetMapID, WorldMapFrame, navMapId)
                            if not ok then
                                WorldMapFrame:SetShown(false)
                            end
                        end
                    end
                elseif button == "RightButton" and allowRightClick then
                    if mount.source.journalEncounter then
                        EncounterJournal_OpenJournal(relevantDifficultyIds[1], mount.source.journalEncounter.instanceId, mount.source.journalEncounter.id, nil, nil, mount.itemId)
                    else
                        local uiMapId = mount.source.uiMapIds[1]
                        if uiMapId == 319 then
                            uiMapId = 320
                        elseif uiMapId == 814 then
                            uiMapId = 812
                        end

                        EncounterJournal_OpenJournal(relevantDifficultyIds[1], EJ_GetInstanceForMap(uiMapId), nil, nil, nil, mount.itemId)
                    end
                end
            end)

            mountBtn:Show()

            table.insert(frame.rewardIcons, mountBtn)
            index = index + 1
        end
    end

    local isInPvP = MRP.Core:IsInPvp()
    local warningText = nil
    local instance = step.source.type == MRP.FilterSourceType.Dungeon and MRP.Data.DUNGEONS[step.source.name] or step.source.type == MRP.FilterSourceType.Raid and MRP.Data.RAIDS[step.source.name] or nil
    local alreadyInInstance = false
    local isInstanceRelevant = false
    local isRepeatable = false
    if instance then
        local bestDifficulties = MRP.Core:GetMostSuitableDifficultyIds(step)
        isInstanceRelevant = #bestDifficulties > 0
        isRepeatable = #bestDifficulties > 0 and tContains(bestDifficulties, 1)
        if #bestDifficulties > 0 and not tContains(bestDifficulties, GetDungeonDifficultyID()) and not tContains(bestDifficulties, WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and GetLegacyRaidDifficultyID() or GetRaidDifficultyID()) and not tContains(bestDifficulties, GetRaidDifficultyID()) then
            if #bestDifficulties == #instance.availableDifficultyIds then
            elseif #bestDifficulties > 1 then
                warningText = format(L["Run the instance on any of the following difficulties to collect all mounts:\n%s"], table.concat(MRP.Util.Map(bestDifficulties, GetDifficultyInfo), ", "))
                if not isInPvP then
                    self:ShowActionSwitchDifficulty(bestDifficulties[#bestDifficulties])
                end
            else
                warningText = format(L["Run the instance on '%s' to collect all mounts."], GetDifficultyInfo(bestDifficulties[1]))
                if not isInPvP then
                    self:ShowActionSwitchDifficulty(bestDifficulties[1])
                end
            end
        end

        if IsInInstance() then
            local instanceId = select(8, GetInstanceInfo())
            for _, mount in ipairs(step.mounts) do
                if mount.source.mapId == instanceId then
                    alreadyInInstance = true
                    break
                end
            end
        end

        -- Show reset button when we have a repeatable instance, not in PvP, not inside the instance, and no other action is showing
        if isRepeatable and not isInPvP and not alreadyInInstance and not actionBtn:IsShown() then
            self:ShowActionResetInstances()
        end
    end

    frame.noteText:SetText("")
    if warningText then
        frame.noteText:SetText((frame.noteText:GetText() or "") .. "\n\n|cffff0000" .. warningText .. "|r")
    end

    local entry = step.source.type == MRP.FilterSourceType.Dungeon and MRP.Data.DUNGEONS[step.source.name] or step.source.type == MRP.FilterSourceType.Raid and MRP.Data.RAIDS[step.source.name] or step.source.type == MRP.FilterSourceType.WorldBoss and MRP.Data.WORLD_BOSSES[step.source.name] or step.source.type == MRP.FilterSourceType.OpenWorld and MRP.Data.OPEN_WORLD[step.source.name] or step.source.type == MRP.FilterSourceType.Quest and MRP.Data.OPEN_WORLD[step.source.name] or step.source.type == MRP.FilterSourceType.Treasure and MRP.Data.OPEN_WORLD[step.source.name] or step.source.type == MRP.FilterSourceType.Vendor and MRP.Data.OPEN_WORLD[step.source.name] or nil

    -- Faction / condition-gated availability warning
    if entry and entry.condition and not MRP.Core:EvaluateCondition(entry.condition) then
        local condNote = MRP.Core:GetConditionMessage(entry.condition)
        frame.noteText:SetText((frame.noteText:GetText() or "") .. "\n\n|cffff9900" .. condNote .. "|r")
    end

    local stepName = self:GetLocalizedStepName(step)
    frame.stepText:SetText(stepName)
    if isRepeatable then
        frame.stepInfoButton:SetPoint("RIGHT", frame.stepText, "CENTER", (frame.stepText:GetWidth() / 2) + 24, 0)
        frame.stepInfoButton:Show()
    else
        frame.stepInfoButton:Hide()
    end
    frame.stepPathfindingText:SetText("")

    -- For quest chains, override entry coordinates to the current quest step's location
    if entry and step.source.type == MRP.FilterSourceType.Quest then
        local questChain = step.mounts[1] and step.mounts[1].source.questChain
        if questChain and #questChain > 0 then
            for _, qStep in ipairs(questChain) do
                if not C_QuestLog.IsQuestFlaggedCompleted(qStep.questID) then
                    if qStep.x and qStep.y then
                        entry = MRP.Util.ShallowCopy(entry)
                        entry.x = qStep.x
                        entry.y = qStep.y
                        if qStep.mapID then entry.mapID = qStep.mapID end
                    end
                    break
                end
            end
        end
    end

    if isInPvP then
        frame.stepPathfindingText:SetTextColor(1, 0.6, 0.6)
        frame.stepPathfindingText:SetText(L["Pathfinding not available in PvP instances."])
    elseif entry and not alreadyInInstance then
        if entry.instanceId and entry.instanceId == 2070 and isHorde then
            self:UpdateCurrentPathfinding(MRP.Data.RAIDS["Battle of Dazar'alor (H)"])
        elseif entry.instanceId and entry.instanceId == 2217 and MRP.Core:IsEntranceOnMap(MRP.Data.RAIDS["Ny'alotha, the Waking City (VoEB)"].mapID, entry.instanceId) then
            self:UpdateCurrentPathfinding(MRP.Data.RAIDS["Ny'alotha, the Waking City (VoEB)"])
        else
            self:UpdateCurrentPathfinding(entry)
        end
    else
        if alreadyInInstance then
            frame.stepPathfindingText:SetTextColor(1, 1, 1)
            if isInstanceRelevant then
                frame.stepPathfindingText:SetText(L["Run the instance"])
            else
                frame.stepPathfindingText:SetText(L["All bosses are dead or all mounts collected"])
            end
        end
        self:ClearCurrentPathfindingData()
    end

    MRP.Map:SetOpenWorldOverlay(entry, step.source.name, step.mounts)
    MRP.Map:UpdateOverlay()

    if (MRP.Core:CanPossiblyTrashIt()) then -- MRP_REMOVE_LINE
        self:ShowActionTrashIt()            -- MRP_REMOVE_LINE
    end                                     -- MRP_REMOVE_LINE

    frame.progress:SetText(L["Step %d of %d"]:format(idx, #steps))
    frame.progressBar:SetWidth(frame.progressBarBG:GetWidth() * (idx / #steps))

    if step ~= lastStep then
        if lastStep ~= nil then
            local pulse = frame:CreateAnimationGroup()
            local alpha = pulse:CreateAnimation("Alpha")
            alpha:SetFromAlpha(1)
            alpha:SetToAlpha(0.5)
            alpha:SetDuration(0.1)
            alpha:SetOrder(1)

            local back = pulse:CreateAnimation("Alpha")
            back:SetFromAlpha(0.5)
            back:SetToAlpha(1)
            back:SetDuration(0.2)
            back:SetOrder(2)

            pulse:Play()
        end

        lastStep = step
    end
end

function UI:ClearCurrentPathfindingData()
    MRP.Map.pathKey = nil
    MRP.Map.path = nil
    MRP.Map.pathPos = 1
    MRP.Map.pathStep = nil
    MRP.Map:UpdateMinimapPin()
    MRP.Map:UpdateOverlay()
end

function UI:UpdateCurrentPathfinding(entry)
    ---@diagnostic disable-next-line: undefined-global -- MRP_REMOVE_LINE
    if ClearLogs then -- MRP_REMOVE_LINE
        ---@diagnostic disable-next-line: undefined-global -- MRP_REMOVE_LINE
        ClearLogs()   -- MRP_REMOVE_LINE
    end               -- MRP_REMOVE_LINE
    ---@diagnostic disable-next-line: undefined-global
    local optimizedPath = MRP.Farstrider.FindTrailTo(entry.mapID, entry.x / 100, entry.y / 100, 0)

    local newPathKey = nil
    if optimizedPath then
        for i, node in ipairs(optimizedPath) do
            if i == 1 then
                newPathKey = node.id
            else
                newPathKey = newPathKey .. ";" .. node.id
            end
        end
    end

    if MRP.Map.pathKey ~= newPathKey then
        MRP.Map.pathKey = newPathKey
        MRP.Map.path = optimizedPath
        MRP.Map.pathPos = 1
        MRP.Map.pathStep = MRP.Map.path and MRP.Map.pathPos <= #MRP.Map.path and MRP.Map.path[MRP.Map.pathPos] or nil

        if DevTool then                                                                                                                             -- MRP_REMOVE_LINE
            DevTool:AddData({ pathKey = MRP.Map.pathKey, path = MRP.Map.path, pathPos = MRP.Map.pathPos, pathStep = MRP.Map.pathStep }, "MRP_Path") -- MRP_REMOVE_LINE
        end                                                                                                                                         -- MRP_REMOVE_LINE
    end

    if MRP.Map.pathStep then
        self:ShowCurrentPathfindingStep()
    else
        frame.stepPathfindingText:SetTextColor(1, 0.6, 0.6)
        frame.stepPathfindingText:SetText(MRP.Core:GetNoOptimizedPathMessage())
    end
end

---@param mount Mount
---@return string|nil
function UI:GetLocalizedSourceNote(mount)
    if mount.source.note then
        if mount.source.note:find("Reins of the Quantum Courser") then
            return L["SourceNote_QuantumCourser"]
        end
        if mount.id == 250 or mount.id == 253 then
            return L["SourceNote_AllDrakesAlive"]
        end

        local key = "SourceNote_" .. mount.id
        if L[key] ~= key then
            return L[key]
        end
        return mount.source.note
    end

    return nil
end

---@param step Step
---@return string
function UI:GetLocalizedStepName(step)
    for _, mount in ipairs(step.mounts) do
        if mount.source.journalEncounter then
            if step.source.type == MRP.FilterSourceType.WorldBoss then
                local encounterName = EJ_GetEncounterInfo(mount.source.journalEncounter.id)
                if encounterName then
                    return encounterName
                end
            else
                local instanceName = EJ_GetInstanceInfo(mount.source.journalEncounter.instanceId)
                if instanceName then
                    return instanceName
                end
            end
        end

        if (step.source.type == MRP.FilterSourceType.OpenWorld or step.source.type == MRP.FilterSourceType.Quest or step.source.type == MRP.FilterSourceType.Treasure or step.source.type == MRP.FilterSourceType.Vendor) and mount.source.specialEncounter then
            return mount.source.specialEncounter.name
        end

        local uiMapId = mount.source.uiMapIds and #mount.source.uiMapIds > 0 and mount.source.uiMapIds[#mount.source.uiMapIds] or nil
        if uiMapId then
            local instanceId = EJ_GetInstanceForMap(uiMapId)
            if instanceId > 0 then
                return select(1, EJ_GetInstanceInfo(instanceId))
            end
        end
    end

    if step.source.type == MRP.FilterSourceType.Raid then
        local raid = MRP.Data.RAIDS[step.source.name]
        if raid and raid.areaId then
            local areaName = C_Map.GetAreaInfo(raid.areaId)
            if areaName then
                return areaName
            end
        end
    end

    local key = step.source.name
    if not key then
        return L["Unknown Step"]
    end

    return L[key]
end

---@param mount Mount
---@return string
function UI:GetLocalizedBossName(mount)
    if mount.source.journalEncounter then
        local encounterName = EJ_GetEncounterInfo(mount.source.journalEncounter.id)
        if encounterName then
            return encounterName
        end
    end

    local key = mount.source.journalEncounter and mount.source.journalEncounter.name or mount.source.dungeonEncounter and mount.source.dungeonEncounter.name or mount.source.specialEncounter and mount.source.specialEncounter.name
    if not key then
        return L["Unknown Boss"]
    end

    return L[key]
end

function UI:AddTomTomWaypoint(loc, loca, key)
    local uid = TomTom:AddWaypoint(
        loc.mapId,
        loc.pos.x,
        loc.pos.y,
        {
            title = loca,
            source = "Mount Route Planner",
            persistent = false,
            minimap = true,
            world = true,
            silent = true,
        }
    )
    if uid then
        table.insert(tomtomIds, uid)
        if (loc.mapId == 249) then self:AddTomTomWaypoint({ mapId = 1527, pos = loc.pos, isUI = loc.isUI }, loca, key) end
        if (loc.mapId == 390) then self:AddTomTomWaypoint({ mapId = 1530, pos = loc.pos, isUI = loc.isUI }, loca, key) end
    else
        print("|cffffcc00[MRP]|r " .. format(L["Failed to add TomTom waypoint for: '%s', please report it."], key))
    end
end

function UI:AddUserWaypoint(loc, loca, key)
    if GetExpansionLevel() < 8 then
        return
    end

    local coords = loc.pos.z and loc.pos.z > 0 and UiMapPoint.CreateFromCoordinates(loc.mapId, loc.pos.x, loc.pos.y, loc.pos.z) or UiMapPoint.CreateFromCoordinates(loc.mapId, loc.pos.x, loc.pos.y)
    if not coords then
        print("|cffffcc00[MRP]|r " .. format(L["Invalid coordinates for: '%s', please report it."], key))
        return
    end

    if C_Map.CanSetUserWaypointOnMap(loc.mapId) then
        C_Map.SetUserWaypoint(coords)
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
        hasSuperTrackedUserWaypoint = true
    else
        local mapInfo = C_Map.GetMapInfo(loc.mapId)
        while mapInfo and mapInfo.parentMapID and mapInfo.mapType > Enum.UIMapType.Continent do
            mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID)
        end
        if mapInfo and mapInfo.mapID ~= loc.mapId then
            local worldMapId, worldPos = C_Map.GetWorldPosFromMapPos(loc.mapId, CreateVector2D(loc.pos.x, loc.pos.y))
            local parentMapId, parentPos = C_Map.GetMapPosFromWorldPos(worldMapId, worldPos, mapInfo.mapID)
            if parentPos then
                self:AddUserWaypoint({ mapId = parentMapId, pos = { x = parentPos.x, y = parentPos.y, z = loc.pos.z }, isUI = loc.isUI }, loca, key)
            else
                local _, lower = C_Map.GetWorldPosFromMapPos(mapInfo.mapID, CreateVector2D(0, 0))
                local _, upper = C_Map.GetWorldPosFromMapPos(mapInfo.mapID, CreateVector2D(1, 1))

                local minX = math.min(lower.x, upper.x)
                local minY = math.min(lower.y, upper.y)
                local maxX = math.max(lower.x, upper.x)
                local maxY = math.max(lower.y, upper.y)

                local normalizedX = (worldPos.x - minX) / (maxX - minX)
                local normalizedY = (worldPos.y - minY) / (maxY - minY)

                self:AddUserWaypoint({ mapId = mapInfo.mapID, pos = { x = 1 - normalizedY, y = 1 - normalizedX, z = loc.pos.z }, isUI = loc.isUI }, loca, key)
            end
        else
            print("|cffffcc00[MRP]|r " .. format(L["Cannot set waypoint on map: '%s', please report it."], key))
        end
    end
end

---@param spellId number
---@return boolean
function UI:CanUseSpell(spellId)
    if not spellId then return false end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        if InCombatLockdown() then return false end
    end

    if not C_SpellBook.IsSpellInSpellBook(spellId) then return false end

    local chargeInfo = C_Spell.GetSpellCharges(spellId)
    if chargeInfo and chargeInfo.currentCharges > 0 then return true end

    return C_Spell.GetSpellCooldown(spellId).duration <= 0
end

---@param itemId number
---@return boolean
function UI:CanUseItem(itemId)
    if not itemId then return false end
    if not (PlayerHasToy(itemId) or (C_Item.GetItemCount(itemId) > 0 and C_Item.IsUsableItem(itemId))) then return false end

    if C_Item.GetItemCooldown then
        if select(2, C_Item.GetItemCooldown(itemId)) <= 0 then return true end
    elseif C_Container then
        if select(2, C_Container.GetItemCooldown(itemId)) <= 0 then return true end
    end

    local chargeInfo = C_Spell.GetSpellCharges(C_Item.GetItemSpell(itemId))
    if chargeInfo and chargeInfo.currentCharges > 0 then return true end

    return false
end

function UI:ShowCurrentPathfindingStep()
    if not MRP.Map.pathStep then
        return
    end

    local actionOptions = MRP.Map.pathStep.actionOptions or {}
    local loc = MRP.Map.pathStep.loc
    if not MRP.Map.pathStep.loc.isUI then
        local localUIMapId, localMapPos = C_Map.GetMapPosFromWorldPos(MRP.Map.pathStep.loc.mapId, CreateVector2D(MRP.Map.pathStep.loc.pos.x, MRP.Map.pathStep.loc.pos.y))
        loc = { mapId = localUIMapId, pos = { x = localMapPos.x, y = localMapPos.y, z = loc.pos.z }, isUI = true }
    end

    local loca = MRP.Map.pathStep.loca
    local key = string.format("%d:%d:%d:%d", loc.mapId, math.floor(loc.pos.x * (10 ^ 4) + 0.5), math.floor(loc.pos.y * (10 ^ 4) + 0.5), math.floor(loc.pos.z + 0.5))

    if MRP.Map.pathPos == #MRP.Map.path then
        local step = MRP.Filter:GetCurrentStep()
        if step then
            local stepName = self:GetLocalizedStepName(step)
            if step.source.type == MRP.FilterSourceType.WorldBoss then
                loca = format(L["Waypoint_WorldBoss"], stepName)
            elseif step.source.type == MRP.FilterSourceType.OpenWorld then
                local owEntry = MRP.Data.OPEN_WORLD[step.source.name]
                local mechanicKey = owEntry and owEntry.mechanic or "kill"
                loca = format(L["Waypoint_OpenWorld_" .. mechanicKey], stepName)
            elseif step.source.type == MRP.FilterSourceType.Dungeon or step.source.type == MRP.FilterSourceType.Raid then
                loca = format(L["Waypoint_Instance"], stepName)
            end
        end
    end

    local validActionOptions = {}
    for _, actionOption in ipairs(actionOptions) do
        if actionOption.type == "spell" and self:CanUseSpell(actionOption.data) then
            table.insert(validActionOptions, actionOption)
            if not actionOption.allowAny then
                break
            end
        elseif actionOption.type == "item" and self:CanUseItem(actionOption.data) then
            table.insert(validActionOptions, actionOption)
            if not actionOption.allowAny then
                break
            end
        elseif actionOption.type == "housing" then
            table.insert(validActionOptions, actionOption)
            break
        elseif actionOption.type == "housing_return" then
            table.insert(validActionOptions, actionOption)
            break
        end
    end

    local gotAction = false
    if #validActionOptions > 0 then
        local randomActionOption = validActionOptions[math.random(#validActionOptions)]
        if randomActionOption.type == "spell" then
            self:ShowActionUseSpell(randomActionOption.data)
            gotAction = true
        elseif randomActionOption.type == "item" then
            self:ShowActionUseItem(randomActionOption.data)
            gotAction = true
        elseif randomActionOption.type == "housing" then
            gotAction = self:ShowActionHousingTeleport() or false
        elseif randomActionOption.type == "housing_return" then
            self:ShowActionHousingReturn()
            gotAction = true
        end
    end

    if IsInInstance() and not gotAction then
        loca = L["Leave your current instance"]
    end

    frame.stepPathfindingText:SetTextColor(1, 1, 1)
    frame.stepPathfindingText:SetText(loca)

    if MRP_Settings.useTomTom and TomTom and TomTom.AddWaypoint then
        self:AddTomTomWaypoint(loc, loca, key)

        -- Add extra TomTom waypoints for open world route/spawn points
        if MRP.Map.pathPos == #MRP.Map.path then
            local step = MRP.Filter:GetCurrentStep()
            if step and step.source.type == MRP.FilterSourceType.OpenWorld then
                local owEntry = MRP.Data.OPEN_WORLD[step.source.name]
                if owEntry and owEntry.waypoints then
                    for _, wp in ipairs(owEntry.waypoints) do
                        local wpMapId = wp.mapID or owEntry.mapID
                        self:AddTomTomWaypoint(
                            { mapId = wpMapId, pos = { x = wp.x / 100, y = wp.y / 100, z = 0 }, isUI = true },
                            loca,
                            key .. "-route"
                        )
                    end
                end
            end
        end
    else
        self:AddUserWaypoint(loc, loca, key)
    end

    MRP.Map:UpdateMinimapPin()
    MRP.Map:UpdateOverlay()
end

function UI:CheckCurrentPathfindingStep()
    if MRP.Map.pathStep and MRP.Map.pathStep.checkDistance and not IsInInstance() then
        local playerUiMapId = C_Map.GetBestMapForUnit("player")
        if playerUiMapId then
            local playerPos = C_Map.GetPlayerMapPosition(playerUiMapId, "player")
            if playerPos and playerPos.x and playerPos.y then
                local completionLoc = MRP.Map.pathStep.completionLoc or MRP.Map.pathStep.loc
                local _, worldA = C_Map.GetWorldPosFromMapPos(playerUiMapId, playerPos)
                local _, worldB
                if completionLoc.isUI then
                    _, worldB = C_Map.GetWorldPosFromMapPos(completionLoc.mapId, CreateVector2D(completionLoc.pos.x, completionLoc.pos.y))
                else
                    worldB = CreateVector2D(completionLoc.pos.x, completionLoc.pos.y)
                end
                if worldA and worldB then
                    local distance = math.sqrt((worldA.x - worldB.x) ^ 2 + (worldA.y - worldB.y) ^ 2)
                    if distance < 15 then
                        MRP.Map.pathPos = MRP.Map.pathPos + 1
                        MRP.Map.pathStep = MRP.Map.path and MRP.Map.pathPos <= #MRP.Map.path and MRP.Map.path[MRP.Map.pathPos] or nil
                        self:ShowCurrentPathfindingStep()
                        MRP.Map:UpdateOverlay()
                    end
                end
            end
        end
    end
end

local warningFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
warningFrame:SetSize(500, 100)
warningFrame:SetPoint("TOP", UIParent, "TOP", 0, -150)
warningFrame:SetFrameStrata("HIGH")
warningFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
warningFrame:SetBackdropColor(0.8, 0, 0, 0.9)
warningFrame:Hide()

warningFrame.title = warningFrame:CreateFontString(nil, "OVERLAY", "Game27Font")
warningFrame.title:SetSize(480, 50)
warningFrame.title:SetPoint("TOP", warningFrame, "TOP", 0, -5)
warningFrame.title:SetTextColor(1, 0.82, 0)
warningFrame.title:SetText(L["Wrong Difficulty"])

warningFrame.subText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
warningFrame.subText:SetSize(440, 50)
warningFrame.subText:SetWordWrap(true)
warningFrame.subText:SetPoint("BOTTOM", warningFrame, "BOTTOM", 0, 10)
warningFrame.subText:SetTextColor(1, 1, 1)
warningFrame.subText:SetText(L["Please switch to '%s' as not all mounts are collectable on this difficulty."])

function UI:ShowDifficultyWarning(difficultyIds)
    warningFrame.title:SetPoint("TOP", warningFrame, "TOP", 0, #difficultyIds > 1 and 0 or -5)
    if #difficultyIds > 1 then
        warningFrame.subText:SetText(string.format(L["Please switch to any of the following difficulties as not all mounts are collectable on this difficulty:\n%s"], table.concat(MRP.Util.Map(difficultyIds, GetDifficultyInfo), ", ")))
    else
        warningFrame.subText:SetText(string.format(L["Please switch to '%s' as not all mounts are collectable on this difficulty."], GetDifficultyInfo(difficultyIds[1])))
    end
    warningFrame:Show()
end

function UI:HideDifficultyWarning()
    warningFrame:Hide()
end
