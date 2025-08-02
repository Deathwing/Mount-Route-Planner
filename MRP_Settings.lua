-- MRP_Settings.lua
-- local _, MRP = ...

---@class Settings
---@field useTomTom boolean Whether to use TomTom for waypoint navigation.
---@field showDifficultyWarning boolean Whether to show a warning for incorrect difficulty settings.
---@field ignoreLFRDifficulty boolean Whether to ignore LFR difficulty on steps.
MRP_Settings = {
    useTomTom = true,
    showDifficultyWarning = true,
    ignoreLFRDifficulty = false
}
