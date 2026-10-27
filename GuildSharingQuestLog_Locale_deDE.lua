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
}
for k, v in pairs(T) do NS.L[k] = v end
