-- MRP_Locale.deDE.lua
local _, MRP = ...

if (GetLocale() ~= "deDE") then
    return;
end

MRP.L = {
    ["Mount Route Planner"] = "Mount Route Planner",
    ["Left-Click: Toggle Panel"] = "Linksklick: Menu umschalten",
    ["Drag: Move Button"] = "Ziehen: Schaltfläche verschieben",

    ["Mount Route Planner - Settings"] = "Mount Route Planner - Einstellungen",
    ["Use TomTom for waypoints"] = "TomTom für Wegpunkte verwenden",
    ["Enable this to use TomTom for waypoint navigation."] = "Durch das Aktivieren wird TomTom für die Wegpunkt Navigation genutzt",
    ["This will create waypoints for each step in your route."] = "Dies erstellt Wegpunkte für jeden Schritt in Ihrer Route.",
    ["You must have TomTom installed for this to work."] = "TomTom muss installiert sein, damit dies funktioniert.",
    ["You can toggle this setting at any time."] = "Du kannst diese Einstellung jederzeit umschalten.",

    ["|cff00ff00[MRP]|r TomTom usage is now: %s"] = "|cff00ff00[MRP]|r TomTom Nutzung ist jetzt: %s",
    ["|cff00ff00ENABLED|r"] = "|cff00ff00AKTIVIERT|r",
    ["|cffff0000DISABLED|r"] = "|cffff0000DEAKTIVIERT|r",

    ["|cffffd200Usage:|r"] = "|cffffd200Benutzung:|r",
    [" - /mrp → Toggle Mount Route Planner UI"] = " - /mrp → Umschalten des Mount Route Planner UI",
    [" - /mrp reset → Clears current progress and steps"] = " - /mrp reset → Löscht den aktuellen Fortschritt und die Schritte",
    [" - /mrp settings → Open addon settings"] = " - /mrp settings → Öffnet die Addon-Einstellungen",
    [" - /mrp tomtom on|off → Enable or disable TomTom integration"] = " - /mrp tomtom on|off → Aktiviert oder deaktiviert die TomTom-Integration",

    ["Reset Steps"] = "Schritte zurücksetzen",
    ["Clears current progress and steps"] = "Löscht den aktuellen Fortschritt und die Schritte",

    ["Settings"] = "Einstellungen",
    ["Open the MRP settings panel"] = "Öffnet das MRP-Einstellungsfenster",

    ["No step loaded."] = "Kein Schritt geladen.",

    ["<< Last"] = "<< Letzter",
    ["Next >>"] = "Nächster >>",

    ["Step 0 of 0"] = "Schritt 0 von 0",
    ["Step %d of %d"] = "Schritt %d von %d",

    ["Import Steps"] = "Importieren von Schritten",
    ["Paste Simple Armory Content"] = "Einfügen von Simple Armory Inhalten",

    ["Import"] = "Importieren",
    ["Prefill"] = "Vorbefüllen",
    ["Cancel"] = "Abbrechen",

    ["Automatically fills the input box with preset content based on your faction."] = "Füllt das Eingabefeld automatisch mit vordefinierten Inhalten basierend auf deiner Fraktion.",
    ["For optimal results import your character's data from Simple Armory."] = "Für optimale Ergebnisse importiere die Daten deines Charakters von Simple Armory.",

    ["To import simple armory content, copy the whole content from your simplearmory.com link and paste it into the input box.\n\nOpen in your Browser:"] = "Um Inhalte von Simple Armory zu importieren, kopiere den gesamten Inhalt von deinem simplearmory.com-Link und füge ihn in das Eingabefeld ein.\n\nIm Browser öffnen:",
    ["Close"] = "Schließen",

    ["Run %s"] = "Laufe %s",
    ["Kill %s"] = "Töte %s",
    ["Use %s"] = "Benutze %s",
    ["Fly to %s"] = "Fliege nach %s",
    ["Take Portal to %s"] = "Nehme das Portal nach %s",
    ["Use Hearthstone to %s"] = "Benutze den Ruhestein nach %s",
    ["Use Teleport to %s"] = "Benutze den Teleporter nach %s",
    ["Take Flight Path to %s"] = "Nehme den Flugpfad nach %s",
    ["Take Blimp to %s"] = "Nehme das Luftschiff nach %s",
    ["Walk to %s"] = "Gehe nach %s",

    ["Heroic 25"] = "Heroisch 25",
    ["Heroic"] = "Heroisch",
    ["Mythic"] = "Mythisch",

    ["Unknown"] = "Unbekannt",
    ["Unknown Boss"] = "Unbekannter Boss",

    ["Run the instance on '%s' difficulty to collect all mounts."] = "Laufe die Instanz auf '%s' Schwierigkeit, um alle Reittiere zu sammeln.",
    ["Your Hearthstone is set to a different location!"] = "Dein Ruhestein ist auf einen anderen Ort gesetzt!",

    ["Mount: %s"] = "Mount: %s",
    ["You have collected this mount."] = "Du hast dieses Reittier gesammelt.",
    ["This boss is dead."] = "Dieser Boss ist tot.",
    ["This boss is still alive."] = "Dieser Boss ist noch am Leben.",

    ["Auto-Skip Steps"] = "Auto-Überspringen von Schritten",
    ["Automatically skips steps that are already completed."] = "Überspringt automatisch Schritte, die bereits abgeschlossen sind.",

    ["Auto-Advance Steps"] = "Auto-Fortschritt der Schritte",
    ["Automatically advances to the next step after completing the current one."] = "Automatisch zum nächsten Schritt wechseln, nachdem der aktuelle abgeschlossen ist.",

    ["Instance location not found: '%s', please report it."] = "Instanzstandort nicht gefunden: '%s', bitte melde es.",
    ["NPC location not found for: '%s', please report it."] = "NPC-Standort nicht gefunden für: '%s', bitte melde es.",
    ["Item location not found for: '%s', please report it."] = "Gegenstandsstandort nicht gefunden für: '%s', bitte melde es.",
    ["Portal location not found for: '%s' in '%s', please report it."] = "Portalstandort nicht gefunden für: '%s' in '%s', bitte melde es.",
    ["Teleport location not found for: '%s', please report it."] = "Teleportstandort nicht gefunden für: '%s', bitte melde es.",
    ["Blimp location not found for: '%s', please report it."] = "Luftschiffstandort nicht gefunden für: '%s', bitte melde es.",
    ["Flightmaster location not found for: '%s', please report it."] = "Flugmeisterstandort nicht gefunden für: '%s', bitte melde es.",
    ["Unknown action: '%s', please report it."] = "Unbekannte Aktion: '%s', bitte melde es.",

    ["Map ID not found for: '%s', please report it."] = "Map ID nicht gefunden für: '%s', bitte melde es.",
    ["Failed to add TomTom waypoint for: '%s', please report it."] = "Fehler beim Hinzufügen des TomTom-Wegpunkts für: '%s', bitte melde es.",
    ["Invalid map ID for: '%s', please report it."] = "Ungültige Map ID für: '%s', bitte melde es.",
    ["Invalid coordinates for: '%s', please report it."] = "Ungültige Koordinaten für: '%s', bitte melde es.",
    ["Cannot set waypoint on map: '%s', please report it."] = "Kann keinen Wegpunkt auf der Karte setzen: '%s', bitte melde es.",

    ["Mount not found: '%s', please report it."] = "Reittier nicht gefunden: '%s', bitte melde es.",
    ["Item not found: '%s', please report it."] = "Gegenstand nicht gefunden: '%s', bitte melde es.",

    ["Wrong Difficulty"] = "Falsche Schwierigkeit",
    ["Please switch to '%s'"] = "Bitte auf '%s' umstellen"
}

setmetatable(MRP.L, {
    __index = function(t, k)
        rawset(t, k, k); return k;
    end
})
