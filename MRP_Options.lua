-- MRP_Options.lua
-- local _, MRP = ...

local L = MRP.L

local Options = {}
MRP.Options = Options

local optionsFrame = CreateFrame("Frame", nil, UIParent)
optionsFrame.name = L["Mount Route Planner"]

local optionsTitle = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
optionsTitle:SetPoint("TOPLEFT", 16, -16)
optionsTitle:SetText(L["Mount Route Planner - Settings"])

local alertFrame = CreateFrame("Frame", nil, UIParent)

local alertTitle = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
alertTitle:SetPoint("TOPLEFT", 16, -16)
alertTitle:SetText(L["Alert"] .. " |cFFFF8800[Experimental]|r")

local alertDisclaimer = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
alertDisclaimer:SetPoint("TOPLEFT", alertTitle, "BOTTOMLEFT", 0, -4)
alertDisclaimer:SetText(L["Alert Experimental Disclaimer"])
alertDisclaimer:SetJustifyH("LEFT")
alertDisclaimer:SetWidth(500)

local helpfulItemsFrame = CreateFrame("Frame", nil, UIParent)

local helpfulItemsCategoryTitle = helpfulItemsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
helpfulItemsCategoryTitle:SetPoint("TOPLEFT", 16, -16)
helpfulItemsCategoryTitle:SetText(L["Helpful Items"])

local helpfulItemsCategorySubtitle = helpfulItemsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
helpfulItemsCategorySubtitle:SetPoint("TOPLEFT", helpfulItemsCategoryTitle, "BOTTOMLEFT", 0, -12)
helpfulItemsCategorySubtitle:SetText(L["Ignored Helpful Items (Owned items only)"])

local tomtomToggle = CreateFrame("CheckButton", nil, optionsFrame, "InterfaceOptionsCheckButtonTemplate")
tomtomToggle:SetPoint("TOPLEFT", optionsTitle, "BOTTOMLEFT", 0, -12)
tomtomToggle.Text:SetText(L["Use TomTom for waypoints"])

tomtomToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Use TomTom for waypoints"], 1, 1, 1)
    GameTooltip:AddLine(L["Enable this to use TomTom for waypoint navigation."], 1, 1, 1)
    GameTooltip:AddLine(L["This will create waypoints for each step in your route."], 1, 1, 1)
    GameTooltip:AddLine(L["You must have TomTom installed for this to work."], 1, 0.5, 0.5)
    GameTooltip:AddLine(L["You can toggle this setting at any time."], 0.5, 1, 0.5)
    GameTooltip:Show()
end)

tomtomToggle:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

tomtomToggle:SetScript("OnClick", function(self)
    MRP_Settings.useTomTom = self:GetChecked()
    MRP.UI:UpdateDisplay()
end)

local showDifficultyWarningToggle = CreateFrame("CheckButton", nil, optionsFrame, "InterfaceOptionsCheckButtonTemplate")
showDifficultyWarningToggle:SetPoint("TOPLEFT", tomtomToggle, "BOTTOMLEFT", 0, -12)
showDifficultyWarningToggle.Text:SetText(L["Show Difficulty Warning"])

showDifficultyWarningToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Show Difficulty Warning"], 1, 1, 1)
    GameTooltip:AddLine(L["Enable this to show a difficulty warning if the current difficulty is not suitable for the current step while within a dungeon or raid."], 1, 1, 1)
    GameTooltip:Show()
end)

showDifficultyWarningToggle:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

showDifficultyWarningToggle:SetScript("OnClick", function(self)
    MRP_Settings.showDifficultyWarning = self:GetChecked()
    MRP.UI:UpdateDisplay()
end)

local ignoreLFRDifficultyToggle = CreateFrame("CheckButton", nil, optionsFrame, "InterfaceOptionsCheckButtonTemplate")
ignoreLFRDifficultyToggle:SetPoint("TOPLEFT", showDifficultyWarningToggle, "BOTTOMLEFT", 0, -12)
ignoreLFRDifficultyToggle.Text:SetText(L["Ignore LFR Difficulty"])

ignoreLFRDifficultyToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Ignore LFR Difficulty"], 1, 1, 1)
    GameTooltip:AddLine(L["Enable this to ignore LFR difficulty on all steps."], 1, 1, 1)
    GameTooltip:Show()
end)

ignoreLFRDifficultyToggle:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

ignoreLFRDifficultyToggle:SetScript("OnClick", function(self)
    MRP_Settings.ignoreLFRDifficulty = self:GetChecked()
    for _, step in ipairs(MRP.Data.STEPS) do
        for _, mount in ipairs(step.mounts) do
            mount.source.relevantDifficultyIds = nil
        end
    end
    MRP.UI:UpdateDisplay()
end)

local showRareAlertToggle = CreateFrame("CheckButton", nil, alertFrame, "InterfaceOptionsCheckButtonTemplate")
showRareAlertToggle:SetPoint("TOPLEFT", alertDisclaimer, "BOTTOMLEFT", 0, -8)
showRareAlertToggle.Text:SetText(L["Show Rare Alert"])

showRareAlertToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Show Rare Alert"], 1, 1, 1)
    GameTooltip:AddLine(L["Show an alert when a relevant mount source is detected nearby, including vendors."], 1, 1, 1)
    GameTooltip:AddLine(L["Includes a button to target the creature."], 0.5, 1, 0.5)
    GameTooltip:AddLine(L["You can drag the popup to move it."], 0.5, 1, 0.5)
    GameTooltip:Show()
end)

showRareAlertToggle:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

showRareAlertToggle:SetScript("OnClick", function(self)
    MRP_Settings.showRareAlert = self:GetChecked()
    if MRP.Alert then
        if MRP_Settings.showRareAlert then
            MRP.Alert:Enable()
        else
            MRP.Alert:Disable()
        end
    end
end)

local resetRareAlertPositionBtn = CreateFrame("Button", nil, alertFrame, "UIPanelButtonTemplate")
resetRareAlertPositionBtn:SetSize(180, 24)
resetRareAlertPositionBtn:SetPoint("TOPLEFT", showRareAlertToggle, "BOTTOMLEFT", 4, -10)
resetRareAlertPositionBtn:SetText(L["Reset Alert Popup Position"])

resetRareAlertPositionBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Reset Alert Popup Position"], 1, 1, 1)
    GameTooltip:AddLine(L["Resets the nearby alert popup to its default position at the top of the screen."], 1, 1, 1)
    GameTooltip:AddLine(L["You can drag the popup itself whenever it is visible."], 0.5, 1, 0.5)
    GameTooltip:Show()
end)

resetRareAlertPositionBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

resetRareAlertPositionBtn:SetScript("OnClick", function()
    if MRP.Alert and MRP.Alert.ResetPosition then
        MRP.Alert:ResetPosition()
    end
end)

local recalculateRouteBtn = CreateFrame("Button", nil, optionsFrame, "UIPanelButtonTemplate")
recalculateRouteBtn:SetSize(160, 24)
recalculateRouteBtn:SetPoint("TOPLEFT", ignoreLFRDifficultyToggle, "BOTTOMLEFT", 0, -16)
recalculateRouteBtn:SetText(L["Recalculate Route"])

recalculateRouteBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Recalculate Route"], 1, 1, 1)
    GameTooltip:AddLine(L["Recalculates the optimized route based on your current location."], 1, 1, 1)
    GameTooltip:Show()
end)

recalculateRouteBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

recalculateRouteBtn:SetScript("OnClick", function()
    MRP.Route:Calculate()
    print(L["|cff00ff00[MRP]|r Route recalculated."])
end)

local cachedHelpfulItems = {}
local ignoredHelpfulItemScrollFrame = nil
local ignoredHelpfulItemToggles = {}

function Options:InitializeIgnoredHelpfulItems()
    local helpfulItems = MRP.Farstrider.DATA.GetHelpfulItems()

    if helpfulItems ~= cachedHelpfulItems then
        cachedHelpfulItems = helpfulItems

        if ignoredHelpfulItemScrollFrame then
            ignoredHelpfulItemScrollFrame:Hide()
            ignoredHelpfulItemScrollFrame:SetParent(nil)
            ignoredHelpfulItemScrollFrame = nil
        end

        ignoredHelpfulItemToggles = {}
    end

    if #helpfulItems == 0 then
        return
    end

    ignoredHelpfulItemScrollFrame = CreateFrame("ScrollFrame", nil, helpfulItemsFrame, "UIPanelScrollFrameTemplate")
    ignoredHelpfulItemScrollFrame:SetPoint("TOPLEFT", helpfulItemsCategorySubtitle, "BOTTOMLEFT", 4, -8)
    ignoredHelpfulItemScrollFrame:SetSize(420, 460)
    ignoredHelpfulItemScrollFrame.scrollBarHideable = true
    ignoredHelpfulItemScrollFrame.ScrollBar:Hide();

    local content = CreateFrame("Frame", nil, ignoredHelpfulItemScrollFrame)
    content:SetSize(400, 1)

    ignoredHelpfulItemScrollFrame:SetScrollChild(content)

    local itemCount = 1
    local lastFrame

    local CHECKBOX_WIDTH = 24
    local ICON_SIZE = 28
    local ITEM_HEIGHT = 32

    for _, itemId in ipairs(helpfulItems) do
        if not C_ToyBox.GetToyInfo(itemId) and C_Item.GetItemCount(itemId, true, true, true, true) > 0 then
            local item = MRP.Util.GetItem(itemId)
            local itemName = item:GetItemName()
            local itemIcon = item:GetItemIcon()

            local itemFrame = CreateFrame("Frame", nil, content)
            itemFrame:SetSize(380, ITEM_HEIGHT)
            if itemCount == 1 then
                itemFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -8)
            else
                itemFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -4)
            end

            local ignoreToggle = CreateFrame("CheckButton", nil, itemFrame, "InterfaceOptionsCheckButtonTemplate")
            ignoreToggle:SetSize(CHECKBOX_WIDTH, CHECKBOX_WIDTH)
            ignoreToggle:SetPoint("RIGHT", itemFrame, "RIGHT", -4, 0)
            ignoreToggle.Text:SetText(L["Ignore"])
            ignoreToggle.Text:ClearAllPoints()
            ignoreToggle.Text:SetPoint("LEFT", ignoreToggle, "RIGHT", 2, 0)
            ignoreToggle:SetChecked(MRP_CharacterSettings.ignoredHelpfulItems[itemId])
            ignoredHelpfulItemToggles[itemId] = ignoreToggle

            ignoreToggle:SetScript("OnClick", function(self)
                MRP_CharacterSettings.ignoredHelpfulItems[itemId] = self:GetChecked()
                MRP.UI:ShowPathfindingWarnings()
            end)

            local icon = itemFrame:CreateTexture(nil, "ARTWORK")
            icon:SetSize(ICON_SIZE, ICON_SIZE)
            icon:SetPoint("LEFT", itemFrame, "LEFT", 0, 0)
            icon:SetTexture(itemIcon or "Interface\\Icons\\INV_Misc_QuestionMark")

            local name = itemFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
            name:SetPoint("RIGHT", ignoreToggle, "LEFT", -8, 0)
            name:SetText(itemName or ("Item " .. itemId))
            name:SetJustifyH("LEFT")

            item:ContinueOnItemLoad(function()
                icon:SetTexture(item:GetItemIcon())
                name:SetText(item:GetItemName())
            end)

            itemFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if InCombatLockdown() then
                    GameTooltip:SetHyperlink("item:" .. itemId)
                else
                    GameTooltip:SetItemByID(itemId)
                end
                GameTooltip:Show()
            end)
            itemFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            lastFrame = itemFrame
            itemCount = itemCount + 1
        end
    end

    if lastFrame then
        content:SetHeight((itemCount - 1) * (ITEM_HEIGHT + 4) + 16)
    else
        content:SetHeight(ITEM_HEIGHT)
    end
end

-- World Map subcategory
local worldMapFrame = CreateFrame("Frame", nil, UIParent)
local worldMapInitialized = false

local worldMapTitle = worldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
worldMapTitle:SetPoint("TOPLEFT", 16, -16)
worldMapTitle:SetText(L["World Map"] .. " |cFFFF8800[Experimental]|r")

local worldMapDisclaimer = worldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
worldMapDisclaimer:SetPoint("TOPLEFT", worldMapTitle, "BOTTOMLEFT", 0, -4)
worldMapDisclaimer:SetText(L["World Map Experimental Disclaimer"])
worldMapDisclaimer:SetJustifyH("LEFT")
worldMapDisclaimer:SetWidth(500)

local showRouteOnMapToggle = CreateFrame("CheckButton", nil, worldMapFrame, "InterfaceOptionsCheckButtonTemplate")
showRouteOnMapToggle:SetPoint("TOPLEFT", worldMapDisclaimer, "BOTTOMLEFT", 0, -8)
showRouteOnMapToggle.Text:SetText(L["Show Route on World Map"])

showRouteOnMapToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Show Route on World Map"], 1, 1, 1)
    GameTooltip:AddLine(L["Display numbered route step markers on the world map."], 1, 1, 1)
    GameTooltip:Show()
end)

showRouteOnMapToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)

showRouteOnMapToggle:SetScript("OnClick", function(self)
    MRP_Settings.showRouteOnMap = self:GetChecked()
    MRP.Map:UpdateOverlay()
end)

local showRouteConnectionsOnMapToggle = CreateFrame("CheckButton", nil, worldMapFrame, "InterfaceOptionsCheckButtonTemplate")
showRouteConnectionsOnMapToggle:SetPoint("TOPLEFT", showRouteOnMapToggle, "BOTTOMLEFT", 0, -8)
showRouteConnectionsOnMapToggle.Text:SetText(L["Show Step Connections on World Map"])

showRouteConnectionsOnMapToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Show Step Connections on World Map"], 1, 1, 1)
    GameTooltip:AddLine(L["Display the yellow and grey connection lines between visible route step pins on the world map."], 1, 1, 1)
    GameTooltip:Show()
end)

showRouteConnectionsOnMapToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)

showRouteConnectionsOnMapToggle:SetScript("OnClick", function(self)
    MRP_Settings.showRouteConnectionsOnMap = self:GetChecked()
    MRP.Map:UpdateOverlay()
end)

local showPathfindingLinesOnMapToggle = CreateFrame("CheckButton", nil, worldMapFrame, "InterfaceOptionsCheckButtonTemplate")
showPathfindingLinesOnMapToggle:SetPoint("TOPLEFT", showRouteConnectionsOnMapToggle, "BOTTOMLEFT", 0, -8)
showPathfindingLinesOnMapToggle.Text:SetText(L["Show Pathfinding Lines on World Map"])

showPathfindingLinesOnMapToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Show Pathfinding Lines on World Map"], 1, 1, 1)
    GameTooltip:AddLine(L["Display the blue pathfinding guide line and arrow toward the current navigation target on local world map views."], 1, 1, 1)
    GameTooltip:Show()
end)

showPathfindingLinesOnMapToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)

showPathfindingLinesOnMapToggle:SetScript("OnClick", function(self)
    MRP_Settings.showPathfindingLinesOnMap = self:GetChecked()
    MRP.Map:UpdateOverlay()
end)

local showOpenWorldOverlayOnMapToggle = CreateFrame("CheckButton", nil, worldMapFrame, "InterfaceOptionsCheckButtonTemplate")
showOpenWorldOverlayOnMapToggle:SetPoint("TOPLEFT", showPathfindingLinesOnMapToggle, "BOTTOMLEFT", 0, -8)
showOpenWorldOverlayOnMapToggle.Text:SetText(L["Show Open World Overlay on World Map"])

showOpenWorldOverlayOnMapToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Show Open World Overlay on World Map"], 1, 1, 1)
    GameTooltip:AddLine(L["Display spawn points, patrol routes, and source markers for the current open-world step on the world map."], 1, 1, 1)
    GameTooltip:Show()
end)

showOpenWorldOverlayOnMapToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)

showOpenWorldOverlayOnMapToggle:SetScript("OnClick", function(self)
    MRP_Settings.showOpenWorldOverlayOnMap = self:GetChecked()
    MRP.Map:UpdateOverlay()
end)

-- Max Steps Ahead
local maxStepsAheadLabel = worldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
maxStepsAheadLabel:SetPoint("TOPLEFT", showOpenWorldOverlayOnMapToggle, "BOTTOMLEFT", 4, -16)
maxStepsAheadLabel:SetText(L["Max Steps Ahead"])

local maxStepsAheadSlider = CreateFrame("Slider", nil, worldMapFrame, "OptionsSliderTemplate")
maxStepsAheadSlider:SetPoint("TOPLEFT", maxStepsAheadLabel, "BOTTOMLEFT", 0, -6)
maxStepsAheadSlider:SetMinMaxValues(0, 50)
maxStepsAheadSlider:SetValueStep(1)
maxStepsAheadSlider:SetObeyStepOnDrag(true)
maxStepsAheadSlider:SetWidth(200)
maxStepsAheadSlider.Low:SetText("0")
maxStepsAheadSlider.High:SetText("50")

local maxStepsAheadValue = worldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
maxStepsAheadValue:SetPoint("LEFT", maxStepsAheadSlider, "RIGHT", 8, 0)

local unlimitedAheadToggle = CreateFrame("CheckButton", nil, worldMapFrame, "InterfaceOptionsCheckButtonTemplate")
unlimitedAheadToggle:SetPoint("TOPLEFT", maxStepsAheadSlider, "BOTTOMLEFT", -4, -4)
unlimitedAheadToggle.Text:SetText(L["Unlimited"])

local function UpdateAheadState()
    local unlimited = MRP_Settings.unlimitedStepsAhead
    if unlimited then
        maxStepsAheadSlider:SetAlpha(0.4)
        maxStepsAheadSlider:EnableMouse(false)
        maxStepsAheadValue:SetText(L["Unlimited"])
    else
        maxStepsAheadSlider:SetAlpha(1)
        maxStepsAheadSlider:EnableMouse(true)
        maxStepsAheadValue:SetText(tostring(MRP_Settings.maxStepsAhead or 5))
    end
end

maxStepsAheadSlider:SetScript("OnValueChanged", function(self, value)
    if not worldMapInitialized then return end
    value = math.floor(value + 0.5)
    MRP_Settings.maxStepsAhead = value
    if not MRP_Settings.unlimitedStepsAhead then
        maxStepsAheadValue:SetText(tostring(value))
    end
    MRP.Map:UpdateOverlay()
end)

maxStepsAheadSlider:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Max Steps Ahead"], 1, 1, 1)
    GameTooltip:AddLine(L["Maximum number of steps ahead of the current step to show on the world map."], 1, 1, 1)
    GameTooltip:Show()
end)

maxStepsAheadSlider:SetScript("OnLeave", function() GameTooltip:Hide() end)

unlimitedAheadToggle:SetScript("OnClick", function(self)
    MRP_Settings.unlimitedStepsAhead = self:GetChecked()
    UpdateAheadState()
    MRP.Map:UpdateOverlay()
end)

unlimitedAheadToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Unlimited"], 1, 1, 1)
    GameTooltip:AddLine(L["Show all steps ahead of the current step on the world map."], 1, 1, 1)
    GameTooltip:Show()
end)

unlimitedAheadToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Max Steps Behind
local maxStepsBehindLabel = worldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
maxStepsBehindLabel:SetPoint("TOPLEFT", unlimitedAheadToggle, "BOTTOMLEFT", 4, -16)
maxStepsBehindLabel:SetText(L["Max Steps Behind"])

local maxStepsBehindSlider = CreateFrame("Slider", nil, worldMapFrame, "OptionsSliderTemplate")
maxStepsBehindSlider:SetPoint("TOPLEFT", maxStepsBehindLabel, "BOTTOMLEFT", 0, -6)
maxStepsBehindSlider:SetMinMaxValues(0, 50)
maxStepsBehindSlider:SetValueStep(1)
maxStepsBehindSlider:SetObeyStepOnDrag(true)
maxStepsBehindSlider:SetWidth(200)
maxStepsBehindSlider.Low:SetText("0")
maxStepsBehindSlider.High:SetText("50")

local maxStepsBehindValue = worldMapFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
maxStepsBehindValue:SetPoint("LEFT", maxStepsBehindSlider, "RIGHT", 8, 0)

local unlimitedBehindToggle = CreateFrame("CheckButton", nil, worldMapFrame, "InterfaceOptionsCheckButtonTemplate")
unlimitedBehindToggle:SetPoint("TOPLEFT", maxStepsBehindSlider, "BOTTOMLEFT", -4, -4)
unlimitedBehindToggle.Text:SetText(L["Unlimited"])

local function UpdateBehindState()
    local unlimited = MRP_Settings.unlimitedStepsBehind
    if unlimited then
        maxStepsBehindSlider:SetAlpha(0.4)
        maxStepsBehindSlider:EnableMouse(false)
        maxStepsBehindValue:SetText(L["Unlimited"])
    else
        maxStepsBehindSlider:SetAlpha(1)
        maxStepsBehindSlider:EnableMouse(true)
        maxStepsBehindValue:SetText(tostring(MRP_Settings.maxStepsBehind or 0))
    end
end

maxStepsBehindSlider:SetScript("OnValueChanged", function(self, value)
    if not worldMapInitialized then return end
    value = math.floor(value + 0.5)
    MRP_Settings.maxStepsBehind = value
    if not MRP_Settings.unlimitedStepsBehind then
        maxStepsBehindValue:SetText(tostring(value))
    end
    MRP.Map:UpdateOverlay()
end)

maxStepsBehindSlider:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Max Steps Behind"], 1, 1, 1)
    GameTooltip:AddLine(L["Maximum number of steps behind the current step to show on the world map."], 1, 1, 1)
    GameTooltip:Show()
end)

maxStepsBehindSlider:SetScript("OnLeave", function() GameTooltip:Hide() end)

unlimitedBehindToggle:SetScript("OnClick", function(self)
    MRP_Settings.unlimitedStepsBehind = self:GetChecked()
    UpdateBehindState()
    MRP.Map:UpdateOverlay()
end)

unlimitedBehindToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Unlimited"], 1, 1, 1)
    GameTooltip:AddLine(L["Show all steps behind the current step on the world map."], 1, 1, 1)
    GameTooltip:Show()
end)

unlimitedBehindToggle:SetScript("OnLeave", function() GameTooltip:Hide() end)

worldMapFrame:SetScript("OnShow", function()
    showRouteOnMapToggle:SetChecked(MRP_Settings.showRouteOnMap ~= false)
    showRouteConnectionsOnMapToggle:SetChecked(MRP_Settings.showRouteConnectionsOnMap ~= false)
    showPathfindingLinesOnMapToggle:SetChecked(MRP_Settings.showPathfindingLinesOnMap ~= false)
    showOpenWorldOverlayOnMapToggle:SetChecked(MRP_Settings.showOpenWorldOverlayOnMap ~= false)
    maxStepsAheadSlider:SetValue(MRP_Settings.maxStepsAhead or 5)
    unlimitedAheadToggle:SetChecked(MRP_Settings.unlimitedStepsAhead)
    maxStepsBehindSlider:SetValue(MRP_Settings.maxStepsBehind or 0)
    unlimitedBehindToggle:SetChecked(MRP_Settings.unlimitedStepsBehind)
    worldMapInitialized = true
    UpdateAheadState()
    UpdateBehindState()
end)

alertFrame:SetScript("OnShow", function()
    showRareAlertToggle:SetChecked(MRP_Settings.showRareAlert)
end)

helpfulItemsFrame:SetScript("OnShow", function()
    Options:InitializeIgnoredHelpfulItems()
    for itemId, toggle in pairs(ignoredHelpfulItemToggles) do
        toggle:SetChecked(MRP_CharacterSettings.ignoredHelpfulItems[itemId])
    end
end)

local settingsCategory = Settings.RegisterCanvasLayoutCategory(optionsFrame, "Mount Route Planner")
local alertCategory = Settings.RegisterCanvasLayoutSubcategory(settingsCategory, alertFrame, L["Alert"] .. " |cFFFF8800[Experimental]|r")
local helpfulItemsCategory = Settings.RegisterCanvasLayoutSubcategory(settingsCategory, helpfulItemsFrame, L["Helpful Items"])
local worldMapCategory = Settings.RegisterCanvasLayoutSubcategory(settingsCategory, worldMapFrame, L["World Map"] .. " |cFFFF8800[Experimental]|r")
Settings.RegisterAddOnCategory(settingsCategory)

function Options:Show()
    tomtomToggle:SetChecked(MRP_Settings.useTomTom)
    showDifficultyWarningToggle:SetChecked(MRP_Settings.showDifficultyWarning)
    ignoreLFRDifficultyToggle:SetChecked(MRP_Settings.ignoreLFRDifficulty)
    showRareAlertToggle:SetChecked(MRP_Settings.showRareAlert)
    showRouteOnMapToggle:SetChecked(MRP_Settings.showRouteOnMap ~= false)
    showRouteConnectionsOnMapToggle:SetChecked(MRP_Settings.showRouteConnectionsOnMap ~= false)
    showPathfindingLinesOnMapToggle:SetChecked(MRP_Settings.showPathfindingLinesOnMap ~= false)
    showOpenWorldOverlayOnMapToggle:SetChecked(MRP_Settings.showOpenWorldOverlayOnMap ~= false)
    worldMapInitialized = true
    maxStepsAheadSlider:SetValue(MRP_Settings.maxStepsAhead or 5)
    unlimitedAheadToggle:SetChecked(MRP_Settings.unlimitedStepsAhead)
    UpdateAheadState()
    maxStepsBehindSlider:SetValue(MRP_Settings.maxStepsBehind or 0)
    unlimitedBehindToggle:SetChecked(MRP_Settings.unlimitedStepsBehind)
    UpdateBehindState()
    for itemId, toggle in pairs(ignoredHelpfulItemToggles) do
        toggle:SetChecked(MRP_CharacterSettings.ignoredHelpfulItems[itemId])
    end

    Settings.OpenToCategory(settingsCategory:GetID())
end

MRP.Frames.Settings = {
    MainFrame = optionsFrame,
    AlertFrame = alertFrame,
    HelpfulItemsFrame = helpfulItemsFrame,
    WorldMapFrame = worldMapFrame,
}
