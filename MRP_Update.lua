-- MRP_Update.lua
-- local _, MRP = ...

local Update = {}
MRP.Update = Update

local PREFIX = "MRPVER1"
local ANNOUNCE_COOLDOWN = 120
local RESPONSE_COOLDOWN = 30
local SOURCES = {
    { name = "GitHub", url = "https://github.com/Deathwing/Mount-Route-Planner/releases/latest" },
    { name = "CurseForge", url = "https://www.curseforge.com/wow/addons/mount-route-planner" },
    { name = "Wago", url = "https://addons.wago.io/addons/mount-route-planner" },
}

local warnedVersions = {}
local lastSent = {}
local sourceFrame
local pendingVersion
local retryScheduled

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

-- Dedicated alias, mirroring Achievements (/ach-update) and Deathlog (/dl-update).
SLASH_MRPUPDATES1 = "/mrp-update"
SlashCmdList["MRPUPDATES"] = function()
    Update:Show()
end

local function isLocalSender(sender)
    local shortSender = Ambiguate and Ambiguate(sender or "", "short") or tostring(sender or ""):match("^[^-]+")
    return shortSender == UnitName("player")
end

local function sendVersion(distribution, cooldown)
    local now = GetTime()
    local previousSend = lastSent[distribution]
    if previousSend and now - previousSend < cooldown then return end
    lastSent[distribution] = now
    pcall(C_ChatInfo.SendAddonMessage, PREFIX, "V\t" .. getVersion(), distribution)
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
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("CHAT_MSG_ADDON")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
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
    if event == "PLAYER_REGEN_ENABLED" then
        tryShowPendingUpdate()
        return
    end
    if event == "CHAT_MSG_ADDON" then
        if prefix ~= PREFIX or isLocalSender(sender) then return end
        local remoteVersion = type(message) == "string" and message:match("^V\t(.+)$") or nil
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