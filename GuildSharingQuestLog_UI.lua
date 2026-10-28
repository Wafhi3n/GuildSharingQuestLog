-- GuildSharingQuestLog_UI.lua — l'affichage (spec docs/specs/quetes-de-guilde.md, T3) : recalcule le
-- tableau des quêtes en commun quand l'annuaire ou mon journal change, puis prévient l'icône de la
-- minicarte (_Indicator.lua) et l'onglet du journal (_LogTab.lua) ; ajoute « Aussi dans la guilde »
-- à la bulle d'une quête du journal.
--
-- La ligne de la bulle passe par l'EventRegistry de Blizzard (« QuestMapLogTitleButton.OnEnter »,
-- déclenché APRÈS son GameTooltip:Show) : ses rappels tournent sous securecallfunction
-- (CallbackRegistry.lua de Forever), notre code ne peut donc pas tacher le sien. On ne touche jamais au
-- suivi des quêtes à l'écran (décision du user, 2026-10-28).
local _, NS = ...
local L = NS.L

local UI = { rows = {} }
NS.UI = UI

local REFRESH_DELAY = 0.5   -- s : une rafale de QUEST_LOG_UPDATE ne recalcule qu'une fois
local GUILD_GREEN = { 0.25, 1, 0.25 }

local function questTitle(id)
    return C_QuestLog.GetTitleForQuestID(id)
end

-- « elite », « group » ou nil. IsEliteQuest n'existe que sur Forever (et le PTR) ; suggestedGroup
-- se lit dans l'entrée du journal. Valeurs réelles jamais mesurées sur Forever (M4).
local function questFlag(id)
    local QL = C_QuestLog
    if QL.IsEliteQuest and QL.IsEliteQuest(id) == true then return "elite" end
    local index = QL.GetLogIndexForQuestID and QL.GetLogIndexForQuestID(id)
    local info = index and QL.GetInfo(index)
    local group = info and info.suggestedGroup
    if type(group) == "number" and group > 1 then return "group" end
    return nil
end

UI.questOpts = { title = questTitle, flag = questFlag }

function UI:Refresh()
    self.pending = false
    local mine = NS.MyQuests and NS.MyQuests() or {}
    self.rows = NS.Board.Build(mine, NS.sync.roster, self.questOpts)
    if NS.Indicator then NS.Indicator:Update(self.rows) end
    if NS.LogTab then NS.LogTab:Update(self.rows) end
end

function UI:RequestRefresh()
    if self.pending then return end
    self.pending = true
    C_Timer.After(REFRESH_DELAY, function() UI:Refresh() end)
end

-- Le titre d'une ligne, avec sa marque (élite, groupe) ; « Quête n°123 » si le jeu ne le donne pas.
function UI.RowTitle(row)
    local title = row.title or string.format(L["Quête n°%d"], row.id)
    if row.flag == "elite" then return title .. " " .. L["(élite)"] end
    if row.flag == "group" then return title .. " " .. L["(groupe)"] end
    return title
end

function UI.HoldersText(row)
    return NS.Board.HoldersText(row.holders, L)
end

-- La ligne ajoutée à la bulle d'une quête du journal, si des guildiens l'ont aussi.
local function onQuestTitleEnter(_, _, questID)
    if type(questID) ~= "number" or not GameTooltip:IsShown() then return end
    for _, row in ipairs(UI.rows) do
        if row.id == questID then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(string.format(L["Aussi dans la guilde : %s"], UI.HoldersText(row)),
                GUILD_GREEN[1], GUILD_GREEN[2], GUILD_GREEN[3], true)
            GameTooltip:Show()
            return
        end
    end
end

NS.OnRosterChange = function() UI:RequestRefresh() end
NS.OnJournalChange = function() UI:RequestRefresh() end

if EventRegistry and EventRegistry.RegisterCallback then
    EventRegistry:RegisterCallback("QuestMapLogTitleButton.OnEnter", onQuestTitleEnter, UI)
end
