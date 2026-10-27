-- GuildSharingQuestLog_Locale_esES.lua — overlay ESPAGNOL (esES/esMX). Clé FR → texte ES.
-- Chargé APRÈS GuildSharingQuestLog_Locale.lua (qui crée NS.L). Sur un client non espagnol : early-return.
local _, NS = ...
NS = NS or _G.GuildSharingQuestLog
if not NS or not NS.L then return end

local locale = GetLocale and GetLocale() or "enUS"
if locale ~= "esES" and locale ~= "esMX" then return end

local T = {
    ["version %s. Tape /%s pour l'aide."] = "versión %s. Escribe /%s para ver la ayuda.",
    ["version %s"]                    = "versión %s",
    ["Commandes :"]                   = "Comandos:",
    ["affiche la version"]            = "muestra la versión",
    ["partage de mes quêtes avec la guilde"]            = "compartir mis misiones con la hermandad",
    ["Partage de mes quêtes avec la guilde : activé."] = "Compartir mis misiones con la hermandad: activado.",
    ["Partage de mes quêtes avec la guilde : coupé."]  = "Compartir mis misiones con la hermandad: desactivado.",
}
for k, v in pairs(T) do NS.L[k] = v end
