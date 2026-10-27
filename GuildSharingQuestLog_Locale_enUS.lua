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
}
for k, v in pairs(T) do NS.L[k] = v end
