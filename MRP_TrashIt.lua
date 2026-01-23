-- MRP_TrashIt.lua
-- local _, MRP = ...

local L = MRP.L

local TrashIt = {}
MRP.TrashIt = TrashIt

local function IsImportantItem(itemId)
    if not itemId then
        return false
    end

    local item = MRP.Util.GetItem(itemId)
    if not item then
        return false
    end

    if C_ToyBox.GetToyInfo(itemId) then
        return true
    end

    local itemClassID, itemSubClassID = select(10, C_Item.GetItemInfo(itemId))
    if itemClassID == Enum.ItemClass.Battlepet or (itemClassID == Enum.ItemClass.Miscellaneous and (itemSubClassID == Enum.ItemMisc.Mount or itemSubClassID == Enum.ItemMisc.Pet)) then
        return true
    end

    if item:GetItemQuality() > Enum.ItemQuality.Epic then
        return true
    end

    return false
end

function TrashIt:RegisterLoot(event, ...)
    local message = ...
    local _, _, itemLink = string.find(message, "(|c%x+|Hitem:.-|h.-|h|r)")
    if not itemLink then
        return
    end

    local itemId = tonumber(string.match(itemLink, "item:(%d+)"))
    if not itemId or IsImportantItem(itemId) or MRP_CharacterSettings.ignoredTrashItItems[itemId] then
        return
    end

    local step = MRP.Filter:GetCurrentStep()
    if not step then
        return
    end

    local inInstance, instanceType = IsInInstance()
    if inInstance and (instanceType == "party" or instanceType == "raid") then
        local instanceId = select(8, GetInstanceInfo())
        local isStepInstance = false
        for _, mount in ipairs(step.mounts) do
            if mount.source.mapId == instanceId then
                isStepInstance = true
                break
            end
        end

        if isStepInstance then
            MRP_CharacterSettings.trashItItems[itemId] = true
        end
    elseif step.source.type == MRP.FilterSourceType.WorldBoss then
        local worldBoss = MRP.Data.worldBosses[step.source.name]
        if worldBoss and C_Map.GetBestMapForUnit("player") == worldBoss.mapID then
            local item = MRP.Util.GetItem(itemId)
            if item and item:GetItemQuality() >= Enum.ItemQuality.Epic then
                MRP_CharacterSettings.trashItItems[itemId] = true
            end
        end
    end
end

---@class TrashItItem
---@field bag number
---@field slot number
---@field item ItemMixin

---@return TrashItItem[] itemsToSell
function TrashIt:GatherTrashItData()
    local itemsToSell = {}

    for bag = 0, NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemId = C_Container.GetContainerItemID(bag, slot)
            if itemId and MRP_CharacterSettings.trashItItems[itemId] and not MRP_CharacterSettings.ignoredTrashItItems[itemId] then
                local item = Item:CreateFromBagAndSlot(bag, slot)
                if item then
                    table.insert(itemsToSell, { bag = bag, slot = slot, item = item })
                end
            end
        end
    end

    return itemsToSell
end

function TrashIt:CanPossiblyTrashIt()
    if not MerchantFrame or not MerchantFrame:IsShown() then
        return false
    end

    if GetMerchantNumItems() == 0 then
        return false
    end

    return #self:GatherTrashItData() > 0
end

function TrashIt:TrashItFromData(itemsToSell)
    if not self:CanPossiblyTrashIt() then
        print(L["|cffffd200[MRP]|r Trashing items is not possible at the moment."])
        C_Timer.After(0.5, function() MRP.UI:UpdateDisplay() end)
        return
    end

    if #itemsToSell == 0 then
        print(L["|cffffd200[MRP]|r No items to trash"])
        C_Timer.After(0.5, function() MRP.UI:UpdateDisplay() end)
        return
    end

    local function SellNext(index)
        if index > #itemsToSell then
            print(L["|cffffd200[MRP]|r All items trashed."])
            for _, data in ipairs(itemsToSell) do
                MRP_CharacterSettings.trashItItems[data.item:GetItemID()] = nil
            end
            C_Timer.After(0.5, function() MRP.UI:UpdateDisplay() end)
            return
        end

        if not MerchantFrame or not MerchantFrame:IsShown() then
            print(L["|cffffd200[MRP]|r Merchant frame is not open. Please open it to trash items."])
            C_Timer.After(0.5, function() MRP.UI:UpdateDisplay() end)
            return
        end

        local data = itemsToSell[index]
        if data then
            C_Container.UseContainerItem(data.bag, data.slot)
            print(format(L["|cffffd200[MRP]|r Trashed item: %s"], data.item:GetItemName()))
            C_Timer.After(0.1, function() SellNext(index + 1) end)
        end
    end

    SellNext(1)
end

function TrashIt:TrashIt()
    self:TrashItFromData(self:GatherTrashItData())
end

---@param event string
function TrashIt:CheckForTrashItInfo(event)
    if not (event == "MERCHANT_SHOW") then
        return
    end

    MRP.UI:ShowActionTrashIt()
end

local lootWatcher = CreateFrame("Frame")
lootWatcher:RegisterEvent("CHAT_MSG_LOOT")
lootWatcher:SetScript("OnEvent", function(_, event, ...)
    TrashIt:RegisterLoot(event, ...)
end)
