-- MRP_Settings.lua
-- local _, MRP = ...

---@class Settings
---@field useTomTom boolean Whether to use TomTom for waypoint navigation.
---@field showDifficultyWarning boolean Whether to show a warning for incorrect difficulty settings.
---@field ignoreLFRDifficulty boolean Whether to ignore LFR difficulty on steps.
---@field showRareAlert boolean Whether to show nearby rare/source alerts.
---@field alertPopupPoint string Anchor point for the nearby alert popup.
---@field alertPopupRelativePoint string Relative anchor point for the nearby alert popup.
---@field alertPopupOffsetX number Horizontal offset for the nearby alert popup.
---@field alertPopupOffsetY number Vertical offset for the nearby alert popup.
---@field showRouteOnMap boolean Whether to show route overview markers on the world map.
---@field showRouteConnectionsOnMap boolean Whether to show route overview connection lines on the world map.
---@field showPathfindingLinesOnMap boolean Whether to show the current pathfinding guide line on the world map.
---@field showOpenWorldOverlayOnMap boolean Whether to show open-world source overlays on the world map.
---@field maxStepsAhead number Maximum steps ahead of current to show on map.
---@field unlimitedStepsAhead boolean Whether to show all steps ahead (ignores maxStepsAhead).
---@field maxStepsBehind number Maximum steps behind current to show on map.
---@field unlimitedStepsBehind boolean Whether to show all steps behind (ignores maxStepsBehind).
---@field lastSeenVersion string? The last addon version observed during login.
---@field lastChangelogVersion string? The last addon version whose changelog was dismissed.
MRP_Settings = {
    useTomTom = true,
    showDifficultyWarning = true,
    ignoreLFRDifficulty = false,
    showRareAlert = true,
    alertPopupPoint = "TOP",
    alertPopupRelativePoint = "TOP",
    alertPopupOffsetX = 0,
    alertPopupOffsetY = -80,
    showRouteOnMap = true,
    showRouteConnectionsOnMap = false,
    showPathfindingLinesOnMap = true,
    showOpenWorldOverlayOnMap = true,
    maxStepsAhead = 5,
    unlimitedStepsAhead = false,
    maxStepsBehind = 1,
    unlimitedStepsBehind = false
}
