-- MRP_Minimap.lua
-- local _, MRP = ...

local L = MRP.L

local minimapButton = CreateFrame("Button", "MRP_MinimapButton", Minimap)
minimapButton:SetSize(28, 28)
minimapButton:SetFrameStrata("HIGH")
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

minimapButton:SetNormalTexture("Interface\\AddOns\\MountRoutePlanner\\Assets\\Icon.tga")
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

minimapButton:SetMovable(true)
minimapButton:EnableMouse(true)
minimapButton:RegisterForDrag("LeftButton")
minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

minimapButton:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)
minimapButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

minimapButton:SetScript("OnClick", function(_, button)
    if button == "RightButton" then
        MRP.Options:Show()
    elseif button == "LeftButton" then
        MRP.UI:Toogle()
    end
end)

minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L["Mount Route Planner"])
    GameTooltip:AddLine(L["Left-Click: Toggle Panel"])
    GameTooltip:AddLine(L["Right-Click: Open Settings"])
    GameTooltip:AddLine(L["Drag: Move Button"])
    GameTooltip:Show()
end)

minimapButton:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

minimapButton:SetScript("OnUpdate", function()
    if MRP.UI then
        MRP.UI:CheckCurrentPathfindingStep()
    end
end)
