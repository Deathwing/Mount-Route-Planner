-- MRP_Changelog.lua
-- local _, MRP = ...

local L = MRP.L

local Changelog = {}
MRP.Changelog = Changelog

local ADDON_NAME = "MountRoutePlanner"
local GetAddOnMetadataCompat = C_AddOns and C_AddOns.GetAddOnMetadata or GetAddOnMetadata
local CURRENT_VERSION = GetAddOnMetadataCompat(ADDON_NAME, "Version") or "v0.0.0"
-- Only advance this when CHANGELOG_CONTENT gains new user-facing notes.
-- Patch/data-only releases can keep the previous changelog version to suppress a new popup.
local CHANGELOG_VERSION = "v2.3.1"

local CHANGELOG_CONTENT = [[
|cffffd200Mount Route Planner 2.3.1|r

|cff00ff00Changes|r
- The "Use TomTom for waypoints" checkbox has been replaced by a Waypoint System dropdown with three options: None, Waypoint (Blizzard's built-in map pin), and TomTom.
- Existing settings are migrated automatically: TomTom-enabled users keep TomTom; disabled users switch to Waypoint.
- The |cffffd200/mrp tomtom|r slash command is deprecated; use |cffffd200/mrp waypoint none||waypoint||tomtom|r instead.
- Updated Russian localization (thanks |cff6fd3ffZamestoTV|r).


|cffffd200Mount Route Planner 2.3.0|r

|cff00ff00What's New|r
- Timewalking filter: steps tied to specific Timewalking events are now automatically shown or hidden based on the currently active event, including Shadowlands Timewalking.
- Other addons can now access key MRP frames through the public API (`MRP_API.Frames`).

|cff00ff00Changes|r
- Timewalking vendor availability is now detected hourly and cached, reducing redundant polling.
- The changelog window now closes with the Escape key.


|cffffd200Mount Route Planner 2.2.0|r

|cff00ff00What's New|r
- Holiday and condition-based filters: Love is in the Air, Brewfest, Hallow's End, Feast of Winter Veil, WoW Anniversary, and more.
- Filter dropdowns now automatically hide options that have no matching steps.

|cff00ff00Changes|r
- Added 7 missing holiday mounts: Love Witch's Sweeper, Spring Butterfly, Brewfest Bomber, Minion of Grumpus, The Headless Horseman's Ghoulish Charger, Illidari Doomhawk, and Azure Worldchiller.
- Added Historian Ma'di (Anniversary vendor) and Izzy Hollyfizzle (Winter Veil vendor) as new step sources.

|cff00ff00Fixes|r
- Fixed restricted-identity errors from nearby rare alerts in delves and similar content where unit GUIDs or names can be secret.


|cffffd200Mount Route Planner 2.1.0|r

|cff00ff00What's New|r
- MRP now detects missing or outdated companion addons and shows clear setup warnings so you know exactly what to install.
- Other addons can now interact with MRP through a public API.
- MRP handles missing companion addons more gracefully instead of throwing errors.

|cff00ff00Improvements|r
- Unreachable destination warnings are now less alarming ("flight path might be required" instead of "required").
- Various internal cleanup and stability improvements.

|cff00ff00Fixes|r
- Fixed heavy lag spikes from nearby rare alerts in crowded areas, especially with nameplates enabled.


|cffffd200Mount Route Planner 2.0.0|r

|cff00ff00What's New|r
- Added this changelog popup! Shows after updates and can be reopened with |cffffd200/mrp changelog|r.
- Brand-new support for Vanilla, TBC, Wrath, and Cataclysm clients. Before 2.0.0, only Mists of Pandaria and Retail were supported.
- Added a world map route overview with numbered pins, clustering, arrows, and current-step guidance.
- Added nearby source alerts for world bosses, open-world rares, quests, treasures, and vendors, including a target button and scan macro.
- Routes now recalculate automatically and remember your preferred step ordering.
- Added faction-aware filters, condition-gated steps, quest-chain progress tracking, and housing teleport support where available.

|cff00ff00Improvements|r
- Better Classic and Anniversary compatibility with safer mount collection handling.
- Improved tooltips and progress info for vendors, treasures, quests, helpful items, and difficulty ratings.
- Smoother world map rendering with native pin pooling and dedicated route art.

|cff00ff00Fixes|r
- Fixed mount collection data not loading on Classic clients, which could hide valid route steps.
- Fixed missing waypoints and travel data on non-Standard flavors.
- Fixed stale route orders after data updates by automatically recalculating baselines.
]]

local changelogFrame

local function GetLastSeenChangelogVersion()
    if not MRP_Settings then
        return nil
    end

    return MRP_Settings.lastSeenChangelogVersion or MRP_Settings.lastSeenVersion
end

local function MarkCurrentVersionsSeen()
    if not MRP_Settings then
        return
    end

    MRP_Settings.lastSeenVersion = CURRENT_VERSION
    MRP_Settings.lastSeenChangelogVersion = CHANGELOG_VERSION
end

local function GetVersionLabelText()
    if CURRENT_VERSION == CHANGELOG_VERSION then
        return string.format("Version %s", CHANGELOG_VERSION)
    end

    return string.format("Addon %s - Notes through %s", CURRENT_VERSION, CHANGELOG_VERSION)
end

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
        MRP_Settings.lastChangelogVersion = CHANGELOG_VERSION
    elseif MRP_Settings.lastChangelogVersion == CHANGELOG_VERSION then
        MRP_Settings.lastChangelogVersion = nil
    end
end

local function CreateChangelogFrame()
    if changelogFrame then
        return changelogFrame
    end

    local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
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

    MRP.Frames.ChangelogFrame = frame

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 18, -16)
    title:SetText(L["Mount Route Planner - What's New"])

    local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    versionText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -4)
    versionText:SetText(GetVersionLabelText())

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
        self.dismissCheckbox:SetChecked(MRP_Settings and MRP_Settings.lastChangelogVersion == CHANGELOG_VERSION or false)
        RefreshContentLayout(self)
        self:Raise()
        self:EnableKeyboard(true)
        C_Timer.After(0, function()
            if changelogFrame == self and self:IsShown() then
                RefreshContentLayout(self)
            end
        end)
    end)

    frame:SetScript("OnHide", function(self)
        self:EnableKeyboard(false)
    end)

    frame:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            self:Hide()
        end
    end)

    frame:SetScript("OnSizeChanged", function(self)
        RefreshContentLayout(self)
    end)

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

    local lastSeenChangelogVersion = GetLastSeenChangelogVersion()
    local lastChangelogVersion = MRP_Settings.lastChangelogVersion

    MarkCurrentVersionsSeen()

    if lastChangelogVersion == CHANGELOG_VERSION then
        return
    end

    if lastSeenChangelogVersion == CHANGELOG_VERSION then
        return
    end

    C_Timer.After(3, function()
        if MRP.Changelog then
            MRP.Changelog:Show()
        end
    end)
end
