-- GuildSharingQuestLog_Locale_deDE.lua — overlay ALLEMAND. Clé FR → texte DE.
-- Chargé APRÈS GuildSharingQuestLog_Locale.lua (qui crée NS.L). Sur un client non allemand : early-return.
local _, NS = ...
NS = NS or _G.GuildSharingQuestLog
if not NS or not NS.L then return end

if (GetLocale and GetLocale() or "enUS") ~= "deDE" then return end

local T = {
    ["version %s. Tape /%s pour l'aide."] = "Version %s. Gib /%s für die Hilfe ein.",
    ["version %s"]                    = "Version %s",
    ["Commandes :"]                   = "Befehle:",
    ["affiche la version"]            = "zeigt die Version",
    ["partage de mes quêtes avec la guilde"]            = "meine Quests mit der Gilde teilen",
    ["Partage de mes quêtes avec la guilde : activé."] = "Meine Quests mit der Gilde teilen: an.",
    ["Partage de mes quêtes avec la guilde : coupé."]  = "Meine Quests mit der Gilde teilen: aus.",
    ["Quête n°%d"]                                      = "Quest Nr. %d",
    ["(élite)"]                                         = "(Elite)",
    ["(groupe)"]                                        = "(Gruppe)",
    ["Aussi dans la guilde : %s"]                       = "Auch in der Gilde: %s",
    ["%s et %d autres"]                                 = "%s und %d weitere",
    ["Quêtes de guilde"]                                = "Gildenquests",
    ["%d quête(s) en commun avec la guilde"]            = "%d gemeinsame Quest(s) mit der Gilde",
    ["… et %d autres"]                                  = "… und %d weitere",
    ["Clic : ouvrir la liste dans le journal (hors combat)"] = "Klick: Liste im Questlog öffnen (außerhalb des Kampfes)",
    ["Clic : voir la quête (hors combat)"]              = "Klick: Quest anzeigen (außerhalb des Kampfes)",
    ["Quêtes en commun avec la guilde"]                 = "Gemeinsame Quests mit der Gilde",
    ["Aucune quête en commun avec un guildien connecté pour l'instant."] = "Noch keine gemeinsame Quest mit einem Gildenmitglied online.",
}
for k, v in pairs(T) do NS.L[k] = v end
