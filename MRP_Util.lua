-- MRP.lua
-- local _, MRP = ...

local L = MRP.L

local Util = {}
MRP.Util = Util

---@generic T
---@generic U
---@param arr T[]
---@param selector fun(currentValue: T, index: number, arr: T[]):U
---@return U[] array
function Util.Map(arr, selector)
    local result = {}
    for i, v in ipairs(arr) do
        result[i] = selector(v, i, arr)
    end
    return result
end

--- Shallow-copy a table (one level deep).
---@param t table
---@return table
function Util.ShallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

---@type table<number, ItemMixin>
local itemCache = {}

---@param itemId number
---@return ItemMixin
function Util.GetItem(itemId)
    if not itemCache[itemId] then
        itemCache[itemId] = Item:CreateFromItemID(itemId)
    end

    return itemCache[itemId]
end

---@param itemId number
---@return string itemName
function Util.GetItemNameSafe(itemId)
    return Util.GetItem(itemId):GetItemName() or L["Item_" .. itemId]
end

---@type table<number, SpellMixin>
local spellCache = {}

function Util.GetSpell(spellId)
    if not spellCache[spellId] then
        spellCache[spellId] = Spell:CreateFromSpellID(spellId)
    end

    return spellCache[spellId]
end

function Util.GetSpellNameSafe(spellId)
    return Util.GetSpell(spellId):GetSpellName() or L["Spell_" .. spellId]
end

---@param mount Mount
---@return string name
---@return any icon
---@return boolean isCollected
function Util.GetMountInfoSafe(mount)
    local name = mount.name or ""
    ---@type any
    local icon = (mount.icon and mount.icon ~= 0) and mount.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
    local isCollected = false

    if C_MountJournal and C_MountJournal.GetMountInfoByID then
        local journalName, _, journalIcon, _, _, _, _, _, _, _, journalCollected = C_MountJournal.GetMountInfoByID(mount.id)
        if journalName then
            name = journalName
        end
        if journalIcon then
            icon = journalIcon
        end
        if journalCollected ~= nil then
            isCollected = journalCollected
            return name, icon, isCollected
        end
    end

    if mount.spellId and C_SpellBook and C_SpellBook.IsSpellInSpellBook and C_SpellBook.IsSpellInSpellBook(mount.spellId) then
        if C_Spell and C_Spell.GetSpellInfo then
            local spellInfo = C_Spell.GetSpellInfo(mount.spellId)
            if spellInfo then
                if spellInfo.name then
                    name = spellInfo.name
                end
                if spellInfo.iconID then
                    icon = spellInfo.iconID
                end
            end
        end
        isCollected = true
    end

    if not isCollected and mount.itemId and C_Item and C_Item.GetItemCount then
        isCollected = C_Item.GetItemCount(mount.itemId, true, true, true, true) > 0
        if isCollected then
            local item = Util.GetItem(mount.itemId)
            local itemName = item:GetItemName()
            local itemIcon = item:GetItemIcon()
            if itemName then
                name = itemName
            end
            if itemIcon then
                icon = itemIcon
            end
        end
    end

    return name, icon, isCollected
end

function Util.HasData()
    return MRP.Data.VERSION > 0
end

function Util.HasFarstrider()
    return MRP.Farstrider.VERSION > 0
end

function Util.HasFarstriderData()
    return MRP.Farstrider.DATA.VERSION > 0
end

-- =====================================================================
-- Unified step conditions API
-- =====================================================================

--- Condition types returned by GetStepConditions.
---@alias ConditionType "faction"|"warfront"|"reputation"|"holiday"

---@class StepCondition
---@field type ConditionType
---@field key string the raw condition/holiday key (e.g. "horde_only", "event_brewfest")
---@field met boolean whether this condition is currently satisfied
---@field message string human-readable description of the requirement

--- Look up the data-table entry for any step, regardless of source type.
---@param step Step
---@return table?
function Util.GetStepEntry(step)
    local t = step.source.type
    local name = step.source.name
    if t == MRP.FilterSourceType.Dungeon then
        return MRP.Data.DUNGEONS[name]
    elseif t == MRP.FilterSourceType.Raid then
        return MRP.Data.RAIDS[name]
    elseif t == MRP.FilterSourceType.WorldBoss then
        return MRP.Data.WORLD_BOSSES[name]
    else
        return MRP.Data.OPEN_WORLD[name]
    end
end

--- Build the list of ALL conditions that apply to a step.
--- Each entry is { type, key, met, message }.
---@param step Step
---@return StepCondition[]
function Util.GetStepConditions(step)
    local entry = Util.GetStepEntry(step)
    if not entry then return {} end

    -- Gather every raw condition key from the entry
    local rawKeys = {}
    if entry.conditions then
        for _, key in ipairs(entry.conditions) do
            table.insert(rawKeys, key)
        end
    end

    local conditions = {}
    for _, key in ipairs(rawKeys) do
        local condType, met
        if key == "horde_only" then
            condType = "faction"
            met = UnitFactionGroup("player") == "Horde"
        elseif key == "alliance_only" then
            condType = "faction"
            met = UnitFactionGroup("player") == "Alliance"
        elseif key:find("^warfront_") then
            condType = "warfront"
            local mapID = (key == "warfront_arathi") and 14 or 62
            if C_QuestLog and C_QuestLog.GetQuestsOnMap then
                local quests = C_QuestLog.GetQuestsOnMap(mapID)
                met = quests ~= nil and #quests > 0
            else
                met = false
            end
        elseif key:find("^rep_") then
            condType = "reputation"
            local factionId, requiredStanding = key:match("^rep_(%d+)_(%d+)$")
            if factionId then
                factionId = tonumber(factionId)
                requiredStanding = tonumber(requiredStanding)
                local factionData = C_Reputation and C_Reputation.GetFactionDataByID and C_Reputation.GetFactionDataByID(factionId)
                met = factionData and factionData.currentStanding >= requiredStanding or false
            else
                met = true
            end
        elseif key:find("^event_") then
            condType = "holiday"
            met = MRP.Holidays:IsHolidayEventActive(key)
        else
            condType = "faction"
            met = true
        end
        table.insert(conditions, {
            type = condType,
            key = key,
            met = met,
            message = MRP.Core:GetConditionMessage(key),
        })
    end

    return conditions
end

--- Returns true only when every condition on the step is satisfied.
---@param step Step
---@return boolean
function Util.AreStepConditionsMet(step)
    local conditions = Util.GetStepConditions(step)
    for _, c in ipairs(conditions) do
        if not c.met then return false end
    end
    return true
end
