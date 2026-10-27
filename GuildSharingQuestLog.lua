-- GuildSharingQuestLog.lua — socle : table d'addon, réglages par défaut, SavedVariables, commande /gsql.
--
-- Chargé APRÈS la locale, AVANT les modules. Les SavedVariables sont prêtes sur l'ADDON_LOADED de
-- CET addon ; les modules démarrent sur PLAYER_LOGIN, quand tous les fichiers du .toc sont chargés
-- (même découpage que LeyLines.lua).
local ADDON, NS = ...
local L = NS.L

NS.VERSION = "0.1.0"   -- = ## Version du .toc ; scripts\bump_version.ps1 -Addon GuildSharingQuestLog la tient égale
_G.GuildSharingQuestLog = NS

-- Réglages par défaut. CopyDefaults complète la base sans écraser ce que le joueur a changé ;
-- schemaVer sert le jour où une migration de la base devient nécessaire.
NS.DEFAULTS = {
    schemaVer = 1,
    share = true,   -- partager mes quêtes avec la guilde (P3 : actif à l'installation)
    known = {},     -- [« Nom-Royaume »] = { [questID] = true } : mes quêtes, d'une session à l'autre
}

local function CopyDefaults(dst, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dst[k]) ~= "table" then dst[k] = {} end
            CopyDefaults(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
end

function NS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ccffDiscord Guild Sharing Quest Log|r " .. tostring(msg))
end

function NS:Printf(fmt, ...)
    self:Print(string.format(fmt, ...))
end

-- `/gsql share` montre l'état ; seuls `on` et `off` le changent (skill publique `chat-output`).
function NS:Share(arg)
    if arg == "on" or arg == "off" then
        local share = arg == "on"
        if self.db.share ~= share then
            self.db.share = share
            if self.sync then self.sync:SharingChanged() end
        end
    end
    self:Print(self.db.share and L["Partage de mes quêtes avec la guilde : activé."]
        or L["Partage de mes quêtes avec la guilde : coupé."])
end

function NS:Slash(msg)
    local cmd, arg = (msg or ""):match("^%s*(%S*)%s*(%S*)")
    cmd, arg = (cmd or ""):lower(), (arg or ""):lower()
    if cmd == "version" then
        self:Printf(L["version %s"], self.VERSION)
    elseif cmd == "share" then
        self:Share(arg)
    else
        self:Print(L["Commandes :"])
        self:Print("/gsql share [on|off] - " .. L["partage de mes quêtes avec la guilde"])
        self:Print("/gsql version - " .. L["affiche la version"])
    end
end

SLASH_GUILDSHARINGQUESTLOG1 = "/gsql"
SlashCmdList["GUILDSHARINGQUESTLOG"] = function(msg) NS:Slash(msg) end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == ADDON then
        GuildSharingQuestLogDB = GuildSharingQuestLogDB or {}
        CopyDefaults(GuildSharingQuestLogDB, NS.DEFAULTS)
        NS.db = GuildSharingQuestLogDB
    elseif event == "PLAYER_LOGIN" then
        -- Muet à la connexion, sauf la première après une installation ou une mise à jour (règle du
        -- user du 2026-10-11, skill publique `chat-output`). seenVersion vit dans la base du COMPTE :
        -- une ligne par compte, pas par perso.
        if NS.db.seenVersion ~= NS.VERSION then
            NS.db.seenVersion = NS.VERSION
            NS:Printf(L["version %s. Tape /%s pour l'aide."], NS.VERSION, "gsql")
        end
    end
end)
