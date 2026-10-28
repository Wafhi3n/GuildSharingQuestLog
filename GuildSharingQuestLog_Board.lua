-- GuildSharingQuestLog_Board.lua — le tableau « quêtes en commun avec la guilde » (spec
-- docs/specs/quetes-de-guilde.md, T3) : de MES quêtes, celles qu'au moins un guildien a aussi, avec
-- qui. Lu par l'icône de la minicarte, l'onglet du journal et la ligne ajoutée au survol.
--
-- Ordre (P6) : le plus de guildiens d'abord ; à égalité, les quêtes élites ou de groupe ; puis le titre.
-- Les noms s'affichent SANS royaume (règle du user : le pont entre royaumes reste invisible).
--
-- Logique pure : le jeu est passé dans `opts` ({ title(id), flag(id) → "elite" | "group" | nil }).
local _, NS = ...

local Board = {}
NS.Board = Board

Board.MAX_NAMES = 5   -- au-delà, « … et 3 autres »

local function readable(v) return NS.Wire.Readable(v) end

-- « Nom-Royaume » → « Nom » ; nil si illisible.
function Board.ShortName(full)
    if not (readable(full) and type(full) == "string" and full ~= "") then return nil end
    return full:match("^([^%-]+)") or full
end

local function call(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, v = pcall(fn, ...)
    if ok and readable(v) then return v end
    return nil
end

local function holdersOf(roster, id)
    local names = {}
    for _, who in ipairs(roster:Who(id)) do
        local n = Board.ShortName(who)
        if n then names[#names + 1] = n end
    end
    table.sort(names)
    return names
end

-- Un titre absent se range comme une chaîne vide (en tête de son groupe), sans comparer nil.
local function before(a, b)
    if #a.holders ~= #b.holders then return #a.holders > #b.holders end
    if (a.flag ~= nil) ~= (b.flag ~= nil) then return a.flag ~= nil end
    local ta, tb = a.title or "", b.title or ""
    if ta ~= tb then return ta < tb end
    return a.id < b.id
end

-- `mine` = mes quêtes (numéros), `roster` = NS.Roster. Rend les lignes triées :
-- { id, title, flag, holders = { noms courts triés } }. `title` vaut nil si le jeu ne le donne pas.
function Board.Build(mine, roster, opts)
    local rows = {}
    opts = opts or {}
    for _, id in ipairs(type(mine) == "table" and mine or {}) do
        local holders = holdersOf(roster, id)
        if #holders > 0 then
            local title = call(opts.title, id)
            if type(title) ~= "string" or title == "" then title = nil end
            local flag = call(opts.flag, id)
            if flag ~= "elite" and flag ~= "group" then flag = nil end
            rows[#rows + 1] = { id = id, title = title, flag = flag, holders = holders }
        end
    end
    table.sort(rows, before)
    return rows
end

-- Les noms d'une ligne, en texte : « Palrien, Campard », ou « A, B, C, D, E et 3 autres ».
-- `L` = la table de locale (clé « %s et %d autres »).
function Board.HoldersText(holders, L)
    local n = #holders
    if n <= Board.MAX_NAMES then return table.concat(holders, ", ") end
    local shown = {}
    for i = 1, Board.MAX_NAMES do shown[i] = holders[i] end
    return string.format(L["%s et %d autres"], table.concat(shown, ", "), n - Board.MAX_NAMES)
end
