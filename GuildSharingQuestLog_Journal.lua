-- GuildSharingQuestLog_Journal.lua — mes quêtes, lues dans le journal (spec docs/specs/quetes-de-guilde.md).
--
-- Une quête ne SORT de la liste que sur une preuve : `QUEST_REMOVED` (géré par l'appelant), ou
-- `IsOnQuest(id) == false` une fois le journal chargé. Jamais parce qu'un balayage ne l'a pas vue :
-- dans le code de Forever, Blizzard déplie les catégories repliées avant de chercher dans le journal
-- (Mainline/QuestMapFrame.lua, QuestSearcher:SaveHeaderStates), signe qu'un repli peut cacher des
-- entrées. Mesuré sur le PTR de Retail le 2026-10-27 : replier « Forêt d'Elwynn » n'a rien caché (M8
-- à refaire sur Forever). On garde donc les quêtes déjà connues, plus les visibles.
--
-- Avant le premier QUEST_LOG_UPDATE (`loaded` faux), le journal peut répondre vide et IsOnQuest
-- non : rien n'est purgé, les quêtes connues restent telles quelles.
--
-- Logique pure : le jeu est passé dans `api` ({ count, info, onQuest }), les tests le simulent.
local _, NS = ...

local Journal = {}
NS.Journal = Journal

local function isQuestID(v)
    return NS.Wire.Readable(v) and type(v) == "number" and v >= 1 and v == math.floor(v)
end

-- Une entrée du journal → id, « à écarter » (cachée ou tâche). nil pour un en-tête ou une entrée
-- illisible. Appelée sous pcall : un champ secret fait lever, l'entrée est alors ignorée.
local function classify(q)
    if type(q) ~= "table" or q.isHeader then return nil end
    if not isQuestID(q.questID) then return nil end
    return q.questID, (q.isHidden or q.isTask) and true or false
end

local function call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, a = pcall(fn, ...)
    if ok then return a end
    return nil
end

-- Mes quêtes : (liste triée pour Wire.Encode, ensemble { [id] = true } à garder comme `known`).
-- `known` = les quêtes déjà connues (sauvegardées, ou reçues par QUEST_ACCEPTED) ; non modifié.
function Journal.Read(api, known, loaded)
    local seen, skip = {}, {}
    local n = call(api.count)
    if not (NS.Wire.Readable(n) and type(n) == "number") then n = 0 end
    for i = 1, n do
        local ok, id, hidden = pcall(classify, call(api.info, i))
        if ok and id then
            if hidden then skip[id] = true else seen[id] = true end
        end
    end
    for id in pairs(type(known) == "table" and known or {}) do
        if isQuestID(id) and not seen[id] and not skip[id] then
            -- Seul un `false` lisible prouve le départ : une erreur ou un secret garde la quête.
            local on = loaded and call(api.onQuest, id)
            if not (loaded and NS.Wire.Readable(on) and on == false) then seen[id] = true end
        end
    end
    local list = {}
    for id in pairs(seen) do list[#list + 1] = id end
    return NS.Wire.Normalize(list), seen
end
