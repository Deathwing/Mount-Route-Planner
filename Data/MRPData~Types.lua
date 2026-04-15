-- MRPData~Types.lua
-- local _, MRPData = ...

if not MRPData.Internal then return end

---@class BaseEntry
---@field x number the x coordinate of the entry
---@field y number the y coordinate of the entry
---@field mapName string the name of the map where the entry is located
---@field mapID number the uiMapID of the entry
---@field expansionLevel number the expansionLevel of the entry
---@field conditions string[]? an optional array of condition keys (faction, warfront, reputation, holiday, …)

---@class Dungeon : BaseEntry
---@field instanceId number the instanceID (mapID)
---@field availableDifficultyIds number[] the available difficultyIDs for the dungeon

---@class Raid : BaseEntry
---@field instanceId number the instanceID (mapID)
---@field availableDifficultyIds number[] the available difficultyIDs for the raid
---@field areaId number? the areaID of the raid

---@class WorldBoss : BaseEntry
---@field questID number the questID for the world boss completion tracking
---@field npcID number? the NPC ID for nearby detection and targeting
---@field targetName string? the exact targetable NPC name when it differs from the encounter/source name

---@class OpenWorld : BaseEntry
---@field questID number the questID for lockout tracking (0 = always farmable)
---@field mechanic string the mechanic type ("kill", "click", "interact")
---@field npcID number? the NPC ID for targeting (nil or 0 for non-NPC sources)
---@field note string? an optional note about the source
---@field waypoints OpenWorldWaypoint[]? additional map locations to highlight
---@field routeType string? visualization type ("patrol" = connected route, "spawns" = individual markers)
---@field routes OpenWorldRoute[]? multiple patrol routes, each drawn in a distinct color

---@class OpenWorldRoute
---@field waypoints OpenWorldWaypoint[] ordered waypoints forming this patrol route

---@class OpenWorldWaypoint
---@field x number the x coordinate (0-100 map percent)
---@field y number the y coordinate (0-100 map percent)
---@field mapID number? optional mapID if different from the main entry's mapID

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

---@class MountCost
---@field type string the cost type ("currency", "gold", "item")
---@field amount number the amount of the cost
---@field currencyId number? the currencyID if the cost type is "currency"
---@field itemId number? the itemID if the cost type is "item"

---@class QuestSource
---@field questID number the questID of the source
---@field name string the name of the quest source
---@field x number? the x coordinate of the quest source
---@field y number? the y coordinate of the quest source
---@field mapID number? the uiMapID of the quest source

---@class MountSource
---@field mapId number the mapID of the source
---@field uiMapIds number[] the uiMapIDs of the source
---@field allowedDifficultyIds number[] the allowed difficulty IDs for the source
---@field relevantDifficultyIds number[]? the relevant difficulty IDs for the source
---@field note string? an optional note for the source
---@field bonusRoll boolean? whether the source can be bonus rolled
---@field factionMask number? the faction mask for the source
---@field mechanic string? the open world mechanic type ("kill", "click", "interact")
---@field journalEncounter JournalEncounter? the journal encounter details
---@field dungeonEncounter DungeonEncounter? the dungeon encounter details
---@field specialEncounter SpecialEncounter? the special encounter details
---@field cost MountCost? the cost details of the mount
---@field costs MountCost[]? the cost details array of the mount
---@field questChain QuestSource[]? the quest chain details if the mount is obtained through a questline

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
---@field npcID number? the npcID used for nearby detection when available
---@field targetName string? the exact targetable NPC name when it differs from the source/encounter name

---@class Step
---@field id number the stepID
---@field mounts Mount[] the list of mounts in this step
---@field source StepSource the source details of the step
---@field expansion number the expansion of the step

---@class MRPDataAPI
---@field VERSION number the version of the API
---@field DUNGEONS { [string]: Dungeon } a table mapping dungeon names to their data
---@field RAIDS { [string]: Raid } a table mapping raid names to their data
---@field WORLD_BOSSES { [string]: WorldBoss } a table mapping world boss names to their data
---@field OPEN_WORLD { [string]: OpenWorld } a table mapping open world event names to their data
---@field STEPS Step[] a table mapping step names to their data
