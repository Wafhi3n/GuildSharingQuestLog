# Registre de verification en jeu - GuildSharingQuestLog

Meme role que celui de Crafting Order - Classic : dire jusqu'ou l'addon a ete **vu fonctionner**
dans le client, puisque aucune porte automatique ne sait le dire. `scripts/untested.ps1 -Addon
GuildSharingQuestLog` fait l'union de tous les releves ci-dessous et liste ce qu'aucun n'avait dans le client.

Format d'un releve (le plus recent EN TETE) :

```
- AAAA-MM-JJ HH:MM - jusqu'a <sha> - <build> - <verdict> - <ce qui a ete observe>
```

Le `<sha>` est le dernier commit reellement present dans le client pendant la seance. On n'ecrit
un releve qu'APRES avoir observe, et on dit ce qui n'a PAS ete observe. Plusieurs sessions peuvent
ecrire ici en parallele : l'heure plutot qu'un numero du jour, et le fichier fusionne en
`merge=union` (`.gitattributes`) sans conflit.

**Un rebase perime le sha d'un releve** : apres le rebase d'une branche deja couverte, avancer son
sha (`git log --oneline` sur la nouvelle branche donne l'equivalent, le message est identique).

## Releves

- 2026-10-27 19:53 - jusqu'a 170da7b - PTR de RETAIL 12.1.7.70493 (PAS Forever), build feat/gsql-sync@170da7b - GO sur le PTR - Paladingue et Palrien (Anasterian, guilde Ost Perdant), client relance, etat lu par DevMacro n9 dans DevMacroDB.log, gestes faits par le user : chacun connait l'autre et ses quetes, 3 quetes en commun calculees juste (19:48) ; Paladingue abandonne la 60, Palrien la voit partir (19:49:10), Paladingue prend la 11360, Palrien la voit arriver (19:49:19) ; /gsql share off : Palrien garde Paladingue avec une liste vide (19:49:40), share on : les 6 quetes reviennent (19:49:49) ; Palrien se deconnecte vers 19:50, Paladingue ne le connait plus a 19:53 ; l'echo de ses propres envois revient a chacun. PAS observe : un 3e perso, la reponse chuchotee a un H1 distinguee de la liste de guilde, le delai exact (releves espaces de 10 a 30 s), le verrou de la messagerie, une liste en plusieurs morceaux, une categorie repliee, quoi que ce soit sur Forever, et rien n'est affiche (T3).
