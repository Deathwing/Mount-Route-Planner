-- MRP_CharacterSettings.lua
-- local _, MRP = ...

---@class CharacterSettings
---@field autoSkip boolean Whether to automatically skip steps in the route.
---@field autoAdvance boolean Whether to automatically advance to the next step after completing the current one.
---@field currentStep number The current step in the route being followed.
---@field filter FilterSettings The filter settings for the character.
---@field ignoredHelpfulItems { [number]: boolean } A list of helpful items to ignore for this character.
---@field trashItItems { [number]: boolean } A list of items to trash.
---@field ignoredTrashItItems { [number]: boolean } A list of items to ignore when trashing.
MRP_CharacterSettings = {
    autoSkip = true,
    autoAdvance = true,
    currentStep = 1,
    filter = {
        expansions = {
            [MRP.FilterExpansion.Classic] = true,
            [MRP.FilterExpansion.TheBurningCrusade] = true,
            [MRP.FilterExpansion.WrathOfTheLichKing] = true,
            [MRP.FilterExpansion.Cataclysm] = true,
            [MRP.FilterExpansion.MistsOfPandaria] = true,
            [MRP.FilterExpansion.WarlordsOfDraenor] = true,
            [MRP.FilterExpansion.Legion] = true,
            [MRP.FilterExpansion.BattleForAzeroth] = true,
            [MRP.FilterExpansion.Shadowlands] = true,
            [MRP.FilterExpansion.Dragonflight] = true,
            [MRP.FilterExpansion.TheWarWithin] = true
        },
        sourceTypes = {
            [MRP.FilterSourceType.Dungeon] = true,
            [MRP.FilterSourceType.Raid] = true,
            [MRP.FilterSourceType.WorldBoss] = true
        },
        collectedStates = {
            [MRP.FilterCollectedState.Collected] = false,
            [MRP.FilterCollectedState.NotCollected] = true
        },
    },
    ignoredHelpfulItems = {},
    trashItItems = {},
    ignoredTrashItItems = {}
}
