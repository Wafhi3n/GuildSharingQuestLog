-- GuildSharingQuestLog_Sync.lua — le partage en jeu (spec docs/specs/quetes-de-guilde.md, T2,
-- critères 3 à 6) : quand envoyer ma liste, à qui répondre, qui oublier.
--   - en guilde : `H1` à la guilde, puis ma liste dès que le journal a répondu une première fois ;
--   - le journal change : DEBOUNCE s plus tard, UNE liste, et seulement si elle a changé ;
--   - un `H1` reçu (par la guilde seulement) : j'oublie ce perso et je lui CHUCHOTE ma liste après un
--     délai tiré au hasard, jamais deux fois en REPLY_GAP s au même perso ; répondre à la guilde
--     ferait, le soir du lancement, une réponse de chacun à tous pour chaque connexion ;
--   - une liste chuchotée n'est prise que dans les WHISPER_WINDOW s qui suivent mon `H1` : sinon un
--     inconnu pourrait s'inscrire dans l'annuaire ;
--   - la liste de guilde dit qui est déconnecté ou parti : on l'oublie (sauf liste reçue il y a moins
--     de GRACE s : la liste de guilde peut avoir un temps de retard sur une connexion) ;
--   - tout ce qui part passe par UNE file, à un message par SEND_GAP s, en pause pendant le verrou de
--     la messagerie ; un envoi refusé reste en tête et repart RETRY s plus tard, MAX_TRIES fois.
-- Jamais une ligne de chat (critère 6). Logique pure : le jeu est passé dans `env` (voir Sync.New).
local _, NS = ...

local Sync = {}
NS.Sync = Sync

Sync.DEBOUNCE = 3
Sync.REPLY_MIN, Sync.REPLY_MAX = 1, 5
Sync.REPLY_GAP = 60
Sync.WHISPER_WINDOW = 60
Sync.GRACE = 120
Sync.SEND_GAP = 1
Sync.RETRY = 5
Sync.MAX_TRIES = 5

-- env : me() → « Nom-Royaume » ou nil ; time() → secondes ; after(s, fn) ; random(a, b) → entier ;
-- send(msg, canal, cible) → true si le jeu l'accepte ; locked() → verrou de la messagerie ;
-- sharing() → partage actif ; readJournal(loaded) → mes quêtes triées ; onChange() facultatif.
function Sync.New(env)
    return setmetatable({ env = env, roster = NS.Roster.New(), queue = {}, replied = {}, seq = 0,
        started = false, loaded = false }, { __index = Sync })
end

local function now(self) return math.floor(self.env.time()) end
local function changed(self) if self.env.onChange then self.env.onChange() end end
local function isText(v) return NS.Wire.Readable(v) and type(v) == "string" end

-- Un nom sans royaume (forme possible de la liste de guilde) prend le mien.
local function fullName(self, name)
    if name:find("-", 1, true) then return name end
    local realm = self.me and self.me:match("%-(.+)$")
    return realm and (name .. "-" .. realm) or name
end

-- ===== La file =====

local function arm(self, delay)
    if self.armed then return end
    self.armed = true
    self.env.after(delay, function() self.armed = false; self:Drain() end)
end

-- Sans doublon : une seule liste de guilde en attente (elle partira à jour), un chuchoté par perso.
function Sync:Enqueue(job)
    for _, j in ipairs(self.queue) do
        if j.kind == job.kind and j.to == job.to then return end
    end
    self.queue[#self.queue + 1] = job
    arm(self, 0)
end

-- Ma liste du moment. Le numéro ne monte que si la liste a changé : max(maintenant, dernier + 1),
-- pour que deux listes de la même seconde ne portent jamais le même.
function Sync:Messages()
    local ids = self.env.sharing() and self.env.readJournal(self.loaded) or {}
    local key = table.concat(ids, ",")
    if key ~= self.key then
        self.seq, self.key = math.max(now(self), self.seq + 1), key
    end
    return NS.Wire.Encode(self.seq, ids), key
end

local function sendAll(self, msgs, channel, to)
    for _, m in ipairs(msgs) do
        if not self.env.send(m, channel, to) then return false end
    end
    return true
end

function Sync:Run(job)
    if job.kind == "hello" then return self.env.send(NS.Wire.HELLO, "GUILD") == true end
    local msgs, key = self:Messages()
    if job.kind == "whisper" then return sendAll(self, msgs, "WHISPER", job.to) end
    if not sendAll(self, msgs, "GUILD") then return false end
    self.sent = key
    return true
end

function Sync:Drain()
    local job = self.queue[1]
    if not job then return end
    if not self.started then self.queue = {} return end
    if self.env.locked() then arm(self, Sync.RETRY) return end
    if self:Run(job) then
        table.remove(self.queue, 1)
        if #self.queue > 0 then arm(self, Sync.SEND_GAP) end
        return
    end
    job.tries = (job.tries or 0) + 1
    if job.tries >= Sync.MAX_TRIES then table.remove(self.queue, 1) end
    if #self.queue > 0 then arm(self, Sync.RETRY) end
end

-- ===== Ce que le jeu nous dit =====

-- En guilde (connexion, /reload, entrée dans une guilde). Sans mon nom complet, on réessaiera au
-- prochain événement.
function Sync:Start()
    if self.started then return end
    local me = self.env.me()
    if not isText(me) then return end
    self.me, self.started, self.helloAt = me, true, now(self)
    self:Enqueue({ kind = "hello" })
    if self.loaded then self:Enqueue({ kind = "guild" }) end
end

-- Plus en guilde : on oublie tout, rien ne part plus.
function Sync:Stop()
    self.started, self.helloAt, self.sent = false, nil, nil
    self.queue, self.replied, self.roster = {}, {}, NS.Roster.New()
    changed(self)
end

-- QUEST_LOG_UPDATE : la liste repart DEBOUNCE s plus tard, si elle a changé.
function Sync:LogUpdated()
    local first = not self.loaded
    self.loaded = true
    if not self.started then return end
    if first then self:Enqueue({ kind = "guild" }) return end
    if self.waiting then return end
    self.waiting = true
    self.env.after(Sync.DEBOUNCE, function()
        self.waiting = false
        if not self.started then return end
        local _, key = self:Messages()
        if key ~= self.sent then self:Enqueue({ kind = "guild" }) end
    end)
end

-- Le joueur a coupé ou rouvert le partage : une liste vide (on m'efface) ou la vraie.
function Sync:SharingChanged()
    if self.started and self.loaded then self:Enqueue({ kind = "guild" }) end
end

function Sync:OnHello(sender)
    self.roster:Forget(sender)
    changed(self)
    if not (self.loaded and self.env.sharing()) then return end
    local t = now(self)
    for who, at in pairs(self.replied) do
        if t - at >= Sync.REPLY_GAP then self.replied[who] = nil end
    end
    if self.replied[sender] then return end
    self.replied[sender] = t
    self.env.after(self.env.random(Sync.REPLY_MIN, Sync.REPLY_MAX), function()
        if self.started then self:Enqueue({ kind = "whisper", to = sender }) end
    end)
end

-- CHAT_MSG_ADDON. Mon propre message revient (écho) : noté pour plus tard (P8), jamais rangé.
function Sync:OnMessage(prefix, msg, channel, sender)
    if not (self.started and isText(prefix) and prefix == NS.Wire.PREFIX) then return end
    if not (isText(channel) and isText(sender)) then return end
    sender = fullName(self, sender)
    if sender == self.me then self.lastEcho = now(self) return end
    local d = NS.Wire.Decode(msg)
    if not d then return end
    if d.kind == "hello" then
        if channel == "GUILD" then self:OnHello(sender) end
        return
    end
    local asked = channel == "WHISPER" and self.helloAt and now(self) - self.helloAt <= Sync.WHISPER_WINDOW
    if channel == "GUILD" or asked then
        if self.roster:Receive(sender, d, now(self)) then changed(self) end
    end
end

-- La liste de guilde : { { name = "Nom-Royaume", online = bool }, … }. Vide = pas encore chargée :
-- on n'oublie personne.
function Sync:GuildRoster(members)
    if not (self.started and type(members) == "table" and #members > 0) then return end
    local online, t, gone = {}, now(self), false
    for _, m in ipairs(members) do
        if type(m) == "table" and isText(m.name) and m.online == true then online[fullName(self, m.name)] = true end
    end
    for _, who in ipairs(self.roster:Known()) do
        local seen = self.roster:LastSeen(who)
        if not online[who] and not (seen and t - seen < Sync.GRACE) then
            self.roster:Forget(who)
            gone = true
        end
    end
    if gone then changed(self) end
end
