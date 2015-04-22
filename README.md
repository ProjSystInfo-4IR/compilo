# compilo - prise en charge des fonctions
Compilateur du langage C (simplifié) basé sur LEX et YACC en instructions assembleur orientées mémoire

## Implémenté sur cette branche : 
* Déclarations variables globales au tout début (grammaire)
* Détection des fonctions avant et après le main (grammaire) 
* Diffférenciation entre déclarations et définitions de fonctions
* Instructions ASM utilisés : 
  -> PUSH {registre} 
  -> JMP  {ligneASM} {nom fonctions} ; PUSH %eip + JMP {ligneASM} = "CALL <function>"  
  -> LEAVE ; instruction pour quitter
  -> POP {registre} 
* Modification table des symboles : chaque variable est liée à une fonction (ou à GLOBAL) 

## Limites / Blocages 
* Comment implémenter ensuite PUSH eip ? Remplacer plutot par PUSH eip+2? (revenir à 2 instructions après l'actuel ?) -> interpreto ? 
* Pas d'arguments pour les fonctions  (PUSH des arguments avant "PUSH eip" ? Mais comment récupérer les arguments ? Variable pour le connaitre nombre d'arguments ?) 

## RAF (essentiel)
* Interpreteur à finaliser (notamment pour la gestion de fonctions) 
* Traitement d'erreur (ok? Supprimer fichier ASM final si erreur ?)
* Implémentation des fonctions à perfectionner (prise en charge d'arguments, ...)

