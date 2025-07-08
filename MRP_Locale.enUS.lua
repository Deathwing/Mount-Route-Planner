-- MRP_Locale.enUS.lua
local _, MRP = ...

MRP.L = {
    ["Mount Route Planner"] = "Mount Route Planner",
    ["Left-Click: Toggle Panel"] = "Left-Click: Toggle Panel",
    ["Drag: Move Button"] = "Drag: Move Button",

    ["Mount Route Planner - Settings"] = "Mount Route Planner - Settings",
    ["Use TomTom for waypoints"] = "Use TomTom for waypoints",
    ["Enable this to use TomTom for waypoint navigation."] = "Enable this to use TomTom for waypoint navigation.",
    ["This will create waypoints for each step in your route."] = "This will create waypoints for each step in your route.",
    ["You must have TomTom installed for this to work."] = "You must have TomTom installed for this to work.",
    ["You can toggle this setting at any time."] = "You can toggle this setting at any time.",

    ["|cff00ff00[MRP]|r TomTom usage is now: %s"] = "|cff00ff00[MRP]|r TomTom usage is now: %s",
    ["|cff00ff00ENABLED|r"] = "|cff00ff00ENABLED|r",
    ["|cffff0000DISABLED|r"] = "|cffff0000DISABLED|r",

    ["|cffffd200Usage:|r"] = "|cffffd200Usage:|r",
    [" - /mrp → Toggle Mount Route Planner UI"] = " - /mrp → Toggle Mount Route Planner UI",
    [" - /mrp reset → Clears current progress and steps"] = " - /mrp reset → Clears current progress and steps",
    [" - /mrp settings → Open addon settings"] = " - /mrp settings → Open addon settings",
    [" - /mrp tomtom on|off → Enable or disable TomTom integration"] = " - /mrp tomtom on|off → Enable or disable TomTom integration",

    ["Reset Steps"] = "Reset Steps",
    ["Clears current progress and steps"] = "Clears current progress and steps",

    ["Settings"] = "Settings",
    ["Open the MRP settings panel"] = "Open the MRP settings panel",

    ["No step loaded."] = "No step loaded.",

    ["<< Last"] = "<< Last",
    ["Next >>"] = "Next >>",

    ["Step 0 of 0"] = "Step 0 of 0",
    ["Step %d of %d"] = "Step %d of %d",

    ["Import Steps"] = "Import Steps",
    ["Paste Simple Armory Content"] = "Paste Simple Armory Content",

    ["Import"] = "Import",
    ["Prefill"] = "Prefill",
    ["Cancel"] = "Cancel",

    ["Automatically fills the input box with preset content based on your faction."] = "Automatically fills the input box with preset content based on your faction.",
    ["For optimal results import your character's data from Simple Armory."] = "For optimal results import your character's data from Simple Armory.",

    ["To import simple armory content, copy the whole content from your simplearmory.com link and paste it into the input box.\n\nOpen in your Browser:"] = "To import simple armory content, copy the whole content from your simplearmory.com link and paste it into the input box.\n\nOpen in your Browser:",
    ["Close"] = "Close",

    ["Run %s"] = "Run %s",
    ["Kill %s"] = "Kill %s",
    ["Use %s"] = "Use %s",
    ["Fly to %s"] = "Fly to %s",
    ["Take Portal to %s"] = "Take Portal to %s",
    ["Use Hearthstone to %s"] = "Use Hearthstone to %s",
    ["Use Teleport to %s"] = "Use Teleport to %s",
    ["Take Flight Path to %s"] = "Take Flight Path to %s",
    ["Take Blimp to %s"] = "Take Blimp to %s",
    ["Walk to %s"] = "Walk to %s",

    ["Heroic 25"] = "Heroic 25",
    ["Heroic"] = "Heroic",
    ["Mythic"] = "Mythic",

    ["Unknown"] = "Unknown",
    ["Unknown Boss"] = "Unknown Boss",

    ["Run the instance on '%s' difficulty to collect all mounts."] = "Run the instance on '%s' difficulty to collect all mounts.",
    ["Your Hearthstone is set to a different location!"] = "Your Hearthstone is set to a different location!",

    ["Mount: %s"] = "Mount: %s",
    ["You have collected this mount."] = "You have collected this mount.",
    ["This boss is dead."] = "This boss is dead.",
    ["This boss is still alive."] = "This boss is still alive.",

    ["Auto-Skip Steps"] = "Auto-Skip Steps",
    ["Automatically skips steps that are already completed."] = "Automatically skips steps that are already completed.",

    ["Auto-Advance Steps"] = "Auto-Advance Steps",
    ["Automatically advances to the next step after completing the current one."] = "Automatically advances to the next step after completing the current one.",

    ["Instance location not found: '%s', please report it."] = "Instance location not found: '%s', please report it.",
    ["NPC location not found for: '%s', please report it."] = "NPC location not found for: '%s', please report it.",
    ["Item location not found for: '%s', please report it."] = "Item location not found for: '%s', please report it.",
    ["Portal location not found for: '%s' in '%s', please report it."] = "Portal location not found for: '%s' in '%s', please report it.",
    ["Teleport location not found for: '%s', please report it."] = "Teleport location not found for: '%s', please report it.",
    ["Blimp location not found for: '%s', please report it."] = "Blimp location not found for: '%s', please report it.",
    ["Flightmaster location not found for: '%s', please report it."] = "Flightmaster location not found for: '%s', please report it.",
    ["Unknown action: '%s', please report it."] = "Unknown action: '%s', please report it.",

    ["Map ID not found for: '%s', please report it."] = "Map ID not found for: '%s', please report it.",
    ["Failed to add TomTom waypoint for: '%s', please report it."] = "Failed to add TomTom waypoint for: '%s', please report it.",
    ["Invalid map ID for: '%s', please report it."] = "Invalid map ID for: '%s', please report it.",
    ["Invalid coordinates for: '%s', please report it."] = "Invalid coordinates for: '%s', please report it.",
    ["Cannot set waypoint on map: '%s', please report it."] = "Cannot set waypoint on map: '%s', please report it.",

    ["Mount not found: '%s', please report it."] = "Mount not found: '%s', please report it.",
    ["Item not found: '%s', please report it."] = "Item not found: '%s', please report it.",

    ["Wrong Difficulty"] = "Wrong Difficulty",
    ["Please switch to '%s'"] = "Please switch to '%s'"
}

setmetatable(MRP.L, {
    __index = function(t, k)
        rawset(t, k, k); return k;
    end
})
