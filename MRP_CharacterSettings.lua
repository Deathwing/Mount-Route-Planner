-- MRP_CharacterSettings.lua
-- local _, MRP = ...

---@class CharacterSettings
---@field autoSkip boolean Whether to automatically skip steps in the route.
---@field autoAdvance boolean Whether to automatically advance to the next step after completing the current one.
---@field currentStep number The current step in the route being followed.
---@field filter FilterSettings The filter settings for the character.
---@field ignoredHelpfulItems { number: boolean } A list of helpful items to ignore for this character.
---@field routeOrder number[]? The optimized baseline route order as an array of step IDs.
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
            [MRP.FilterExpansion.TheWarWithin] = true,
            [MRP.FilterExpansion.Midnight] = true
        },
        sourceTypes = {
            [MRP.FilterSourceType.Dungeon] = true,
            [MRP.FilterSourceType.Raid] = true,
            [MRP.FilterSourceType.WorldBoss] = true,
            [MRP.FilterSourceType.OpenWorld] = true
        },
        collectedStates = {
            [MRP.FilterCollectedState.Collected] = false,
            [MRP.FilterCollectedState.NotCollected] = true
        },
        factions = {
            [MRP.FilterFaction.Neutral] = true,
            [MRP.FilterFaction.Alliance] = true,
            [MRP.FilterFaction.Horde] = true,
        },
        holidays = {
            [MRP.FilterHoliday.LunarFestival] = true,
            [MRP.FilterHoliday.LoveIsInTheAir] = true,
            [MRP.FilterHoliday.Noblegarden] = true,
            [MRP.FilterHoliday.ChildrensWeek] = true,
            [MRP.FilterHoliday.MidsummerFireFestival] = true,
            [MRP.FilterHoliday.Brewfest] = true,
            [MRP.FilterHoliday.HallowsEnd] = true,
            [MRP.FilterHoliday.DayOfTheDead] = true,
            [MRP.FilterHoliday.PilgrimsBounty] = true,
            [MRP.FilterHoliday.FeastOfWinterVeil] = true,
            [MRP.FilterHoliday.PiratesDay] = true,
            [MRP.FilterHoliday.WoWAnniversary] = true,
        },
    },
    ignoredHelpfulItems = {},
    routeOrder = nil
}
