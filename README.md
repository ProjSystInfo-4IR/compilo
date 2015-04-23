# compilo - prise en charge des fonctions
Compilateur du langage C (simplifié) basé sur LEX et YACC en instructions assembleur orientées mémoire

## Implémenté sur cette branche : 
* Déclarations variables globales au tout début (grammaire)
* Détection des fonctions avant et après le main (grammaire)
* Détection des arguments (0, 1  ou plusieurs) pour les fonctions, sauf pour main (grammaire)
* Diffférenciation entre déclarations et définitions de fonctions
* Possibilité de déclarer des surcharges (même nom, mais différents nombre d'arguments)
* Instructions ASM utilisés :  
    ø CALL {ligneASM} <function> <nb_args> ; appel à une fonction à <nb_args>
    ø RET ; retour fonction précédente
    ø PUSH @adresse ; empiler l'argument situ à adresse @adresse 
    ø POP ; récupérer le dernier argument empilé
    ø LEAVE ; instruction pour quitter le programme
* Modification table des symboles : chaque variable est liée à une fonction (ou à GLOBAL) 
* printf(<string>) (lex + grammaire fait)  

## Limites / Blocages 
* problème variables locales dans le cas des surcharges (rajouter nb_args dans tab_symboles pour différencier les fonctions ou abandonner l'idée ?)  
* printf <string> : retransciption en "ASM PRI <string>" à revoir ? s'inspirer de ce qu'on fait avec les integers (tab_symboles) pour les strings également ?
* PUSH des arguments avant CALL , POP début de la fonction -> comment bien récupérer les arguments ? 

## RAF (essentiel)
* Interpreteur à finaliser (notamment pour la gestion de fonctions : gestion CALL / RET / LEAVE / PUSH / POP , avec maitrise de ebp, esp, eip)
* Traitement d'erreur (ok? Supprimer fichier ASM final si erreur ?)
* Implémentation des fonctions à perfectionner (notamment avec les arguments)


