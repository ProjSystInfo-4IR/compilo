# compilo - prise en charge des fonctions
Compilateur du langage C (simplifié) basé sur LEX et YACC en instructions assembleur orientées mémoire

## Implémenté : 
* Détection des fonctions avant et après le main (grammaire) 
* Diffférenciation entre déclarations et définitions de fonctions
* Instructions ASM utilisés : 
  -> PUSH {registre} 
  -> JMP  {ligneASM} {nom fonctions} ; PUSH %eip + JMP {ligneASM} = "CALL <function>"  
  -> LEAVE ; instruction pour quitter
  -> POP {registre} 

## Limites / Blocages 
* Comment implémenter ensuite PUSH eip ? Remplacer plutot par PUSH eip+2? (revenir à 2 instructions après l'actuel ?)
* Pas d'arguments pour les fonctions  (PUSH des arguments avant "PUSH eip" ? Mais comment récupérer les arguments ? Variable pour le connaitre nombre d'arguments ?)
* Toutes les variables sont considérées comme globales (modifier tab_symboles ? un tab_symboles par fonction ?)  

## RAF (essentiel)
* Interpreteur à finaliser
* Traitement d'erreur (ok? Supprimer fichier ASM final si erreur ?)
* Implémentation des fonctions à perfectionner (optionnel)

