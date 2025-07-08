-- MRP_UI.lua
local _, MRP = ...

local L = MRP.L

local UI = {}
MRP.UI = UI

local frame = CreateFrame("Frame", "MRPFrame", UIParent, "BackdropTemplate")
frame:SetSize(400, 250)
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

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
frame.title:SetPoint("TOP", 0, -16)
frame.title:SetText(L["Mount Route Planner"])
MRPFrame = frame

local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", -10, -10)

local clear = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
clear:SetSize(24, 24)
clear:SetNormalTexture("Interface\\Buttons\\UI-RefreshButton")
clear:SetPushedTexture("Interface\\Buttons\\UI-RefreshButton")
clear:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
clear:SetPoint("TOPRIGHT", close, "TOPLEFT", 0, 0)
clear:SetScript("OnClick", function()
    MRP_Clear()
end)

clear:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Reset Steps"])
    GameTooltip:AddLine(L["Clears current progress and steps"], 1, 1, 1)
    GameTooltip:Show()
end)

clear:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local settingsBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
settingsBtn:SetSize(24, 24)
settingsBtn:SetNormalTexture("Interface\\Buttons\\UI-OptionsButton")
settingsBtn:SetPushedTexture("Interface\\Buttons\\UI-OptionsButton")
settingsBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
settingsBtn:SetPoint("TOPRIGHT", clear, "TOPLEFT", 0, 0)

settingsBtn:SetScript("OnClick", function()
    MRP_OpenSettings()
end)

settingsBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Settings"])
    GameTooltip:AddLine(L["Open the MRP settings panel"], 1, 1, 1)
    GameTooltip:Show()
end)
settingsBtn:SetScript("OnLeave", GameTooltip_Hide)

frame.stepText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
frame.stepText:SetPoint("TOP", frame.title, "BOTTOM", 0, -20)
frame.stepText:SetText(L["No step loaded."])

frame.noteText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
frame.noteText:SetPoint("TOP", frame.stepText, "BOTTOM", 0, -56)
frame.noteText:SetText("")

local lastBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
lastBtn:SetSize(60, 24)
lastBtn:SetPoint("BOTTOMLEFT", 10, 10)
lastBtn:SetText(L["<< Last"])
lastBtn:SetScript("OnClick", function()
    MRP_PreviousStep()
end)

local nextBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
nextBtn:SetSize(60, 24)
nextBtn:SetPoint("BOTTOMRIGHT", -10, 10)
nextBtn:SetText(L["Next >>"])
nextBtn:SetScript("OnClick", function()
    MRP_NextStep()
end)

frame.progress = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
frame.progress:SetPoint("BOTTOM", 0, 12)
frame.progress:SetText(L["Step 0 of 0"])

frame.progressBarBG = frame:CreateTexture(nil, "BACKGROUND")
frame.progressBarBG:SetColorTexture(0, 0, 0, 0.5)
frame.progressBarBG:SetSize(200, 12)
frame.progressBarBG:SetPoint("CENTER", frame.progress, "CENTER")

frame.progressBar = frame:CreateTexture(nil, "ARTWORK")
frame.progressBar:SetColorTexture(0.2, 0.8, 0.2, 0.8)
frame.progressBar:SetSize(0, 12)
frame.progressBar:SetPoint("LEFT", frame.progressBarBG, "LEFT", 0, 0)

frame.importButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
frame.importButton:SetSize(120, 40)
frame.importButton:SetPoint("CENTER")
frame.importButton:SetText(L["Import Steps"])

local importFrame = CreateFrame("Frame", "MRPImportFrame", UIParent, "BackdropTemplate")
importFrame:SetSize(500, 400)
importFrame:SetPoint("CENTER")
importFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = {
        left = 8,
        right = 8,
        top = 8,
        bottom = 8
    }
})
importFrame:SetFrameStrata("DIALOG")
importFrame:SetFrameLevel(100)
importFrame:SetMovable(true)
importFrame:EnableMouse(true)
importFrame:RegisterForDrag("LeftButton")
importFrame:SetScript("OnDragStart", importFrame.StartMoving)
importFrame:SetScript("OnDragStop", importFrame.StopMovingOrSizing)
importFrame:Hide()

importFrame.title = importFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
importFrame.title:SetPoint("TOP", 0, -10)
importFrame.title:SetText(L["Paste Simple Armory Content"])

local scrollFrame = CreateFrame("ScrollFrame", nil, importFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 20, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 50)

local editBox = CreateFrame("EditBox", nil, scrollFrame)
editBox:SetMultiLine(true)
editBox:SetFontObject(ChatFontNormal)
editBox:SetAutoFocus(true)
editBox:SetWidth(440)
editBox:SetScript("OnEscapePressed", function()
    importFrame:Hide()
end)

scrollFrame:SetScrollChild(editBox)

frame.importButton:SetScript("OnClick", function()
    editBox:SetText("")
    importFrame:Show()
end)

local importBtn = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
importBtn:SetSize(100, 24)
importBtn:SetPoint("BOTTOMRIGHT", -20, 15)
importBtn:SetText(L["Import"])
importBtn:SetScript("OnClick", function()
    MRP_Parse(editBox:GetText())
    importFrame:Hide()
end)

-- add prefill (with faction preset content) button
local prefillBtn = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
prefillBtn:SetSize(100, 24)
prefillBtn:SetPoint("BOTTOMRIGHT", -130, 15)
prefillBtn:SetText(L["Prefill"])
prefillBtn:SetScript("OnClick", function()
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" then
        editBox:SetText(MRP_GetAlliancePrefill())
    else
        editBox:SetText(MRP_GetHordePrefill())
    end
end)
prefillBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Prefill"])
    GameTooltip:AddLine(L["Automatically fills the input box with preset content based on your faction."], 1, 1, 1, true)
    GameTooltip:AddLine(L["For optimal results import your character's data from Simple Armory."], 0.6, 0.6, 1, true)
    GameTooltip:Show()
end)
prefillBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

local cancelBtn = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
cancelBtn:SetSize(100, 24)
cancelBtn:SetPoint("BOTTOMLEFT", 20, 15)
cancelBtn:SetText(L["Cancel"])
cancelBtn:SetScript("OnClick", function()
    importFrame:Hide()
end)

local helpBtn = CreateFrame("Button", nil, importFrame, "UIPanelButtonTemplate")
helpBtn:SetSize(24, 24)
helpBtn:SetPoint("TOPRIGHT", -10, -10)
helpBtn:SetText("?")
-- helpBtn:SetNormalTexture("Interface\\Buttons\\UI-QuestionMark")
-- helpBtn:SetPushedTexture("Interface\\Buttons\\UI-QuestionMark-Down")
-- helpBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
helpBtn:SetScript("OnClick", function()
    local region = GetCurrentRegionName():lower()
    local realm = GetRealmName():gsub("%s+", ""):lower()
    local charName = UnitName("player")
    local url = string.format("https://simplearmory.com/#/%s/%s/%s/collectable/mounts/planner", region, realm, charName)

    StaticPopupDialogs["MOUNT_ROUTE_PLANNER_HELP"] = {
        text = L["To import simple armory content, copy the whole content from your simplearmory.com link and paste it into the input box.\n\nOpen in your Browser:"],
        button1 = L["Close"],
        timeout = 0,
        hasEditBox = true,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function(self)
            self.editBox:SetText(url)
            self.editBox:HighlightText()
            self.editBox:SetFocus()
        end,
        EditBoxOnEscapePressed = function(self)
            self:GetParent():Hide()
        end,
    }

    StaticPopup_Show("MOUNT_ROUTE_PLANNER_HELP")
end)

local centerAction = CreateFrame("Button", "MRPSecureUseButton", frame, "InsecureActionButtonTemplate")
centerAction:SetSize(48, 48)
centerAction:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -14, 34)
centerAction:SetFrameStrata("HIGH")
centerAction:RegisterForClicks("AnyUp", "AnyDown")
centerAction:SetAttribute("type", "macro")
centerAction:Hide()

centerAction.icon = centerAction:CreateTexture(nil, "ARTWORK")
centerAction.icon:SetAllPoints(centerAction)
centerAction.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

centerAction:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2")
centerAction:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
centerAction:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")

centerAction.glow = centerAction:CreateTexture(nil, "OVERLAY")
centerAction.glow:SetTexture("Interface\\Buttons\\CheckButtonGlow")
centerAction.glow:SetBlendMode("ADD")
centerAction.glow:SetAllPoints(centerAction)
centerAction.glow:SetAlpha(0)

local animFrame = CreateFrame("Frame")
local animAlpha = 0
local animDirection = 1

animFrame:SetScript("OnUpdate", function(self, elapsed)
    if centerAction:IsShown() then
        animAlpha = animAlpha + (elapsed * animDirection)
        if animAlpha > 1 then
            animAlpha = 1
            animDirection = -1
        elseif animAlpha < 0.3 then
            animAlpha = 0.3
            animDirection = 1
        end
        centerAction.glow:SetAlpha(animAlpha)
    else
        centerAction.glow:SetAlpha(0)
    end
end)

local knownItemIds = {
    ["Hearthstone"] = 6948,
    ["Garrison Hearthstone"] = 110560,
    ["Dalaran Hearthstone"] = 140192,
}

local itemMissingReportedCache = {}

function UI:ShowCenterUseItemButton(itemName)
    local btn = centerAction

    local itemID = select(1, C_Item.GetItemInfoInstant(itemName))
    if not itemID and knownItemIds[itemName] then
        itemID = knownItemIds[itemName]
    end

    if itemID then
        local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)
        if name then
            if icon then
                btn.icon:SetTexture(icon)
            else
                btn.icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end

            btn:SetAttribute("macrotext", "/use " .. name)
            btn:Show()
        end
    elseif not itemMissingReportedCache[itemName] then
        itemMissingReportedCache[itemName] = true
        print("|cffffcc00[MRP]|r " .. format(L["Item not found: '%s', please report it."], itemName))
    end
end

function UI:HideCenterAction()
    centerAction:Hide()
end

function UI:ShowHide()
    if not frame:IsShown() then
        frame:Show()
        self:UpdateDisplay()
    else
        frame:Hide()
    end
end

local tomtomIds = {}
local hasTrackedWaypoint = false

function UI:UpdateDisplay()
    local steps = MRP.parsedSteps or {}
    local idx = MRP.currentIndex or 1
    local step = steps[idx]

    self:HideCenterAction()

    if TomTom and TomTom["RemoveWaypoint"] then
        for _, id in ipairs(tomtomIds) do
            TomTom:RemoveWaypoint(id)
        end
        tomtomIds = {}
    end

    if hasTrackedWaypoint then
        C_Map.ClearUserWaypoint()
        C_SuperTrack.SetSuperTrackedUserWaypoint(false)
        hasTrackedWaypoint = false
    end

    if MRPFrame.rewardIcons then
        for _, icon in ipairs(MRPFrame.rewardIcons) do
            icon:Hide()
            if icon.checkmark then
                icon.checkmark:Hide()
            end
        end
    end
    MRPFrame.rewardIcons = {}

    if not step then
        frame.stepText:SetText(L["No step loaded."])
        frame.noteText:SetText("")
        frame.importButton:Show()
        frame.progress:SetText(L["Step 0 of 0"])
        frame.progressBar:SetWidth(0)
        return
    end

    frame.importButton:Hide()

    local warningText = nil

    if step.instance then
        frame.stepText:SetText(format(L["Run %s"], step.instance))

        local missingDifficulties = {}

        for _, reward in ipairs(step.rewards or {}) do
            if reward.boss and reward.mount then
                local mountName = reward.mount
                local mountCollected = MRP_GetMountCollectedByName(mountName)
                if not mountCollected then
                    if reward.note and reward.note:find("Heroic 25 only") then
                        if not MRP_IsCorrectDifficulty("Heroic 25 only") then
                            if not tContains(missingDifficulties, L["Heroic 25"]) then
                                table.insert(missingDifficulties, L["Heroic 25"])
                            end
                        end
                    elseif reward.note and reward.note:find("Heroic only") then
                        if not MRP_IsCorrectDifficulty("Heroic only") then
                            if not tContains(missingDifficulties, L["Heroic"]) then
                                table.insert(missingDifficulties, L["Heroic"])
                            end
                        end
                    elseif reward.note and reward.note:find("Mythic only") then
                        if not MRP_IsCorrectDifficulty("Mythic only") then
                            if not tContains(missingDifficulties, L["Mythic"]) then
                                table.insert(missingDifficulties, L["Mythic"])
                            end
                        end
                    end
                end
            end
        end

        if #missingDifficulties > 0 then
            warningText = format(L["Run the instance on '%s' difficulty to collect all mounts."], table.concat(missingDifficulties, ", "))
        end
    elseif step.npc then
        frame.stepText:SetText(format(L["Kill %s"], step.npc))
    elseif step.item then
        frame.stepText:SetText(format(L["Use %s"], step.item))
        self:ShowCenterUseItemButton(step.item)
    elseif step.flyTo then
        frame.stepText:SetText(format(L["Fly to %s"], step.flyTo))
    elseif step.portal then
        frame.stepText:SetText(format(L["Take Portal to %s"], step.portal))
    elseif step.hearthstone then
        frame.stepText:SetText(format(L["Use Hearthstone to %s"], step.hearthstone))
        self:ShowCenterUseItemButton("Hearthstone")

        if GetBindLocation() ~= step.hearthstone then
            warningText = L["Your Hearthstone is set to a different location!"]
        end
    elseif step.teleport then
        frame.stepText:SetText(format(L["Use Teleport to %s"], step.teleport))
    elseif step.flightPath then
        frame.stepText:SetText(format(L["Take Flight Path to %s"], step.flightPath))
    elseif step.blimp then
        frame.stepText:SetText(format(L["Take Blimp to %s"], step.blimp))
    elseif step.walkTo then
        frame.stepText:SetText(format(L["Walk to %s"], step.walkTo))
    elseif step.action then
        frame.stepText:SetText(step.action)
    end

    if step.location then
        local label = step.label or L["Unknown"]

        local locX = step.location.x
        if (locX >= 1) then
            locX = locX / 100
        end

        local locY = step.location.y
        if (locY >= 1) then
            locY = locY / 100
        end

        local locStr = (step.location.mapName or "Unknown Map") .. " (" .. (step.location.mapID or 0) .. ")"

        if not step.location.mapID then
            step.location.mapID = MRP.Data.mapNamesToIds[step.location.mapName] or 0
            if not step.location.mapID or step.location.mapID == 0 then
                print("|cffffcc00[MRP]|r " .. format(L["Map ID not found for: '%s', please report it."], locStr))
                step.location.mapID = 0
            end
        end

        if MRP_DB.useTomTom and TomTom and TomTom["AddWaypoint"] then
            local uid = TomTom:AddWaypoint(
                step.location.mapID,
                locX,
                locY,
                {
                    title = label,
                    source = "Mount Route Planner",
                    persistent = false,
                    minimap = true,
                    world = true,
                    silent = true,
                }
            )
            if uid then
                table.insert(tomtomIds, uid)
            else
                print("|cffffcc00[MRP]|r " .. format(L["Failed to add TomTom waypoint for: '%s', please report it."], locStr))
            end
        else
            if type(step.location.mapID) ~= "number" then
                print("|cffffcc00[MRP]|r " .. format(L["Invalid map ID for: '%s', please report it."], locStr))
            end

            local coords = UiMapPoint.CreateFromCoordinates(step.location.mapID, locX, locY)
            if not coords then
                print("|cffffcc00[MRP]|r " .. format(L["Invalid coordinates for: '%s', please report it."], locStr))
                return
            end

            if C_Map.CanSetUserWaypointOnMap(step.location.mapID) then
                C_Map.SetUserWaypoint(coords)
                C_SuperTrack.SetSuperTrackedUserWaypoint(true)
                hasTrackedWaypoint = true
            elseif step.location.mapID ~= 582 and step.location.mapID ~= 627 then
                print("|cffffcc00[MRP]|r " .. format(L["Cannot set waypoint on map: '%s', please report it."], locStr))
            end
        end
    end

    local totalIconsForStep = 0
    for _, r in ipairs(step.rewards or {}) do
        if r.boss and r.mount then
            totalIconsForStep = totalIconsForStep + 1
        end
    end

    local index = 1
    for _, reward in ipairs(step.rewards or {}) do
        if reward.boss and reward.mount then
            local isCollected = MRP_GetMountCollectedByName(reward.mount)
            local isDead = MRP_IsBossDead(reward.boss, step.instance)
            if reward.mount and not reward.icon then
                reward.icon = MRP_GetMountIconByName(reward.mount)
            end

            local icon = MRPFrame:CreateTexture(nil, "OVERLAY")
            icon:SetSize(32, 32)
            do
                local row = (index - 1) >= 8 and 1 or 0
                local col = (index - 1) % 8
                local iconsInRow = row == 0 and math.min(8, totalIconsForStep) or (totalIconsForStep - 8)
                local frameWidth = MRPFrame:GetWidth()
                local startX = (frameWidth - (iconsInRow * 36)) / 2
                icon:SetPoint("TOPLEFT", MRPFrame, "TOPLEFT", startX + col * 36, -74 - row * 36)
            end
            icon:SetTexture(reward.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
            icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            icon:SetDesaturated(isDead or isCollected)

            icon:SetScript("OnEnter", function()
                ---@diagnostic disable-next-line: param-type-mismatch
                GameTooltip:SetOwner(icon, "ANCHOR_RIGHT")
                GameTooltip:AddLine(reward.boss or L["Unknown Boss"], 1, 1, 1)
                if reward.note then
                    GameTooltip:AddLine(reward.note, nil, nil, nil, true)
                end
                if reward.mount then
                    GameTooltip:AddLine(format(L["Mount: %s"], reward.mount), 0.6, 1, 0.6)
                end
                if isCollected then
                    GameTooltip:AddLine(L["You have collected this mount."], 1, 0.6, 0.6)
                else
                    if isDead then
                        GameTooltip:AddLine(L["This boss is dead."], 1, 0.6, 0.6)
                    else
                        GameTooltip:AddLine(L["This boss is still alive."], 0.6, 0.6, 1)
                    end
                end
                GameTooltip:Show()
            end)
            icon:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            icon:Show()

            table.insert(MRPFrame.rewardIcons, icon)
            index = index + 1
        end
    end

    frame.noteText:SetText(step.note or "")
    if warningText then
        frame.noteText:SetText((frame.noteText:GetText() or "") .. "\n\n|cffff0000" .. warningText .. "|r")
    end

    frame.progress:SetText(L["Step %d of %d"]:format(idx, #steps))
    frame.progressBar:SetWidth(frame.progressBarBG:GetWidth() * (idx / #steps))

    local pulse = MRPFrame:CreateAnimationGroup()
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

local toggle = CreateFrame("CheckButton", nil, MRPFrame, "UICheckButtonTemplate")
toggle:SetSize(24, 24)
toggle:SetPoint("BOTTOMLEFT", MRPFrame, "BOTTOMLEFT", 10, 58)
toggle.text = toggle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
toggle.text:SetPoint("LEFT", toggle, "RIGHT", 4, 0)
toggle.text:SetText(L["Auto-Skip Steps"])
toggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Auto-Skip Steps"])
    GameTooltip:AddLine(L["Automatically skips steps that are already completed."], 1, 1, 1, true)
    GameTooltip:Show()
end)
toggle:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

toggle:SetChecked(MRP_DB.autoSkip)
toggle:SetScript("OnClick", function(self)
    MRP_DB.autoSkip = self:GetChecked()
end)

local autoAdvanceToggle = CreateFrame("CheckButton", nil, MRPFrame, "UICheckButtonTemplate")
autoAdvanceToggle:SetSize(24, 24)
autoAdvanceToggle:SetPoint("BOTTOMLEFT", MRPFrame, "BOTTOMLEFT", 10, 34)
autoAdvanceToggle.text = autoAdvanceToggle:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
autoAdvanceToggle.text:SetPoint("LEFT", autoAdvanceToggle, "RIGHT", 4, 0)
autoAdvanceToggle.text:SetText(L["Auto-Advance Steps"])
autoAdvanceToggle:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Auto-Advance Steps"])
    GameTooltip:AddLine(L["Automatically advances to the next step after completing the current one."], 1, 1, 1, true)
    GameTooltip:Show()
end)
autoAdvanceToggle:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

autoAdvanceToggle:SetChecked(MRP_DB.autoAdvance)
autoAdvanceToggle:SetScript("OnClick", function(self)
    MRP_DB.autoAdvance = self:GetChecked()
end)

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    toggle:SetChecked(MRP_DB.autoSkip)
    autoAdvanceToggle:SetChecked(MRP_DB.autoAdvance)
end)

local warningFrame = CreateFrame("Frame", "MRPDifficultyWarningFrame", UIParent, "BackdropTemplate")
warningFrame:SetSize(500, 100)
warningFrame:SetPoint("TOP", UIParent, "TOP", 0, -150)
warningFrame:SetFrameStrata("HIGH")
warningFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
warningFrame:SetBackdropColor(0.8, 0, 0, 0.9)
warningFrame:Hide()

-- Main text of the warning
warningFrame.title = warningFrame:CreateFontString(nil, "OVERLAY", "GameFont_Gigantic")
warningFrame.title:SetPoint("TOP", warningFrame, "TOP", 0, -25)
warningFrame.title:SetTextColor(1, 0.82, 0)
warningFrame.title:SetText(L["Wrong Difficulty"])

-- Subtitle with the instruction
warningFrame.subText = warningFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
warningFrame.subText:SetPoint("TOP", warningFrame.title, "BOTTOM", 0, -8)
warningFrame.subText:SetTextColor(1, 1, 1)
warningFrame.subText:SetText(L["Please switch to '%s'"])

-- Functions for displaying and hiding the window
function UI:ShowDifficultyWarning(requiredDifficultyText)
    warningFrame.subText:SetText(string.format(L["Please switch to '%s'"], requiredDifficultyText))
    warningFrame:Show()
end

function UI:HideDifficultyWarning()
    warningFrame:Hide()
end
