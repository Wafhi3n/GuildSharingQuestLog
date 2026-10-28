-- GuildSharingQuestLog_LogTab.lua — l'onglet « Guilde » du journal de quêtes (spec
-- docs/specs/quetes-de-guilde.md, T3) : un 4e onglet sous Quêtes, Événements et Légende, qui affiche
-- la liste des quêtes en commun avec la guilde par-dessus le contenu du journal.
--
-- RÈGLE DE SÛRETÉ (taint) : on n'écrit JAMAIS dans les tables de Blizzard. Notre onglet n'hérite pas de
-- QuestLogTabButtonTemplate (son parentArray l'ajouterait à QuestMapFrame.TabButtons, que Blizzard
-- parcourt) mais de LargeSideTabButtonTemplate, le même dessin sans l'inscription ; notre panneau n'est
-- pas dans ContentFrames, et on n'appelle pas SetDisplayMode. On ne fait que : poser nos cadres,
-- accrocher des scripts après les siens (HookScript), écouter son EventRegistry, et appeler SetChecked
-- de ses onglets (dessin seul, aucun champ écrit). À MESURER au PTR avec /console taintLog 1 avant de
-- garder quoi que ce soit (critère 16).
local _, NS = ...
local L = NS.L

local LogTab = { rows = {}, lines = {} }
NS.LogTab = LogTab

local ATLAS = NS.Indicator.ATLAS
local ROW_H = 36
local BLIZZARD_TABS = { "QuestsTab", "EventsTab", "MapLegendTab" }

local function blizzardTabs(fn)
    for _, key in ipairs(BLIZZARD_TABS) do
        local tab = QuestMapFrame[key]
        if tab then fn(tab) end
    end
end

-- Remet les coches de Blizzard comme SON état les veut (son SetDisplayMode ne repasse pas quand on
-- reclique l'onglet déjà choisi).
local function restoreBlizzardChecks()
    blizzardTabs(function(tab) tab:SetChecked(tab.displayMode == QuestMapFrame.displayMode) end)
end

function LogTab:Show()
    if not self.panel then return end
    self.panel:Show()
    self.tab:SetChecked(true)
    blizzardTabs(function(tab) tab:SetChecked(false) end)
    NS.UI:Refresh()
end

function LogTab:Hide()
    if not (self.panel and self.panel:IsShown()) then return end
    self.panel:Hide()
    self.tab:SetChecked(false)
    restoreBlizzardChecks()
end

-- Depuis l'icône de la minicarte : ouvre le journal puis l'onglet. Jamais en combat (ouvrir la carte
-- depuis un addon en combat n'a pas été mesuré).
function LogTab:OpenFromOutside()
    if InCombatLockdown() or not self.panel then return end
    if not QuestMapFrame:IsVisible() and OpenQuestLog then OpenQuestLog() end
    self:Show()
end

-- Une quête cliquée : retour au journal de Blizzard, sur le détail de cette quête (hors combat).
function LogTab:OpenQuest(id)
    if InCombatLockdown() then return end
    self:Hide()
    if QuestMapFrame_ShowQuestDetails then QuestMapFrame_ShowQuestDetails(id) end
end

local function rowTooltip(line)
    local row = line.row
    if not row then return end
    GameTooltip:SetOwner(line, "ANCHOR_RIGHT")
    GameTooltip:AddLine(NS.UI.RowTitle(row))
    for _, name in ipairs(row.holders) do GameTooltip:AddLine(name, 1, 1, 1) end
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine(L["Clic : voir la quête (hors combat)"], 0.25, 1, 0.25)
    GameTooltip:Show()
end

local function newLine(content, i)
    local line = CreateFrame("Button", nil, content)
    line:SetHeight(ROW_H)
    line:SetPoint("TOPLEFT", 0, -(i - 1) * ROW_H)
    line:SetPoint("RIGHT")
    line.title = line:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    line.title:SetPoint("TOPLEFT", 8, -4)
    line.title:SetPoint("RIGHT", -8, 0)
    line.title:SetJustifyH("LEFT")
    line.names = line:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    line.names:SetPoint("TOPLEFT", line.title, "BOTTOMLEFT", 8, -3)
    line.names:SetPoint("RIGHT", -8, 0)
    line.names:SetJustifyH("LEFT")
    local hl = line:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetColorTexture(1, 1, 1, 0.08)
    line:SetScript("OnClick", function(self) if self.row then LogTab:OpenQuest(self.row.id) end end)
    line:SetScript("OnEnter", rowTooltip)
    line:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return line
end

-- Redessine la liste ; seulement si le panneau est ouvert (sinon à son ouverture).
function LogTab:Update(rows)
    self.rows = rows
    if not (self.panel and self.panel:IsShown()) then return end
    for i, row in ipairs(rows) do
        local line = self.lines[i] or newLine(self.content, i)
        self.lines[i] = line
        line.row = row
        line.title:SetText(NS.UI.RowTitle(row) .. "  |cffffffff(" .. #row.holders .. ")|r")
        line.names:SetText(NS.UI.HoldersText(row))
        line:Show()
    end
    for i = #rows + 1, #self.lines do
        self.lines[i].row = nil
        self.lines[i]:Hide()
    end
    self.content:SetHeight(math.max(1, #rows * ROW_H))
    self.empty:SetShown(#rows == 0)
end

local function buildPanel()
    local panel = CreateFrame("Frame", nil, QuestMapFrame)
    panel:SetPoint("TOPLEFT", QuestMapFrame.ContentsAnchor, "TOPLEFT")
    panel:SetPoint("BOTTOMRIGHT", QuestMapFrame.ContentsAnchor, "BOTTOMRIGHT")
    panel:SetFrameLevel(QuestMapFrame:GetFrameLevel() + 100)   -- au-dessus du contenu de Blizzard
    panel:EnableMouse(true)                                      -- et les clics ne passent pas dessous
    panel:SetClipsChildren(true)
    local back = panel:CreateTexture(nil, "BACKGROUND", nil, -2)
    back:SetAllPoints()
    back:SetColorTexture(0.05, 0.04, 0.03, 0.97)
    local art = panel:CreateTexture(nil, "BACKGROUND", nil, -1)
    art:SetAtlas("QuestLog-main-background", true)               -- le fond du journal de Forever
    art:SetPoint("TOPLEFT")
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalMed2")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText(L["Quêtes en commun avec la guilde"])
    local scroll = CreateFrame("ScrollFrame", nil, panel, "ScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -34)
    scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(1, 1)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnSizeChanged", function(self, w) content:SetWidth(w) end)
    local empty = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    empty:SetPoint("TOPLEFT", 12, -40)
    empty:SetPoint("RIGHT", -12, 0)
    empty:SetJustifyH("LEFT")
    empty:SetText(L["Aucune quête en commun avec un guildien connecté pour l'instant."])
    panel:Hide()
    return panel, content, empty
end

local function buildTab()
    local tab = CreateFrame("Frame", nil, QuestMapFrame, "LargeSideTabButtonTemplate")
    tab:EnableMouse(true)
    tab.activeAtlas, tab.inactiveAtlas = ATLAS, ATLAS
    tab.tooltipText = L["Quêtes en commun avec la guilde"]
    tab:SetPoint("TOP", QuestMapFrame.MapLegendTab, "BOTTOM", 0, -3)
    tab:SetChecked(false)
    tab:SetCustomOnMouseUpHandler(function(_, button, upInside)
        if button == "LeftButton" and upInside then LogTab:Show() end
    end)
    return tab
end

-- Pose l'onglet une fois le journal de Blizzard chargé. true si c'est fait (ou déjà fait).
function LogTab:Install()
    if self.tab then return true end
    if not (QuestMapFrame and QuestMapFrame.MapLegendTab and QuestMapFrame.ContentsAnchor) then return false end
    self.panel, self.content, self.empty = buildPanel()
    self.tab = buildTab()
    local hide = function() LogTab:Hide() end
    blizzardTabs(function(tab)
        tab:HookScript("OnMouseUp", function(_, button) if button == "LeftButton" then hide() end end)
    end)
    QuestMapFrame:HookScript("OnHide", hide)
    if EventRegistry and EventRegistry.RegisterCallback then
        EventRegistry:RegisterCallback("QuestLog.SetDisplayMode", hide, self)
    end
    return true
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self)
    if LogTab:Install() then self:UnregisterAllEvents() end
end)
