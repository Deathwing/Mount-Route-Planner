-- MRP_Changelog.lua
-- local _, MRP = ...

local L = MRP.L

local Changelog = {}
MRP.Changelog = Changelog

local ADDON_NAME = "MountRoutePlanner"
local GetAddOnMetadataCompat = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local CURRENT_VERSION = GetAddOnMetadataCompat(ADDON_NAME, "Version") or "v0.0.0"

local CHANGELOG_CONTENT = [[
|cffffd200Mount Route Planner 2.0.0|r

|cff00ff00Highlights|r
- Mount Route Planner now supports Vanilla, TBC, Wrath, and Cataclysm in addition to Mists and Retail.
- The route can now be recalculated in-game and shown on the world map with numbered pins and step guidance.
- Open-world steps now support rares, quests, treasures, vendors, and nearby source alerts.
- Filters are smarter, tooltips are richer, and route progress is more informative overall.
- Housing teleport and return support was added where available.

|cff00ff00Behind the Scenes|r
- Data loading and packaging were reworked so all supported flavors can ship from one shared source.
- Route validation, pathfinding, and compatibility handling were improved for Classic and Anniversary clients.

|cff00ff00Fixes|r
- Fixed several issues with missing step visibility, travel data, and route rendering.
]]

local changelogFrame

local function RefreshContentLayout(frame)
    if not frame or not frame.scrollFrame or not frame.contentText or not frame.scrollChild then
        return
    end

    local width = frame.scrollFrame:GetWidth()
    if not width or width <= 0 then
        return
    end

    frame.contentText:SetWidth(width - 24)
    frame.scrollChild:SetHeight(math.max(frame.contentText:GetStringHeight() + 8, frame.scrollFrame:GetHeight()))
end

local function UpdateDismissState(checked)
    if not MRP_Settings then
        return
    end

    if checked then
        MRP_Settings.lastChangelogVersion = CURRENT_VERSION
    elseif MRP_Settings.lastChangelogVersion == CURRENT_VERSION then
        MRP_Settings.lastChangelogVersion = nil
    end
end

local function CreateChangelogFrame()
    if changelogFrame then
        return changelogFrame
    end

    local frame = CreateFrame("Frame", "MRPChangelogFrame", UIParent, "BackdropTemplate")
    frame:SetSize(620, 520)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
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
        insets = {
            left = 11,
            right = 12,
            top = 12,
            bottom = 11,
        },
    })
    frame:Hide()

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 18, -16)
    title:SetText(L["Mount Route Planner - What's New"])

    local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    versionText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    versionText:SetText(string.format("Version %s", CURRENT_VERSION))

    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -10, -10)

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 18, -56)
    scrollFrame:SetPoint("BOTTOMRIGHT", -34, 62)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetPoint("TOPLEFT")
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    local contentText = scrollChild:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    contentText:SetPoint("TOPLEFT", 0, 0)
    contentText:SetJustifyH("LEFT")
    contentText:SetJustifyV("TOP")
    contentText:SetText(CHANGELOG_CONTENT)

    local hintText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    hintText:SetPoint("BOTTOMLEFT", 18, 36)
    hintText:SetText(L["Use /mrp changelog to open this again."])

    local dismissCheckbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    dismissCheckbox:SetPoint("BOTTOMLEFT", 14, 10)
    dismissCheckbox.Text:SetText(L["Don't show this changelog again"])
    dismissCheckbox:SetScript("OnClick", function(self)
        UpdateDismissState(self:GetChecked())
    end)

    frame.scrollFrame = scrollFrame
    frame.scrollChild = scrollChild
    frame.contentText = contentText
    frame.dismissCheckbox = dismissCheckbox

    frame:SetScript("OnShow", function(self)
        self.dismissCheckbox:SetChecked(MRP_Settings and MRP_Settings.lastChangelogVersion == CURRENT_VERSION or false)
        RefreshContentLayout(self)
        self:Raise()
        C_Timer.After(0, function()
            if changelogFrame == self and self:IsShown() then
                RefreshContentLayout(self)
            end
        end)
    end)

    frame:SetScript("OnSizeChanged", function(self)
        RefreshContentLayout(self)
    end)

    table.insert(UISpecialFrames, "MRPChangelogFrame")

    changelogFrame = frame
    return frame
end

function Changelog:Show()
    local frame = CreateChangelogFrame()
    frame:Show()
    frame:Raise()
end

function Changelog:IsVisible()
    return changelogFrame ~= nil and changelogFrame:IsShown()
end

function Changelog:CheckShowOnLogin()
    if not MRP_Settings then
        return
    end

    local lastSeenVersion = MRP_Settings.lastSeenVersion
    local lastChangelogVersion = MRP_Settings.lastChangelogVersion

    MRP_Settings.lastSeenVersion = CURRENT_VERSION

    if lastChangelogVersion == CURRENT_VERSION then
        return
    end

    if lastSeenVersion == CURRENT_VERSION then
        return
    end

    C_Timer.After(3, function()
        if MRP.Changelog then
            MRP.Changelog:Show()
        end
    end)
end
