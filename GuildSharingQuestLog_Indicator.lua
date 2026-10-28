-- GuildSharingQuestLog_Indicator.lua — l'icône de la minicarte (spec docs/specs/quetes-de-guilde.md,
-- T3) : allumée quand au moins un guildien connecté a une de mes quêtes, avec leur nombre dans le
-- coin ; au survol, la liste ; au clic (hors combat), le journal sur l'onglet « Guilde ».
--
-- MÉTHODE REPRISE DE COC, mesurée contre le taint dans TaintLab le 2026-09-27 puis revue en jeu le
-- 2026-09-28 (skill coc-native-ui, « Icônes d'état de la minicarte ») : l'icône est un ENFANT de la
-- barre `MinimapCluster.IndicatorFrame` (un cadre du mode Édition), placée par `layoutIndex`, et la
-- barre se recompose par `Layout()` seulement quand l'icône apparaît ou disparaît. Ne pas changer de
-- méthode sans remesurer. Rang 10 : 1 et 2 sont à Blizzard, 3 à 5 à COC (icone-minicarte.md).
local _, NS = ...
local L = NS.L

local Indicator = {}
NS.Indicator = Indicator

Indicator.RANK = 10
Indicator.SIZE = 22
Indicator.ATLAS = "questlog-questtypeicon-group"   -- utilisé par Blizzard sur Forever (Constants.lua)
Indicator.MAX_LINES = 10

local function bar()
    local mc = _G.MinimapCluster
    return mc and mc.IndicatorFrame
end

local function fillTooltip(tt)
    local rows = NS.UI.rows
    tt:AddLine(L["Quêtes de guilde"])
    tt:AddLine(string.format(L["%d quête(s) en commun avec la guilde"], #rows), 1, 1, 1)
    for i, row in ipairs(rows) do
        if i > Indicator.MAX_LINES then
            tt:AddLine(string.format(L["… et %d autres"], #rows - Indicator.MAX_LINES), 0.7, 0.7, 0.7)
            break
        end
        tt:AddDoubleLine(NS.UI.RowTitle(row), NS.UI.HoldersText(row), 1, 0.82, 0, 1, 1, 1)
    end
    tt:AddLine(" ")
    tt:AddLine(L["Clic : ouvrir la liste dans le journal (hors combat)"], 0.25, 1, 0.25)
end

local function build(parent)
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(Indicator.SIZE, Indicator.SIZE)
    f.layoutIndex = Indicator.RANK
    f:EnableMouse(true)
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetAtlas(Indicator.ATLAS)
    tex:SetAllPoints()
    f.count = f:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    f.count:SetPoint("BOTTOMRIGHT", 1, -1)
    f:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        fillTooltip(GameTooltip)
        GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)
    f:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" and NS.LogTab then NS.LogTab:OpenFromOutside() end
    end)
    f:Hide()
    return f
end

-- Allume ou éteint l'icône selon le tableau. Le cadre n'est créé qu'au premier allumage ; sans la
-- barre (autre client), rien.
function Indicator:Update(rows)
    local b = bar()
    if not b then return end
    local want = #rows > 0
    if not self.frame then
        if not want then return end
        self.frame = build(b)
    end
    self.frame.count:SetText(want and tostring(#rows) or "")
    if self.frame:IsShown() == want then return end
    self.frame:SetShown(want)
    if b.Layout then b:Layout() end
end
