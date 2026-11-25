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
local CHANGELOG_VERSION = "v2.6.0"

local CHANGELOG_CONTENT = [[
|cffffd200Mount Route Planner 2.6.0|r

|cff00ff00What's New|r
- Classic Era, WoW Forever and TBC routes now use the flight paths you know
- A flight path counts as known once you open that flight master's map

|cffff2020Fixes|r
- Routes from inside a dungeon or raid now start by leaving it
- Better choices of boats, portals, flights, Hearthstone and teleports
- No more errors in dungeons, raids, delves and Mythic+
- Map pins and TomTom arrows land on the right spot, plus smaller fixes


|cffffd200Mount Route Planner 2.5.0|r

|cff00ff00What's New|r
- Added support for World of Warcraft: Forever
- The CurseForge download now includes the companion addons (update older separate copies)

|cffff2020Fixes|r
- Route directions are now in French on French clients (thanks |cff6fd3ffNeogeekmo|r)
- Classic routes know many more connections, such as the Deeprun Tram and mage teleports
- Smaller fixes

|cff00ff00Changes|r
- Added support for Patch 12.1.5


|cffffd200Mount Route Planner 2.4.5|r

|cffff2020Fixes|r
- Explored map areas no longer hide route lines and arrows on retail

|cff00ff00Changes|r
- Added support for Patch 12.1.0 and its new mounts
- Removed mounts that are no longer obtainable
- Update reminders now work outside your guild or group too


|cffffd200Mount Route Planner 2.4.4|r

|cff00ff00Changes|r
- Update and changelog popups now only appear while resting in an inn or city
- New /mrp versions command shows the installed versions


|cffffd200Mount Route Planner 2.4.2|r

|cff00ff00Changes|r
- You are now told when guild or group members have a newer version
- Added |cffffd200/mrp update|r with GitHub, CurseForge and Wago download links
- Now also available on GitHub and Wago


|cffffd200Mount Route Planner 2.4.1|r

|cff00ff00Fixes|r
- Alliance routes no longer use Horde-only zeppelins and portals
- Route pins now show on the fullscreen world map on Classic clients
- Fixed world map errors when hovering points of interest
- Smaller fixes

|cff00ff00Changes|r
- Added support for TBC Anniversary 2.5.6
- Updated Russian translation (thanks |cff6fd3ffZamestoTV|r)


|cffffd200Mount Route Planner 2.4.0|r

|cff00ff00What's New|r
- You can now hide the minimap button, and |cffffd200/mrp|r still opens the panel
- Alliance routes can now use the Silvermoon City portal to Stormwind

|cff00ff00Fixes|r
- Travel items are only suggested when your character can use them
- Several mounts now point to the right place
- Fixed errors in the world map and tooltips

|cff00ff00Changes|r
- Updated Russian translation (thanks |cff6fd3ffZamestoTV|r) and mount data for 12.0.7


|cffffd200Mount Route Planner 2.3.1|r

|cff00ff00Changes|r
- The TomTom checkbox is now a Waypoint System dropdown: None, Waypoint or TomTom
- Your old setting carries over automatically
- |cffffd200/mrp tomtom|r is replaced by |cffffd200/mrp waypoint none||waypoint||tomtom|r
- Updated Russian translation (thanks |cff6fd3ffZamestoTV|r)


|cffffd200Mount Route Planner 2.3.0|r

|cff00ff00What's New|r
- Timewalking steps now show or hide with the active Timewalking event

|cff00ff00Changes|r
- The changelog window now closes with Escape


|cffffd200Mount Route Planner 2.2.0|r

|cff00ff00What's New|r
- New holiday filters, such as Love is in the Air, Brewfest and Hallow's End
- Filter lists now hide options with no matching steps

|cff00ff00Changes|r
- Added 7 missing holiday mounts and two holiday vendors

|cff00ff00Fixes|r
- Fixed errors from nearby rare alerts in delves


|cffffd200Mount Route Planner 2.1.0|r

|cff00ff00What's New|r
- Missing or outdated companion addons now show a clear warning instead of errors

|cff00ff00Improvements|r
- Unreachable destinations now say a flight path might be required

|cff00ff00Fixes|r
- Fixed lag spikes from nearby rare alerts in crowded areas


|cffffd200Mount Route Planner 2.0.0|r

|cff00ff00What's New|r
- Now supports Vanilla, TBC, Wrath and Cataclysm clients too
- New world map route overview with numbered pins and arrows
- Alerts for nearby rares, world bosses, quests, treasures and vendors
- Routes recalculate automatically and remember your step order
- Faction filters, quest-chain progress and housing teleports
- Added this changelog (reopen it with |cffffd200/mrp changelog|r)

|cff00ff00Fixes|r
- Fixed missing route steps and waypoints on Classic clients
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

    -- Only show the changelog while resting (inn/city). Showing it out in the
    -- open world is intrusive, so defer and retry until the player is resting.
    local function showWhenResting()
        if InCombatLockdown() or not IsResting() then
            C_Timer.After(5, showWhenResting)
            return
        end
        if MRP.Changelog then
            MRP.Changelog:Show()
        end
    end
    C_Timer.After(3, showWhenResting)
end
