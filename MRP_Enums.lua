-- MRP_Enums.lua
-- local _, MRP = ...

---@enum FilterExpansion
MRP.FilterExpansion = {
    Classic = 0,
    TheBurningCrusade = 1,
    WrathOfTheLichKing = 2,
    Cataclysm = 3,
    MistsOfPandaria = 4,
    WarlordsOfDraenor = 5,
    Legion = 6,
    BattleForAzeroth = 7,
    Shadowlands = 8,
    Dragonflight = 9,
    TheWarWithin = 10,
    Midnight = 11,
}

MRP.FilterExpansionOrder = {
    "Classic",
    "TheBurningCrusade",
    "WrathOfTheLichKing",
    "Cataclysm",
    "MistsOfPandaria",
    "WarlordsOfDraenor",
    "Legion",
    "BattleForAzeroth",
    "Shadowlands",
    "Dragonflight",
    "TheWarWithin",
    "Midnight"
}

---@enum FilterSourceType
MRP.FilterSourceType = {
    Dungeon = "Dungeon",
    Raid = "Raid",
    WorldBoss = "WorldBoss",
    OpenWorld = "OpenWorld",
    Quest = "Quest",
    Treasure = "Treasure",
    Vendor = "Vendor",
}

MRP.FilterSourceTypeOrder = {
    "Dungeon",
    "Raid",
    "WorldBoss",
    "OpenWorld",
    "Quest",
    "Treasure",
    "Vendor"
}

---@enum FilterCollectedState
MRP.FilterCollectedState = {
    Collected = true,
    NotCollected = false,
}

MRP.FilterCollectedStateOrder = {
    "Collected",
    "NotCollected"
}

---@enum FilterFaction
MRP.FilterFaction = {
    Neutral = "Neutral",
    Alliance = "Alliance",
    Horde = "Horde",
}

MRP.FilterFactionOrder = {
    "Neutral",
    "Alliance",
    "Horde"
}

---@enum RequiredAddon
MRP.RequiredAddon = {
    MRPData = "Mount Route Planner Data",
    FarstriderLib = "FarstriderLib",
    FarstriderLibData = "FarstriderLib Data",
}
