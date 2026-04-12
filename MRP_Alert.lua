-- MRP_Alert.lua
-- Alert system for nearby mount sources
-- local _, MRP = ...

local L = MRP.L

local Alert = {}
MRP.Alert = Alert

-- Build a lookup table: npcID → source names for all tracked NPC-backed sources
local npcToEntry = {}
local alertSourceTypes = {
    [MRP.FilterSourceType.OpenWorld] = true,
    [MRP.FilterSourceType.WorldBoss] = true,
    [MRP.FilterSourceType.Quest] = true,
    [MRP.FilterSourceType.Treasure] = true,
    [MRP.FilterSourceType.Vendor] = true,
}
local NEARBY_SCAN_INTERVAL = 1
local SCAN_MACRO_NAME = "MRP_SCAN"
local SCAN_MACRO_ICON = "Interface/Icons/Ability_Hunter_SniperShot"
local SCAN_MACRO_REFRESH_INTERVAL = 5
local ALERT_CACHE_REFRESH_INTERVAL = 1
local SCAN_MACRO_MAX_LENGTH = 255
local SCAN_MACRO_NEAR_DISTANCE = 0.10
local ALERT_DEFAULT_POINT = "TOP"
local ALERT_DEFAULT_RELATIVE_POINT = "TOP"
local ALERT_DEFAULT_OFFSET_X = 0
local ALERT_DEFAULT_OFFSET_Y = -80
local SCANNED_UNIT_TOKENS = {
    "target",
    "mouseover",
    "focus",
    "softenemy",
    "softenemyinteract",
    "softinteract",
    "softfriend",
}
local ALERT_DEBUG_ENABLED = false

local alertDebugStates = {}
local handledAlertKeys = {}
local alertableSteps = {}
local alertableNpcEntries = {}
local alertableNameEntries = {}
local alertCacheDirty = true
local alertCacheFilteredStepsRef = nil
local alertCacheFilteredStepCount = 0
local alertCacheLastRefresh = 0
local alertHooksInstalled = false
local IsStepAlertable

local function FormatDebugValue(value)
    if value == nil or value == "" then
        return "nil"
    end

    return tostring(value)
end

local function FormatDebugBool(value)
    return value and "yes" or "no"
end

local function DebugLog(message, ...)
    if not ALERT_DEBUG_ENABLED then
        return
    end

    local formattedMessage = select("#", ...) > 0 and string.format(message, ...) or message
    print("|cff00ff00[MRP AlertDebug]|r " .. formattedMessage)
end

local function DebugLogOnce(key, message, ...)
    if not ALERT_DEBUG_ENABLED then
        return
    end

    local formattedMessage = select("#", ...) > 0 and string.format(message, ...) or message
    if alertDebugStates[key] == formattedMessage then
        return
    end

    alertDebugStates[key] = formattedMessage
    print("|cff00ff00[MRP AlertDebug]|r " .. formattedMessage)
end

local function AddNpcLookupEntry(name, entry)
    if not entry or not entry.npcID or entry.npcID <= 0 then
        return
    end

    if not npcToEntry[entry.npcID] then
        npcToEntry[entry.npcID] = {}
    end
    npcToEntry[entry.npcID][name] = true
end

local function BuildNpcLookup()
    wipe(npcToEntry)
    for name, entry in pairs(MRP.Data.OPEN_WORLD) do
        AddNpcLookupEntry(name, entry)
    end

    for name, entry in pairs(MRP.Data.WORLD_BOSSES) do
        AddNpcLookupEntry(name, entry)
    end
end

local function GetNpcIDFromGUID(guid)
    if not guid then return nil end

    local npcID = select(6, strsplit("-", guid))
    return npcID and tonumber(npcID) or nil
end

local function NormalizeName(name)
    if not name or name == "" then
        return nil
    end

    return strlower(name)
end

local function GetAlertKey(npcName, npcID, targetName)
    if npcID and npcID > 0 then
        return "npc:" .. npcID
    end

    local normalizedTarget = NormalizeName(targetName or npcName)
    if normalizedTarget then
        return "name:" .. normalizedTarget
    end

    return nil
end

local function GetTrackedEntryForStep(step)
    if not step or not step.source then
        return nil
    end

    local entry = nil
    if step.source.type == MRP.FilterSourceType.WorldBoss then
        entry = MRP.Data.WORLD_BOSSES[step.source.name]
    else
        entry = MRP.Data.OPEN_WORLD[step.source.name]
    end

    local stepNpcID = step.source.npcID
    if entry then
        if stepNpcID and stepNpcID > 0 and entry.npcID ~= stepNpcID then
            return {
                x = entry.x,
                y = entry.y,
                mapName = entry.mapName,
                mapID = entry.mapID,
                questID = entry.questID,
                expansionLevel = entry.expansionLevel,
                npcID = stepNpcID,
                targetName = step.source.targetName or entry.targetName,
                mechanic = entry.mechanic,
                note = entry.note,
                condition = entry.condition,
                waypoints = entry.waypoints,
                routeType = entry.routeType,
                routes = entry.routes,
            }
        end

        return entry
    end

    if stepNpcID and stepNpcID > 0 then
        return { npcID = stepNpcID }
    end

    return nil
end

local function GetTargetNameForStep(step)
    if not step or not step.source then
        return nil
    end

    if step.source.targetName and step.source.targetName ~= "" then
        return step.source.targetName
    end

    local entry = GetTrackedEntryForStep(step)
    if entry and entry.targetName and entry.targetName ~= "" then
        return entry.targetName
    end

    return step.source.name
end

local function AddAlertableNameEntry(name, sourceName, targetName)
    local normalizedName = NormalizeName(name)
    if not normalizedName or alertableNameEntries[normalizedName] then
        return
    end

    alertableNameEntries[normalizedName] = {
        sourceName = sourceName,
        targetName = targetName,
    }
end

function Alert:MarkAlertCacheDirty()
    alertCacheDirty = true
end

function Alert:InstallHooks()
    if alertHooksInstalled then
        return
    end

    if MRP.Filter and MRP.Filter.Apply then
        hooksecurefunc(MRP.Filter, "Apply", function()
            Alert:MarkAlertCacheDirty()
        end)
    end

    if MRP.Core and MRP.Core.CheckCurrentStepComplete then
        hooksecurefunc(MRP.Core, "CheckCurrentStepComplete", function()
            Alert:MarkAlertCacheDirty()
        end)
    end

    alertHooksInstalled = true
end

function Alert:RefreshAlertableCache()
    wipe(alertableSteps)
    wipe(alertableNpcEntries)
    wipe(alertableNameEntries)

    local steps = MRP.Filter and MRP.Filter.filteredSteps or nil
    if steps then
        for _, step in ipairs(steps) do
            if IsStepAlertable(step) then
                local entry = GetTrackedEntryForStep(step)
                local targetName = GetTargetNameForStep(step)

                table.insert(alertableSteps, step)

                if entry and entry.npcID and not alertableNpcEntries[entry.npcID] then
                    alertableNpcEntries[entry.npcID] = {
                        sourceName = step.source.name,
                        targetName = targetName,
                    }
                end

                AddAlertableNameEntry(step.source.name, step.source.name, targetName)
                if targetName and targetName ~= step.source.name then
                    AddAlertableNameEntry(targetName, step.source.name, targetName)
                end
            end
        end
    end

    alertCacheFilteredStepsRef = steps
    alertCacheFilteredStepCount = steps and #steps or 0
    alertCacheLastRefresh = GetTime()
    alertCacheDirty = false
end

function Alert:EnsureAlertableCache(force)
    local steps = MRP.Filter and MRP.Filter.filteredSteps or nil
    local stepCount = steps and #steps or 0
    local now = GetTime()

    if not force
        and not alertCacheDirty
        and alertCacheFilteredStepsRef == steps
        and alertCacheFilteredStepCount == stepCount
        and (now - alertCacheLastRefresh) < ALERT_CACHE_REFRESH_INTERVAL then
        return
    end

    self:RefreshAlertableCache()
end

function Alert:LogCurrentStepContext(context)
    local trackedStepCount = 0
    local steps = MRP.Filter and MRP.Filter.filteredSteps or nil
    if steps then
        for _, step in ipairs(steps) do
            if alertSourceTypes[step.source.type] then
                trackedStepCount = trackedStepCount + 1
            end
        end
    end

    local step = MRP.Filter and MRP.Filter.GetCurrentStep and MRP.Filter:GetCurrentStep() or nil
    if not step or not step.source then
        DebugLog("%s currentStep=nil trackedFilteredSteps=%s", FormatDebugValue(context), trackedStepCount)
        return
    end

    local entry = GetTrackedEntryForStep(step)
    DebugLog(
        "%s currentStep=%s type=%s target=%s npcID=%s mapID=%s trackedFilteredSteps=%s",
        FormatDebugValue(context),
        FormatDebugValue(step.source.name),
        FormatDebugValue(step.source.type),
        FormatDebugValue(GetTargetNameForStep(step)),
        FormatDebugValue(entry and entry.npcID),
        FormatDebugValue(entry and entry.mapID),
        trackedStepCount
    )
end

local function AppendMacroLine(body, npcName)
    local line = "/targetexact " .. npcName
    if not body or body == "" then
        if #line > SCAN_MACRO_MAX_LENGTH then
            return body, false
        end

        return line, true
    end

    local nextBody = body .. "\n" .. line
    if #nextBody > SCAN_MACRO_MAX_LENGTH then
        return body, false
    end

    return nextBody, true
end

local function MapsOverlap(mapID, otherMapID)
    local currentMapID = mapID
    while currentMapID do
        if currentMapID == otherMapID then
            return true
        end

        local mapInfo = C_Map.GetMapInfo(currentMapID)
        currentMapID = mapInfo and mapInfo.parentMapID or nil
    end

    currentMapID = otherMapID
    while currentMapID do
        if currentMapID == mapID then
            return true
        end

        local mapInfo = C_Map.GetMapInfo(currentMapID)
        currentMapID = mapInfo and mapInfo.parentMapID or nil
    end

    return false
end

-- Track which vignette GUIDs we've already alerted for this session
local alertedVignettes = {}
local nearbyNpcGuids = {}

-- The alert frame
local alertFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
alertFrame:SetSize(320, 80)
alertFrame:SetPoint(ALERT_DEFAULT_POINT, UIParent, ALERT_DEFAULT_RELATIVE_POINT, ALERT_DEFAULT_OFFSET_X, ALERT_DEFAULT_OFFSET_Y)
alertFrame:SetFrameStrata("DIALOG")
alertFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
alertFrame:SetBackdropColor(0.1, 0.05, 0.15, 0.95)
alertFrame:Hide()
alertFrame:EnableMouse(true)
alertFrame:SetClampedToScreen(true)
alertFrame:SetMovable(true)
alertFrame:RegisterForDrag("LeftButton")
alertFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
alertFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    Alert:SavePosition()
end)

-- Icon
local alertIcon = alertFrame:CreateTexture(nil, "ARTWORK")
alertIcon:SetSize(40, 40)
alertIcon:SetPoint("LEFT", alertFrame, "LEFT", 12, 0)
alertIcon:SetAtlas("VignetteKillElite")

-- Title
local alertTitle = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
alertTitle:SetPoint("TOPLEFT", alertIcon, "TOPRIGHT", 10, -2)
alertTitle:SetPoint("RIGHT", alertFrame, "RIGHT", -36, 0)
alertTitle:SetJustifyH("LEFT")
alertTitle:SetTextColor(1, 0.82, 0)
alertTitle:SetText("")

-- Subtitle
local alertSubtitle = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
alertSubtitle:SetPoint("TOPLEFT", alertTitle, "BOTTOMLEFT", 0, -2)
alertSubtitle:SetPoint("RIGHT", alertFrame, "RIGHT", -36, 0)
alertSubtitle:SetJustifyH("LEFT")
alertSubtitle:SetTextColor(0.8, 0.8, 0.8)
alertSubtitle:SetText("")

-- Close button
local alertCloseBtn = CreateFrame("Button", nil, alertFrame, "UIPanelCloseButton")
alertCloseBtn:SetSize(24, 24)
alertCloseBtn:SetPoint("TOPRIGHT", alertFrame, "TOPRIGHT", -2, -2)
alertCloseBtn:SetScript("OnClick", function()
    Alert:HideAlert()
end)

-- Action button for targeting (integrated with MRP_UI action button system)
local alertActionBtn = CreateFrame("Button", nil, alertFrame, "InsecureActionButtonTemplate")
alertActionBtn:SetSize(36, 36)
alertActionBtn:SetPoint("RIGHT", alertFrame, "RIGHT", -8, 0)
alertActionBtn:SetNormalTexture("Interface\\Icons\\Ability_Hunter_SniperShot")
alertActionBtn:SetHighlightTexture("Interface\\Icons\\Ability_Hunter_SniperShot")
alertActionBtn:SetPushedTexture("Interface\\Icons\\Ability_Hunter_SniperShot")
alertActionBtn:GetPushedTexture():SetVertexColor(0.6, 0.6, 0.6, 1)
alertActionBtn:SetAttribute("type", "macro")
alertActionBtn:RegisterForClicks("AnyUp", "AnyDown")
if WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE then
    alertActionBtn:RegisterForClicks("AnyUp")
end
alertActionBtn:Hide()

alertActionBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:AddLine(L["Target NPC"], 1, 1, 1)
    GameTooltip:AddLine(L["Click to target this creature."], 0.6, 0.6, 0.6)
    GameTooltip:AddLine(L["Only works while the NPC is still nearby and targetable."], 0.6, 0.6, 0.6)
    GameTooltip:Show()
end)
alertActionBtn:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

function Alert:ApplySavedPosition()
    local point = MRP_Settings and MRP_Settings.alertPopupPoint or ALERT_DEFAULT_POINT
    local relativePoint = MRP_Settings and MRP_Settings.alertPopupRelativePoint or ALERT_DEFAULT_RELATIVE_POINT
    local offsetX = MRP_Settings and MRP_Settings.alertPopupOffsetX or ALERT_DEFAULT_OFFSET_X
    local offsetY = MRP_Settings and MRP_Settings.alertPopupOffsetY or ALERT_DEFAULT_OFFSET_Y

    alertFrame:ClearAllPoints()
    alertFrame:SetPoint(point, UIParent, relativePoint, offsetX, offsetY)
end

function Alert:SavePosition()
    if not MRP_Settings then
        return
    end

    local point, _, relativePoint, offsetX, offsetY = alertFrame:GetPoint()
    if not point or not relativePoint or not offsetX or not offsetY then
        return
    end

    MRP_Settings.alertPopupPoint = point
    MRP_Settings.alertPopupRelativePoint = relativePoint
    MRP_Settings.alertPopupOffsetX = offsetX
    MRP_Settings.alertPopupOffsetY = offsetY
end

function Alert:ResetPosition()
    if not MRP_Settings then
        return
    end

    MRP_Settings.alertPopupPoint = ALERT_DEFAULT_POINT
    MRP_Settings.alertPopupRelativePoint = ALERT_DEFAULT_RELATIVE_POINT
    MRP_Settings.alertPopupOffsetX = ALERT_DEFAULT_OFFSET_X
    MRP_Settings.alertPopupOffsetY = ALERT_DEFAULT_OFFSET_Y
    self:ApplySavedPosition()
end

-- Auto-hide timer
local autoHideTimer = nil

-- Fade-in animation
local fadeIn = alertFrame:CreateAnimationGroup()
local alphaIn = fadeIn:CreateAnimation("Alpha")
alphaIn:SetFromAlpha(0)
alphaIn:SetToAlpha(1)
alphaIn:SetDuration(0.3)
alphaIn:SetOrder(1)

function Alert:ShowAlert(npcName, npcID, targetName)
    local alertKey = GetAlertKey(npcName, npcID, targetName)
    if alertKey and handledAlertKeys[alertKey] then
        DebugLogOnce(
            "show-alert-suppressed:" .. alertKey,
            "showAlert suppressed duplicate key=%s name=%s npcID=%s target=%s",
            alertKey,
            FormatDebugValue(npcName),
            FormatDebugValue(npcID),
            FormatDebugValue(targetName)
        )
        return false
    end

    if InCombatLockdown() then
        DebugLogOnce(
            "show-alert-blocked-combat:" .. FormatDebugValue(targetName or npcName or npcID),
            "showAlert blocked by combat name=%s npcID=%s target=%s",
            FormatDebugValue(npcName),
            FormatDebugValue(npcID),
            FormatDebugValue(targetName)
        )
        return false
    end
    if not MRP_Settings.showRareAlert then
        DebugLogOnce(
            "show-alert-disabled:" .. FormatDebugValue(targetName or npcName or npcID),
            "showAlert blocked because rare alerts are disabled name=%s npcID=%s target=%s",
            FormatDebugValue(npcName),
            FormatDebugValue(npcID),
            FormatDebugValue(targetName)
        )
        return false
    end

    alertTitle:SetText(npcName or L["Rare Found!"])
    alertSubtitle:SetText(L["Mount source detected nearby!"])
    alertIcon:SetAtlas("VignetteKillElite")
    alertIcon:SetVertexColor(1, 0.82, 0, 1)

    -- Set up targeting macro
    local macroTargetName = targetName or npcName
    if macroTargetName and not InCombatLockdown() then
        alertActionBtn:SetAttribute("macrotext", "/cleartarget\n/targetexact " .. macroTargetName)
        alertActionBtn:Show()
    else
        alertActionBtn:Hide()
    end

    alertFrame:Show()
    fadeIn:Play()

    -- Play alert sound
    PlaySound(SOUNDKIT.RAID_WARNING, "Master")

    -- Auto-hide after 15 seconds
    if autoHideTimer then
        autoHideTimer:Cancel()
    end
    autoHideTimer = C_Timer.NewTimer(15, function()
        Alert:HideAlert()
    end)

    if alertKey then
        handledAlertKeys[alertKey] = true
    end

    DebugLog(
        "showAlert displayed name=%s npcID=%s target=%s",
        FormatDebugValue(npcName),
        FormatDebugValue(npcID),
        FormatDebugValue(targetName)
    )

    return true
end

function Alert:HideAlert()
    if InCombatLockdown() then return end
    alertFrame:Hide()
    alertActionBtn:Hide()
    if autoHideTimer then
        autoHideTimer:Cancel()
        autoHideTimer = nil
    end
end

IsStepAlertable = function(step)
    if not step or not step.source or not alertSourceTypes[step.source.type] then
        return false
    end

    if MRP.Core and MRP.Core.ShouldSkipStep and MRP.Core:ShouldSkipStep(step) then
        return false
    end

    return true
end

-- Check if a given npcID is a mount source the player should care about
function Alert:IsRelevantMountSourceNpc(npcID)
    if not npcID or npcID == 0 then return false end
    self:EnsureAlertableCache()

    local entry = alertableNpcEntries[npcID]
    if entry then
        return true, entry.sourceName, entry.targetName
    end

    return false
end

function Alert:IsRelevantMountSourceName(npcName)
    local normalizedName = NormalizeName(npcName)
    if not normalizedName then
        return false
    end

    self:EnsureAlertableCache()

    local entry = alertableNameEntries[normalizedName]
    if entry then
        return true, entry.sourceName, entry.targetName
    end

    return false
end

function Alert:TryShowNpcAlert(npcID, displayName)
    local isRelevant, entryName, targetName = self:IsRelevantMountSourceNpc(npcID)
    if not isRelevant then
        return false
    end

    return self:ShowAlert(displayName or targetName or entryName or L["Rare Found!"], npcID, targetName)
end

function Alert:TryShowNameAlert(displayName)
    local isRelevant, entryName, targetName = self:IsRelevantMountSourceName(displayName)
    if not isRelevant then
        return false
    end

    return self:ShowAlert(displayName or targetName or entryName or L["Rare Found!"], nil, targetName)
end

function Alert:EnsureScanMacro()
    if InCombatLockdown() then
        return false
    end

    if GetMacroInfo(SCAN_MACRO_NAME) then
        return true
    end

    if GetNumMacros() >= 119 then
        return false
    end

    CreateMacro(SCAN_MACRO_NAME, GetFileIDFromPath(SCAN_MACRO_ICON), "")
    return true
end

function Alert:BuildScanMacroBody(nearbyOnly)
    local playerMapID = C_Map.GetBestMapForUnit("player")
    if not playerMapID then
        return "", false
    end

    self:EnsureAlertableCache()

    local playerMapPosition = C_Map.GetPlayerMapPosition(playerMapID, "player")
    local macroBody = ""
    local addedNames = {}

    for _, step in ipairs(alertableSteps) do
        local entry = GetTrackedEntryForStep(step)
        local npcName = GetTargetNameForStep(step)
        local isNearby = not nearbyOnly

        if nearbyOnly and entry and playerMapPosition and MapsOverlap(entry.mapID, playerMapID) and entry.x and entry.y then
            local dx = playerMapPosition.x - (entry.x / 100)
            local dy = playerMapPosition.y - (entry.y / 100)
            isNearby = math.sqrt(dx * dx + dy * dy) <= SCAN_MACRO_NEAR_DISTANCE
        end

        if entry and entry.npcID and MapsOverlap(entry.mapID, playerMapID) and npcName and not addedNames[npcName] and isNearby then
            local nextBody, appended = AppendMacroLine(macroBody, npcName)
            if not appended then
                return macroBody, true
            end

            macroBody = nextBody
            addedNames[npcName] = true
        end
    end

    return macroBody, false
end

function Alert:UpdateScanMacro()
    if not MRP_Settings or not MRP_Settings.showRareAlert then return end
    if MacroFrame and MacroFrame:IsVisible() then return end
    if not self:EnsureScanMacro() then return end

    local macroBody, overflow = self:BuildScanMacroBody(false)
    if overflow then
        macroBody = self:BuildScanMacroBody(true)
    end

    if not InCombatLockdown() then
        EditMacro(SCAN_MACRO_NAME, SCAN_MACRO_NAME, nil, macroBody or "")
    end
end

function Alert:ClearScanMacro()
    if InCombatLockdown() then return end
    if MacroFrame and MacroFrame:IsVisible() then return end
    if not GetMacroInfo(SCAN_MACRO_NAME) then return end

    EditMacro(SCAN_MACRO_NAME, SCAN_MACRO_NAME, nil, "")
end

function Alert:TryAlertUnit(unitToken, seenGuids)
    if not UnitExists(unitToken) or UnitIsPlayer(unitToken) then
        return false
    end

    local unitName = UnitName(unitToken)
    local guid = UnitGUID(unitToken)
    if not guid then
        return false
    end
    if seenGuids then
        seenGuids[guid] = true
    end

    if nearbyNpcGuids[guid] then
        return false
    end

    local npcID = GetNpcIDFromGUID(guid)
    if not npcID then
        return false
    end

    local trackedByNpc = npcToEntry[npcID] ~= nil
    local isRelevantByNpc, entryName, targetName = self:IsRelevantMountSourceNpc(npcID)
    local isRelevantByName, nameEntryName, nameTargetName = self:IsRelevantMountSourceName(unitName)
    local shown = false

    if isRelevantByNpc then
        shown = self:ShowAlert(unitName, npcID, targetName)
    end

    if trackedByNpc or isRelevantByName then
        DebugLogOnce(
            "unit:" .. guid .. ":" .. FormatDebugBool(shown),
            "unit token=%s name=%s guid=%s npcID=%s trackedNpc=%s matchNpc=%s matchName=%s entry=%s target=%s shown=%s",
            FormatDebugValue(unitToken),
            FormatDebugValue(unitName),
            FormatDebugValue(guid),
            FormatDebugValue(npcID),
            FormatDebugBool(trackedByNpc),
            FormatDebugBool(isRelevantByNpc),
            FormatDebugBool(isRelevantByName),
            FormatDebugValue(entryName or nameEntryName),
            FormatDebugValue(targetName or nameTargetName),
            FormatDebugBool(shown)
        )
    end

    if shown or isRelevantByNpc or isRelevantByName then
        nearbyNpcGuids[guid] = true
    end

    if shown then
        return true
    end

    return false
end

function Alert:CheckNearbyNpcUnits()
    if not MRP_Settings or not MRP_Settings.showRareAlert then
        wipe(nearbyNpcGuids)
        return
    end

    local seenGuids = {}

    for _, unitToken in ipairs(SCANNED_UNIT_TOKENS) do
        self:TryAlertUnit(unitToken, seenGuids)
    end

    for index = 1, 8 do
        self:TryAlertUnit("boss" .. index, seenGuids)
    end

    for index = 1, 40 do
        self:TryAlertUnit("nameplate" .. index, seenGuids)
    end

    for guid in pairs(nearbyNpcGuids) do
        if not seenGuids[guid] then
            nearbyNpcGuids[guid] = nil
        end
    end
end

-- Handle VIGNETTE_MINIMAP_UPDATED
function Alert:OnVignetteUpdate(vignetteGUID)
    if not MRP_Settings or not MRP_Settings.showRareAlert then return end
    if not vignetteGUID then return end
    if alertedVignettes[vignetteGUID] then return end

    local vignetteInfo = C_VignetteInfo.GetVignetteInfo(vignetteGUID)
    if not vignetteInfo then return end

    local npcID = vignetteInfo.objectGUID and GetNpcIDFromGUID(vignetteInfo.objectGUID) or nil
    local trackedByNpc = npcID and npcToEntry[npcID] ~= nil or false
    local isRelevantByNpc, entryName, targetName = npcID and self:IsRelevantMountSourceNpc(npcID) or false, nil, nil
    if npcID then
        isRelevantByNpc, entryName, targetName = self:IsRelevantMountSourceNpc(npcID)
    end
    local isRelevantByName, nameEntryName, nameTargetName = self:IsRelevantMountSourceName(vignetteInfo.name)
    local shown = false
    local matchedBy = nil

    if isRelevantByNpc then
        shown = self:ShowAlert(vignetteInfo.name, npcID, targetName)
        matchedBy = "npc"
    elseif isRelevantByName then
        shown = self:ShowAlert(vignetteInfo.name, nil, nameTargetName)
        matchedBy = "name"
    end

    if trackedByNpc or isRelevantByName then
        DebugLogOnce(
            "vignette:" .. FormatDebugValue(vignetteGUID) .. ":" .. FormatDebugBool(shown) .. ":" .. FormatDebugValue(matchedBy),
            "vignette guid=%s name=%s hasObjectGUID=%s npcID=%s trackedNpc=%s matchNpc=%s matchName=%s via=%s entry=%s target=%s shown=%s",
            FormatDebugValue(vignetteGUID),
            FormatDebugValue(vignetteInfo.name),
            FormatDebugBool(vignetteInfo.objectGUID ~= nil),
            FormatDebugValue(npcID),
            FormatDebugBool(trackedByNpc),
            FormatDebugBool(isRelevantByNpc),
            FormatDebugBool(isRelevantByName),
            FormatDebugValue(matchedBy),
            FormatDebugValue(entryName or nameEntryName),
            FormatDebugValue(targetName or nameTargetName),
            FormatDebugBool(shown)
        )
    end

    if shown or isRelevantByNpc or isRelevantByName then
        alertedVignettes[vignetteGUID] = true
        return
    end
end

function Alert:OnVignettesUpdated()
    if not MRP_Settings or not MRP_Settings.showRareAlert then return end
    if not C_VignetteInfo or not C_VignetteInfo.GetVignettes then return end

    for _, vignetteGUID in ipairs(C_VignetteInfo.GetVignettes() or {}) do
        self:OnVignetteUpdate(vignetteGUID)
    end
end

function Alert:OnTargetChanged()
    if not MRP_Settings or not MRP_Settings.showRareAlert then return end
    self:TryAlertUnit("target")
end

function Alert:OnMouseoverChanged()
    if not MRP_Settings or not MRP_Settings.showRareAlert then return end
    self:TryAlertUnit("mouseover")
end

function Alert:OnNameplateAdded(unitToken)
    if not MRP_Settings or not MRP_Settings.showRareAlert then return end
    self:TryAlertUnit(unitToken)
end

function Alert:OnUnitChanged(unitToken)
    if not MRP_Settings or not MRP_Settings.showRareAlert then return end
    self:TryAlertUnit(unitToken)
end

function Alert:OnEncounterUnitsChanged()
    if not MRP_Settings or not MRP_Settings.showRareAlert then return end
    self:CheckNearbyNpcUnits()
end

-- Event watcher for nearby mount source alerts
local vignetteWatcher = CreateFrame("Frame")
local nearbyNpcTicker = nil
local scanMacroTicker = nil

function Alert:Enable()
    BuildNpcLookup()
    self:InstallHooks()
    self:MarkAlertCacheDirty()
    self:EnsureAlertableCache(true)
    self:ApplySavedPosition()
    wipe(alertDebugStates)
    vignetteWatcher:UnregisterAllEvents()
    vignetteWatcher:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
    vignetteWatcher:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    vignetteWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")
    vignetteWatcher:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        vignetteWatcher:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
        vignetteWatcher:RegisterEvent("VIGNETTES_UPDATED")
    end

    vignetteWatcher:SetScript("OnEvent", function(_, event, ...)
        if event == "INSTANCE_ENCOUNTER_ENGAGE_UNIT" then
            Alert:OnEncounterUnitsChanged()
            return
        end

        if event == "NAME_PLATE_UNIT_ADDED" then
            Alert:OnNameplateAdded(...)
            return
        end

        if event == "PLAYER_TARGET_CHANGED" then
            Alert:OnTargetChanged()
            return
        end

        if event == "UPDATE_MOUSEOVER_UNIT" then
            Alert:OnMouseoverChanged()
            return
        end

        if event == "VIGNETTE_MINIMAP_UPDATED" then
            Alert:OnVignetteUpdate(...)
            return
        end

        if event == "VIGNETTES_UPDATED" then
            Alert:OnVignettesUpdated()
        end
    end)

    self:LogCurrentStepContext("enable")

    if nearbyNpcTicker then
        nearbyNpcTicker:Cancel()
    end
    nearbyNpcTicker = C_Timer.NewTicker(NEARBY_SCAN_INTERVAL, function()
        Alert:CheckNearbyNpcUnits()
        Alert:OnVignettesUpdated()
    end)

    if scanMacroTicker then
        scanMacroTicker:Cancel()
    end
    scanMacroTicker = C_Timer.NewTicker(SCAN_MACRO_REFRESH_INTERVAL, function()
        Alert:UpdateScanMacro()
    end)

    self:CheckNearbyNpcUnits()
    self:OnVignettesUpdated()
    self:UpdateScanMacro()
end

function Alert:Disable()
    vignetteWatcher:UnregisterAllEvents()
    if nearbyNpcTicker then
        nearbyNpcTicker:Cancel()
        nearbyNpcTicker = nil
    end
    if scanMacroTicker then
        scanMacroTicker:Cancel()
        scanMacroTicker = nil
    end
    wipe(alertDebugStates)
    wipe(handledAlertKeys)
    wipe(nearbyNpcGuids)
    wipe(alertableSteps)
    wipe(alertableNpcEntries)
    wipe(alertableNameEntries)
    alertCacheFilteredStepsRef = nil
    alertCacheFilteredStepCount = 0
    alertCacheLastRefresh = 0
    alertCacheDirty = true
    self:ClearScanMacro()
    self:HideAlert()
end

-- Zone change: clear alerted vignettes so we can re-alert in new zones
function Alert:OnZoneChanged()
    self:MarkAlertCacheDirty()
    wipe(alertedVignettes)
    wipe(alertDebugStates)
    wipe(handledAlertKeys)
    wipe(nearbyNpcGuids)
    self:LogCurrentStepContext("zone-change")
    self:CheckNearbyNpcUnits()
    self:OnVignettesUpdated()
    self:UpdateScanMacro()
end
