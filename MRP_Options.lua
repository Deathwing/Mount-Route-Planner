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

local settingsCategory = Settings.RegisterCanvasLayoutCategory(optionsFrame, "Mount Route Planner")
Settings.RegisterAddOnCategory(settingsCategory)

function Options:Show()
    tomtomToggle:SetChecked(MRP_Settings.useTomTom)
    showDifficultyWarningToggle:SetChecked(MRP_Settings.showDifficultyWarning)

    Settings.OpenToCategory(settingsCategory:GetID())
end
