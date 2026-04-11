-- MRP_Steps.lua
-- local _, MRP = ...

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
---@field condition string? the open world condition key for phase gating
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

---@type Step[]
local steps = {}

if MRPData then
    for _, step in ipairs(MRPData.Steps) do table.insert(steps, step) end
end

MRP.Steps = steps
