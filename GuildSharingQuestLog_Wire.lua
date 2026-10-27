-- GuildSharingQuestLog_Wire.lua — le message d'addon de guilde, seul format lu HORS de cette copie de
-- l'addon (spec docs/specs/quetes-de-guilde.md, section « Contrat ») :
--   L1|<seq>|<morceau>/<total>|<id>,<id>,…   ma liste de quêtes, en un ou plusieurs morceaux
--   H1                                       je (re)démarre : oubliez ma liste, envoyez-moi la vôtre
-- Ce qui est gelé, c'est la forme produite : tests/test_gsql_wire.lua fige les exemples de la spec
-- octet pour octet. Une autre version (L2, H2) ou une autre forme est ignorée, sans erreur.
--
-- Logique pure : rien n'est appelé au chargement, et les fonctions ne touchent au jeu que par
-- `issecretvalue` quand il existe. Les tests headless chargent ce fichier tel quel.
local _, NS = ...

local Wire = {}
NS.Wire = Wire

Wire.PREFIX = "GSQL"
Wire.HELLO = "H1"
Wire.MAX_BYTES = 255     -- au-delà, le serveur coupe le message sans erreur (skill wow-forever-api)
Wire.MAX_PARTS = 9       -- un seul chiffre : `i/n` fait toujours 3 octets ; 9 morceaux = 200 quêtes et plus
Wire.MAX_ID_DIGITS = 9   -- un numéro de quête plus long est un message abîmé ou forgé
Wire.MAX_SEQ_DIGITS = 12

-- Une valeur qu'on a le droit de lire. Une valeur SECRÈTE ne se compare pas et ne se passe pas à
-- :match : on la teste AVANT toute opération, et `type` est le seul tri sûr avant ce test. Sans
-- `issecretvalue` (tests, autre client) tout est lisible ; un `issecretvalue` qui lève rend illisible.
local function readable(v)
    if type(v) == "nil" then return false end
    local probe = _G.issecretvalue
    if not probe then return true end
    local ok, secret = pcall(probe, v)
    return ok and not secret
end
Wire.Readable = readable

local function isWhole(v, max)
    return readable(v) and type(v) == "number" and v >= 1 and v <= max and v == math.floor(v)
end

local MAX_ID = 10 ^ Wire.MAX_ID_DIGITS - 1
local MAX_SEQ = 10 ^ Wire.MAX_SEQ_DIGITS - 1

-- Les numéros qu'on peut envoyer : entiers de 1 à 9 chiffres, sans doublon, triés (la même liste
-- donne toujours le même message, quel que soit l'ordre du journal). Le reste est écarté.
function Wire.Normalize(ids)
    local seen, out = {}, {}
    if type(ids) ~= "table" then return out end
    for _, id in pairs(ids) do
        if isWhole(id, MAX_ID) and not seen[id] then
            seen[id] = true
            out[#out + 1] = id
        end
    end
    table.sort(out)
    return out
end

-- La liste en messages de MAX_BYTES octets au plus, chacun lisible seul : un numéro n'est jamais
-- coupé. Au-delà de MAX_PARTS morceaux, les plus grands numéros restent dehors (un journal n'en
-- approche jamais). nil si `seq` n'est pas un entier positif.
function Wire.Encode(seq, ids)
    if not isWhole(seq, MAX_SEQ) then return nil end
    local list = Wire.Normalize(ids)
    local budget = Wire.MAX_BYTES - #("L1|" .. seq .. "|1/1|")
    local chunks, cur = {}, {}
    local size = 0
    for _, id in ipairs(list) do
        local s = tostring(id)
        local add = #s + (#cur > 0 and 1 or 0)
        if size + add > budget then
            if #chunks + 1 == Wire.MAX_PARTS then break end
            chunks[#chunks + 1] = cur
            cur, size, add = {}, 0, #s
        end
        cur[#cur + 1] = s
        size = size + add
    end
    chunks[#chunks + 1] = cur
    local out = {}
    for i, c in ipairs(chunks) do
        out[i] = "L1|" .. seq .. "|" .. i .. "/" .. #chunks .. "|" .. table.concat(c, ",")
    end
    return out
end

-- Les numéros d'un morceau : 1 à 9 chiffres sans zéro en tête, séparés par une virgule, rien d'autre.
-- `""` n'est permis que pour une liste vide (un morceau unique). nil si abîmé.
local function decodeIds(field, total)
    local ids = {}
    if field == "" then return total == 1 and ids or nil end
    for tok in (field .. ","):gmatch("([^,]*),") do
        if not tok:match("^[1-9]%d*$") or #tok > Wire.MAX_ID_DIGITS then return nil end
        ids[#ids + 1] = tonumber(tok)
    end
    return ids
end

-- Un message reçu → { kind = "list", seq, part, total, ids } ou { kind = "hello" } ; nil pour tout
-- le reste (autre version, autre forme, morceau abîmé, valeur illisible), sans erreur.
function Wire.Decode(msg)
    if not (readable(msg) and type(msg) == "string") then return nil end
    if msg == Wire.HELLO then return { kind = "hello" } end
    local seq, part, total, field = msg:match("^L1|([1-9]%d*)|([1-9])/([1-9])|([%d,]*)$")
    if not seq or #seq > Wire.MAX_SEQ_DIGITS then return nil end
    part, total = tonumber(part), tonumber(total)
    if part > total then return nil end
    local ids = decodeIds(field, total)
    if not ids then return nil end
    return { kind = "list", seq = tonumber(seq), part = part, total = total, ids = ids }
end
