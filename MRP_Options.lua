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

local tomtomToggle = CreateFrame("CheckButton", nil, optionsFrame, "InterfaceOptionsCheckButtonTemplate")
tomtomToggle:SetPoint("TOPLEFT", optionsTitle, "BOTTOMLEFT", 0, -12)
tomtomToggle.Text:SetText(L["Use TomTom for waypoints"])

tomtomToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Use TomTom for waypoints"])
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
    GameTooltip:SetText(L["Show Difficulty Warning"])
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
    GameTooltip:SetText(L["Ignore LFR Difficulty"])
    GameTooltip:AddLine(L["Enable this to ignore LFR difficulty on all steps."], 1, 1, 1)
    GameTooltip:Show()
end)

ignoreLFRDifficultyToggle:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

ignoreLFRDifficultyToggle:SetScript("OnClick", function(self)
    MRP_Settings.ignoreLFRDifficulty = self:GetChecked()
    for _, step in ipairs(MRP.Steps) do
        for _, mount in ipairs(step.mounts) do
            mount.source.relevantDifficultyIds = nil
        end
    end
    MRP.UI:UpdateDisplay()
end)

local ignoredHelpfulItemsInitialized = false
local ignoredHelpfulItemToggles = {}

function Options:InitializeIgnoredHelpfulItems()
    if ignoredHelpfulItemsInitialized then
        return
    end

    local ignoredHelpfulItemsTitle = optionsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    ignoredHelpfulItemsTitle:SetPoint("TOPLEFT", ignoreLFRDifficultyToggle, "BOTTOMLEFT", 0, -12)
    ignoredHelpfulItemsTitle:SetText(L["Ignored Helpful Items (Owned items only)"])

    local scrollFrame = CreateFrame("ScrollFrame", nil, optionsFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", ignoredHelpfulItemsTitle, "BOTTOMLEFT", 4, -4)
    scrollFrame:SetSize(340, 220)
    scrollFrame.scrollBarHideable = true
    scrollFrame.ScrollBar:Hide();

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(320, 1)

    scrollFrame:SetScrollChild(content)

    local itemCount = 1
    local lastFrame

    local CHECKBOX_WIDTH = 24
    local ICON_SIZE = 28
    local ITEM_HEIGHT = 32

    for _, itemId in ipairs(MRP.Data.helpfulItems) do
        if not C_ToyBox.GetToyInfo(itemId) and C_Item.GetItemCount(itemId, true, true, true, true) > 0 then
            local item = MRP.Util.GetItem(itemId)
            local itemName = item:GetItemName()
            local itemIcon = item:GetItemIcon()

            local itemFrame = CreateFrame("Frame", nil, content)
            itemFrame:SetSize(300, ITEM_HEIGHT)
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

    ignoredHelpfulItemsInitialized = true
end

local settingsCategory = Settings.RegisterCanvasLayoutCategory(optionsFrame, "Mount Route Planner")
Settings.RegisterAddOnCategory(settingsCategory)

function Options:Show()
    tomtomToggle:SetChecked(MRP_Settings.useTomTom)
    showDifficultyWarningToggle:SetChecked(MRP_Settings.showDifficultyWarning)
    ignoreLFRDifficultyToggle:SetChecked(MRP_Settings.ignoreLFRDifficulty)
    for itemId, toggle in pairs(ignoredHelpfulItemToggles) do
        toggle:SetChecked(MRP_CharacterSettings.ignoredHelpfulItems[itemId])
    end

    Settings.OpenToCategory(settingsCategory:GetID())
end
