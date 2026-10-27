# Quêtes de guilde : qui a la même quête que moi

> État : **validée en partie** le 2026-10-27 · T1 codé (le contrat et qui a quelle quête, logique
> pure, en test) ; rien n'est encore appelé en jeu. L'idée (D1) et le nom (D2) sont du
> user ; P1, P2, P3, P6 et P9 sont des propositions de l'agent acceptées par le user (« oui vas-y » à
> la liste des recommandations) ; P4, P5, P7 et P8 sont des choix techniques de l'agent, pas encore
> discutés. Addon `GuildSharingQuestLog`, créé le 2026-10-27 (`scripts\new_addon.ps1`) ; spec écrite
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

Contexte déjà décidé ailleurs, repris tel quel : la guilde part sur le royaume **PvP**, côté
**Alliance** ; son Discord est relié au jeu en **flux séparé** (spec `appel-a-l-aide`, D5) ; un seul
bot lit le salon relié (`F:\CraftingOrderBot`).

### Propositions de l'agent

Acceptées par le user le 2026-10-27 : **P1, P2, P3, P6, P9**. Pas encore discutées : P4, P5, P7, P8.

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

Les critères de la phase 2 s'écriront avec la spec du bot.

## Contrat (figé à T1, le 2026-10-27, avant toute release)

### Message d'addon de guilde, version 1

Préfixe : `GSQL`. Séparateur `|`, comme COC et CraftLink, qui l'utilisent déjà dans leurs messages
d'addon. Code : `GuildSharingQuestLog_Wire.lua` ; exemples figés octet pour octet par
`tests/test_gsql_wire.lua` (outillage).

- **Liste** : `L1|<seq>|<morceau>/<total>|<id>,<id>,…`
  - `seq` : entier de 1 à 12 chiffres, sans zéro en tête, qui monte à chaque nouvelle liste du perso.
    Il part de l'horloge (secondes) : après un `/reload`, qui efface le compteur, la liste suivante
    passe encore devant les anciennes. Une liste qui renvoie la même liste garde le même `seq`.
  - `morceau/total` : un chiffre chacun, `1/1` presque toujours ; 9 morceaux au plus. Chaque morceau
    fait 255 octets au plus et se lit seul (un numéro n'est jamais coupé). Au-delà de 9 morceaux (plus
    de 200 quêtes), les plus grands numéros restent dehors.
  - Les numéros : entiers de 1 à 9 chiffres, sans zéro en tête, **triés, sans doublon** (la même
    liste donne toujours le même message, quel que soit l'ordre du journal).
  - Liste vide : `L1|<seq>|1/1|`, permise seulement en un morceau.
- **Demande** : `H1`, exactement. Sens : « je (re)démarre ». Ceux qui la reçoivent **oublient tout de
  l'envoyeur, numéro compris** (sa liste suivante fait foi, même si son horloge a reculé), puis lui
  envoient leur liste.
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

Les réglages seulement (partage actif ou non). Rien de ce qui est reçu.

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
- **T2** — Lecture du journal, envoi regroupé, demande et réponse, expiration (critères 3 à 6).
- **T3** — L'affichage en jeu (critères 8 à 11).
- **T4** — Banc Forever : M1 à M6, puis les critères 8 à 11.
- **T5** — Phase 2 : spec du bot, ligne Discord, file au geste.
