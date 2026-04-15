-- MRP_Map.lua
-- local _, MRP = ...

local L = MRP.L

local Map = {}
MRP.Map = Map

-- Path state (shared with MRP_UI pathfinding logic via MRP.Map)
Map.pathKey = nil
Map.path = nil
Map.pathPos = 1
Map.pathStep = nil
local mapOverlayLines = {}
local mapOverlayArrows = {}
local mapOverlayCanvas = nil
local openWorldOverlayData = nil
local mapOverlayHooked = false

-- Route overview pools (Phase 3 — full route drawn on world map)
local routePins = {}
local routeLines = {}
local routeArrows = {}

local MAP_OVERLAY_FRAME_STRATA = "MEDIUM"
local MAP_OVERLAY_LINE_LEVEL_OFFSET = 10
local MAP_OVERLAY_ARROW_LEVEL_OFFSET = 20
local MAP_OVERLAY_ARROW_CHILD_LEVEL_OFFSET = 1
local ROUTE_PIN_FRAME_LEVEL_OFFSET = 30

-- High-strata overlay frame so pins/lines render above the fog of war.
-- Pins use a higher frame level so they stay in front of connector art.
local overlayLineFrame = nil
local overlayArrowFrame = nil

local function SetOverlayFrameRenderOrder(frame, canvas, levelOffset)
    frame:SetFrameStrata(MAP_OVERLAY_FRAME_STRATA)
    frame:SetFrameLevel((canvas:GetFrameLevel() or 0) + levelOffset)
end

local function GetRoutePinBaseFrameLevel()
    if not WorldMapFrame or not WorldMapFrame.GetCanvas then
        return ROUTE_PIN_FRAME_LEVEL_OFFSET
    end

    local canvas = WorldMapFrame:GetCanvas()
    return ((canvas and canvas:GetFrameLevel()) or 0) + ROUTE_PIN_FRAME_LEVEL_OFFSET
end

local function GetOverlayLineFrame(canvas)
    if overlayLineFrame and overlayLineFrame:GetParent() == canvas then
        return overlayLineFrame
    end
    overlayLineFrame = CreateFrame("Frame", nil, canvas)
    SetOverlayFrameRenderOrder(overlayLineFrame, canvas, MAP_OVERLAY_LINE_LEVEL_OFFSET)
    overlayLineFrame:SetAllPoints(canvas)
    return overlayLineFrame
end

local function GetOverlayArrowFrame(canvas)
    if overlayArrowFrame and overlayArrowFrame:GetParent() == canvas then
        return overlayArrowFrame
    end
    overlayArrowFrame = CreateFrame("Frame", nil, canvas)
    SetOverlayFrameRenderOrder(overlayArrowFrame, canvas, MAP_OVERLAY_ARROW_LEVEL_OFFSET)
    overlayArrowFrame:SetAllPoints(canvas)
    return overlayArrowFrame
end

local hbdPins
local function GetHBDPins()
    if hbdPins then return hbdPins end
    if LibStub then
        hbdPins = LibStub("HereBeDragons-Pins-2.0", true)
    end
    return hbdPins
end

-- Minimap pin frame
local minimapPin
local function GetMinimapPin()
    if minimapPin then return minimapPin end
    minimapPin = CreateFrame("Frame", nil, Minimap)
    minimapPin:SetSize(24, 24)
    local icon = minimapPin:CreateTexture(nil, "OVERLAY")
    icon:SetAllPoints()
    icon:SetAtlas("Waypoint-MapPin-ChatBubble")
    icon:SetVertexColor(1, 0.82, 0, 1)
    minimapPin.icon = icon
    return minimapPin
end

-- Route colors for open world spawn/patrol visualization
local ROUTE_COLORS = {
    { r = 0.20, g = 0.90, b = 0.30 }, -- green
    { r = 0.20, g = 0.60, b = 1.00 }, -- blue
    { r = 1.00, g = 0.85, b = 0.10 }, -- yellow
    { r = 1.00, g = 0.30, b = 0.20 }, -- red
    { r = 0.80, g = 0.40, b = 1.00 }, -- purple
    { r = 1.00, g = 0.55, b = 0.10 }, -- orange
}

local ROUTE_PIN_TEXTURE = "Interface\\AddOns\\MountRoutePlanner\\Assets\\M_Pin_NEW.tga"
local ROUTE_CLUSTER_PIN_TEXTURE = "Interface\\AddOns\\MountRoutePlanner\\Assets\\M_Pin_Cluster_NEW.tga"
local ROUTE_CURRENT_PIN_TEXTURE = "Interface\\AddOns\\MountRoutePlanner\\Assets\\M_Pin_Current_NEW.tga"
local ROUTE_TARGET_PIN_TEXTURE = "Interface\\AddOns\\MountRoutePlanner\\Assets\\M_Pin_Target.tga"
local ROUTE_OPEN_WORLD_PIN_TEXTURE = "Interface\\AddOns\\MountRoutePlanner\\Assets\\M_Pin_Boss_NEW.tga"
local ROUTE_PIN_TEMPLATE = "MRPRouteWorldMapPinTemplate"
local ROUTE_PIN_FILL_RATIO = 0.75
local ROUTE_PIN_DEFAULT_SIZE = 20
local ROUTE_OPEN_WORLD_PIN_SIZE = 32
local ROUTE_OPEN_WORLD_PIN_ICON_RATIO = 0.9
local ROUTE_PIN_WORLD_MIN_SCALE = 0.45
local ROUTE_PIN_CONTINENT_MIN_SCALE = 0.55
local ROUTE_PIN_LOCAL_MIN_SCALE = 0.7
local ROUTE_PIN_MAX_SCALE = 1.0
local ROUTE_PIN_FRAME_LEVEL_TYPE = "PIN_FRAME_LEVEL_MAP_LINK"
local CURRENT_PATH_PIN_FRAME_LEVEL_BOOST = 100
local ROUTE_CLUSTER_DISTANCE_LOCAL = 22
local ROUTE_CLUSTER_DISTANCE_CONTINENT = 38
local ROUTE_CLUSTER_DISTANCE_WORLD = 72
local SHOW_CURRENT_STEP_PLAYER_GUIDE = false
local CURRENT_ACTIVE_R = 0.20
local CURRENT_ACTIVE_G = 0.90
local CURRENT_ACTIVE_B = 0.30
local CURRENT_ACTIVE_HIGHLIGHT_ALPHA = 0.45
local CURRENT_ACTIVE_GLOW_ALPHA = 0.9

---@class RoutePinInfo
local RoutePinType = {
    Step = "step",
    Cluster = "cluster",
    CurrentStep = "currentStep",
    CurrentPath = "currentPath",
    OpenWorld = "openWorld",
}

local ROUTE_PIN_TEXTURES = {
    [RoutePinType.Step] = ROUTE_PIN_TEXTURE,
    [RoutePinType.Cluster] = ROUTE_CLUSTER_PIN_TEXTURE,
    [RoutePinType.CurrentStep] = ROUTE_CURRENT_PIN_TEXTURE,
    [RoutePinType.CurrentPath] = ROUTE_TARGET_PIN_TEXTURE,
    [RoutePinType.OpenWorld] = ROUTE_OPEN_WORLD_PIN_TEXTURE,
}

---@class MRPRouteWorldMapPinPool
---@field parent table?
---@field createFunc function?
---@field resetFunc function?
---@field creationFunc function?
---@field resetterFunc function?

local routeWorldMapPinPool = nil ---@type MRPRouteWorldMapPinPool?
local RouteWorldMapPinMixin = CreateFromMixins(MapCanvasPinMixin)
local GetNextRoutePinStepIdx
local ApplyRoutePinScalingLimits
local SetRoutePinHoverVisualState
local SetRoutePinHoverGroupState
local SetRoutePinEffectColors

local function InitializeRoutePinVisuals(pin)
    if pin.base then
        return
    end

    -- Masked center fill so the step number remains readable inside M_Pin.
    local bg = pin:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("CENTER", 0, 0)
    bg:SetTexture("Interface\\Buttons\\WHITE8X8")
    local bgMask = pin:CreateMaskTexture()
    bgMask:SetAllPoints(bg)
    bgMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    bg:AddMaskTexture(bgMask)
    pin.bg = bg

    local glow = pin:CreateTexture(nil, "BACKGROUND")
    glow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
    glow:SetTexCoord(0.00781250, 0.50781250, 0.27734375, 0.52734375)
    glow:SetVertexColor(1, 0.82, 0, 0.8)
    glow:SetBlendMode("ADD")
    glow:Hide()
    pin.glow = glow

    local pulseAG = glow:CreateAnimationGroup()
    pulseAG:SetLooping("BOUNCE")
    local fadeOut = pulseAG:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0.3)
    fadeOut:SetDuration(0.6)
    fadeOut:SetSmoothing("IN_OUT")
    pin.pulseAG = pulseAG

    local icon = pin:CreateTexture(nil, "OVERLAY")
    icon:SetPoint("CENTER", 0, 0)
    local iconMask = pin:CreateMaskTexture()
    iconMask:SetAllPoints(icon)
    iconMask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask")
    icon:AddMaskTexture(iconMask)
    pin.icon = icon
    pin.iconMask = iconMask

    local base = pin:CreateTexture(nil, "ARTWORK")
    base:SetTexture(ROUTE_PIN_TEXTURE)
    pin.base = base

    local highlight = pin:CreateTexture(nil, "OVERLAY")
    highlight:SetBlendMode("ADD")
    highlight:SetVertexColor(1, 1, 1, 0.4)
    highlight:Hide()
    pin.highlight = highlight

    local label = pin:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetJustifyH("CENTER")
    label:SetShadowOffset(1, -1)
    label:SetShadowColor(0, 0, 0, 1)
    do
        local fontFile, _, fontFlags = label:GetFont()
        if fontFile then
            pin.labelFontFile = fontFile
            pin.labelFontFlags = fontFlags
            label:SetFont(fontFile, 14, fontFlags)
        end
    end
    pin.label = label

    local badge = pin:CreateTexture(nil, "OVERLAY")
    badge:SetSize(12, 12)
    badge:SetPoint("BOTTOMRIGHT", pin, "BOTTOMRIGHT", 6, -6)
    pin.badge = badge

    pin:EnableMouse(true)
    pin:SetScript("OnEnter", function(self)
        if self.tooltipTitle then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(self.tooltipTitle, 1, 1, 1)
            if self.tooltipLines and #self.tooltipLines > 0 then
                GameTooltip:AddLine(" ")
                for _, tooltipLine in ipairs(self.tooltipLines) do
                    GameTooltip:AddLine(tooltipLine, 0.95, 0.85, 0.35, true)
                end
            end
            GameTooltip:AddLine(" ")
            if self.tooltipMounts then
                for _, m in ipairs(self.tooltipMounts) do
                    local name, icon, isCollected = MRP.Util.GetMountInfoSafe(m)
                    local iconStr = "|T" .. (icon or "Interface\\Icons\\INV_Misc_QuestionMark") .. ":16:16:0:0:64:64:0:64:0:64|t"
                    if isCollected then
                        GameTooltip:AddLine(iconStr .. "  " .. (name or m.name) .. "  |TInterface\\RaidFrame\\ReadyCheck-Ready:12:12|t", 0.5, 0.5, 0.5)
                    else
                        GameTooltip:AddLine(iconStr .. "  " .. (name or m.name), 1, 1, 1)
                    end
                end
            end
            if self.tooltipWarning then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("|cffff9900" .. self.tooltipWarning .. "|r", 1, 1, 1, true)
            end
            if self.routeStepIndices and #self.routeStepIndices > 0 then
                local nextStepIdx = GetNextRoutePinStepIdx(self.routeStepIndices, MRP_CharacterSettings.currentStep)
                if nextStepIdx then
                    GameTooltip:AddLine(" ")
                    if #self.routeStepIndices > 1 then
                        GameTooltip:AddLine(string.format("Shift-click: set current step to #%d and cycle this cluster", nextStepIdx), 0.75, 0.82, 0.95, true)
                    else
                        GameTooltip:AddLine(string.format("Shift-click: set current step to #%d", nextStepIdx), 0.75, 0.82, 0.95, true)
                    end
                end
            end
            GameTooltip:Show()
        end
        SetRoutePinHoverGroupState(self, true)
    end)
    pin:SetScript("OnLeave", function(self)
        if GameTooltip:GetOwner() == self then
            GameTooltip:Hide()
        end
        SetRoutePinHoverGroupState(self, false)
    end)
    pin:SetScript("OnMouseUp", function(self, button)
        if button ~= "LeftButton" or not IsShiftKeyDown() then
            return
        end

        local nextStepIdx = GetNextRoutePinStepIdx(self.routeStepIndices, MRP_CharacterSettings.currentStep)
        if nextStepIdx then
            MRP.Core:SetCurrentStep(nextStepIdx)
        end
    end)
end

SetRoutePinHoverVisualState = function(pin, isActive)
    if not pin or not pin.highlight or not pin.glow then
        return
    end

    if isActive or pin.alwaysGlow then
        pin.highlight:Show()
        pin.glow:Show()
        pin.pulseAG:Play()
    else
        pin.pulseAG:Stop()
        pin.glow:Hide()
        pin.highlight:Hide()
    end
end

SetRoutePinHoverGroupState = function(pin, isActive)
    if not pin then
        return
    end

    local highlightGroup = pin.highlightGroup
    if not highlightGroup then
        SetRoutePinHoverVisualState(pin, isActive)
        return
    end

    local seen = {}
    for _, candidate in pairs(routePins) do
        if candidate and not seen[candidate] and candidate.highlightGroup == highlightGroup and candidate:IsShown() then
            SetRoutePinHoverVisualState(candidate, isActive)
            seen[candidate] = true
        end
    end
end

SetRoutePinEffectColors = function(pin, pinType)
    if pinType == RoutePinType.CurrentStep or pinType == RoutePinType.CurrentPath then
        pin.highlight:SetVertexColor(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, CURRENT_ACTIVE_HIGHLIGHT_ALPHA)
        pin.glow:SetVertexColor(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, CURRENT_ACTIVE_GLOW_ALPHA)
    else
        pin.highlight:SetVertexColor(1, 1, 1, 0.4)
        pin.glow:SetVertexColor(1, 0.82, 0, 0.8)
    end
end

---@param pin table
---@param pinType string
local function ConfigureRoutePinLayout(pin, pinType)
    pin.bg:ClearAllPoints()
    pin.glow:ClearAllPoints()
    pin.base:ClearAllPoints()
    pin.highlight:ClearAllPoints()
    pin.label:ClearAllPoints()
    pin:UseFrameLevelType(ROUTE_PIN_FRAME_LEVEL_TYPE)
    ApplyRoutePinScalingLimits(pin)
    pin:SetFrameStrata(MAP_OVERLAY_FRAME_STRATA)
    pin:SetFrameLevel(math.max(pin:GetFrameLevel() or 0, GetRoutePinBaseFrameLevel())
        + (pinType == RoutePinType.CurrentPath and CURRENT_PATH_PIN_FRAME_LEVEL_BOOST or 0))
    pin.highlightGroup = pinType == RoutePinType.OpenWorld and "openWorldOverlay" or nil
    pin.alwaysGlow = pinType == RoutePinType.CurrentStep or pinType == RoutePinType.CurrentPath
    SetRoutePinEffectColors(pin, pinType)

    pin.bg:SetPoint("CENTER", 0, 0)
    pin.glow:SetPoint("TOPLEFT", -10, 10)
    pin.glow:SetPoint("BOTTOMRIGHT", 10, -10)
    pin.base:SetTexture(ROUTE_PIN_TEXTURES[pinType] or ROUTE_PIN_TEXTURE)
    pin.base:SetPoint("TOPLEFT", -4, 4)
    pin.base:SetPoint("BOTTOMRIGHT", 4, -4)
    pin.highlight:SetTexture(ROUTE_PIN_TEXTURES[pinType] or ROUTE_PIN_TEXTURE)
    pin.highlight:SetPoint("TOPLEFT", -4, 4)
    pin.highlight:SetPoint("BOTTOMRIGHT", 4, -4)
    pin.label:SetPoint("CENTER", 0, 0)
end

ApplyRoutePinScalingLimits = function(pin)
    local minScale = ROUTE_PIN_LOCAL_MIN_SCALE
    local mapInfo = C_Map.GetMapInfo(WorldMapFrame:GetMapID() or 0)
    local mapType = mapInfo and mapInfo.mapType
    if not mapType or mapType <= 1 then
        minScale = ROUTE_PIN_WORLD_MIN_SCALE
    elseif mapType == 2 then
        minScale = ROUTE_PIN_CONTINENT_MIN_SCALE
    end
    pin:SetScalingLimits(1, minScale, ROUTE_PIN_MAX_SCALE)
end

local function GetRouteClusterDistance(mapID)
    local mapInfo = C_Map.GetMapInfo(mapID)
    local mapType = mapInfo and mapInfo.mapType

    if not mapType or mapType <= 1 then
        return ROUTE_CLUSTER_DISTANCE_WORLD
    end
    if mapType == 2 then
        return ROUTE_CLUSTER_DISTANCE_CONTINENT
    end
    return ROUTE_CLUSTER_DISTANCE_LOCAL
end

function GetNextRoutePinStepIdx(stepIndices, currentStepIdx)
    if not stepIndices or #stepIndices == 0 then
        return nil
    end

    currentStepIdx = currentStepIdx or 0
    for _, stepIdx in ipairs(stepIndices) do
        if stepIdx > currentStepIdx then
            return stepIdx
        end
    end

    return stepIndices[1]
end

local function SetRoutePinLabelText(pin, text, pinSize)
    local labelText = tostring(text)
    local digits = #labelText
    local baseFontSize
    if digits >= 3 then
        baseFontSize = 8
    elseif digits == 2 then
        baseFontSize = 10
    else
        baseFontSize = 13
    end

    local scale = (pinSize or ROUTE_PIN_DEFAULT_SIZE) / ROUTE_PIN_DEFAULT_SIZE
    local fontSize = math.max(8, math.floor((baseFontSize * scale) + 0.5))

    if pin.labelFontFile then
        pin.label:SetFont(pin.labelFontFile, fontSize, pin.labelFontFlags)
    end
    pin.label:SetText(labelText)
end

local function SetRoutePinStepLabel(pin, stepIdx)
    SetRoutePinLabelText(pin, stepIdx, ROUTE_PIN_DEFAULT_SIZE)
end

local function ApplyRoutePinVisualState(pin, pinSize, bgR, bgG, bgB, bgA, baseAlpha, labelText, labelR, labelG, labelB, labelA)
    pin:SetSize(pinSize, pinSize)
    pin.bg:SetSize(pinSize * ROUTE_PIN_FILL_RATIO * 5, pinSize * ROUTE_PIN_FILL_RATIO * 5)
    pin.bg:SetVertexColor(bgR, bgG, bgB, bgA)
    -- pin.bg:Show()
    pin.bg:Hide()
    pin.icon:Hide()
    pin.base:SetVertexColor(1, 1, 1, baseAlpha)
    pin.base:Show()

    if labelText ~= nil then
        SetRoutePinLabelText(pin, labelText, pinSize)
        pin.label:SetTextColor(labelR or 1, labelG or 1, labelB or 1, labelA or 1)
        pin.label:Show()
    else
        pin.label:SetText(nil)
        pin.label:Hide()
    end

    pin.badge:Hide()
    SetRoutePinHoverVisualState(pin, false)
end

local function ApplyOpenWorldPinVisualState(pin, pinSize, iconTexture)
    pin:SetSize(pinSize, pinSize)
    pin.bg:Hide()
    pin.icon:SetSize(pinSize * ROUTE_OPEN_WORLD_PIN_ICON_RATIO, pinSize * ROUTE_OPEN_WORLD_PIN_ICON_RATIO)
    pin.icon:SetTexture(iconTexture)
    pin.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    pin.icon:SetVertexColor(1, 1, 1, 1)
    pin.icon:Show()
    pin.base:SetVertexColor(1, 1, 1, 1)
    pin.base:Show()
    pin.label:SetText(nil)
    pin.label:Hide()
    pin.badge:Hide()
    SetRoutePinHoverVisualState(pin, false)
end

local function SetRouteConnectionLineColor(line, isFuture, isCurrentSegment, futureAlpha, pastAlpha)
    if isCurrentSegment then
        line:SetColorTexture(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, futureAlpha)
    elseif isFuture then
        line:SetColorTexture(1, 0.82, 0, futureAlpha)
    else
        line:SetColorTexture(0.5, 0.5, 0.5, pastAlpha)
    end
end

local function SetRouteConnectionArrowColor(arrow, isFuture, isCurrentSegment, futureAlpha, pastAlpha)
    if isCurrentSegment then
        arrow.icon:SetVertexColor(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, futureAlpha)
    elseif isFuture then
        arrow.icon:SetVertexColor(1, 0.82, 0, futureAlpha)
    else
        arrow.icon:SetVertexColor(0.5, 0.5, 0.5, pastAlpha)
    end
end

local function GetRoutePinBadgeAtlas(sourceType)
    if sourceType == MRP.FilterSourceType.Dungeon then
        return "Dungeon"
    elseif sourceType == MRP.FilterSourceType.Raid then
        return "Raid"
    elseif sourceType == MRP.FilterSourceType.WorldBoss then
        return "VignetteKillElite"
    elseif sourceType == MRP.FilterSourceType.OpenWorld then
        return "VignetteKillElite"
    elseif sourceType == MRP.FilterSourceType.Quest then
        return "QuestNormal"
    elseif sourceType == MRP.FilterSourceType.Treasure then
        return "VignetteLoot"
    elseif sourceType == MRP.FilterSourceType.Vendor then
        return "Banker"
    end
    return nil
end

local function BuildRoutePinClusters(visibleRoute, canvasW, canvasH, currentStepIdx)
    local clusters = {}
    local thresholdSq = GetRouteClusterDistance(WorldMapFrame:GetMapID()) ^ 2

    for visibleIndex, info in ipairs(visibleRoute) do
        local pixelX = info.x * canvasW
        local pixelY = info.y * canvasH
        local clusterMatch

        info.visibleIndex = visibleIndex

        for _, cluster in ipairs(clusters) do
            local dx = pixelX - cluster.pixelX
            local dy = pixelY - cluster.pixelY
            if (dx * dx + dy * dy) <= thresholdSq then
                clusterMatch = cluster
                break
            end
        end

        if not clusterMatch then
            clusterMatch = {
                count = 0,
                sumX = 0,
                sumY = 0,
                x = info.x,
                y = info.y,
                pixelX = pixelX,
                pixelY = pixelY,
                members = {},
            }
            table.insert(clusters, clusterMatch)
        end

        clusterMatch.count = clusterMatch.count + 1
        clusterMatch.sumX = clusterMatch.sumX + info.x
        clusterMatch.sumY = clusterMatch.sumY + info.y
        clusterMatch.x = clusterMatch.sumX / clusterMatch.count
        clusterMatch.y = clusterMatch.sumY / clusterMatch.count
        clusterMatch.pixelX = clusterMatch.x * canvasW
        clusterMatch.pixelY = clusterMatch.y * canvasH

        table.insert(clusterMatch.members, info)
        info.cluster = clusterMatch
    end

    for _, cluster in ipairs(clusters) do
        local seenMounts = {}
        local sameSourceType = cluster.members[1] and cluster.members[1].sourceType or nil

        cluster.allPast = true
        cluster.allUnavailable = true
        cluster.containsCurrent = false
        cluster.primaryInfo = cluster.members[1]
        cluster.mounts = {}
        cluster.tooltipLines = cluster.count > 1 and {} or nil

        for memberIndex, info in ipairs(cluster.members) do
            info.displayX = cluster.x
            info.displayY = cluster.y

            if info.stepIdx == currentStepIdx then
                cluster.containsCurrent = true
                cluster.primaryInfo = info
            end
            if info.stepIdx >= currentStepIdx then
                cluster.allPast = false
            end
            if info.conditionsMet then
                cluster.allUnavailable = false
            end
            if sameSourceType ~= info.sourceType then
                sameSourceType = nil
            end

            for _, mount in ipairs(info.mounts) do
                if not seenMounts[mount.id] then
                    seenMounts[mount.id] = true
                    table.insert(cluster.mounts, mount)
                end
            end

            if cluster.tooltipLines and memberIndex <= 5 then
                table.insert(cluster.tooltipLines, string.format("#%d  %s", info.stepIdx, info.name))
            end
        end

        if cluster.tooltipLines and cluster.count > 5 then
            table.insert(cluster.tooltipLines, string.format("...and %d more", cluster.count - 5))
        end

        -- Pin a cluster that contains the current step to the current step's
        -- exact position instead of the member centroid.
        if cluster.containsCurrent then
            cluster.x = cluster.primaryInfo.x
            cluster.y = cluster.primaryInfo.y
            cluster.pixelX = cluster.x * canvasW
            cluster.pixelY = cluster.y * canvasH
        end

        cluster.stepIndices = {}
        for _, info in ipairs(cluster.members) do
            table.insert(cluster.stepIndices, info.stepIdx)
        end

        cluster.badgeAtlas = cluster.count == 1 and GetRoutePinBadgeAtlas(sameSourceType) or nil
        if cluster.count == 1 then
            cluster.tooltipTitle = string.format("#%d  %s", cluster.primaryInfo.stepIdx, cluster.primaryInfo.name)
            cluster.tooltipLines = nil
        else
            cluster.tooltipTitle = string.format("%d overlapping route steps", cluster.count)
        end
        local conditionsWarning
        if cluster.primaryInfo.conditions then
            for _, cond in ipairs(cluster.primaryInfo.conditions) do
                if not cond.met then
                    conditionsWarning = cond.message
                    break
                end
            end
        end
        cluster.tooltipWarning = conditionsWarning or cluster.primaryInfo.difficultyWarning or nil
    end

    return clusters
end

local function ResetRoutePinVisuals(pin)
    if not pin.base then
        return
    end

    pin:SetSize(1, 1)
    pin:SetAlpha(1)
    pin.tooltipTitle = nil
    pin.tooltipLines = nil
    pin.tooltipMounts = nil
    pin.tooltipWarning = nil
    pin.routeStepIndices = nil
    pin.highlightGroup = nil
    pin.alwaysGlow = nil
    pin.bg:Hide()
    pin.bg:SetVertexColor(1, 1, 1, 1)
    pin.pulseAG:Stop()
    pin.glow:Hide()
    pin.icon:SetTexture(nil)
    pin.icon:Hide()
    pin.base:Hide()
    pin.base:SetVertexColor(1, 1, 1, 1)
    pin.highlight:Hide()
    pin.label:SetText(nil)
    pin.label:Hide()
    pin.badge:Hide()
end

function RouteWorldMapPinMixin:OnLoad()
    self:SetFrameStrata(MAP_OVERLAY_FRAME_STRATA)
    self:UseFrameLevelType(ROUTE_PIN_FRAME_LEVEL_TYPE)
    ApplyRoutePinScalingLimits(self)
    InitializeRoutePinVisuals(self)
    ResetRoutePinVisuals(self)
end

function RouteWorldMapPinMixin:OnAcquired(x, y)
    InitializeRoutePinVisuals(self)
    self:SetFrameStrata(MAP_OVERLAY_FRAME_STRATA)
    self:UseFrameLevelType(ROUTE_PIN_FRAME_LEVEL_TYPE)
    ApplyRoutePinScalingLimits(self)
    self:SetParent(WorldMapFrame:GetCanvas())
    self:SetPosition(x, y)
    ResetRoutePinVisuals(self)
end

function RouteWorldMapPinMixin:OnReleased()
    if GameTooltip:GetOwner() == self then
        GameTooltip:Hide()
    end
    ResetRoutePinVisuals(self)
end

RouteWorldMapPinMixin.SetPassThroughButtons = function() end

local function EnsureRouteWorldMapPinPool(canvas)
    if not WorldMapFrame or not WorldMapFrame.GetCanvas then
        return false
    end

    WorldMapFrame.pinPools = WorldMapFrame.pinPools or {}

    if routeWorldMapPinPool then
        routeWorldMapPinPool.parent = canvas
        return true
    end

    if WorldMapFrame.pinPools[ROUTE_PIN_TEMPLATE] then
        routeWorldMapPinPool = WorldMapFrame.pinPools[ROUTE_PIN_TEMPLATE]
        routeWorldMapPinPool.parent = canvas
        return true
    end

    if CreateUnsecuredRegionPoolInstance then
        routeWorldMapPinPool = CreateUnsecuredRegionPoolInstance(ROUTE_PIN_TEMPLATE)
    else
        routeWorldMapPinPool = CreateFramePool("FRAME")
    end

    local pool = routeWorldMapPinPool
    if not pool then
        return false
    end

    pool.parent = canvas
    pool.createFunc = function()
        local pinCanvas = WorldMapFrame:GetCanvas() or canvas
        local frame = CreateFrame("Frame", nil, pinCanvas)
        frame:SetSize(1, 1)
        frame:SetFrameStrata(MAP_OVERLAY_FRAME_STRATA)
        return Mixin(frame, RouteWorldMapPinMixin)
    end
    pool.resetFunc = function(pinPool, pin)
        pin:Hide()
        pin:ClearAllPoints()
        pin:OnReleased()
        pin.pinTemplate = nil
        pin.owningMap = nil
    end

    -- Pre-11.x pool field names.
    pool.creationFunc = pool.createFunc
    pool.resetterFunc = pool.resetFunc

    WorldMapFrame.pinPools[ROUTE_PIN_TEMPLATE] = pool

    return true
end

local function ReleaseAllRoutePins()
    if WorldMapFrame and WorldMapFrame.RemoveAllPinsByTemplate and WorldMapFrame.pinPools and WorldMapFrame.pinPools[ROUTE_PIN_TEMPLATE] then
        WorldMapFrame:RemoveAllPinsByTemplate(ROUTE_PIN_TEMPLATE)
    end
    wipe(routePins)
end

local function AcquireRoutePin(index, canvas, x, y)
    if not EnsureRouteWorldMapPinPool(canvas) then
        return nil
    end

    local pin = WorldMapFrame:AcquirePin(ROUTE_PIN_TEMPLATE, x, y)
    routePins[index] = pin
    return pin
end

local function GetOrCreateOverlayLine(index, canvas)
    local line = mapOverlayLines[index]
    if not line then
        local overlay = GetOverlayLineFrame(canvas)
        line = overlay:CreateLine(nil, "ARTWORK")
        line:SetThickness(2)
        mapOverlayLines[index] = line
    end
    return line
end

local function GetOrCreateOverlayArrow(index, canvas)
    local overlay = GetOverlayArrowFrame(canvas)
    local arrow = mapOverlayArrows[index]
    if not arrow then
        arrow = CreateFrame("Frame", nil, overlay)
        arrow:SetFrameLevel(overlay:GetFrameLevel() + MAP_OVERLAY_ARROW_CHILD_LEVEL_OFFSET)
        local icon = arrow:CreateTexture(nil, "OVERLAY")
        icon:SetAllPoints()
        icon:SetAtlas("Garr_FollowerPortrait_Arrow")
        arrow.icon = icon
        mapOverlayArrows[index] = arrow
    end
    arrow:SetParent(overlay)
    return arrow
end

local function NormalizeToUI(loc)
    if loc.isUI then
        return loc.mapId, loc.pos.x, loc.pos.y
    end
    local uiMapId, mapPos = C_Map.GetMapPosFromWorldPos(loc.mapId, CreateVector2D(loc.pos.x, loc.pos.y))
    if uiMapId and mapPos then
        return uiMapId, mapPos.x, mapPos.y
    end
    return nil, nil, nil
end

local function GetLocWorldPos(loc)
    if not loc or not loc.mapId or not loc.pos then
        return nil, nil
    end

    if loc.isUI then
        return C_Map.GetWorldPosFromMapPos(loc.mapId, CreateVector2D(loc.pos.x, loc.pos.y))
    end

    return loc.mapId, CreateVector2D(loc.pos.x, loc.pos.y)
end

local function ResolveLocToMapProjected(loc, currentMapID)
    if not loc or not currentMapID then
        return nil, nil
    end

    if loc.isUI and loc.mapId == currentMapID then
        return loc.pos.x, loc.pos.y
    end

    local continentID, worldPos = GetLocWorldPos(loc)
    if not continentID or not worldPos then
        return nil, nil
    end

    local _, resultPos = C_Map.GetMapPosFromWorldPos(continentID, worldPos, currentMapID)
    if resultPos then
        return resultPos.x, resultPos.y
    end

    return nil, nil
end

local function ResolveLocToMap(loc, currentMapID)
    local x, y = ResolveLocToMapProjected(loc, currentMapID)
    if x and y and x >= 0 and x <= 1 and y >= 0 and y <= 1 then
        return x, y
    end

    return nil, nil
end

local function ResolvePlayerToMap(currentMapID)
    local playerMapID = C_Map.GetBestMapForUnit("player")
    local playerPos = playerMapID and C_Map.GetPlayerMapPosition(playerMapID, "player")
    if not playerMapID or not playerPos then
        return nil, nil, playerMapID, playerPos
    end

    if playerMapID == currentMapID then
        return playerPos.x, playerPos.y, playerMapID, playerPos
    end

    local continentID, worldPos = C_Map.GetWorldPosFromMapPos(playerMapID, playerPos)
    if not continentID or not worldPos then
        return nil, nil, playerMapID, playerPos
    end

    local _, resultPos = C_Map.GetMapPosFromWorldPos(continentID, worldPos, currentMapID)
    if resultPos then
        return resultPos.x, resultPos.y, playerMapID, playerPos
    end

    return nil, nil, playerMapID, playerPos
end

-- Approximate continent center positions on the Azeroth world map (0-1 scale).
-- Used as fallback when API projection fails for cross-continent direction hints.
local CONTINENT_AZEROTH_POS = {
    [12]   = { 0.27, 0.50 }, -- Kalimdor
    [13]   = { 0.73, 0.40 }, -- Eastern Kingdoms
    [101]  = { 0.50, 0.50 }, -- Outland (no Azeroth position)
    [113]  = { 0.55, 0.08 }, -- Northrend
    [424]  = { 0.45, 0.80 }, -- Pandaria
    [572]  = { 0.50, 0.50 }, -- Draenor (no Azeroth position)
    [619]  = { 0.58, 0.25 }, -- Broken Isles
    [875]  = { 0.52, 0.65 }, -- Zandalar
    [876]  = { 0.78, 0.32 }, -- Kul Tiras
    [1550] = { 0.50, 0.50 }, -- Shadowlands (no Azeroth position)
    [1978] = { 0.50, 0.12 }, -- Dragon Isles
    [2274] = { 0.16, 0.20 }, -- Khaz Algar
}

-- Walk from any uiMapID up the parent chain to find its continent-level map.
local function GetContinentMapID(mapID)
    local info = C_Map.GetMapInfo(mapID)
    while info do
        if info.mapType == 2 then -- Enum.UIMapType.Continent
            return info.mapID
        end
        if info.parentMapID and info.parentMapID > 0 then
            info = C_Map.GetMapInfo(info.parentMapID)
        else
            break
        end
    end
    return nil
end

local function GetLocWorldMapPos(loc)
    local continentID, worldPos = GetLocWorldPos(loc)
    if not continentID or not worldPos then
        return nil, nil, nil
    end

    for _, refMap in ipairs({ 947, 946 }) do
        local _, rPos = C_Map.GetMapPosFromWorldPos(continentID, worldPos, refMap)
        if rPos then
            return rPos.x, rPos.y, false
        end
    end

    local continentMapID = GetContinentMapID(continentID) or continentID
    if CONTINENT_AZEROTH_POS[continentMapID] then
        return CONTINENT_AZEROTH_POS[continentMapID][1], CONTINENT_AZEROTH_POS[continentMapID][2], true
    end

    return nil, nil, nil
end

-- Project a data entry position onto the Azeroth (947) or Cosmic (946) world map.
-- Used to compute cross-continent direction when direct projection fails.
-- Returns x, y in Azeroth-map [0,1] space, plus isFallback=true when the
-- position could only be approximated from the continent centroid.
local function GetWorldMapPos(mapID, x, y)
    local cID, wPos = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(x / 100, y / 100))
    if cID and wPos then
        for _, refMap in ipairs({ 947, 946 }) do
            local _, rPos = C_Map.GetMapPosFromWorldPos(cID, wPos, refMap)
            if rPos then return rPos.x, rPos.y, false end
        end
    end
    -- Fallback: approximate position from continent lookup
    local contID = GetContinentMapID(mapID)
    if contID and CONTINENT_AZEROTH_POS[contID] then
        return CONTINENT_AZEROTH_POS[contID][1], CONTINENT_AZEROTH_POS[contID][2], true
    end
    return nil, nil, nil
end

-- Compute an edge point on the 0-1 map bounds by walking from (ox,oy) in direction (angle).
local function ProjectToEdge(ox, oy, angle)
    local dx, dy = math.cos(angle), math.sin(angle)
    local t = math.huge
    if dx > 0 then
        t = math.min(t, (0.99 - ox) / dx)
    elseif dx < 0 then
        t = math.min(t, (0.01 - ox) / dx)
    end
    if dy > 0 then
        t = math.min(t, (0.99 - oy) / dy)
    elseif dy < 0 then
        t = math.min(t, (0.01 - oy) / dy)
    end
    if t > 0 and t < math.huge then
        return math.max(0.01, math.min(0.99, ox + t * dx)),
            math.max(0.01, math.min(0.99, oy + t * dy))
    end
    return nil, nil
end

local PLAYER_LINE_START_PADDING_PX = 12
local CURRENT_PATH_PIN_LINE_END_MARGIN_PX = 2

local function TrimLineStartFromPlayerMarker(px, py, tx, ty, canvasW, canvasH)
    return px, py
    -- local dx = tx - px
    -- local dy = ty - py
    -- local distancePx = math.sqrt((dx * canvasW) ^ 2 + (dy * canvasH) ^ 2)

    -- if distancePx <= PLAYER_LINE_START_PADDING_PX then
    --     return px, py
    -- end

    -- local trim = PLAYER_LINE_START_PADDING_PX / distancePx
    -- return px + dx * trim, py + dy * trim
end

local function GetCurrentPathPinLineEndPaddingPx(step)
    local pinSize = ROUTE_PIN_DEFAULT_SIZE
    if step.pin then
        local pinWidth = step.pin:GetWidth() or 0
        local pinHeight = step.pin:GetHeight() or 0
        if pinWidth > 0 or pinHeight > 0 then
            pinSize = math.max(pinWidth, pinHeight)
        end
    end

    return (pinSize * 0.5) + 4 + CURRENT_PATH_PIN_LINE_END_MARGIN_PX
end

local function TrimLineEndFromCurrentPathPin(sx, sy, tx, ty, canvasW, canvasH, paddingPx)
    return tx, ty
    -- local dx = tx - sx
    -- local dy = ty - sy
    -- local distancePx = math.sqrt((dx * canvasW) ^ 2 + (dy * canvasH) ^ 2)

    -- if distancePx <= paddingPx then
    --     return tx, ty
    -- end

    -- local trim = paddingPx / distancePx
    -- return tx - dx * trim, ty - dy * trim
end

-- Resolve a data entry's position onto the currently viewed map.
-- Returns x, y as 0-1 fractions, or nil if the entry is not visible on this map.
local function ResolveEntryToMap(entryMapID, entryX, entryY, currentMapID)
    if entryMapID == currentMapID then
        return entryX / 100, entryY / 100
    end
    local continentID, worldPos = C_Map.GetWorldPosFromMapPos(entryMapID, CreateVector2D(entryX / 100, entryY / 100))
    if not continentID or not worldPos then return nil, nil end
    -- For continent/zone level maps, ensure entry shares the same coordinate space
    -- to prevent cross-continent false positives. Skip for world/cosmic maps.
    local currentInfo = C_Map.GetMapInfo(currentMapID)
    if currentInfo and currentInfo.mapType and currentInfo.mapType >= 2 then
        local targetContinent = C_Map.GetWorldPosFromMapPos(currentMapID, CreateVector2D(0.5, 0.5))
        if not targetContinent or targetContinent ~= continentID then return nil, nil end
    end
    local _, resultPos = C_Map.GetMapPosFromWorldPos(continentID, worldPos, currentMapID)
    if resultPos then
        local rx, ry = resultPos.x, resultPos.y
        -- Only show if within the visible map bounds
        if rx >= 0 and rx <= 1 and ry >= 0 and ry <= 1 then
            return rx, ry
        end
    end
    return nil, nil
end

-- Look up the data entry for a step
local function GetStepEntry(step)
    local t = step.source.type
    if t == MRP.FilterSourceType.Dungeon then
        return MRP.Data.DUNGEONS[step.source.name]
    elseif t == MRP.FilterSourceType.Raid then
        return MRP.Data.RAIDS[step.source.name]
    elseif t == MRP.FilterSourceType.WorldBoss then
        return MRP.Data.WORLD_BOSSES[step.source.name]
    elseif t == MRP.FilterSourceType.OpenWorld or t == MRP.FilterSourceType.Quest or t == MRP.FilterSourceType.Treasure or t == MRP.FilterSourceType.Vendor then
        return MRP.Data.OPEN_WORLD[step.source.name]
    end
    return nil
end

local function GetOrCreateRouteLine(index, canvas)
    local line = routeLines[index]
    if not line then
        local overlay = GetOverlayLineFrame(canvas)
        line = overlay:CreateLine(nil, "ARTWORK")
        line:SetThickness(2)
        routeLines[index] = line
    end
    return line
end

local function GetOrCreateRouteArrow(index, canvas)
    local overlay = GetOverlayArrowFrame(canvas)
    local arrow = routeArrows[index]
    if not arrow then
        arrow = CreateFrame("Frame", nil, overlay)
        arrow:SetFrameLevel(overlay:GetFrameLevel() + MAP_OVERLAY_ARROW_CHILD_LEVEL_OFFSET)
        local icon = arrow:CreateTexture(nil, "OVERLAY")
        icon:SetAllPoints()
        icon:SetAtlas("Garr_FollowerPortrait_Arrow")
        arrow.icon = icon
        routeArrows[index] = arrow
    end
    arrow:SetParent(overlay)
    return arrow
end

local function SetCurrentPathLineEndPoint(line, step, startX, startY, canvas, canvasW, canvasH)
    local endX = step.x
    local endY = step.y
    if step.pin then
        local paddingPx = GetCurrentPathPinLineEndPaddingPx(step)
        endX, endY = TrimLineEndFromCurrentPathPin(startX, startY, endX, endY, canvasW, canvasH, paddingPx)
    end
    line:SetEndPoint("TOPLEFT", canvas, endX * canvasW, -(endY * canvasH))
end

local function RaiseCurrentPathPinAboveRoutePins(currentPathPin)
    if not currentPathPin or not currentPathPin:IsShown() then
        return
    end

    local maxFrameLevel = currentPathPin:GetFrameLevel() or 0
    local seen = {}
    for _, candidate in pairs(routePins) do
        if candidate and candidate ~= currentPathPin and not seen[candidate] and candidate:IsShown() then
            maxFrameLevel = math.max(maxFrameLevel, candidate:GetFrameLevel() or 0)
            seen[candidate] = true
        end
    end

    currentPathPin:SetFrameLevel(maxFrameLevel + 1)
    currentPathPin:Raise()
end

function Map:ClearOverlay()
    for _, line in ipairs(mapOverlayLines) do line:Hide() end
    for _, arrow in ipairs(mapOverlayArrows) do arrow:Hide() end
    ReleaseAllRoutePins()
    for _, line in ipairs(routeLines) do line:Hide() end
    for _, arrow in ipairs(routeArrows) do arrow:Hide() end
    openWorldOverlayData = nil
    local pins = GetHBDPins()
    if pins then
        pins:RemoveAllMinimapIcons("MRP")
    end
end

function Map:SetOpenWorldOverlay(entry, sourceName, mounts)
    if not entry or (not entry.waypoints and not entry.routes) then
        openWorldOverlayData = nil
        return
    end
    openWorldOverlayData = {
        mapID = entry.mapID,
        waypoints = entry.waypoints,
        routeType = entry.routeType,
        mechanic = entry.mechanic,
        mainX = entry.x,
        mainY = entry.y,
        routes = entry.routes,
        sourceName = sourceName,
        mounts = mounts,
    }
end

function Map:UpdateOverlay()
    for _, line in ipairs(mapOverlayLines) do line:Hide() end
    for _, arrow in ipairs(mapOverlayArrows) do arrow:Hide() end
    ReleaseAllRoutePins()
    for _, line in ipairs(routeLines) do line:Hide() end
    for _, arrow in ipairs(routeArrows) do arrow:Hide() end

    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    if not WorldMapFrame.GetCanvas then return end

    local canvas = WorldMapFrame:GetCanvas()
    if not canvas then return end

    -- If canvas changed (map reload), invalidate old lines and overlay frame
    if mapOverlayCanvas ~= canvas then
        wipe(mapOverlayLines)
        wipe(mapOverlayArrows)
        wipe(routeLines)
        wipe(routeArrows)
        overlayLineFrame = nil
        overlayArrowFrame = nil
        mapOverlayCanvas = canvas
    end

    local currentMapID = WorldMapFrame:GetMapID()
    if not currentMapID then return end
    local showCurrentPathGuideLine = MRP_Settings.showPathfindingLinesOnMap ~= false

    local canvasW, canvasH = canvas:GetSize()
    if not canvasW or canvasW <= 0 then return end

    local pinIdx = 0
    local lineIdx = 0
    local arrowIdx = 0
    local currentPathForegroundPin = nil

    local path = self.path
    local pathPos = self.pathPos

    -- Phase 1: Draw the current pathfinding route even when the MRP window is closed.
    if path and #path > 0 then
        local currentVisiblePathStep = nil
        local currentPathStep = path[pathPos]
        local shouldShowCurrentPathPin = pathPos < #path

        if currentPathStep then
            local x, y = ResolveLocToMap(currentPathStep.loc, currentMapID)
            if x and y then
                if shouldShowCurrentPathPin then
                    local pin = AcquireRoutePin("currentPath", canvas, x, y)
                    if pin then
                        -- Show only the active navigation node to avoid misleading cross-map path chains.
                        ConfigureRoutePinLayout(pin, RoutePinType.CurrentPath)
                        ApplyRoutePinVisualState(pin, ROUTE_PIN_DEFAULT_SIZE, 0.1, 0.1, 0.1, 0.9, 1, nil)
                        pin.tooltipTitle = currentPathStep.loca
                        pin:EnableMouse(currentPathStep.loca ~= nil)
                        pin:Show()
                        currentPathForegroundPin = pin

                        currentVisiblePathStep = { pin = pin, x = x, y = y }
                    end
                else
                    -- Show only the active navigation node to avoid misleading cross-map path chains.
                    currentVisiblePathStep = { x = x, y = y }
                end
            end
        end

        if showCurrentPathGuideLine and currentVisiblePathStep then
            local px, py, playerMapID, playerPos = ResolvePlayerToMap(currentMapID)
            if px and py and px >= 0 and px <= 1 and py >= 0 and py <= 1 then
                local lineStartX, lineStartY = TrimLineStartFromPlayerMarker(
                    px,
                    py,
                    currentVisiblePathStep.x,
                    currentVisiblePathStep.y,
                    canvasW,
                    canvasH
                )
                lineIdx = lineIdx + 1
                local line = GetOrCreateOverlayLine(lineIdx, canvas)
                line:SetStartPoint("TOPLEFT", canvas, lineStartX * canvasW, -(lineStartY * canvasH))
                SetCurrentPathLineEndPoint(line, currentVisiblePathStep, lineStartX, lineStartY, canvas, canvasW, canvasH)
                line:SetColorTexture(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, 0.8)
                line:SetThickness(3)
                line:Show()

                local angle = math.atan2(currentVisiblePathStep.y - py, currentVisiblePathStep.x - px)
                arrowIdx = arrowIdx + 1
                local arrow = GetOrCreateOverlayArrow(arrowIdx, canvas)
                arrow:SetSize(18, 18)
                arrow:ClearAllPoints()
                arrow:SetPoint(
                    "CENTER",
                    canvas,
                    "TOPLEFT",
                    ((lineStartX + currentVisiblePathStep.x) / 2) * canvasW,
                    -(((lineStartY + currentVisiblePathStep.y) / 2) * canvasH)
                )
                arrow.icon:SetVertexColor(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, 0.95)
                arrow.icon:SetRotation(-angle + math.pi / 2)
                arrow:Show()
            elseif px and py then
                local edgeAngle = math.atan2(currentVisiblePathStep.y - py, currentVisiblePathStep.x - px)
                local ex, ey = ProjectToEdge(currentVisiblePathStep.x, currentVisiblePathStep.y, edgeAngle + math.pi)
                if ex then
                    lineIdx = lineIdx + 1
                    local line = GetOrCreateOverlayLine(lineIdx, canvas)
                    line:SetStartPoint("TOPLEFT", canvas, ex * canvasW, -(ey * canvasH))
                    SetCurrentPathLineEndPoint(line, currentVisiblePathStep, ex, ey, canvas, canvasW, canvasH)
                    line:SetColorTexture(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, 0.45)
                    line:SetThickness(2)
                    line:Show()

                    arrowIdx = arrowIdx + 1
                    local arrow = GetOrCreateOverlayArrow(arrowIdx, canvas)
                    arrow:SetSize(18, 18)
                    arrow:ClearAllPoints()
                    arrow:SetPoint("CENTER", canvas, "TOPLEFT", ex * canvasW, -(ey * canvasH))
                    arrow.icon:SetVertexColor(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, 0.7)
                    arrow.icon:SetRotation(-edgeAngle + math.pi / 2)
                    arrow:Show()
                end
            elseif playerMapID and playerPos and currentPathStep then
                local pAx, pAy = GetWorldMapPos(playerMapID, playerPos.x * 100, playerPos.y * 100)
                local sAx, sAy = GetLocWorldMapPos(currentPathStep.loc)
                if pAx and sAx and (pAx ~= sAx or pAy ~= sAy) then
                    local edgeAngle = math.atan2(sAy - pAy, sAx - pAx)
                    local ex, ey = ProjectToEdge(currentVisiblePathStep.x, currentVisiblePathStep.y, edgeAngle + math.pi)
                    if ex then
                        lineIdx = lineIdx + 1
                        local line = GetOrCreateOverlayLine(lineIdx, canvas)
                        line:SetStartPoint("TOPLEFT", canvas, ex * canvasW, -(ey * canvasH))
                        SetCurrentPathLineEndPoint(line, currentVisiblePathStep, ex, ey, canvas, canvasW, canvasH)
                        line:SetColorTexture(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, 0.45)
                        line:SetThickness(2)
                        line:Show()

                        arrowIdx = arrowIdx + 1
                        local arrow = GetOrCreateOverlayArrow(arrowIdx, canvas)
                        arrow:SetSize(18, 18)
                        arrow:ClearAllPoints()
                        arrow:SetPoint("CENTER", canvas, "TOPLEFT", ex * canvasW, -(ey * canvasH))
                        arrow.icon:SetVertexColor(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, 0.7)
                        arrow.icon:SetRotation(-edgeAngle + math.pi / 2)
                        arrow:Show()
                    end
                end
            end
        elseif showCurrentPathGuideLine and currentPathStep then
            local px, py, playerMapID, playerPos = ResolvePlayerToMap(currentMapID)
            if playerMapID and playerPos and px and py and px >= 0 and px <= 1 and py >= 0 and py <= 1 then
                local tx, ty = ResolveLocToMapProjected(currentPathStep.loc, currentMapID)
                local angle
                if tx and ty then
                    angle = math.atan2(ty - py, tx - px)
                else
                    local pAx, pAy = GetWorldMapPos(playerMapID, playerPos.x * 100, playerPos.y * 100)
                    local sAx, sAy = GetLocWorldMapPos(currentPathStep.loc)
                    if pAx and sAx and (pAx ~= sAx or pAy ~= sAy) then
                        angle = math.atan2(sAy - pAy, sAx - pAx)
                    end
                end

                if angle then
                    local ex, ey = ProjectToEdge(px, py, angle)
                    if ex then
                        local lineStartX, lineStartY = TrimLineStartFromPlayerMarker(px, py, ex, ey, canvasW, canvasH)
                        lineIdx = lineIdx + 1
                        local line = GetOrCreateOverlayLine(lineIdx, canvas)
                        line:SetStartPoint("TOPLEFT", canvas, lineStartX * canvasW, -(lineStartY * canvasH))
                        line:SetEndPoint("TOPLEFT", canvas, ex * canvasW, -(ey * canvasH))
                        line:SetColorTexture(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, 0.45)
                        line:SetThickness(2)
                        line:Show()

                        arrowIdx = arrowIdx + 1
                        local arrow = GetOrCreateOverlayArrow(arrowIdx, canvas)
                        arrow:SetSize(18, 18)
                        arrow:ClearAllPoints()
                        arrow:SetPoint("CENTER", canvas, "TOPLEFT", ex * canvasW, -(ey * canvasH))
                        arrow.icon:SetVertexColor(CURRENT_ACTIVE_R, CURRENT_ACTIVE_G, CURRENT_ACTIVE_B, 0.7)
                        arrow.icon:SetRotation(-angle + math.pi / 2)
                        arrow:Show()
                    end
                end
            end
        end
    end

    -- Phase 2: Draw open world overlay (routes or legacy waypoints; requires MRP frame open)
    if MRP.UI:IsShown() and openWorldOverlayData and MRP_Settings.showOpenWorldOverlayOnMap ~= false then
        -- Resolve creature portrait icon from first mount
        local creatureIcon
        local mounts = openWorldOverlayData.mounts
        if mounts and #mounts > 0 then
            local _, icon = MRP.Util.GetMountInfoSafe(mounts[1])
            if icon then
                creatureIcon = icon
            end
        end
        if not creatureIcon then
            creatureIcon = 132161 -- fallback: Interface/Icons/INV_Misc_QuestionMark
        end

        local openWorldPinIdx = 0

        local function AcquireOpenWorldOverlayPin(xPercent, yPercent, note)
            openWorldPinIdx = openWorldPinIdx + 1
            local pin = AcquireRoutePin("openWorld:" .. openWorldPinIdx, canvas, xPercent / 100, yPercent / 100)
            if not pin then
                return nil
            end

            ConfigureRoutePinLayout(pin, RoutePinType.OpenWorld)
            ApplyOpenWorldPinVisualState(pin, ROUTE_OPEN_WORLD_PIN_SIZE, creatureIcon)
            pin.tooltipTitle = openWorldOverlayData.sourceName or ""
            pin.tooltipLines = note and { note } or nil
            pin.tooltipMounts = openWorldOverlayData.mounts
            pin.tooltipWarning = nil
            pin.routeStepIndices = nil
            pin:EnableMouse(true)
            pin:Show()
            return pin
        end

        local function SetOpenWorldLineEndpoints(line, fromWaypoint, toWaypoint)
            line:SetStartPoint("TOPLEFT", canvas, (fromWaypoint.x / 100) * canvasW, -((fromWaypoint.y / 100) * canvasH))
            line:SetEndPoint("TOPLEFT", canvas, (toWaypoint.x / 100) * canvasW, -((toWaypoint.y / 100) * canvasH))
        end

        if openWorldOverlayData.routes then
            -- Multi-route mode: each route gets its own color, lines, and arrows
            for routeIdx, route in ipairs(openWorldOverlayData.routes) do
                local colorIdx = ((routeIdx - 1) % #ROUTE_COLORS) + 1
                local c = ROUTE_COLORS[colorIdx]

                -- Collect visible waypoints for this route
                local visible = {}
                for _, wp in ipairs(route.waypoints) do
                    local wpMapID = wp.mapID or openWorldOverlayData.mapID
                    if wpMapID == currentMapID then
                        table.insert(visible, wp)
                    end
                end

                -- Draw creature portrait at first waypoint only
                if #visible > 0 then
                    local routeName = route.name or ("Route " .. routeIdx)
                    AcquireOpenWorldOverlayPin(visible[1].x, visible[1].y, "Patrols along " .. routeName)
                end

                -- Draw lines connecting consecutive visible waypoints
                for i = 1, #visible - 1 do
                    lineIdx = lineIdx + 1
                    local line = GetOrCreateOverlayLine(lineIdx, canvas)
                    SetOpenWorldLineEndpoints(line, visible[i], visible[i + 1])
                    line:SetColorTexture(c.r, c.g, c.b, 0.6)
                    line:SetThickness(3)
                    line:Show()

                    -- Directional arrow at midpoint
                    local wp1 = visible[i]
                    local wp2 = visible[i + 1]
                    local midX = ((wp1.x + wp2.x) / 2 / 100) * canvasW
                    local midY = ((wp1.y + wp2.y) / 2 / 100) * canvasH
                    local angle = math.atan2(wp2.y - wp1.y, wp2.x - wp1.x)

                    arrowIdx = arrowIdx + 1
                    local arrow = GetOrCreateOverlayArrow(arrowIdx, canvas)
                    arrow:SetSize(16, 16)
                    arrow:ClearAllPoints()
                    arrow:SetPoint("CENTER", canvas, "TOPLEFT", midX, -midY)
                    arrow.icon:SetVertexColor(c.r, c.g, c.b, 0.9)
                    arrow.icon:SetRotation(-angle + math.pi / 2)
                    arrow:Show()
                end
            end
        elseif openWorldOverlayData.waypoints then
            -- Legacy single-route mode (patrol / spawns)
            local visibleWaypoints = {}
            for _, wp in ipairs(openWorldOverlayData.waypoints) do
                local wpMapID = wp.mapID or openWorldOverlayData.mapID
                if wpMapID == currentMapID then
                    table.insert(visibleWaypoints, wp)
                end
            end

            local isPatrol = openWorldOverlayData.routeType == "patrol"
            local isSpawns = openWorldOverlayData.routeType == "spawns"

            if isSpawns then
                -- Spawns mode: creature portrait at each spawn location
                for _, wp in ipairs(visibleWaypoints) do
                    AcquireOpenWorldOverlayPin(wp.x, wp.y, "Can spawn at this location")
                end
            elseif isPatrol then
                -- Patrol mode: creature portrait at first waypoint only
                if #visibleWaypoints > 0 then
                    local patrolColor = ROUTE_COLORS[1]
                    AcquireOpenWorldOverlayPin(visibleWaypoints[1].x, visibleWaypoints[1].y, "Patrols along this route")
                end
            else
                -- Default: creature portrait at each waypoint
                for _, wp in ipairs(visibleWaypoints) do
                    AcquireOpenWorldOverlayPin(wp.x, wp.y, nil)
                end
            end

            -- Draw route lines for patrol routes
            if isPatrol and #visibleWaypoints > 1 then
                local patrolColor = ROUTE_COLORS[1]
                for i = 1, #visibleWaypoints do
                    local nextIdx = (i % #visibleWaypoints) + 1
                    lineIdx = lineIdx + 1
                    local line = GetOrCreateOverlayLine(lineIdx, canvas)
                    SetOpenWorldLineEndpoints(line, visibleWaypoints[i], visibleWaypoints[nextIdx])
                    line:SetColorTexture(patrolColor.r, patrolColor.g, patrolColor.b, 0.6)
                    line:SetThickness(3)
                    line:Show()

                    local wp1 = visibleWaypoints[i]
                    local wp2 = visibleWaypoints[nextIdx]
                    local midX = ((wp1.x + wp2.x) / 2 / 100) * canvasW
                    local midY = ((wp1.y + wp2.y) / 2 / 100) * canvasH
                    local angle = math.atan2(wp2.y - wp1.y, wp2.x - wp1.x)

                    arrowIdx = arrowIdx + 1
                    local arrow = GetOrCreateOverlayArrow(arrowIdx, canvas)
                    arrow:SetSize(16, 16)
                    arrow:ClearAllPoints()
                    arrow:SetPoint("CENTER", canvas, "TOPLEFT", midX, -midY)
                    arrow.icon:SetVertexColor(patrolColor.r, patrolColor.g, patrolColor.b, 0.9)
                    arrow.icon:SetRotation(-angle + math.pi / 2)
                    arrow:Show()
                end
            end
        end
    end

    -- Phase 3: Draw route overview (all filtered steps visible on this map)
    if MRP_Settings.showRouteOnMap ~= false then
        local steps = MRP.Filter.filteredSteps
        local currentStepIdx = MRP_CharacterSettings.currentStep
        local showRouteConnectionsOnMap = MRP_Settings.showRouteConnectionsOnMap ~= false

        -- Let MapCanvasPinMixin keep the world-map pins visually consistent while zooming.
        local pinScale = 1

        -- Determine step range based on maxStepsAhead / maxStepsBehind settings
        local maxAhead = MRP_Settings.maxStepsAhead or 5
        local maxBehind = MRP_Settings.maxStepsBehind or 0
        local minIdx = (not MRP_Settings.unlimitedStepsBehind and currentStepIdx) and math.max(1, currentStepIdx - maxBehind) or 1
        local maxIdx = (not MRP_Settings.unlimitedStepsAhead and currentStepIdx) and math.min(#steps, currentStepIdx + maxAhead) or #steps

        -- Collect steps that resolve onto the current map
        local visibleRoute = {}
        for i, step in ipairs(steps) do
            if i < minIdx or i > maxIdx then
                -- skip: outside the configured step range
            else
                local entry = GetStepEntry(step)
                if entry then
                    local x, y = ResolveEntryToMap(entry.mapID, entry.x, entry.y, currentMapID)
                    if x and y then
                        local mounts = {}
                        for _, mount in ipairs(step.mounts) do
                            table.insert(mounts, { id = mount.id, name = mount.name, icon = mount.icon, spellId = mount.spellId, itemId = mount.itemId })
                        end
                        local diffWarning
                        if step.source.type == MRP.FilterSourceType.Dungeon or step.source.type == MRP.FilterSourceType.Raid then
                            local bestDifficulties = MRP.Core:GetMostSuitableDifficultyIds(step)
                            if #bestDifficulties > 0
                                and not tContains(bestDifficulties, GetDungeonDifficultyID())
                                and not tContains(bestDifficulties, WOW_PROJECT_ID == WOW_PROJECT_MAINLINE and GetLegacyRaidDifficultyID() or GetRaidDifficultyID())
                                and not tContains(bestDifficulties, GetRaidDifficultyID()) then
                                if entry.availableDifficultyIds and #bestDifficulties ~= #entry.availableDifficultyIds then
                                    if #bestDifficulties > 1 then
                                        diffWarning = string.format(L["Run the instance on any of the following difficulties to collect all mounts:\n%s"], table.concat(MRP.Util.Map(bestDifficulties, GetDifficultyInfo), ", "))
                                    else
                                        diffWarning = string.format(L["Run the instance on '%s' to collect all mounts."], GetDifficultyInfo(bestDifficulties[1]))
                                    end
                                end
                            end
                        end
                        table.insert(visibleRoute, {
                            stepIdx = i,
                            x = x,
                            y = y,
                            name = step.source.name,
                            sourceType = step.source.type,
                            conditionsMet = MRP.Util.AreStepConditionsMet(step),
                            conditions = MRP.Util.GetStepConditions(step),
                            mounts = mounts,
                            difficultyWarning = diffWarning,
                        })
                    end
                end
            end
        end

        local routePinIdx = 0
        local routeLineIdx = 0
        local routeArrowIdx = 0

        if #visibleRoute > 0 then
            local routeClusters = BuildRoutePinClusters(visibleRoute, canvasW, canvasH, currentStepIdx)

            for _, cluster in ipairs(routeClusters) do
                routePinIdx = routePinIdx + 1
                local pin = AcquireRoutePin(routePinIdx, canvas, cluster.x, cluster.y)
                if not pin then
                    return
                end

                local isCurrent = cluster.containsCurrent
                local isPast = cluster.allPast
                local condUnavailable = cluster.allUnavailable
                local isCluster = cluster.count > 1
                local clusterBonus = isCluster and 12 or 0

                ConfigureRoutePinLayout(pin, isCurrent and RoutePinType.CurrentStep or (isCluster and RoutePinType.Cluster or RoutePinType.Step))

                local baseAlpha = 1
                local pinSize
                if condUnavailable then
                    -- Condition not met (e.g. warfront not active) — dim the pin
                    pinSize = (18 + clusterBonus) * pinScale
                    baseAlpha = 0.5
                    ApplyRoutePinVisualState(pin, pinSize, 0.24, 0.14, 0.14, 0.82, baseAlpha,
                        cluster.primaryInfo.stepIdx, 0.7, 0.5, 0.5, 0.8)
                elseif isCurrent then
                    pinSize = (24 + clusterBonus) * pinScale
                    ApplyRoutePinVisualState(pin, pinSize, 0.05, 0.15, 0.05, 0.92, baseAlpha,
                        cluster.primaryInfo.stepIdx, 1, 1, 1, 1)
                elseif isPast then
                    pinSize = (18 + clusterBonus) * pinScale
                    baseAlpha = 0.75
                    ApplyRoutePinVisualState(pin, pinSize, 0.12, 0.12, 0.12, 0.86, baseAlpha,
                        cluster.primaryInfo.stepIdx, 0.7, 0.7, 0.7, 0.9)
                else
                    pinSize = (ROUTE_PIN_DEFAULT_SIZE + clusterBonus) * pinScale
                    ApplyRoutePinVisualState(pin, pinSize, 0.1, 0.1, 0.1, 0.9, baseAlpha,
                        cluster.primaryInfo.stepIdx, 1, 1, 1, 1)
                end

                -- Show source type badge
                if cluster.badgeAtlas then
                    pin.badge:SetAtlas(cluster.badgeAtlas)
                    pin.badge:SetAlpha(condUnavailable and 0.4 or (isCurrent and 1 or (isPast and 0.5 or 0.9)))
                    pin.badge:Show()
                else
                    pin.badge:Hide()
                end

                -- Tooltip
                pin.tooltipTitle = cluster.tooltipTitle
                pin.tooltipLines = cluster.tooltipLines
                pin.tooltipMounts = cluster.mounts
                pin.tooltipWarning = cluster.tooltipWarning
                pin.routeStepIndices = cluster.stepIndices

                pin:Show()

                for _, info in ipairs(cluster.members) do
                    routePins[info.visibleIndex] = pin
                end
            end

            if showRouteConnectionsOnMap then
                -- Connect consecutive visible route steps with lines and arrows
                for j = 1, #visibleRoute - 1 do
                    local cur = visibleRoute[j]
                    local nxt = visibleRoute[j + 1]
                    local curPin = routePins[j]
                    local nxtPin = routePins[j + 1]

                    local isFuture = cur.stepIdx >= currentStepIdx
                    local hasGap = nxt.stepIdx - cur.stepIdx > 1

                    if curPin ~= nxtPin then
                        routeLineIdx = routeLineIdx + 1
                        local line = GetOrCreateRouteLine(routeLineIdx, canvas)
                        line:SetStartPoint("CENTER", curPin)
                        line:SetEndPoint("CENTER", nxtPin)
                        local isCurrentSegment = cur.stepIdx == currentStepIdx
                        SetRouteConnectionLineColor(line, isFuture, isCurrentSegment, hasGap and 0.25 or 0.7, hasGap and 0.15 or 0.35)
                        line:SetThickness(hasGap and 2 or 3)
                        line:Show()

                        -- Directional arrow at midpoint
                        local midX = (((cur.displayX or cur.x) + (nxt.displayX or nxt.x)) / 2) * canvasW
                        local midY = (((cur.displayY or cur.y) + (nxt.displayY or nxt.y)) / 2) * canvasH
                        local angle = math.atan2((nxt.displayY or nxt.y) - (cur.displayY or cur.y), (nxt.displayX or nxt.x) - (cur.displayX or cur.x))

                        routeArrowIdx = routeArrowIdx + 1
                        local arrow = GetOrCreateRouteArrow(routeArrowIdx, canvas)
                        arrow:SetSize(20, 20)
                        arrow:ClearAllPoints()
                        arrow:SetPoint("CENTER", canvas, "TOPLEFT", midX, -midY)
                        SetRouteConnectionArrowColor(arrow, isFuture, isCurrentSegment, 0.9, 0.5)
                        arrow.icon:SetRotation(-angle + math.pi / 2)
                        arrow:Show()
                    end

                    -- Mid-route gap: off-screen steps between cur and nxt
                    if hasGap then
                        -- Outgoing from cur toward first off-screen step
                        local nextOffEntry = GetStepEntry(steps[cur.stepIdx + 1])
                        if nextOffEntry then
                            local edgeX, edgeY
                            local cID, wPos = C_Map.GetWorldPosFromMapPos(nextOffEntry.mapID, CreateVector2D(nextOffEntry.x / 100, nextOffEntry.y / 100))
                            if cID and wPos then
                                local targetCont = C_Map.GetWorldPosFromMapPos(currentMapID, CreateVector2D(0.5, 0.5))
                                if targetCont and targetCont == cID then
                                    local _, rPos = C_Map.GetMapPosFromWorldPos(cID, wPos, currentMapID)
                                    if rPos and (rPos.x < 0 or rPos.x > 1 or rPos.y < 0 or rPos.y > 1) then
                                        edgeX = math.max(0.01, math.min(0.99, rPos.x))
                                        edgeY = math.max(0.01, math.min(0.99, rPos.y))
                                    end
                                end
                            end
                            if not edgeX then
                                local curEntry = GetStepEntry(steps[cur.stepIdx])
                                if curEntry then
                                    local ax1, ay1 = GetWorldMapPos(curEntry.mapID, curEntry.x, curEntry.y)
                                    local ax2, ay2 = GetWorldMapPos(nextOffEntry.mapID, nextOffEntry.x, nextOffEntry.y)
                                    if ax1 and ax2 and (ax1 ~= ax2 or ay1 ~= ay2) then
                                        local gapAngle = math.atan2(ay2 - ay1, ax2 - ax1)
                                        edgeX, edgeY = ProjectToEdge(cur.displayX or cur.x, cur.displayY or cur.y, gapAngle)
                                    end
                                end
                            end
                            if edgeX then
                                routeLineIdx = routeLineIdx + 1
                                local eline = GetOrCreateRouteLine(routeLineIdx, canvas)
                                eline:SetStartPoint("CENTER", curPin)
                                eline:SetEndPoint("TOPLEFT", canvas, edgeX * canvasW, -(edgeY * canvasH))
                                SetRouteConnectionLineColor(eline, isFuture, cur.stepIdx == currentStepIdx, 0.3, 0.15)
                                eline:SetThickness(2)
                                eline:Show()

                                local eAngle = math.atan2(edgeY - (cur.displayY or cur.y), edgeX - (cur.displayX or cur.x))
                                routeArrowIdx = routeArrowIdx + 1
                                local eArrow = GetOrCreateRouteArrow(routeArrowIdx, canvas)
                                eArrow:SetSize(20, 20)
                                eArrow:ClearAllPoints()
                                eArrow:SetPoint("CENTER", canvas, "TOPLEFT", edgeX * canvasW, -(edgeY * canvasH))
                                SetRouteConnectionArrowColor(eArrow, isFuture, cur.stepIdx == currentStepIdx, 0.5, 0.25)
                                eArrow.icon:SetRotation(-eAngle + math.pi / 2)
                                eArrow:Show()
                            end
                        end

                        -- Incoming to nxt from last off-screen step
                        local prevOffEntry = GetStepEntry(steps[nxt.stepIdx - 1])
                        if prevOffEntry then
                            local edgeX, edgeY
                            local cID, wPos = C_Map.GetWorldPosFromMapPos(prevOffEntry.mapID, CreateVector2D(prevOffEntry.x / 100, prevOffEntry.y / 100))
                            if cID and wPos then
                                local targetCont = C_Map.GetWorldPosFromMapPos(currentMapID, CreateVector2D(0.5, 0.5))
                                if targetCont and targetCont == cID then
                                    local _, rPos = C_Map.GetMapPosFromWorldPos(cID, wPos, currentMapID)
                                    if rPos and (rPos.x < 0 or rPos.x > 1 or rPos.y < 0 or rPos.y > 1) then
                                        edgeX = math.max(0.01, math.min(0.99, rPos.x))
                                        edgeY = math.max(0.01, math.min(0.99, rPos.y))
                                    end
                                end
                            end
                            if not edgeX then
                                local nxtEntry = GetStepEntry(steps[nxt.stepIdx])
                                if nxtEntry then
                                    local ax1, ay1 = GetWorldMapPos(prevOffEntry.mapID, prevOffEntry.x, prevOffEntry.y)
                                    local ax2, ay2 = GetWorldMapPos(nxtEntry.mapID, nxtEntry.x, nxtEntry.y)
                                    if ax1 and ax2 and (ax1 ~= ax2 or ay1 ~= ay2) then
                                        local gapAngle = math.atan2(ay2 - ay1, ax2 - ax1)
                                        edgeX, edgeY = ProjectToEdge(nxt.displayX or nxt.x, nxt.displayY or nxt.y, gapAngle + math.pi)
                                    end
                                end
                            end
                            if edgeX then
                                routeLineIdx = routeLineIdx + 1
                                local eline = GetOrCreateRouteLine(routeLineIdx, canvas)
                                eline:SetStartPoint("TOPLEFT", canvas, edgeX * canvasW, -(edgeY * canvasH))
                                eline:SetEndPoint("CENTER", nxtPin)
                                SetRouteConnectionLineColor(eline, isFuture, false, 0.3, 0.15)
                                eline:SetThickness(2)
                                eline:Show()

                                local eAngle = math.atan2((nxt.displayY or nxt.y) - edgeY, (nxt.displayX or nxt.x) - edgeX)
                                routeArrowIdx = routeArrowIdx + 1
                                local eArrow = GetOrCreateRouteArrow(routeArrowIdx, canvas)
                                eArrow:SetSize(20, 20)
                                eArrow:ClearAllPoints()
                                eArrow:SetPoint("CENTER", canvas, "TOPLEFT", edgeX * canvasW, -(edgeY * canvasH))
                                SetRouteConnectionArrowColor(eArrow, isFuture, false, 0.5, 0.25)
                                eArrow.icon:SetRotation(-eAngle + math.pi / 2)
                                eArrow:Show()
                            end
                        end
                    end
                end

                -- Off-screen edge connections for steps just outside the visible map
                local firstInfo = visibleRoute[1]
                local lastInfo = visibleRoute[#visibleRoute]

                -- Outgoing: last visible step → next off-screen step (clamped to map edge)
                if lastInfo.stepIdx < #steps then
                    local nextStep = steps[lastInfo.stepIdx + 1]
                    local nextEntry = GetStepEntry(nextStep)
                    if nextEntry then
                        local edgeX, edgeY
                        -- Try direct projection (same continent, off-screen)
                        local cID, wPos = C_Map.GetWorldPosFromMapPos(nextEntry.mapID, CreateVector2D(nextEntry.x / 100, nextEntry.y / 100))
                        if cID and wPos then
                            local targetCont = C_Map.GetWorldPosFromMapPos(currentMapID, CreateVector2D(0.5, 0.5))
                            if targetCont and targetCont == cID then
                                local _, rPos = C_Map.GetMapPosFromWorldPos(cID, wPos, currentMapID)
                                if rPos and (rPos.x < 0 or rPos.x > 1 or rPos.y < 0 or rPos.y > 1) then
                                    edgeX = math.max(0.01, math.min(0.99, rPos.x))
                                    edgeY = math.max(0.01, math.min(0.99, rPos.y))
                                end
                            end
                        end
                        -- Cross-continent fallback: compute direction on world map
                        if not edgeX then
                            local lastEntry = GetStepEntry(steps[lastInfo.stepIdx])
                            if lastEntry then
                                local ax1, ay1 = GetWorldMapPos(lastEntry.mapID, lastEntry.x, lastEntry.y)
                                local ax2, ay2, fb2 = GetWorldMapPos(nextEntry.mapID, nextEntry.x, nextEntry.y)
                                -- Skip if destination only resolved to a continent centroid: direction is unreliable
                                if ax1 and ax2 and not fb2 and (ax1 ~= ax2 or ay1 ~= ay2) then
                                    local angle = math.atan2(ay2 - ay1, ax2 - ax1)
                                    edgeX, edgeY = ProjectToEdge(lastInfo.displayX or lastInfo.x, lastInfo.displayY or lastInfo.y, angle)
                                end
                            end
                        end
                        if edgeX then
                            local isFuture = lastInfo.stepIdx >= currentStepIdx
                            routeLineIdx = routeLineIdx + 1
                            local line = GetOrCreateRouteLine(routeLineIdx, canvas)
                            line:SetStartPoint("CENTER", routePins[#visibleRoute])
                            line:SetEndPoint("TOPLEFT", canvas, edgeX * canvasW, -(edgeY * canvasH))
                            SetRouteConnectionLineColor(line, isFuture, lastInfo.stepIdx == currentStepIdx, 0.3, 0.15)
                            line:SetThickness(2)
                            line:Show()

                            local angle = math.atan2(edgeY - (lastInfo.displayY or lastInfo.y), edgeX - (lastInfo.displayX or lastInfo.x))
                            routeArrowIdx = routeArrowIdx + 1
                            local arrow = GetOrCreateRouteArrow(routeArrowIdx, canvas)
                            arrow:SetSize(20, 20)
                            arrow:ClearAllPoints()
                            arrow:SetPoint("CENTER", canvas, "TOPLEFT", edgeX * canvasW, -(edgeY * canvasH))
                            SetRouteConnectionArrowColor(arrow, isFuture, lastInfo.stepIdx == currentStepIdx, 0.5, 0.25)
                            arrow.icon:SetRotation(-angle + math.pi / 2)
                            arrow:Show()
                        end
                    end
                end

                -- Incoming: previous off-screen step → first visible step (clamped to map edge)
                if firstInfo.stepIdx > 1 then
                    local prevStep = steps[firstInfo.stepIdx - 1]
                    local prevEntry = GetStepEntry(prevStep)
                    if prevEntry then
                        local edgeX, edgeY
                        -- Try direct projection (same continent, off-screen)
                        local cID, wPos = C_Map.GetWorldPosFromMapPos(prevEntry.mapID, CreateVector2D(prevEntry.x / 100, prevEntry.y / 100))
                        if cID and wPos then
                            local targetCont = C_Map.GetWorldPosFromMapPos(currentMapID, CreateVector2D(0.5, 0.5))
                            if targetCont and targetCont == cID then
                                local _, rPos = C_Map.GetMapPosFromWorldPos(cID, wPos, currentMapID)
                                if rPos and (rPos.x < 0 or rPos.x > 1 or rPos.y < 0 or rPos.y > 1) then
                                    edgeX = math.max(0.01, math.min(0.99, rPos.x))
                                    edgeY = math.max(0.01, math.min(0.99, rPos.y))
                                end
                            end
                        end
                        -- Cross-continent fallback: compute direction on world map
                        if not edgeX then
                            local firstEntry = GetStepEntry(steps[firstInfo.stepIdx])
                            if firstEntry then
                                local ax1, ay1, fb1 = GetWorldMapPos(prevEntry.mapID, prevEntry.x, prevEntry.y)
                                local ax2, ay2 = GetWorldMapPos(firstEntry.mapID, firstEntry.x, firstEntry.y)
                                -- Skip if source only resolved to a continent centroid: direction is unreliable
                                if ax1 and ax2 and not fb1 and (ax1 ~= ax2 or ay1 ~= ay2) then
                                    local angle = math.atan2(ay2 - ay1, ax2 - ax1)
                                    edgeX, edgeY = ProjectToEdge(firstInfo.displayX or firstInfo.x, firstInfo.displayY or firstInfo.y, angle + math.pi)
                                end
                            end
                        end
                        if edgeX then
                            local isFuture = firstInfo.stepIdx > currentStepIdx
                            routeLineIdx = routeLineIdx + 1
                            local line = GetOrCreateRouteLine(routeLineIdx, canvas)
                            line:SetStartPoint("TOPLEFT", canvas, edgeX * canvasW, -(edgeY * canvasH))
                            line:SetEndPoint("CENTER", routePins[1])
                            SetRouteConnectionLineColor(line, isFuture, false, 0.3, 0.15)
                            line:SetThickness(2)
                            line:Show()

                            local eAngle = math.atan2((firstInfo.displayY or firstInfo.y) - edgeY, (firstInfo.displayX or firstInfo.x) - edgeX)
                            routeArrowIdx = routeArrowIdx + 1
                            local eArrow = GetOrCreateRouteArrow(routeArrowIdx, canvas)
                            eArrow:SetSize(20, 20)
                            eArrow:ClearAllPoints()
                            eArrow:SetPoint("CENTER", canvas, "TOPLEFT", edgeX * canvasW, -(edgeY * canvasH))
                            SetRouteConnectionArrowColor(eArrow, isFuture, false, 0.5, 0.25)
                            eArrow.icon:SetRotation(-eAngle + math.pi / 2)
                            eArrow:Show()
                        end
                    end
                end
            end
        end

        -- Draw green line from player position toward the current step
        -- (works even when no route steps are visible on this map)
        if SHOW_CURRENT_STEP_PLAYER_GUIDE and currentStepIdx and currentStepIdx >= 1 and currentStepIdx <= #steps then
            local currentRoutePinIdx
            if #visibleRoute > 0 then
                for j, info in ipairs(visibleRoute) do
                    if info.stepIdx == currentStepIdx then
                        currentRoutePinIdx = j
                        break
                    end
                end
            end

            local playerMapID = C_Map.GetBestMapForUnit("player")
            local playerPos = playerMapID and C_Map.GetPlayerMapPosition(playerMapID, "player")
            if playerPos then
                local px, py
                if playerMapID == currentMapID then
                    px, py = playerPos.x, playerPos.y
                else
                    local pContinent, pWorld = C_Map.GetWorldPosFromMapPos(playerMapID, playerPos)
                    if pContinent and pWorld then
                        local targetContinent = C_Map.GetWorldPosFromMapPos(currentMapID, CreateVector2D(0.5, 0.5))
                        if targetContinent and targetContinent == pContinent then
                            local _, pResult = C_Map.GetMapPosFromWorldPos(pContinent, pWorld, currentMapID)
                            if pResult then px, py = pResult.x, pResult.y end
                        end
                    end
                end

                if currentRoutePinIdx then
                    -- Current step is visible on this map
                    local curInfo = visibleRoute[currentRoutePinIdx]
                    if px and py and px >= 0 and px <= 1 and py >= 0 and py <= 1 then
                        local targetX = curInfo.displayX or curInfo.x
                        local targetY = curInfo.displayY or curInfo.y
                        local lineStartX, lineStartY = TrimLineStartFromPlayerMarker(px, py, targetX, targetY, canvasW, canvasH)
                        -- Player on-screen: direct green line
                        routeLineIdx = routeLineIdx + 1
                        local line = GetOrCreateRouteLine(routeLineIdx, canvas)
                        line:SetStartPoint("TOPLEFT", canvas, lineStartX * canvasW, -(lineStartY * canvasH))
                        line:SetEndPoint("CENTER", routePins[currentRoutePinIdx])
                        line:SetColorTexture(0.05, 0.7, 0.2, 0.6)
                        line:SetThickness(3)
                        line:Show()

                        local midX = ((lineStartX + targetX) / 2) * canvasW
                        local midY = ((lineStartY + targetY) / 2) * canvasH
                        local angle = math.atan2(targetY - py, targetX - px)
                        routeArrowIdx = routeArrowIdx + 1
                        local arrow = GetOrCreateRouteArrow(routeArrowIdx, canvas)
                        arrow:SetSize(20, 20)
                        arrow:ClearAllPoints()
                        arrow:SetPoint("CENTER", canvas, "TOPLEFT", midX, -midY)
                        arrow.icon:SetVertexColor(0.05, 0.7, 0.2, 0.9)
                        arrow.icon:SetRotation(-angle + math.pi / 2)
                        arrow:Show()
                    elseif px and py then
                        -- Player off-screen same continent: edge-project toward player
                        local edgeAngle = math.atan2((curInfo.displayY or curInfo.y) - py, (curInfo.displayX or curInfo.x) - px)
                        local ex, ey = ProjectToEdge(curInfo.displayX or curInfo.x, curInfo.displayY or curInfo.y, edgeAngle + math.pi)
                        if ex then
                            routeLineIdx = routeLineIdx + 1
                            local line = GetOrCreateRouteLine(routeLineIdx, canvas)
                            line:SetStartPoint("TOPLEFT", canvas, ex * canvasW, -(ey * canvasH))
                            line:SetEndPoint("CENTER", routePins[currentRoutePinIdx])
                            line:SetColorTexture(0.05, 0.7, 0.2, 0.35)
                            line:SetThickness(2)
                            line:Show()
                        end
                    else
                        -- Player on different continent: world map direction
                        local pAx, pAy = GetWorldMapPos(playerMapID, playerPos.x * 100, playerPos.y * 100)
                        local currentEntry = GetStepEntry(steps[currentStepIdx])
                        if currentEntry and pAx then
                            local sAx, sAy = GetWorldMapPos(currentEntry.mapID, currentEntry.x, currentEntry.y)
                            if sAx and (pAx ~= sAx or pAy ~= sAy) then
                                local edgeAngle = math.atan2(sAy - pAy, sAx - pAx)
                                local ex, ey = ProjectToEdge(curInfo.displayX or curInfo.x, curInfo.displayY or curInfo.y, edgeAngle + math.pi)
                                if ex then
                                    routeLineIdx = routeLineIdx + 1
                                    local line = GetOrCreateRouteLine(routeLineIdx, canvas)
                                    line:SetStartPoint("TOPLEFT", canvas, ex * canvasW, -(ey * canvasH))
                                    line:SetEndPoint("CENTER", routePins[currentRoutePinIdx])
                                    line:SetColorTexture(0.05, 0.7, 0.2, 0.35)
                                    line:SetThickness(2)
                                    line:Show()
                                end
                            end
                        end
                    end
                else
                    -- Current step NOT visible on this map
                    local stepEntry = GetStepEntry(steps[currentStepIdx])
                    if stepEntry and px and py and px >= 0 and px <= 1 and py >= 0 and py <= 1 then
                        -- Player on-screen, step off-screen: draw green line to edge
                        local sx, sy
                        local sCont, sWorld = C_Map.GetWorldPosFromMapPos(stepEntry.mapID, CreateVector2D(stepEntry.x / 100, stepEntry.y / 100))
                        if sCont and sWorld then
                            local targetCont = C_Map.GetWorldPosFromMapPos(currentMapID, CreateVector2D(0.5, 0.5))
                            if targetCont and targetCont == sCont then
                                local _, sResult = C_Map.GetMapPosFromWorldPos(sCont, sWorld, currentMapID)
                                if sResult then sx, sy = sResult.x, sResult.y end
                            end
                        end
                        local angle
                        if sx and sy then
                            angle = math.atan2(sy - py, sx - px)
                        else
                            -- Cross-continent: use world map direction
                            local pAx, pAy = GetWorldMapPos(playerMapID, playerPos.x * 100, playerPos.y * 100)
                            local sAx, sAy = GetWorldMapPos(stepEntry.mapID, stepEntry.x, stepEntry.y)
                            if pAx and sAx and (pAx ~= sAx or pAy ~= sAy) then
                                angle = math.atan2(sAy - pAy, sAx - pAx)
                            end
                        end
                        if angle then
                            local ex, ey = ProjectToEdge(px, py, angle)
                            if ex then
                                local lineStartX, lineStartY = TrimLineStartFromPlayerMarker(px, py, ex, ey, canvasW, canvasH)
                                routeLineIdx = routeLineIdx + 1
                                local line = GetOrCreateRouteLine(routeLineIdx, canvas)
                                line:SetStartPoint("TOPLEFT", canvas, lineStartX * canvasW, -(lineStartY * canvasH))
                                line:SetEndPoint("TOPLEFT", canvas, ex * canvasW, -(ey * canvasH))
                                line:SetColorTexture(0.05, 0.7, 0.2, 0.35)
                                line:SetThickness(2)
                                line:Show()

                                routeArrowIdx = routeArrowIdx + 1
                                local arrow = GetOrCreateRouteArrow(routeArrowIdx, canvas)
                                arrow:SetSize(20, 20)
                                arrow:ClearAllPoints()
                                arrow:SetPoint("CENTER", canvas, "TOPLEFT", ex * canvasW, -(ey * canvasH))
                                arrow.icon:SetVertexColor(0.05, 0.7, 0.2, 0.6)
                                arrow.icon:SetRotation(-angle + math.pi / 2)
                                arrow:Show()
                            end
                        end
                    end
                end
            end
        end
    end

    RaiseCurrentPathPinAboveRoutePins(currentPathForegroundPin)
end

function Map:UpdateMinimapPin()
    local pins = GetHBDPins()
    if not pins then return end

    pins:RemoveAllMinimapIcons("MRP")

    if not self.pathStep then return end

    local uiMapId, x, y = NormalizeToUI(self.pathStep.loc)
    if not uiMapId or not x or not y then return end

    local pin = GetMinimapPin()
    pins:AddMinimapIconMap("MRP", pin, uiMapId, x, y, true, true)
end

function Map:InitHooks()
    if mapOverlayHooked then return end
    if not WorldMapFrame or not WorldMapFrame.GetCanvas then return end

    mapOverlayHooked = true

    hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
        Map:UpdateOverlay()
    end)

    WorldMapFrame:HookScript("OnShow", function()
        Map:UpdateOverlay()
    end)

    local canvas = WorldMapFrame:GetCanvas()
    if canvas then
        canvas:HookScript("OnSizeChanged", function()
            Map:UpdateOverlay()
        end)
    end
end

-- Try hooking now if WorldMapFrame is already loaded
if WorldMapFrame and WorldMapFrame.GetCanvas then
    Map:InitHooks()
else
    local hookFrame = CreateFrame("Frame")
    hookFrame:RegisterEvent("ADDON_LOADED")
    hookFrame:SetScript("OnEvent", function(self, event, addonName)
        if addonName == "Blizzard_WorldMap" then
            Map:InitHooks()
            self:UnregisterAllEvents()
        end
    end)
end
