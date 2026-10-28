# Quêtes de guilde : qui a la même quête que moi

> État : **validée en partie** le 2026-10-27 · T1 et T2 codés et vus sur le PTR ; T3 (l'affichage,
> D3 du 2026-10-28) codé et testé sans le jeu, PAS encore vu au PTR. P7
> (expiration) est mis en œuvre par T2 tel que proposé. L'idée (D1) et le nom (D2) sont du
> user ; P1, P2, P3, P6 et P9 sont des propositions de l'agent acceptées par le user (« oui vas-y » à
> la liste des recommandations) ; P4 (liste complète), P5 (numéros, pas titres), le `seq` parti de
> l'horloge et le sens de `H1`, adoptés par T1, **acceptés par le user le 2026-10-27** (« oui
> vas-y ») ; P7 et P8 ne sont pas encore discutés. Addon `GuildSharingQuestLog`, créé le 2026-10-27 (`scripts\new_addon.ps1`) ; spec écrite
> d'abord dans l'outillage, puis déplacée ici le même jour.
> Mesures : une séance sur le **PTR de Retail** 12.1.7.70493 le 2026-10-27, faute de Forever (fermé
> jusqu'au 2026-11-04). Rien n'est mesuré sur Forever ; la liste de ce qui reste est plus bas.

## Le problème

Au lancement de WoW: Forever (2026-11-04), toute la guilde du user monte de niveau en même temps, sur
du contenu vanilla : quêtes élites, quêtes de groupe, chaînes de donjon, qu'on ne finit pas seul.
Pour trouver un partenaire, il faut aujourd'hui taper en guilde « qui a [la quête] ? » et attendre.
Personne ne sait qui a quoi, et les guildiens qui ne sont pas en jeu (sur Discord) ne voient rien.

## Ce qu'on veut

- **En jeu** : pour chacune de mes quêtes, je vois quels guildiens connectés l'ont aussi. Je peux
  aussi ouvrir la liste des quêtes de la guilde, quête par quête, avec qui les a.
- **Sur Discord** (l'idée d'origine, D1) : un salon tient un **tableau** de toutes les quêtes de la
  guilde et de qui les possède, mis à jour tout seul.
- Rien à taper : prendre, rendre ou abandonner une quête suffit à mettre les autres à jour.
- Le joueur peut couper le partage de ses quêtes (P3).

## Ce qu'on NE fait PAS

- **La progression des objectifs** (« 4/10 loups ») : seulement « il a la quête ». (P)
- **Grouper ou inviter à sa place** : l'addon montre qui, le joueur décide.
- **Lire ce qui est tapé sur Discord** : une ligne venue de Discord arrive en jeu illisible pour un
  addon (mesuré sur la bêta Forever, skill `wow-forever-api`). Discord ne fait que regarder.
- **Partager hors de la guilde** : ni canal public, ni chuchoté à un inconnu.
- **L'historique** des quêtes rendues.
- **Remplacer le partage de quête de Blizzard** en groupe : il existe déjà.

## Règles de la maison (pas des propositions)

- **Chat sobre** (skill `chat-output`) : aucune ligne de chat sur un événement réseau. Qu'un guildien
  prenne une quête, ou que le partage tombe en panne, se voit dans l'interface de l'addon, jamais
  dans le chat. Un interrupteur tapé seul montre son état ; seuls `on` / `off` le changent.
- **Pas de royaume affiché** : `Paladingue`, jamais `Paladingue-Anasterian` (c'est la forme reçue).
- **Tout le texte localisé** : clé en français, overlays enUS, deDE, esES.
- **Pas d'orage de messages** : les messages d'addon sont invisibles mais plafonnés par le serveur ;
  une demande à laquelle toute la guilde répond en même temps est un orage (cas particuliers).
- **Toute donnée reçue du réseau expire** (P7).

## Cas particuliers

- **Journal vide** : on envoie une liste vide, et les autres m'effacent.
- **Liste trop longue** : au-delà de 255 octets, un message d'addon est **coupé sans erreur** (mesuré
  sur Forever en chuchoté le 2026-10-05, revu en guilde sur le PTR). Le contrat prévoit donc plusieurs morceaux ; l'envoyeur vérifie
  la taille lui-même.
- **Messages de guilde perdus sans erreur** : vu sur le PTR, un perso a vu tous ses envois de guilde
  disparaître (`Success`, rien d'arrivé, pas d'écho) jusqu'à une déconnexion complète. Son `/g` et
  ses chuchotés passaient. Cause inconnue (P8).
- **Arrivée en jeu** (connexion, `/reload`) : je n'ai rien. Je demande, et chacun répond **après un
  délai tiré au hasard** (quelques secondes), au plus une réponse par demande et par minute.
- **Un guildien se déconnecte ou quitte la guilde** : ses quêtes disparaissent de chez moi.
- **Une quête que je n'ai jamais eue** : son titre n'est peut-être pas dans mon cache. Je montre
  « Quête n°123 » jusqu'à ce que le jeu me le donne (M3).
- **Quêtes cachées ou spéciales** : le PTR en a montré deux qui ne comptent pas dans le journal
  (introduction de Midnight, logis). On écarte les entrées cachées et les tâches ; ce que Forever a
  de pareil reste à voir (M6).
- **Verrou de messagerie** (combat de boss) : l'envoi attend la fin du verrou
  (`C_ChatInfo.InChatMessagingLockdown`, présente sur Forever).
- **Rerolls** : chaque perso compte à part. (P)
- **Deux guildiens sur des royaumes différents** (sur Forever, le royaume suit le compte) : les
  messages d'addon de guilde passent-ils ? (M5)

## Décisions

- **D1** (user, 2026-10-27) — L'idée : un addon synchronise les quêtes des guildiens, via Discord ;
  un salon Discord tient un tableau de toutes les quêtes de la guilde et de qui les possède. « Il y a
  plein de trucs à faire avec Discord. »
- **D2** (user, 2026-10-27) — Titre affiché **« Discord Guild Sharing Quest Log »** (nom proposé par
  le user) ; dossier **`GuildSharingQuestLog`**, sans « Discord » (recommandé par l'agent, choisi par
  le user : la v1 marche en jeu sans Discord, et un dossier qui commence par « Discord » peut
  laisser croire à un addon officiel). Le dossier ne se renomme plus après la première release.
  Commande `/gsql` (choisie par défaut par l'agent, elle peut changer).
- **D3** (user, 2026-10-28, sur trois propositions de l'agent) — L'affichage, « un peu comme
  Questie » :
  - **le suivi des quêtes à l'écran n'est pas touché** ;
  - une **icône au-dessus de la minicarte**, comme celles de COC (même méthode, mesurée contre le
    taint ; **rang 10**, COC tient 3 à 5) : allumée quand un guildien connecté a une de mes quêtes,
    leur nombre dans le coin, la liste au survol, le journal sur l'onglet « Guilde » au clic (hors
    combat) ;
  - une **section dans le journal de quêtes** : un **4e onglet « Guilde »** sous Quêtes, Événements
    et Légende, qui liste les quêtes en commun (précisé par l'agent : le plus partagé d'abord, élites
    et groupes marqués, un clic ouvre le détail de la quête hors combat) ;
  - au survol d'une quête du journal, une ligne **« Aussi dans la guilde : … »**.
  Condition posée par l'agent et acceptée : l'onglet ne reste que si la mesure du taint au PTR est
  propre ; sinon la même liste passe dans un panneau à nous, ouvert par l'icône.
  Le panneau à part de P6 est remplacé par cet onglet.

Contexte déjà décidé ailleurs, repris tel quel : la guilde part sur le royaume **PvP**, côté
**Alliance** ; son Discord est relié au jeu en **flux séparé** (spec `appel-a-l-aide`, D5) ; un seul
bot lit le salon relié (`F:\CraftingOrderBot`).

### Propositions de l'agent

Acceptées par le user le 2026-10-27 : **P1, P2, P3, P6, P9**, puis **P4, P5** (avec le contrat de
T1). Pas encore discutées : P7, P8.

- **P1** — **Deux phases.** Phase 1 en jeu seulement, par messages d'addon de guilde : ils partent
  sans geste, et touchent tous les guildiens en jeu, même sans Discord. Phase 2, le tableau Discord.
  Raison : la phase 1 est mesurée et ne coûte presque rien ; Discord demande un geste du joueur à
  chaque envoi, fait du bruit dans le salon où la guilde parle, et un module de bot à écrire.
- **P2** — **Un addon à part**, comme World PvP Police (nom : D2).
- **P3** — **Partage actif par défaut** une fois l'addon installé (l'installer, c'est déjà vouloir
  partager), avec un interrupteur.
- **P4** — **On envoie la liste complète** des quêtes (pas les changements), à chaque changement du
  journal, regroupée (on attend quelques secondes après le dernier changement), plus en réponse à une
  demande. Une liste complète remplace la précédente : rien ne se désynchronise. Mesuré : 6 à 8
  quêtes font 29 à 38 caractères.
- **P5** — **Des numéros, pas des titres** : chaque client lit le titre dans sa langue
  (`C_QuestLog.GetTitleForQuestID`).
- **P6** — **Ce qu'on affiche en phase 1** : sur mes quêtes, qui d'autre les a ; et un panneau
  « quêtes de la guilde », groupé par quête, les quêtes partagées par au moins deux joueurs en tête,
  les quêtes élites ou de groupe signalées (`IsEliteQuest`, `suggestedGroup` : M4).
- **P7** — **Expiration** : une entrée vit tant que son auteur est connecté et dans la guilde. Rien
  de reçu n'est sauvegardé.
- **P8** — **Accusé de réception par l'écho**, **si Forever renvoie à l'envoyeur son propre message
  de guilde** (M2 ; le PTR le fait, et CraftLink écarte déjà ses propres messages, ce qui le laisse
  penser sans le prouver). Pas d'écho dans les 10 s : « partage en panne », visible dans
  l'interface, avec le seul remède vu (se déconnecter et revenir). Si Forever n'envoie pas d'écho,
  P8 tombe.
- **P9** — **Phase 2, Discord** :
  - écrire dans le fil Discord de la guilde demande un **geste** : la ligne attend dans une file et
    part au prochain clic ou à la prochaine touche (le motif de la file de COC, au banc, jamais
    validé) ;
  - au plus une ligne par perso et par 15 minutes, et seulement si la liste a changé ;
  - la ligne **nomme le perso** (elle part sous le nom du compte Discord) ;
  - le bot la lit, la **supprime** du salon relié (il ne peut pas y écrire, mais il peut y
    supprimer), et tient **un seul message-tableau** par guilde dans un salon à lui, groupé par
    quête ;
  - une entrée expire après quelques heures sans ligne de son perso ;
  - les noms de quête viennent d'une récolte sur Wowhead Forever, comme les objets pour COC ;
  - le bot peut répondre à une commande `/qui-a <quête>` sur Discord.

## Mesures

### Faites sur le PTR de Retail 12.1.7.70493, le 2026-10-27 (PAS sur Forever)

Outil : DevMacro, branche `test/ptr-quetes` (commandes n°1 à n°6), sorties relues dans
`DevMacroDB.log`. Trois persos humains de la même guilde : Paladingue, Jjoajao, Campard.

- Le journal de quêtes se lit (numéro et titre), **sans valeur secrète** ; maximum 35 quêtes.
- Une liste tient dans un message : 29 à 38 caractères pour 6 à 8 quêtes.
- Un message d'addon `GUILD` arrive chez les autres **dans la seconde**, et **revient à
  l'envoyeur** (écho). Le chuchoté d'addon arrive aussi.
- À trois persos, chacun calcule juste les quêtes qu'il partage avec chaque autre.
- 300 caractères en `GUILD` : `Success`, mais coupé à 255 à l'arrivée (comme en chuchoté sur
  Forever).
- Un perso (Jjoajao) : 6 envois de guilde sur 6 perdus sans erreur et sans écho, jusqu'à une
  déconnexion complète. Écartés comme cause : le marquage JcJ, le mode guerre, le rang (même
  officier), le compte, le combat, le verrou, le contenu, le royaume, la guilde.
- **Rejoindre la guilde en cours de session ne casse rien** : Campard, exclu puis réinvité en ligne,
  envoie et reçoit aussitôt.
- Les fonctions dont la spec a besoin ont la **même documentation** sur ce PTR et sur Forever 70532
  (journal de quêtes, messages d'addon, Discord).
- **Catégorie repliée** (18:58, Paladingue) : replier « Forêt d'Elwynn », qui contient deux de ses
  quêtes, n'a rien caché à `C_QuestLog.GetInfo` (6 quêtes vues et 19 entrées, avant comme après).
  Le code de Forever, lui, déplie les catégories avant de chercher (M8).
- **Liste de guilde** (18:58, Paladingue et Jjoajao) : `GetGuildRosterInfo` rend 17 valeurs ; le nom
  est `Nom-Royaume` même sur son propre royaume, le 9e champ dit « en ligne », le 14e (appli mobile)
  vaut `false` pour tous les connectés.

### À faire sur Forever (banc, après le 2026-11-04)

Les commandes DevMacro de `test/ptr-quetes` resservent telles quelles (le `.toc` porte 16001).

- **M1** — Journal : lisible ? maximum ? longueur d'une liste pleine ?
- **M2** — Un message `GUILD` revient-il à son envoyeur ? (décide P8)
- **M3** — Titre d'une quête que le receveur n'a jamais eue : `GetTitleForQuestID` rend-il `nil` ?
  `C_QuestLog.RequestLoadQuestByID` puis `QUEST_DATA_LOAD_RESULT` le donnent-ils ?
- **M4** — `IsEliteQuest` et `suggestedGroup` portent-ils de vraies valeurs sur une quête élite ou
  de groupe connue ?
- **M5** — Les messages d'addon de guilde passent-ils entre royaumes d'une même guilde ? (même
  question que M6 de `appel-a-l-aide`)
- **M6** — Forever a-t-il des entrées cachées ou spéciales dans le journal ?
- **M7** (phase 2) — Une ligne supprimée par le bot laisse-t-elle une notification ou une pastille
  « non lu » chez les autres membres du Discord ?
- **M8** — Une catégorie repliée cache-t-elle ses quêtes à `C_QuestLog.GetInfo` sur Forever (pas sur
  le PTR) ? Si oui, `IsOnQuest` les voit-il encore ? (DevMacro n°7 : un passage tout déplié, puis un
  passage avec une catégorie repliée.) T2 ne fait sortir une quête que sur preuve, quelle que soit la
  réponse.

## Critères d'acceptation (phase 1)

1. [test] Une liste encodée puis décodée redonne la même liste ; au-delà de 255 octets, plusieurs
   morceaux de 255 octets au plus ; un morceau abîmé ou une liste incomplète est refusé.
2. [test] Une liste reçue remplace la précédente du même perso ; une liste plus ancienne (numéro de
   séquence) est ignorée ; une liste vide efface le perso.
3. [test] Un perso qui se déconnecte ou quitte la guilde disparaît.
4. [test] Cinq changements du journal en 3 s donnent un seul envoi.
5. [test] Une demande obtient une réponse après un délai aléatoire, jamais deux réponses du même
   perso dans la minute.
6. [test] Aucune ligne de chat sur un événement réseau (compteur de lignes, skill `chat-output`).
7. [check] Les quatre portes (Lua, tailles, locale, tests).
8. [human] Banc à deux comptes dans la même guilde, deux quêtes en commun et une différente chacun :
   dans les 10 s après qu'A prend une quête que B a, B voit A sur cette quête. Témoin : la quête que
   seul B a ne montre personne d'autre. Observateur : le user au banc.
9. [human] A abandonne la quête : elle disparaît chez B dans les 10 s.
10. [human] B se connecte après A : il voit les quêtes d'A dans les 30 s, sans rien faire.
11. [human] Aucun nom affiché ne porte de royaume.
12. [agent] Revue `api-gotcha-reviewer` : aucune fonction absente de Forever, aucune écriture dans
    les cadres de Blizzard.
13. [test] L'icône n'existe qu'au premier allumage, dans la barre de la minicarte, au rang 10, avec le
    nombre de quêtes en commun ; la barre ne se recompose que quand l'icône apparaît ou disparaît ;
    l'onglet ne pose aucune clé dans `QuestMapFrame` ni dans ses onglets ; en combat, ni l'icône ni
    une ligne n'ouvrent quoi que ce soit (`test_gsql_ui.lua`, sur un faux journal).
14. [human] Au PTR, deux persos avec une quête en commun : l'icône s'allume au-dessus de la minicarte
    avec « 1 », sa bulle nomme la quête et l'autre perso, son clic ouvre le journal sur l'onglet
    « Guilde ». Témoin : la lettre du courrier, dans la même barre, reste à sa place.
15. [human] L'onglet « Guilde » se dessine sous la Légende, avec le même aspect que les trois autres ;
    cliquer un onglet de Blizzard revient à son contenu ; au survol d'une quête partagée dans
    l'onglet Quêtes, la bulle finit par « Aussi dans la guilde : … ». Témoin : la bulle d'une quête
    que personne d'autre n'a, inchangée.
16. [human] `/console taintLog 1`, puis : ouvrir et fermer le journal, passer d'un onglet à l'autre,
    cliquer l'icône et une ligne, entrer en combat journal ouvert, ouvrir le mode Édition ; ensuite
    `Logs\taint.log` ne cite pas GuildSharingQuestLog, et aucune « action bloquée ». Témoin : la même
    séquence addon désactivé.

Les critères de la phase 2 s'écriront avec la spec du bot.

## Contrat (écrit à T1 le 2026-10-27, accepté par le user le même jour)

Avant toute release, il peut encore changer. Après, toute évolution passe par une **nouvelle
version** (`L2`, envoyée à côté de `L1` tant que des copies v1 tournent) : on n'ajoute jamais de
champ à `L1`, le lecteur v1 refuse une ligne qui en a un de plus.

### Message d'addon de guilde, version 1

Préfixe : `GSQL`. Séparateur `|`, comme COC et CraftLink, qui l'utilisent déjà dans leurs messages
d'addon. Code : `GuildSharingQuestLog_Wire.lua` ; exemples figés octet pour octet par
`tests/test_gsql_wire.lua` (outillage).

- **Liste** : `L1|<seq>|<morceau>/<total>|<id>,<id>,…`
  - `seq` : entier de 1 à 12 chiffres, sans zéro en tête, qui monte à chaque nouvelle liste du perso.
    **Règle de l'envoyeur : `seq = max(time(), dernier seq + 1)`.** L'horloge fait qu'après un
    `/reload`, qui efface le compteur, la liste suivante passe encore devant les anciennes ; le `+ 1`
    fait que deux listes différentes dans la même seconde n'ont pas le même `seq` (le receveur
    ignorerait la seconde sans pouvoir le voir). Renvoyer la même liste garde le même `seq`.
  - `morceau/total` : un chiffre chacun, `1/1` presque toujours ; 9 morceaux au plus. Chaque morceau
    fait 255 octets au plus et se lit seul (un numéro n'est jamais coupé). Au-delà de 9 morceaux (plus
    de 200 quêtes), les plus grands numéros restent dehors.
  - Les numéros : entiers de 1 à 9 chiffres, sans zéro en tête, **triés, sans doublon** (la même
    liste donne toujours le même message, quel que soit l'ordre du journal).
  - Liste vide : `L1|<seq>|1/1|`, permise seulement en un morceau.
- **Demande** : `H1`, exactement, **par la guilde seulement**. Sens : « je (re)démarre ». Ceux qui la
  reçoivent **oublient tout de l'envoyeur, numéro compris** (sa liste suivante fait foi, même si son
  horloge a reculé), puis lui **chuchotent** leur liste (précisé à T2 : une réponse par la guilde
  ferait, à chaque connexion, une réponse de chacun à tous). Un `H1` chuchoté est ignoré : un inconnu
  ne doit pas recevoir nos listes.
- Une liste se reçoit par la guilde, ou en chuchoté dans la minute qui suit mon propre `H1` (les
  réponses à ma demande) ; jamais autrement.
- Tout le reste est ignoré sans erreur : une autre version (`L2`, `H2`), un champ en plus ou en
  moins, une virgule de trop, un numéro mal écrit, un morceau hors de son total.

Exemples (la vraie liste de Paladingue, relevée sur le PTR) :

```
L1|1761580800|1/1|60,62,26378,76107,91281,93057
L1|1761580860|1/1|
H1
```

### Ce que le receveur en fait (critère 2, `GuildSharingQuestLog_Roster.lua`)

- Une liste **complète** remplace la précédente du même perso. Un `seq` plus petit ou égal à celui
  déjà reçu est ignoré (l'écho de sa propre liste aussi).
- Une liste en morceaux ne compte qu'une fois tous ses morceaux arrivés, dans n'importe quel ordre ;
  jusque-là, l'ancienne reste. Des morceaux en attente depuis plus de **30 s** sont jetés ; un même
  `seq` avec un autre `total` recommence l'assemblage.
- Une liste vide efface le perso, mais son `seq` reste : une liste plus vieille ne le ressuscite pas.

### Données sauvegardées

`GuildSharingQuestLogDB` (base du compte) : `share` (partage actif, `true` par défaut) et `known`
(`[« Nom-Royaume »] = { [questID] = true }` : mes propres quêtes, pour ne pas les perdre si une
catégorie repliée les cache au démarrage). Rien de ce qui est reçu des autres.

### Ligne Discord (phase 2, esquisse à figer avec la spec du bot)

Le nom du perso et les numéros des quêtes, sur une seule ligne : `QST <Perso> <id>,<id>,… #Q<seq>`.

## Renvois

- Spec voisine, même guilde, mêmes canaux : `WorldPvPPolice/docs/specs/appel-a-l-aide.md`.
- La file au geste pour Discord : `CraftingOrderClassic/docs/specs/annonce-discord.md` (D5).
- Le bot : `F:\CraftingOrderBot` (sa spec s'écrira en phase 2).
- Skills : `wow-addon-dev:wow-forever-api` (messages coupés à 255 octets, ligne Discord),
  `wow-addon-dev:chat-output`, `wow-classic-addon-dev`.
- Banc de mesure : DevMacro, branche `test/ptr-quetes` ; cible `retailptr` de `deploy.ps1` (dans le
  `master` de l'outillage depuis le 2026-10-27).

## Plan (2026-10-27) — volatile, meurt quand c'est fait

- ~~**T0**~~ — Fait le 2026-10-27 : nom choisi, addon déclaré (outillage `4d6e504`) et créé
  (`de9b229`), spec déplacée ici ; dépôt GitHub privé `Wafhi3n/GuildSharingQuestLog` (au mot du user).
- ~~**T1**~~ — Fait le 2026-10-27, branches `feat/gsql-contrat` de l'addon et de l'outillage : le
  contrat (`_Wire.lua`), qui a quelle quête (`_Roster.lua`), critères 1 et 2 tenus en test
  (`test_gsql_wire.lua`, `test_gsql_roster.lua`). Rien n'est encore appelé en jeu.
- ~~**T2**~~ — Fait le 2026-10-27, branches `feat/gsql-sync` (sur `feat/gsql-contrat`) de l'addon et
  de l'outillage : `_Journal.lua` (une quête ne sort que sur preuve ; rien n'est purgé avant le
  premier `QUEST_LOG_UPDATE`), `_Sync.lua` (logique : regroupement 3 s ; réponse chuchotée à un `H1`
  après 1 à 5 s tirées au hasard, une par perso et par minute ; oubli des déconnectés, sauf liste
  reçue il y a moins de 2 min ; une seule file à un message par seconde, en pause pendant le verrou,
  5 essais), `_Events.lua` (le branchement), `/gsql share [on|off]`, `120107` au `.toc` pour le PTR.
  Critères 3 à 6 tenus en test (`test_gsql_journal.lua`, `test_gsql_sync.lua`). Mon écho est noté,
  rien de plus (P8 pas discuté). Rien n'est encore vu en jeu.
- **T3** — Codé le 2026-10-28 (D3), branches `feat/gsql-ui` (sur `feat/gsql-sync`) de l'addon et de
  l'outillage : `_Board.lua` (le tableau, logique pure), `_UI.lua` (rafraîchissement regroupé, ligne
  de bulle par l'EventRegistry), `_Indicator.lua` (icône, rang 10, atlas
  `questlog-questtypeicon-group` que Blizzard utilise sur Forever), `_LogTab.lua` (l'onglet sur
  `LargeSideTabButtonTemplate`, le panneau par-dessus le contenu du journal). Critères 13 et 11 en
  test (`test_gsql_board.lua`, `test_gsql_ui.lua`). **Reste : la séance au PTR (critères 14 à 16).**
- **T4** — Banc Forever : M1 à M6, puis les critères 8 à 11.
- **T5** — Phase 2 : spec du bot, ligne Discord, file au geste.
