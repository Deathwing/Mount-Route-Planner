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

---@enum FilterHoliday
MRP.FilterHoliday = {
    None = "none",
    LunarFestival = "event_lunar",
    LoveIsInTheAir = "event_love",
    Noblegarden = "event_noblegarden",
    ChildrensWeek = "event_childrens",
    MidsummerFireFestival = "event_midsummer",
    Brewfest = "event_brewfest",
    HallowsEnd = "event_hallows",
    DayOfTheDead = "event_dead",
    PilgrimsBounty = "event_pilgrims",
    FeastOfWinterVeil = "event_winterveil",
    PiratesDay = "event_pirates",
    WoWAnniversary = "event_anniversary",
}

MRP.FilterHolidayOrder = {
    "None",
    "LunarFestival",
    "LoveIsInTheAir",
    "Noblegarden",
    "ChildrensWeek",
    "MidsummerFireFestival",
    "Brewfest",
    "HallowsEnd",
    "DayOfTheDead",
    "PilgrimsBounty",
    "FeastOfWinterVeil",
    "PiratesDay",
    "WoWAnniversary",
}

--- Map from FilterHoliday condition strings to known calendar event IDs.
--- Used by the runtime calendar scanner to match active events.
MRP.HolidayCalendarEventIDs = {
    ["event_lunar"] = { 181 },                    -- Lunar Festival
    ["event_love"] = { 335, 423 },                -- Love is in the Air
    ["event_noblegarden"] = { 233 },              -- Noblegarden
    ["event_childrens"] = { 201 },                -- Children's Week
    ["event_midsummer"] = { 341, 424 },           -- Midsummer Fire Festival
    ["event_brewfest"] = { 372 },                 -- Brewfest
    ["event_hallows"] = { 324, 425 },             -- Hallow's End
    ["event_dead"] = { 409 },                     -- Day of the Dead
    ["event_pilgrims"] = { 404 },                 -- Pilgrim's Bounty
    ["event_winterveil"] = { 141 },               -- Feast of Winter Veil
    ["event_pirates"] = { 398 },                  -- Pirates' Day
    ["event_anniversary"] = { 1262, 1418, 1266 }, -- WoW Anniversary / Bronze Celebration
}

---@enum RequiredAddon
MRP.RequiredAddon = {
    MRPData = "Mount Route Planner Data",
    FarstriderLib = "FarstriderLib",
    FarstriderLibData = "FarstriderLib Data",
}
