-- MRP_Update.lua
-- local _, MRP = ...

local Update = {}
MRP.Update = Update

local PREFIX = "MRPVER1"
local ANNOUNCE_COOLDOWN = 120
local RESPONSE_COOLDOWN = 30
-- Shared hidden discovery channel: lets MRP detect peers (and version updates)
-- across the open world, not just within a guild/group. Variant suffixes are
-- tried in order so players spill into an overflow channel when one fills up.
local CHANNEL_BASE = "mrproutes"
local CHANNEL_PASSWORD = nil
local CHANNEL_JOIN_DELAY = 3
local CHANNEL_RETRY_DELAY = 4
local channelCandidates = {
    "mrproutes",
    "mrproutesb",
    "mrproutesc",
    "mrproutesd",
    "mrproutese",
}
local SOURCES = {
    { name = "GitHub", url = "https://github.com/Deathwing/Mount-Route-Planner/releases/latest" },
    { name = "CurseForge", url = "https://www.curseforge.com/wow/addons/mount-route-planner" },
    { name = "Wago", url = "https://addons.wago.io/addons/mount-route-planner" },
    { name = "WoWInterface", url = "https://www.wowinterface.com/downloads/info27171-MountRoutePlanner.html" },
}

local warnedVersions = {}
local lastSent = {}
local sourceFrame
local pendingVersion
local retryScheduled
local activeChannelName
local joiningChannel
local channelFiltersInstalled
local channelStaticPopupHooked

local function getVersion()
    local getMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    return tostring(getMetadata("MountRoutePlanner", "Version") or "unknown")
end

local function compareVersions(left, right)
    local leftParts = {}
    local rightParts = {}
    for part in tostring(left or ""):gmatch("%d+") do
        leftParts[#leftParts + 1] = tonumber(part) or 0
    end
    for part in tostring(right or ""):gmatch("%d+") do
        rightParts[#rightParts + 1] = tonumber(part) or 0
    end
    for index = 1, math.max(#leftParts, #rightParts, 1) do
        local difference = (leftParts[index] or 0) - (rightParts[index] or 0)
        if difference ~= 0 then return difference end
    end
    return 0
end

local function createSourceFrame()
    local frame = CreateFrame("Frame", "MRPUpdateSourcesFrame", UIParent, "BackdropTemplate")
    frame:SetSize(460, 190)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetClampedToScreen(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 },
    })

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -22)
    title:SetText("Mount Route Planner Updates")
    frame.title = title

    local description = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOP", title, "BOTTOM", 0, -10)
    description:SetText("Choose an official download source, then copy the selected address.")

    local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    editBox:SetSize(400, 28)
    editBox:SetPoint("BOTTOM", 0, 24)
    editBox:SetAutoFocus(false)
    editBox:SetScript("OnEscapePressed", editBox.ClearFocus)
    frame.editBox = editBox

    local previousButton
    for _, source in ipairs(SOURCES) do
        local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        button:SetSize(120, 28)
        if previousButton then
            button:SetPoint("LEFT", previousButton, "RIGHT", 10, 0)
        else
            button:SetPoint("TOPLEFT", 35, -82)
        end
        button:SetText(source.name)
        button:SetScript("OnClick", function()
            editBox:SetText(source.url)
            editBox:SetFocus()
            editBox:HighlightText()
        end)
        previousButton = button
    end

    editBox:SetText(SOURCES[1].url)
    frame:Hide()
    return frame
end

function Update:Show(newVersion)
    if not sourceFrame then sourceFrame = createSourceFrame() end
    if newVersion then
        sourceFrame.title:SetText("Mount Route Planner " .. tostring(newVersion) .. " is available")
    else
        sourceFrame.title:SetText("Mount Route Planner Updates - " .. getVersion())
    end
    sourceFrame:Show()
    sourceFrame:Raise()
end

local tryShowPendingUpdate

local function scheduleRetry(delay)
    if retryScheduled then return end
    retryScheduled = true
    C_Timer.After(delay, tryShowPendingUpdate)
end

tryShowPendingUpdate = function()
    retryScheduled = nil
    if not pendingVersion then return end
    if MRP_Settings.lastUpdatePopupVersion == pendingVersion then
        pendingVersion = nil
        return
    end
    if InCombatLockdown() then return end
    -- Only surface the update popup in rested areas (inns/cities). Popping it up
    -- mid-world is too intrusive, so defer and retry until the player is resting.
    if not IsResting() then
        scheduleRetry(5)
        return
    end
    if MRP.Changelog and MRP.Changelog:IsVisible() then
        scheduleRetry(2)
        return
    end
    local version = pendingVersion
    pendingVersion = nil
    MRP_Settings.lastUpdatePopupVersion = version
    Update:Show(version)
end

local function scheduleUpdatePopup(newVersion)
    newVersion = tostring(newVersion or "unknown")
    local detectedVersion = MRP_Settings.newestDetectedUpdateVersion
    if detectedVersion and compareVersions(detectedVersion, newVersion) > 0 then
        newVersion = detectedVersion
    end
    MRP_Settings.newestDetectedUpdateVersion = newVersion
    if MRP_Settings.lastUpdatePopupVersion and compareVersions(newVersion, MRP_Settings.lastUpdatePopupVersion) <= 0 then return end
    pendingVersion = newVersion
    scheduleRetry(3)
end

function Update:Notify(newVersion)
    newVersion = tostring(newVersion or "unknown")
    scheduleUpdatePopup(newVersion)
    if warnedVersions[newVersion] then return end
    warnedVersions[newVersion] = true
    print("|cffffff00[MRP]|r A newer version (" .. newVersion .. ") is available; you are running " .. getVersion() .. ". Type |cffffffff/mrp update|r for official GitHub, CurseForge, and Wago downloads.")
end

--- Returns true when `candidate` is a strictly newer version than `current`.
function Update:IsVersionNewer(candidate, current)
    return compareVersions(candidate, current) > 0
end

--- Print the versions of Mount Route Planner and its bundled sub-addons/libraries
--- to chat, noting if a newer version has been detected from other players.
function Update:PrintVersions()
    local getMetadata = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
    local isLoaded = C_AddOns and C_AddOns.IsAddOnLoaded or IsAddOnLoaded

    -- Print a separately-shipped companion AddOn line. GetAddOnMetadata reads the
    -- on-disk TOC, so it returns a version even when the AddOn is installed but
    -- DISABLED (unchecked in the AddOns list) — which is misleading because a
    -- disabled companion contributes nothing at runtime. So report the loaded
    -- state: skip entirely when not installed, and mark it (disabled) when it is
    -- installed but not loaded.
    local function printCompanion(label, addonName)
        local version = getMetadata(addonName, "Version")
        if not version then return end -- not installed
        if isLoaded and isLoaded(addonName) then
            print("  " .. label .. ": |cffffffff" .. tostring(version) .. "|r")
        else
            print("  " .. label .. ": |cffffffff" .. tostring(version) .. "|r |cff999999(installed, disabled)|r")
        end
    end

    print("|cffffd200Mount Route Planner versions|r")

    local mainVersion = getVersion()
    print("  Mount Route Planner: |cffffffff" .. mainVersion .. "|r")

    -- FarstriderLib is a hard dependency embedded into MRP, so its runtime value
    -- is always the active one. Prefer the separately-shipped TOC version when
    -- present, else fall back to the runtime revision (embedded dev structure).
    local fs = MRP.Farstrider
    local fsVersion = getMetadata("FarstriderLib", "Version")
        or (fs and fs.VERSION and fs.VERSION ~= 0 and fs.VERSION or nil)
    if fsVersion then
        print("  FarstriderLib: |cffffffff" .. tostring(fsVersion) .. "|r")
    end

    -- FarstriderLib Data and Mount Route Planner Data are optional companions;
    -- only report them as active when actually loaded.
    printCompanion("FarstriderLib Data", "FarstriderLibData")
    printCompanion("Mount Route Planner Data", "MountRoutePlannerData")

    -- Note a known newer version, if one has been detected from other players.
    local detected = MRP_Settings and MRP_Settings.newestDetectedUpdateVersion
    if detected and compareVersions(detected, mainVersion) > 0 then
        print("|cffff5555Update available:|r Mount Route Planner |cffffffff" .. tostring(detected)
            .. "|r has been seen from other players. Type |cffffffff/mrp update|r for download sources.")
    else
        print("|cff55ff55You're up to date|r as far as Mount Route Planner can tell.")
    end
end

-- Dedicated alias, mirroring Achievements (/ach-update) and Deathlog (/dl-update).
SLASH_MRPUPDATES1 = "/mrp-update"
SlashCmdList["MRPUPDATES"] = function()
    Update:Show()
end

local function isLocalSender(sender)
    local shortSender = Ambiguate and Ambiguate(sender or "", "short") or tostring(sender or ""):match("^[^-]+")
    return shortSender == UnitName("player")
end

---------------------------------------------------------------------------
-- Shared discovery channel
---------------------------------------------------------------------------
local function cleanChannelName(channelName)
    if type(channelName) ~= "string" then return nil end
    local cleaned = channelName:match("^%d+%.%s*(.+)$") or channelName
    return string.lower(cleaned or "")
end

local function isDiscoveryChannelName(channelName)
    local cleaned = cleanChannelName(channelName)
    return cleaned and cleaned:sub(1, #CHANNEL_BASE) == CHANNEL_BASE
end

local function extractChannelName(...)
    local explicitName = select(9, ...)
    if type(explicitName) == "string" and explicitName ~= "" then
        return cleanChannelName(explicitName)
    end
    local channelText = select(4, ...)
    if type(channelText) == "string" and channelText ~= "" then
        return cleanChannelName(channelText)
    end
    return nil
end

local function hideChannelFromChatFrames(channelName)
    if not channelName then return end
    for frameIndex = 1, 10 do
        local chatFrame = _G["ChatFrame" .. frameIndex]
        if chatFrame then
            pcall(ChatFrame_RemoveChannel, chatFrame, channelName)
        end
    end
end

local function getJoinedChannelID(channelName)
    if type(channelName) ~= "string" then return nil end
    local ok, channelID = pcall(GetChannelName, channelName)
    channelID = ok and tonumber(channelID) or nil
    if channelID and channelID ~= 0 then return channelID end
    return nil
end

local function installChannelFilters()
    if channelFiltersInstalled then return end
    channelFiltersInstalled = true
    local function channelFilter(_, _, ...)
        return isDiscoveryChannelName(extractChannelName(...)) and true or false
    end
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", channelFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", channelFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE_USER", channelFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", channelFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", channelFilter)
    if not channelStaticPopupHooked then
        channelStaticPopupHooked = true
        hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
            if data and isDiscoveryChannelName(data) then
                StaticPopup_Hide(which)
            end
        end)
    end
end

local function tryJoinDiscoveryChannel(candidateIndex)
    candidateIndex = candidateIndex or 1
    local channelName = channelCandidates[candidateIndex]
    if not channelName then
        joiningChannel = nil
        return
    end
    activeChannelName = channelName
    joiningChannel = true
    pcall(JoinChannelByName, channelName, CHANNEL_PASSWORD, nil, false)
    hideChannelFromChatFrames(channelName)
    C_Timer.After(CHANNEL_RETRY_DELAY, function()
        if getJoinedChannelID(channelName) then
            activeChannelName = channelName
            joiningChannel = nil
            hideChannelFromChatFrames(channelName)
            return
        end
        tryJoinDiscoveryChannel(candidateIndex + 1)
    end)
end

local function joinDiscoveryChannel()
    installChannelFilters()
    if activeChannelName and getJoinedChannelID(activeChannelName) then
        hideChannelFromChatFrames(activeChannelName)
        return
    end
    if joiningChannel then return end
    C_Timer.After(CHANNEL_JOIN_DELAY, function()
        tryJoinDiscoveryChannel(1)
    end)
end

local function sendVersion(distribution, cooldown, target)
    local now = GetTime()
    local key = target and (distribution .. ":" .. target) or distribution
    local previousSend = lastSent[key]
    if previousSend and now - previousSend < cooldown then return end
    lastSent[key] = now
    pcall(C_ChatInfo.SendAddonMessage, PREFIX, "V\t" .. getVersion(), distribution, target)
end

local function announceOnChannel(cooldown)
    local channelID = activeChannelName and getJoinedChannelID(activeChannelName)
    if not channelID then return end
    sendVersion("CHANNEL", cooldown or ANNOUNCE_COOLDOWN, tostring(channelID))
end

local function announceVersion()
    if IsInGuild() then sendVersion("GUILD", ANNOUNCE_COOLDOWN) end
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        sendVersion("INSTANCE_CHAT", ANNOUNCE_COOLDOWN)
    elseif IsInRaid() then
        sendVersion("RAID", ANNOUNCE_COOLDOWN)
    elseif IsInGroup() then
        sendVersion("PARTY", ANNOUNCE_COOLDOWN)
    end
    announceOnChannel(ANNOUNCE_COOLDOWN)
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
eventFrame:SetScript("OnEvent", function(_, event, prefix, message, distribution, sender)
    if event == "PLAYER_LOGIN" then
        pcall(C_ChatInfo.RegisterAddonMessagePrefix, PREFIX)
        local detectedVersion = MRP_Settings.newestDetectedUpdateVersion
        if detectedVersion and compareVersions(detectedVersion, getVersion()) > 0 then
            scheduleUpdatePopup(detectedVersion)
        else
            MRP_Settings.newestDetectedUpdateVersion = nil
        end
        C_Timer.After(8, announceVersion)
        return
    end
    if event == "PLAYER_ENTERING_WORLD" then
        joinDiscoveryChannel()
        return
    end
    if event == "ZONE_CHANGED_NEW_AREA" then
        joinDiscoveryChannel()
        return
    end
    if event == "PLAYER_REGEN_ENABLED" then
        tryShowPendingUpdate()
        return
    end
    if event == "CHAT_MSG_ADDON" then
        if prefix ~= PREFIX or isLocalSender(sender) then return end
        if type(message) ~= "string" then return end
        -- A peer explicitly asks for our version -> whisper it straight back.
        if message:match("^VER_REQ") then
            local target = Ambiguate and Ambiguate(sender, "short") or sender
            if target and target ~= "" then
                sendVersion("WHISPER", RESPONSE_COOLDOWN, target)
            end
            return
        end
        local remoteVersion = message:match("^V\t(.+)$")
        if not remoteVersion then return end
        local comparison = compareVersions(remoteVersion, getVersion())
        if comparison > 0 then
            Update:Notify(remoteVersion)
        elseif comparison < 0 and (distribution == "GUILD" or distribution == "PARTY" or distribution == "RAID" or distribution == "INSTANCE_CHAT") then
            C_Timer.After(math.random(1, 3), function()
                sendVersion(distribution, RESPONSE_COOLDOWN)
            end)
        end
        return
    end
    C_Timer.After(2, announceVersion)
end)