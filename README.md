# compilo - prise en charge des fonctions
Compilateur du langage C (simplifié) basé sur LEX et YACC en instructions assembleur orientées mémoire

## Implémenté sur cette branche : 
* Déclarations variables globales au tout début (grammaire)
* Détection des fonctions avant et après le main (grammaire) 
* Diffférenciation entre déclarations et définitions de fonctions
* Instructions ASM utilisés :  
    ø CALL {ligneASM} <function>  ; appel à une fonction
    ø RET ; retour fonction précédente
    ø LEAVE ; instruction pour quitter le programme
* Modification table des symboles : chaque variable est liée à une fonction (ou à GLOBAL) 
* printf(<string>) (lex + grammaire fait, retransciption en ASM PRI <string> à revoir ?)  

## Limites / Blocages 
* printf <string> : s'inspirer de ce qu'on fait avec les integers (tab_symboles) pour les strings également ?
* Pas d'arguments pour les fonctions  (PUSH des arguments avant  ? Mais comment récupérer les arguments ? Variable pour le connaitre nombre d'arguments ?) 

## RAF (essentiel)
* Interpreteur à finaliser (notamment pour la gestion de fonctions : gestion CALL / RET / LEAVE avec maitrise de ebp, esp, eip)
* Traitement d'erreur (ok? Supprimer fichier ASM final si erreur ?)
* Implémentation des fonctions à perfectionner (prise en charge d'arguments avec PUSh / POP, etc. )

