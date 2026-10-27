-- GuildSharingQuestLog_Roster.lua — qui a quelle quête, d'après les listes reçues (spec
-- docs/specs/quetes-de-guilde.md, critère 2) :
--   - une liste complète REMPLACE la précédente du même perso ; une liste plus vieille (numéro de
--     séquence plus petit ou égal) est ignorée, l'écho d'une liste déjà reçue aussi ;
--   - une liste en plusieurs morceaux ne compte qu'une fois tous ses morceaux arrivés ; un morceau
--     manquant laisse l'ancienne liste en place ; des morceaux en attente depuis PENDING_TTL s sont
--     jetés ;
--   - une liste vide efface le perso, mais garde son numéro : une liste plus vieille ne le ressuscite
--     pas ;
--   - Forget (un `H1` reçu, plus tard une déconnexion) oublie tout du perso, numéro compris : il
--     redémarre, sa prochaine liste fait foi.
-- Rien n'est sauvegardé (P7). Logique pure : `now` est passé par l'appelant (secondes).
local _, NS = ...

local Roster = {}
NS.Roster = Roster

Roster.PENDING_TTL = 30   -- s : les morceaux d'une liste partent ensemble ; au-delà, la liste est perdue

local function isName(v)
    return NS.Wire.Readable(v) and type(v) == "string" and v ~= ""
end

-- Un morceau tel que Wire.Decode le rend (une table forgée autrement est refusée, sans erreur).
local function isPart(p)
    return type(p) == "table" and p.kind == "list" and type(p.seq) == "number"
        and type(p.part) == "number" and type(p.total) == "number" and type(p.ids) == "table"
end

function Roster.New()
    return setmetatable({ lists = {}, pending = {} }, { __index = Roster })
end

-- Jette les listes dont un morceau manque depuis trop longtemps.
function Roster:Sweep(now)
    for who, p in pairs(self.pending) do
        if now - p.at > Roster.PENDING_TTL then self.pending[who] = nil end
    end
end

-- Les morceaux en attente pour ce numéro, recommencés si le numéro ou le total change. nil si le
-- morceau appartient à une liste plus vieille que celle qu'on assemble.
local function pendingFor(self, sender, part, now)
    local p = self.pending[sender]
    if p and p.seq > part.seq then return nil end
    if not p or p.seq ~= part.seq or p.total ~= part.total then
        p = { seq = part.seq, total = part.total, parts = {}, got = 0, at = now }
        self.pending[sender] = p
    end
    return p
end

-- Un morceau décodé (Wire.Decode) de `sender`, reçu à `now`. true si une liste COMPLÈTE vient de
-- remplacer la précédente de ce perso.
function Roster:Receive(sender, part, now)
    if not (isName(sender) and isPart(part) and type(now) == "number") then return false end
    self:Sweep(now)
    local cur = self.lists[sender]
    if cur and part.seq <= cur.seq then return false end
    local p = pendingFor(self, sender, part, now)
    if not p then return false end
    if not p.parts[part.part] then
        p.parts[part.part] = part.ids
        p.got = p.got + 1
    end
    if p.got < p.total then return false end
    local quests, count = {}, 0
    for i = 1, p.total do
        for _, id in ipairs(p.parts[i]) do
            if not quests[id] then quests[id], count = true, count + 1 end
        end
    end
    self.lists[sender] = { seq = p.seq, quests = quests, count = count, at = now }
    self.pending[sender] = nil
    return true
end

function Roster:Forget(sender)
    self.lists[sender], self.pending[sender] = nil, nil
end

-- Les persos qui ont cette quête, triés par nom.
function Roster:Who(questID)
    local out = {}
    for who, l in pairs(self.lists) do
        if l.quests[questID] then out[#out + 1] = who end
    end
    table.sort(out)
    return out
end

-- Les quêtes d'un perso, triées ; vide si on ne sait rien de lui.
function Roster:QuestsOf(sender)
    local out = {}
    local l = self.lists[sender]
    for id in pairs(l and l.quests or {}) do out[#out + 1] = id end
    table.sort(out)
    return out
end

-- Tous les persos dont on sait quelque chose (liste, même vide, ou morceaux en attente).
function Roster:Known()
    local seen, out = {}, {}
    for who in pairs(self.lists) do seen[who] = true end
    for who in pairs(self.pending) do seen[who] = true end
    for who in pairs(seen) do out[#out + 1] = who end
    table.sort(out)
    return out
end

-- Quand on a reçu quelque chose de ce perso pour la dernière fois (secondes), ou nil.
function Roster:LastSeen(sender)
    local l, p = self.lists[sender], self.pending[sender]
    local a, b = l and l.at, p and p.at
    if a and b then return math.max(a, b) end
    return a or b
end

-- Les persos qui ont au moins une quête, triés par nom.
function Roster:Senders()
    local out = {}
    for who, l in pairs(self.lists) do
        if l.count > 0 then out[#out + 1] = who end
    end
    table.sort(out)
    return out
end
