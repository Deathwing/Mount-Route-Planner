MRP = MRP or {}
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
        local num, action = line:match("^(%d+)%s+(.+)$")
        if num and not action:find("^Man,") then
            current = {
                actions = splitActions(self:GetRacialText(action)),
                rewards = {}
            }
            lastReward = nil -- Reset for the new step
            table.insert(raw, current)
        elseif current then
            -- Check if the line has actual content or is just whitespace
            local content = line:match("^%s*(%S.*%S*)%s*$")

            if content then -- Only proceed if the line is not empty
                local boss, mount = content:match("^(%S.-)%s%s+(%S.-)$")
                if boss and mount then
                    -- This line defines a boss and a mount
                    lastReward = {
                        boss = boss,
                        mount = mount,
                        note = ""
                    }
                    table.insert(current.rewards, lastReward)
                else
                    -- This line is a note. Let's attach it to the right place.
                    local txt = content
                    if lastReward then
                        -- If we just read a boss/mount, this note belongs to it.
                        if lastReward.note and lastReward.note ~= "" then
                            lastReward.note = lastReward.note .. "\n" .. txt
                        else
                            lastReward.note = txt
                        end
                    else
                        -- If no reward is listed yet for this step, it's a general note.
                        if not current.note then current.note = "" end
                        if current.note ~= "" then
                            current.note = current.note .. "\n" .. self:GetRacialText(txt)
                        else
                            current.note = self:GetRacialText(txt)
                        end
                    end
                end
            end
            -- Lines that are empty or only contain whitespace will now be correctly ignored.
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
            step.location = MRP.Data.genericPortals[step.portal or ""] or (MRP.Data.portals[prevLabel or ""] and MRP.Data.portals[prevLabel or ""][step.portal or ""])
            if not step.location then
                print("|cffffcc00[MRP]|r " .. format(L["Portal location not found for: '%s' in '%s', please report it."], step.portal or "", prevLabel or ""))
            end
        elseif lower:find("hearthstone to") then
            step.hearthstone = step.action:match("Hearthstone to (.+)")
            step.location = { x = 0.5, y = 0.5, mapName = step.hearthstone, getFromNextStep = true }
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
