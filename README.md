# compilo - prise en charge des fonctions
Compilateur du langage C (simplifié) basé sur LEX et YACC en instructions assembleur orientées mémoire

## Implémenté sur cette branche : 
* Déclarations variables globales au tout début (grammaire)
* Détection des fonctions avant et après le main (grammaire)
* Détection des arguments (0, 1  ou plusieurs) pour les fonctions, sauf pour main (grammaire)
* Diffférenciation entre déclarations et définitions de fonctions
* Instructions ASM utilisés :  
    - CALL {ligneASM} function nb_args ; appel à une fonction à nb_args
    - RET ; retour fonction précédente
    - PUSH @adresse ; empiler l'argument situé à adresse @adresse 
    - POP @adresse ; récupérer le dernier élément empilé et l'affecter à la variable d'adresse @adresse
    - LEAVE ; instruction pour quitter le programme
* PUSH des arguments dans l'ordre avant CALL puis POP (affectation aux arguments) en début de la fonction :  
    - solutions mode FIFO
    - solution mode LIFO (commentée) 
    - -> Commenter / décommenter en fonction de l'implémentation de la pile ASM choisie dans interpreto  
* Modification table des symboles : chaque variable est liée à une fonction (ou à GLOBAL) 
* printf(string) (lex + grammaire fait)  

## Limites 
* printf (string) : retransciption en "ASM PRI (string)" à revoir ? s'inspirer de ce qu'on fait avec les integers (tab_symboles) pour les strings également ?


## RAF (essentiel)
* Interpreteur à finaliser (notamment pour la gestion de fonctions : gestion CALL / RET / LEAVE / PUSH / POP , avec maitrise de ebp, esp, eip)
* Traitement d'erreur (ok? Supprimer fichier ASM final si erreur ?)


