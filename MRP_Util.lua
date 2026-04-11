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

---@return Location playerLocation
function Util.GetPlayerLocation()
    local uiMapId = C_Map.GetBestMapForUnit("player")
    local uiMapCoords = C_Map.GetPlayerMapPosition(C_Map.GetBestMapForUnit("player"), "player")

    if not uiMapCoords then
        local parentMapId = C_Map.GetMapInfo(uiMapId).parentMapID
        if parentMapId then
            uiMapId = parentMapId

            local instanceId = EJ_GetInstanceForMap(uiMapId)
            local dungeonEntrances = C_EncounterJournal.GetDungeonEntrancesForMap(parentMapId)

            for _, entrance in ipairs(dungeonEntrances) do
                if entrance.journalInstanceID == instanceId then
                    uiMapId = parentMapId
                    uiMapCoords = entrance.position
                    break
                end
            end
        end
    end

    if not uiMapCoords then
        uiMapCoords = { x = 0.5, y = 0.5 }
    end

    return { mapId = uiMapId, pos = { x = uiMapCoords.x, y = uiMapCoords.y, z = 0 }, isUI = true }
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
