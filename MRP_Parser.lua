-- MRP_Parser.lua
local _, MRP = ...

local L = MRP.L

local Parser = {}
MRP.Parser = Parser

function Parser:GetRacialText(text)
    if text:find(" / ") then
        local faction1, faction2 = text:match("^(.-) / (.-)$")
        if faction1 and faction2 then
            local playerFaction = UnitFactionGroup("player")

            if (faction1:find("Blimp")) then
                return playerFaction == "Horde" and faction1 or faction2
            elseif (faction2:find("Blimp")) then
                return playerFaction == "Horde" and faction2 or faction1
            end

            if (faction1:find("Zandalar")) then
                return playerFaction == "Alliance" and faction1:gsub("Zandalar", "Kul'Tiras") or faction1
            elseif (faction2:find("Zandalar")) then
                return playerFaction == "Alliance" and faction2:gsub("Zandalar", "Kul'Tiras") or faction2
            end
        end
    end

    return text
end

function Parser:ParseSteps(text)
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    local raw = {}
    local current, lastReward
    local bossesCount = 0
    local notesCount = 0

    local function splitActions(action)
        local parts = {}

        if action:lower():find("normal and heroic") then
            table.insert(parts, action)
        else
            local last_end = 1
            local s, e = string.find(action, "%s+and%s+", last_end)
            while s do
                local part = string.sub(action, last_end, s - 1)
                table.insert(parts, part)
                last_end = e + 1
                s, e = string.find(action, "%s+and%s+", last_end)
            end
            table.insert(parts, string.sub(action, last_end))

            local newParts = {}
            for _, part in ipairs(parts) do
                local sub_last_end = 1
                local sub_s, sub_e = string.find(part, ",%s*then%s+", sub_last_end)
                if sub_s then
                    while sub_s do
                        local sub_part = string.sub(part, sub_last_end, sub_s - 1)
                        table.insert(newParts, sub_part)
                        sub_last_end = sub_e + 1
                        sub_s, sub_e = string.find(part, ",%s*then%s+", sub_last_end)
                    end
                    table.insert(newParts, string.sub(part, sub_last_end))
                else
                    table.insert(newParts, part)
                end
            end
            parts = newParts
        end

        for i, v in ipairs(parts) do
            parts[i] = v:gsub("^%s+", ""):gsub("%s+$", "")
        end
        for i, v in ipairs(parts) do
            parts[i] = v:gsub("^then%s+", "")
        end
        return parts
    end

    for _, line in ipairs(lines) do
        -- if the line is like '482 / 1095 (45%)' then skip it
        if not line:find("^%d+%s*/%s*%d+%s*%(%d+%%%)$") then
            line = line:gsub("^%s*[-—]*%s*", "")
            local num, action = line:match("^(%d+)%s+(.+)$")
            if num and not action:find("^Man,") then
                local part1, part2 = action:match("^(.-)%s%s%s%s%s%s%s%s(.*)$")
                current = {
                    actions = splitActions(self:GetRacialText(part1 or action)),
                    rewards = {},
                    rawRewardNotes = {},
                }
                if part2 and part2 ~= "" then
                    current.note = self:GetRacialText(part2)
                end
                lastReward = nil
                bossesCount = 0
                notesCount = 0
                table.insert(raw, current)
            elseif current then
                local boss, mount = line:match("^(%S.-)%s%s+(%S.-)%s*$")
                if boss and mount then
                    lastReward = {
                        boss = boss,
                        mount = mount,
                        note = ""
                    }
                    table.insert(current.rewards, lastReward)
                    bossesCount = bossesCount + 1
                else
                    local txt = line:match("%S.*") or ""
                    if current.rewards and #current.rewards > 0 then
                        table.insert(current.rawRewardNotes, txt)
                    else
                        current.note = self:GetRacialText(txt)
                    end
                    notesCount = notesCount + 1
                end
            end
        end
    end

    local steps = {}
    local id = 1
    for _, entry in ipairs(raw) do
        for _, act in ipairs(entry.actions) do
            local s = {
                step = id,
                action = act
            }
            if entry.note then
                s.note = entry.note
            end
            if #entry.rewards > 0 then
                s.rewards = entry.rewards
            end
            if #entry.rawRewardNotes > 0 then
                local noteOffset = 0

                -- on firefox we get 1 more note than rewards
                if #entry.rawRewardNotes == #entry.rewards + 1 then
                    noteOffset = 1
                end

                -- copy raw reward notes to rewards
                for i, reward in ipairs(entry.rewards) do
                    if entry.rawRewardNotes[i + noteOffset] then
                        reward.note = entry.rawRewardNotes[i + noteOffset]
                    end
                end
            end
            table.insert(steps, s)
            id = id + 1
        end
    end

    return steps
end

function Parser:Parse(text)
    local steps = self:ParseSteps(text)

    local prevLabel = nil
    for i, step in ipairs(steps) do
        local lower = step.action:lower()
        if lower:find("run ") then
            step.instance = step.action:match("Run (.+)")
            step.instance = step.instance:gsub(" on both Normal and Heroic", "")

            step.location = MRP.Data.instances[step.instance or ""]
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Instance location not found: '%s', please report it."], step.instance or ""))
            end
        elseif lower:find("kill ") then
            step.npc = step.action:match("Kill (.+)")
            step.location = MRP.Data.npcs[step.npc or ""]
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["NPC location not found for: '%s', please report it."], step.npc or ""))
            end
        elseif lower:find("use ") then
            step.item = step.action:match("Use (.+)")
            step.location = MRP.Data.items[step.item or ""]
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Item location not found for: '%s', please report it."], step.item or ""))
            end
        elseif lower:find("fly to ") then
            step.flyTo = step.action:match("Fly to (.+)")
            step.location = { x = 0.5, y = 0.5, mapName = step.flyTo, getFromNextStep = true }
        elseif lower:find("take the teleporter to ") then
            step.portal = step.action:match("take the teleporter to (.+)")
            step.location = MRP.Data.genericPortals[step.portal or ""] or (MRP.Data.portals[prevLabel or ""] and MRP.Data.portals[prevLabel or ""][step.portal or ""])
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Portal location not found for: '%s' in '%s', please report it."], step.portal or "", prevLabel or ""))
            end
        elseif lower:find("take the portal to ") then
            step.portal = step.action:match("Take the portal to (.+)")
            step.portal = step.portal:gsub(" in the Emerald Enclave", "")

            step.location = MRP.Data.genericPortals[step.portal or ""] or (MRP.Data.portals[prevLabel or ""] and MRP.Data.portals[prevLabel or ""][step.portal or ""])
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Portal location not found for: '%s' in '%s', please report it."], step.portal or "", prevLabel or ""))
            end
        elseif lower:find("portal to ") then
            step.portal = step.action:match("Portal to (.+)")
            if i == 1 then
                prevLabel = UnitFactionGroup("player") == "Horde" and "Orgrimmar" or "Stormwind"
            end

            step.location = MRP.Data.genericPortals[step.portal or ""] or (MRP.Data.portals[prevLabel or ""] and MRP.Data.portals[prevLabel or ""][step.portal or ""])
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Portal location not found for: '%s' in '%s', please report it."], step.portal or "", prevLabel or ""))
            end
        elseif lower:find("hearthstone to") or lower:find("heartstone to ") then
            step.hearthstone = step.action:match("Hearthstone to (.+)") or step.action:match("Heartstone to (.+)")
            if step.hearthstone == "Dalaran" then
                step.hearthstone = nil
                step.item = "Dalaran Hearthstone"
                step.location = MRP.Data.items[step.item or ""]
                if not step.location then
                    print("|cffffcc00[MRP]|r " .. format(L["Item location not found for: '%s', please report it."], step.item or ""))
                end
            else
                step.location = { x = 0.5, y = 0.5, mapName = step.hearthstone, getFromNextStep = true }
            end
        elseif lower:find("teleport to ") then
            step.teleport = step.action:match("Teleport to (.+)")
            step.location = MRP.Data.teleports[step.teleport or ""]
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Teleport location not found for: '%s', please report it."], step.teleport or ""))
            end
        elseif lower:find("blimp to ") then
            step.blimp = step.action:match("Blimp to (.+)")
            step.location = MRP.Data.blimps[step.blimp or ""]
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Blimp location not found for: '%s', please report it."], step.blimp or ""))
            end
        elseif lower:find("flightpath to ") then
            step.flightpath = step.action:match("Flightpath to (.+)")
            step.location = MRP.Data.flightmasters[prevLabel or ""]
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Flightmaster location not found for: '%s', please report it."], prevLabel or ""))
            end
        elseif lower:find("walk to ") then
            step.walkTo = step.action:match("Walk to (.+)")
            step.location = { x = 0.5, y = 0.5, mapName = step.walkTo, getFromNextStep = true }
        else
            print("|cffffcc00[MRP]|r " .. format(L["Unknown action: '%s', please report it."], step.action))
        end

        if step.rewards and #step.rewards > 0 then
            for i = i - 1, 1, -1 do
                local prevStep = steps[i]
                if prevStep.rewards and #prevStep.rewards > 0 then
                    break
                end
                prevStep.linkedStep = step
            end
        end

        step.label = step.instance or step.npc or step.item or step.flyTo or step.portal or step.hearthstone or step.teleport or step.blimp or step.flightpath or step.walkTo or ""
        prevLabel = step.label
    end

    return steps
end
