-- MRP_Settings.lua
-- local _, MRP = ...

---@class Settings
---@field autoSkip boolean Whether to automatically skip steps in the route.
---@field autoAdvance boolean Whether to automatically advance to the next step after completing the current one.
---@field useTomTom boolean Whether to use TomTom for waypoint navigation.
MRP_Settings = {
    autoSkip = true,
    autoAdvance = true,
    useTomTom = true,
    showDifficultyWarning = true,
}
