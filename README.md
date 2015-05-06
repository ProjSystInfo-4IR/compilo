# compilo
Compilateur du langage C (simplifié) basé sur LEX et YACC en instructions assembleur orientées mémoire

## Utilisation 
* Makefile : obtention du programme "simpleGCC", notre compilateur C simplifié : 
` ~/compilo$ make `
* Compilation d'un fichier C (cf plus bas les fonctionalités C supportées) :
> /compilo$ ./simpleGCC test_files/print_string_test.c -v
> /compilo$ ./simpleGCC test_files/print_string_test.c 
Rajouter le flag -v permet d'avoir des informations concernant la compilation du fichier C (affichage de la table des symboles finale, affichage de la table des fonctions, ...). 
Sans le flag -v, seules les erreurs de compilation apparaissent.

## Précisions de codage liées à notre compilateur simplifié :
* Variables et constantes : le seul type accepté est integer (int) 
* Variables locales : les déclarations dans la fonction doivent se faire avant toute instruction 
* Déclarations des variables globales : elles doivent se faire au tout début du fichier C (avant toute déclaration de fonctions)  
* Expressions arithmétiques : elles ne sont possibles que sur des intergers ( '(', ')', '+', '-', '*', '/' uniquement) 
* Expressions conditionnelles IF et WHILE : 0 vaut "false", les autres integers valent "true" 
* Fonctions déclarées / définies : Toute déclaration (et définitions) de fonctions peut se faire avant ou après le main ; notez que le compilateur sait faire la différence entre déclarations et définitions de fonctions
* Arguments des fonctions : 0, 1  ou plusieurs aarguments pour les fonctions, sauf pour main (pas d'arguments)
* Affichage : Prise en charge de printf(arg1) avec arg1 de type int ou String (char*).   

## Limites (ce qu'il faudrait revoir)
* Traitement des erreurs : n'affiche pas la ligne du fichier C où une erreur est détectée. 
* Fonctions (main compris) : les fonctions ne retournent rien, elles sont déclarées directement sans type défini ( ex : fonction1(arg1, arg2) { ...} )  
* Affichage avec printf (string) : retransciption en "ASM PRI (string)" à revoir ? s'inspirer dajouter el type string/char* dans la table des symboles ? 

## Informations complémentaires 
* Instructions ASM utilisés en supplément de celles proposées dans le sujet du projet :  
    - CALL {ligneASM} function ; appel à une fonction
    - RET ; retour fonction précédente
    - PUSH @adresse ; empiler l'argument situé à adresse @adresse dans la table des symboles 
    - POP @adresse ; récupérer le dernier élément empilé et l'affecter à la variable d'adresse @adresse de la table des symboles
    - LEAVE ; instruction pour quitter le programme
* Gestion des arguments : "PUSH" de chaque argument lors de l'appel d'une fonction (dans le main  par exemple). Une fois dans la fonction en question, on affecte les arguments (variables locales) avec des "POP".   
* Table des symboles contenue dans tab_symboles.c : Tableau C définissant chaque variable déclarée. Chaque variable est liée à une fonction (ou à GLOBAL pour des variables globales) 
* Table des instructions contenue dans tab_ic.c : Tableau C permettant de manipuler les expressions conditionnelles IF et WHILE
* Table des fonctions : Tableau C définissant chaque fonction déclarée. 
* Traitement des erreurs : supprime le fichier ASM créé si il y a eu des erreurs de compilation




