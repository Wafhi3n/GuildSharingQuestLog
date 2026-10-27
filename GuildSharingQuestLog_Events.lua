-- GuildSharingQuestLog_Events.lua — le branchement sur le jeu : les événements de Blizzard vers
-- NS.Sync (la logique, testée sans client), et le jeu vers son `env`. Rien d'autre ici.
--
-- Fonctions du jeu utilisées, toutes présentes sur Forever (documentation de l'API, build 70532,
-- relue le 2026-10-27) ou mesurées : C_QuestLog.GetNumQuestLogEntries / GetInfo / IsOnQuest,
-- C_ChatInfo.SendAddonMessage / RegisterAddonMessagePrefix / InChatMessagingLockdown,
-- C_GuildInfo.GuildRoster, GetNormalizedRealmName, IsInGuild ; GetNumGuildMembers et
-- GetGuildRosterInfo sont des globales vivantes sur Forever (skill wow-forever-api) ; sur le PTR de
-- Retail, leurs noms arrivent en « Nom-Royaume » et le champ 9 dit « en ligne » (mesuré le 2026-10-27).
local _, NS = ...

local ROSTER_EVERY = 60   -- s : on redemande la liste de guilde (le serveur bride lui-même)

-- « Nom-Royaume » du joueur, ou nil tant que le royaume n'est pas connu (tôt dans la session).
local function myName()
    local name = UnitName and UnitName("player")
    local realm = GetNormalizedRealmName and GetNormalizedRealmName()
    if type(name) == "string" and type(realm) == "string" and realm ~= "" then return name .. "-" .. realm end
    return nil
end

-- Mes quêtes connues, gardées d'une session à l'autre (base du COMPTE : rangées par perso).
local function known()
    local me = myName()
    if not (me and NS.db) then return {} end
    NS.db.known = NS.db.known or {}
    NS.db.known[me] = NS.db.known[me] or {}
    return NS.db.known[me]
end

local questApi = {
    count = function() return (C_QuestLog.GetNumQuestLogEntries()) end,
    info = function(i) return C_QuestLog.GetInfo(i) end,
    onQuest = function(id) return C_QuestLog.IsOnQuest(id) end,
}

-- Une fois le journal chargé, ce qu'on vient de lire devient la liste connue (les quêtes parties sur
-- preuve en sortent).
local function readJournal(loaded)
    local me = myName()
    local ids, set = NS.Journal.Read(questApi, known(), loaded)
    if loaded and me and NS.db then NS.db.known[me] = set end
    return ids
end

local SUCCESS = Enum and Enum.SendAddonMessageResult and Enum.SendAddonMessageResult.Success or 0

local function send(msg, channel, target)
    local ok, r = pcall(C_ChatInfo.SendAddonMessage, NS.Wire.PREFIX, msg, channel, target)
    return ok and (r == SUCCESS or r == true)
end

local function locked()
    local f = C_ChatInfo and C_ChatInfo.InChatMessagingLockdown
    return f ~= nil and f() == true
end

NS.sync = NS.Sync.New({
    me = myName,
    time = time,
    after = function(s, fn) C_Timer.After(s, fn) end,
    random = function(a, b) return math.random(a, b) end,
    send = send,
    locked = locked,
    sharing = function() return not (NS.db and NS.db.share == false) end,
    readJournal = readJournal,
    onChange = function() if NS.OnRosterChange then NS.OnRosterChange() end end,
})

local function guildMembers()
    local out = {}
    if not (GetNumGuildMembers and GetGuildRosterInfo) then return out end
    for i = 1, (GetNumGuildMembers() or 0) do
        local name, _, _, _, _, _, _, _, online = GetGuildRosterInfo(i)
        out[#out + 1] = { name = name, online = online }
    end
    return out
end

local function inGuild() return IsInGuild and IsInGuild() end

local function tryStart()
    if inGuild() then NS.sync:Start() end
end

local handlers = {
    PLAYER_ENTERING_WORLD = tryStart,
    PLAYER_GUILD_UPDATE = function()
        if inGuild() then NS.sync:Start() else NS.sync:Stop() end
    end,
    GUILD_ROSTER_UPDATE = function()
        tryStart()
        NS.sync:GuildRoster(guildMembers())
    end,
    QUEST_LOG_UPDATE = function()
        tryStart()
        NS.sync:LogUpdated()
    end,
    QUEST_ACCEPTED = function(id) if type(id) == "number" then known()[id] = true end end,
    QUEST_REMOVED = function(id) if type(id) == "number" then known()[id] = nil end end,
    CHAT_MSG_ADDON = function(...) NS.sync:OnMessage(...) end,
}

if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
    C_ChatInfo.RegisterAddonMessagePrefix(NS.Wire.PREFIX)
end

local f = CreateFrame("Frame")
for event in pairs(handlers) do f:RegisterEvent(event) end
f:SetScript("OnEvent", function(_, event, ...) handlers[event](...) end)

if C_Timer and C_Timer.NewTicker then
    C_Timer.NewTicker(ROSTER_EVERY, function()
        if inGuild() and C_GuildInfo and C_GuildInfo.GuildRoster then C_GuildInfo.GuildRoster() end
    end)
end
