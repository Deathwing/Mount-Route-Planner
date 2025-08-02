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
    "TheWarWithin"
}

---@enum FilterSourceType
MRP.FilterSourceType = {
    Dungeon = "Dungeon",
    Raid = "Raid",
    WorldBoss = "WorldBoss",
}

MRP.FilterSourceTypeOrder = {
    "Dungeon",
    "Raid",
    "WorldBoss"
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

---@enum SpecialLocaId
MRP.SpecialLocaId = {
    TravelTo = 1000,
    FlightpathTo = 1001,
    PortalTo = 1002,
    BoatTo = 1003,
    ZeppelinTo = 1004,
    ItemTo = 1005,
    DalaranArgusPortalStart = 2000,
    DalaranArgusPortalEnd = 2001,
    HearthstoneStart = 3000,
    HearthstoneEnd = 3001,
    DalaranHearthstoneStart = 3002,
    DalaranHearthstoneEnd = 3003,
    GarrisonHearthstoneAllianceStart = 3004,
    GarrisonHearthstoneAllianceEnd = 3005,
    GarrisonHearthstoneHordeStart = 3006,
    GarrisonHearthstoneHordeEnd = 3007,
}

--#region MRP_WaypointL

---@class WaypointLocale
---@field enUS string English US locale
---@field deDE string German locale
---@field esES string Spanish (Spain) locale
---@field esMX string Spanish (Mexico) locale
---@field frFR string French locale
---@field itIT string Italian locale
---@field koKR string Korean locale
---@field ptBR string Portuguese (Brazil) locale
---@field ruRU string Russian locale
---@field zhCN string Chinese (Simplified) locale
---@field zhTW string Chinese (Traditional) locale

--#endregion MRP_WaypointL

--#region MRP_Waypoints

---@class Vec3
---@field x number
---@field y number
---@field z number

---@class Location
---@field mapId number
---@field pos Vec3
---@field isUI? boolean

---@class ActionOption
---@field type string
---@field data any

---@class WaypointLocation
---@field locaId number
---@field locaArgs? table
---@field flags number
---@field loc? Location
---@field dynLoc? fun(): Location
---@field type number
---@field unknown1 number
---@field condition? fun(): boolean
---@field actionOptions? ActionOption[]
---@field important? boolean

---@class Waypoint
---@field id number
---@field from WaypointLocation
---@field to WaypointLocation
---@field bidirectional boolean
---@field cost number
---@field condition? fun(): boolean

--#endregion MRP_Waypoints

--#region MRP_Steps

---@class JournalEncounter
---@field id number the encounterID
---@field name string the encounter name
---@field instanceId number the instanceID of the encounter
---@field uiMapId number the uiMapID of the encounter

---@class DungeonEncounter
---@field id number the encounterID
---@field name string the encounter name
---@field mapId number the mapID of the encounter

---@class SpecialEncounter
---@field name string the name of the special encounter

---@class MountSource
---@field mapId number the mapID of the source
---@field uiMapIds number[] the uiMapIDs of the source
---@field allowedDifficultyIds number[] the allowed difficulty IDs for the source
---@field relevantDifficultyIds number[]? the relevant difficulty IDs for the source
---@field note string? an optional note for the source
---@field bonusRoll boolean? whether the source can be bonus rolled
---@field factionMask number? the faction mask for the source
---@field journalEncounter JournalEncounter? the journal encounter details
---@field dungeonEncounter DungeonEncounter? the dungeon encounter details
---@field specialEncounter SpecialEncounter? the special encounter details

---@class Mount
---@field id number the mountID
---@field name string the name of the mount
---@field icon string the icon texture path of the mount
---@field itemId number the itemID of the mount
---@field spellId number the spellID of the mount
---@field source MountSource the source details of the mount

---@class StepSource
---@field type FilterSourceType the type of the source
---@field name string the name of the source

---@class Step
---@field id number the stepID
---@field mounts Mount[] the list of mounts in this step
---@field source StepSource the source details of the step
---@field expansion number the expansion of the step

--#endregion MRP_Steps
