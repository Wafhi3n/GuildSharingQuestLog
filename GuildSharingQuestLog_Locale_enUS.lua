-- GuildSharingQuestLog_Locale_enUS.lua — overlay ANGLAIS (enUS/enGB). Clé FR → texte EN.
-- Chargé APRÈS GuildSharingQuestLog_Locale.lua (qui crée NS.L). Sur un client non anglais : early-return.
local _, NS = ...
NS = NS or _G.GuildSharingQuestLog
if not NS or not NS.L then return end

local locale = GetLocale and GetLocale() or "enUS"
if locale ~= "enUS" and locale ~= "enGB" then return end

local T = {
    ["version %s. Tape /%s pour l'aide."] = "version %s. Type /%s for help.",
    ["version %s"]                    = "version %s",
    ["Commandes :"]                   = "Commands:",
    ["affiche la version"]            = "shows the version",
    ["partage de mes quêtes avec la guilde"]            = "share my quests with the guild",
    ["Partage de mes quêtes avec la guilde : activé."] = "Sharing my quests with the guild: on.",
    ["Partage de mes quêtes avec la guilde : coupé."]  = "Sharing my quests with the guild: off.",
    ["Quête n°%d"]                                      = "Quest #%d",
    ["(élite)"]                                         = "(elite)",
    ["(groupe)"]                                        = "(group)",
    ["Aussi dans la guilde : %s"]                       = "Also in the guild: %s",
    ["%s et %d autres"]                                 = "%s and %d others",
    ["Quêtes de guilde"]                                = "Guild quests",
    ["%d quête(s) en commun avec la guilde"]            = "%d quest(s) shared with the guild",
    ["… et %d autres"]                                  = "… and %d more",
    ["Clic : ouvrir la liste dans le journal (hors combat)"] = "Click: open the list in the quest log (out of combat)",
    ["Clic : voir la quête (hors combat)"]              = "Click: show the quest (out of combat)",
    ["Quêtes en commun avec la guilde"]                 = "Quests shared with the guild",
    ["Aucune quête en commun avec un guildien connecté pour l'instant."] = "No quest shared with an online guildmate yet.",
}
for k, v in pairs(T) do NS.L[k] = v end
