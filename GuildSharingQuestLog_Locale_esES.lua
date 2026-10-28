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
    ["Quête n°%d"]                                      = "Misión n.º %d",
    ["(élite)"]                                         = "(élite)",
    ["(groupe)"]                                        = "(grupo)",
    ["Aussi dans la guilde : %s"]                       = "También en la hermandad: %s",
    ["%s et %d autres"]                                 = "%s y %d más",
    ["Quêtes de guilde"]                                = "Misiones de hermandad",
    ["%d quête(s) en commun avec la guilde"]            = "%d misión(es) en común con la hermandad",
    ["… et %d autres"]                                  = "… y %d más",
    ["Clic : ouvrir la liste dans le journal (hors combat)"] = "Clic: abrir la lista en el registro de misiones (fuera de combate)",
    ["Clic : voir la quête (hors combat)"]              = "Clic: ver la misión (fuera de combate)",
    ["Quêtes en commun avec la guilde"]                 = "Misiones en común con la hermandad",
    ["Aucune quête en commun avec un guildien connecté pour l'instant."] = "Aún no hay misiones en común con un miembro conectado.",
}
for k, v in pairs(T) do NS.L[k] = v end
