# compilo
Compilateur du langage C (simplifié) basé sur LEX et YACC en instructions assembleur (ASM) orientées mémoire

## Utilisation 
Téléchargement des fichiers à partir de notre répertoire Git “compilo”
* Il suffit de “cloner” notre répertoire Git “compilo” avec la commande :

`~$ git clone https://github.com/ProjSystInfo-4IR/compilo.git`
* Toute la partie compilateur du projet se trouve dans le répertoire compilo ainsi obtenu.  

## Contenu du projet (partie compilo) :
* Analyseur lexical analyzer_lex.lex
* Analyseur syntaxique syntaxic_analyzer.y
* Table des symboles contenue dans tab_symboles.c : Tableau C définissant chaque variable déclarée. Chaque variable est liée à une fonction (ou à GLOBAL pour des variables globales)
* Table des instructions contenue dans tab_ic.c : Tableau C permettant de manipuler les expressions conditionnelles IF et WHILE
* Table des fonctions contenue dans tab_fct.c : Tableau C définissant chaque fonction déclarée.
* Gestionnaire de l’affichage et des erreurs de compilation : Intégration de la partie  dumb-logger développé (fichier dumb-logger.c). 

## Utilisation du compilateur “maison” 
* Makefile : obtention du programme simpleGCC, notre compilateur C simplifié :
`~/compilo$ make`
* Compilation d'un fichier C (cf plus bas les fonctionalités C supportées) :
`~/compilo$ ./simpleGCC [fichier_a_compiler.c] [flags]`
* Sans flags, seules les erreurs de compilation apparaissent et le fichier de sortie (par default) est output.asm .
Rajouter le flag -v permet d'avoir des informations concernant la compilation du fichier C (affichage de la table des symboles finale, affichage de la table des fonctions, ...).
Rajouter le flag -o permet de spécifier le nom de fichier de sortie du compilateur.
* A noter que différents fichiers C de tests sont fournis dans le répertoire compilo/test_files.

## Précisions de codage liées à notre compilateur simplifié :
* Variables et constantes : le seul type accepté est integer (int)
* Variables locales : les déclarations dans une fonction doivent se faire avant toute instruction.
* Déclarations des variables globales : elles doivent se faire au tout début du fichier C (avant toute déclaration de fonctions)
* Expressions arithmétiques : elles ne sont possibles que sur des integers ( '(', ')', '+', '-', '*', '/' uniquement)
* Expressions conditionnelles IF et WHILE : 0 vaut "false", le reste des int valent  "true"
* Fonctions déclarées / définies : Toute déclaration (et définitions) de fonctions peut se faire avant ou après le main ; notez que le compilateur sait faire la différence entre déclarations et définitions de fonctions
* Arguments des fonctions : 0, 1 ou plusieurs arguments pour les fonctions, sauf pour main (pas d'arguments)
* Affichage : Prise en charge de printf(arg1) avec arg1 de type int ou string (char*).
* Gestion des erreurs : La ligne du fichier C où une erreur est détectée est informée.
* Limites (ce qu'il faudrait revoir)
* Fonctions (main compris) : les fonctions ne retournent rien, elles sont déclarées directement sans type défini ( ex : fonction1(arg1, arg2) { ...} )
* Affichage avec printf (string) : retranscription en ASM PRI {string} à revoir ? Ajouter le type string/char* dans la table des symboles ?

## Informations complémentaires
* Instructions ASM utilisées en supplément de celles proposées dans le sujet du projet :
	* CALL {ligneASM} {nb_var}  ; appel à une fonction (équivalent à un JMP {ligneASM})
	* RET ; retour fonction précédente
	* PUSH @adresse ; empiler l'argument situé à l’adresse @adresse dans la table des symboles
	* POP @adresse ; récupérer le dernier élément empilé et l'affecter à la variable d'adresse @adresse de la table des symboles
	* LEAVE ; instruction pour quitter le programme
* Gestion des arguments : PUSH de chaque argument lors de l'appel d'une fonction (dans le main par exemple). Une fois dans la fonction en question, on affecte les arguments (variables locales) avec des POP.
* Gestion des variables locales / globales : Toute variable locale est liée à une fonction dans la table des symboles (“fonction _GLOBAL” pour les variables globales).
La valeur d’adressage mémoire est réinitialisée à chaque début de fonction ; cette valeur d’adressage mémoire init_mem est égale au nombre de variables globales.
Par exemple,  s'il y a au début 5 variables globales de déclarée (index de 0 à 4 dans tab_symboles.c), toutes les variables locales (des fonctions) commenceront à partir de l’adresse 5. 
A l’appel d’une fonction A par une fonction B, on inscrit CALL {ligneASM} {nb_var}, avec nb_var le nombre de variables locales de la fonction B. Ceci permettra plus tard à l’interpréteur de “sauter” suffisamment dans la mémoire pour ne pas écraser les valeurs des variables déclarées de la fonction B ors de l’execution de la fonction A. 

## Processus de compilation :
* Parsing, en plaçant des marqueurs lorsqu’ils y a des inconnues pour les JMP/JMF/CALL (??? pour IF/WHILE, $$$ pour les fonctions). Le logger (dumb-logger.c)  affiche ou non les informations à l’écran, affiche (et comptabilise) les erreurs survenues.
* A la fin du parsing, remplacement des marqueurs par les bonnes valeurs de lignes ASM grâce à la table des instructions et la table des fonctions. 
* Le fichier ASM créé lors du parsing est supprimé s’il y a eu des erreurs de compilation.
