%{

  /* inclusion de librairies C */ 
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <errno.h>  // permet de manipuler les "error code"
#include <unistd.h> // librairie pour la fonction getopt

  /* inclusion de nos fichiers C externes */ 
#include "tab_symboles.h" // table des symboles : Tableau C définissant chaque variable déclarée. Chaque variable est liée à une fonction (ou à GLOBAL pour les variables globales)
#include "tab_ic.h" // table des instructions : Tableau C permettant de manipuler les expressions conditionnelles IF et WHILE
#include "tab_fct.h" // table des fonctions : Tableau C définissant chaque fonction déclarée.
#include "dumb-logger/logger.h" // gestion des affichages et des erreurs



  /* Déclaration des constantes */ 

#define NB_VAR_TEMPORAIRE_MAX 50  // Nombre maximum de variables temporaires (valeur fixée selon la recommandation de notre encadrant de TP)
#define LINE_CAPACITY 100 // Nombre maximum de caracteres dans une ligne de code assembleur que le compilateur peut générer
#define WORD_CAPACITY 32  // On fixe une limite concernant le nommage des fonctions : un nom de fonction ne peut excéder 32 caratères  
#define NB_ARGS_MAX 20 // Nombre maximum d'arguments pour une fonction
 
  // Déclaration des marqueurs inscrits lorsque l'argument d'une instruction ASM n'est pas encore connu 
  const char* MARQUEUR_TIC = "???"; // Cas du traitement des expressions conditionnelles IF et WHILE  
  const char* MARQUEUR_FCT = "$$$" ; // Cas du traitement des fonctions

  /* Autres déclarations */ 

  extern FILE * yyin;  // YACC in
  char inputFileName[100]; // nom du fichier C analysé (100 caractères max) 
  extern int yylineno; // ligne C actuelle aanalysée
  FILE* fp ; // fichier de sortie 

  int ligneAsmCourant = 1; // numéro de la ligne où on se trouve sur le fichier ASM produit 
  int flagConst ;  // détection du caratère constant d'une variable déclarée 
  int nbVarTmpCourant = 0; // nombre de variables temporaires dans la table des symboles 
  char nomVarTmpCourant[NB_VAR_TEMPORAIRE_MAX];

  int nb_args ; // nombre d'arguments de la fonction courante  
  int adresseArgs[NB_ARGS_MAX] ; // tableau contenant les adresses (dans la table des symboles) des arguments d'une fonction
  int NB_ARGS_MAIN = 0 ; // la fonction main ne prend pas en charge d'arguments

  int nb_var_globales ; // nombre actuel de variables globles
  int nb_var_locales ;  // nombre actuel de variable dans la fonction en question

  int cpt ; // variable int utilisée en guise de compteur
  
  char* nom_fonc  ; // nom de la fonction en question 
  char* MAIN = "main" ;   

  %}

/* Tokens reconnus dans l'analyseur analyzer_lex/lex */ 
%token  EXP  
%token  tEGAL tPLUS tMOINS tFOIS  tDIVISE
%token  tPARO tPARF tACCO tACCF
%token  tINT tCONST  
%token  tSPACE tVIRGULE tFININSTRUCTION tDEUXPOINTS
%token  tECHO tMAIN tIF tELSE tWHILE
%error-verbose

/* Typage de tokens particuliers */ 
%token <chaine> VAR
%union {char* chaine;} 

%token <string> TXT
%union {char* string;}

%token <nombre> NOMBRE
%union {int nombre;}

%type <expr> Expression
%union {int expr;}

/* Priorité des opérateurs arithmétiques */ 
%left tPLUS  tMOINS
%left tFOIS  tDIVISE
%right tEGAL

%start Input
%%

 /* On peut déclarer des variables globales, mais ensuite, il faut passer à l'execution du main. 
    La déclaration/définition de fonctions peut se faire avant ou après le main  */ 
Input:			Declarations { fprintf(fp, "CALL %s %s %d %d\n", MARQUEUR_FCT, MAIN, NB_ARGS_MAIN, nb_var_globales); ligneAsmCourant++; } DebFonctions MainProg DebFonctions ; 


/* Détection de fonctions et ses arguments */ 
DebFonctions:           VAR {nb_args = 0 ; init_adr_mem(nb_var_globales) ; nom_fonc = $1 ;} tPARO ListeArgs tPARF { ajout_fct($1, nb_args) ;  nb_var_locales = nb_args ; } SuiteFct DebFonctions | ; 

ListeArgs: Type Arg Args | ; 

Args: tVIRGULE Type Arg Args | ;  

// pour l'instant seuls les integers sont pris en charge
Type: tINT { flagConst = 0 ; } 
| tCONST tINT { flagConst = 1 ; } 
;

Arg: VAR {
  flagConst = 0 ; 
  if (ts_addr($1, nom_fonc) == -1) { 
    ts_ajouter($1, nom_fonc, flagConst, 1); 
  } else { 
    logger_info("fonction %s : Argument %s déjà déclaré\n", nom_fonc, $1); 
  }  
  adresseArgs[nb_args] = ts_addr($1,  nom_fonc) ; 
  nb_args++; 
  } ; 

SuiteFct:               DeclFonction | DefFonction ;

DeclFonction:		tFININSTRUCTION  { logger_info ("Fonction %s déclarée \n", nom_fonc) ; } ; 

DefFonction:	        tACCO { 
  set_code_decl(nom_fonc, nb_args) ; 
  set_start(nom_fonc, ligneAsmCourant, nb_args) ; 
  for(cpt=0 ; cpt < nb_args ; cpt++) {
    // les arguments récupèrent les valeurs affectées lors de l'appel de la fonction  
    fprintf(fp, "POP %d\n", adresseArgs[nb_args-1-cpt]); // cas PUSH/POP LIFO (pile)   
    //fprintf(fp, "POP %d\n", adresseArgs[cpt]); // cas PUSH/POP FIFO (file)
    ligneAsmCourant++;
  }
} 
                        Operations tACCF 
{  
  fprintf(fp, "RET\n");	// retour fonction mère 
  ligneAsmCourant++;
  logger_info ("Fonction %s définie \n", nom_fonc) ; 
} ;



/* Détection du main */ 
MainProg:		tMAIN 
{ 
  nb_args = NB_ARGS_MAIN ;
  nb_var_locales = 0 ;
  init_adr_mem(nb_var_globales) ;
  nom_fonc = MAIN ; 
  ajout_fct(MAIN, NB_ARGS_MAIN) ; 
  set_code_decl(MAIN, NB_ARGS_MAIN) ; 
  set_start(MAIN, ligneAsmCourant, NB_ARGS_MAIN) ;
} 
                       tPARO tPARF tACCO Operations tACCF 
{                         
  fprintf(fp, "LEAVE\n"); // fin du programme (quitter)
  ligneAsmCourant++;
  logger_info ("Fin du main à la ligne %d \n", ligneAsmCourant-1) ;
}  ;



/* Opérations */ 
Operations:		Declarations Instructions ;   

Declarations:		Declaration Declarations
| 
; 

Declaration: tINT  {flagConst = 0;} VariablesDeclarations                 
| tCONST tINT {flagConst = 1;} VariablesDeclarations	
;

VariablesDeclarations:  VAR tFININSTRUCTION {
  if (ts_addr($1, nom_fonc) == -1) { 
    ts_ajouter($1, nom_fonc, flagConst, 0);
    if(strcmp(nom_fonc,GLOBAL)==0){
      nb_var_globales++ ; 
    }
    else {
      nb_var_locales++ ; 
    }
  } 
  else { 
    logger_lerror(yylineno, "fonction %s : Symbole %s déjà déclarée\n", nom_fonc, $1); 
  }
}
| VAR tEGAL Expression tFININSTRUCTION {
  if (ts_addr($1, nom_fonc) == -1) { 
    if(strcmp(nom_fonc,GLOBAL)==0){
      nb_var_globales++ ; 
    }
    else {
      nb_var_locales++ ; 
    }
    ts_depiler();
    nbVarTmpCourant--;  
    ts_ajouter($1, nom_fonc, flagConst, 1);  
    fprintf(fp, "COP %d %d\n", ts_addr($1, nom_fonc), $3);
    ligneAsmCourant++;
  } 
  else { 
    logger_lerror(yylineno, "fonction %s : Symbole %s déjà déclaré\n", nom_fonc, $1); 
  }
}
| VAR tVIRGULE  {
  if (ts_addr($1, nom_fonc) == -1) { 
    ts_ajouter($1, nom_fonc, flagConst, 0);
    if(strcmp(nom_fonc,GLOBAL)==0){
      nb_var_globales++ ; 
    }
    else {
      nb_var_locales++ ; 
    } 
  } 
  else { 
    logger_lerror(yylineno, "fonction %s : Symbole %s déjà déclarée\n", nom_fonc, $1); 
  }
} VariablesDeclarations
| VAR tEGAL Expression tVIRGULE  {
  if (ts_addr($1, nom_fonc) == -1) { 
      if(strcmp(nom_fonc,GLOBAL)==0){
	     nb_var_globales++ ; 
      }
      else {
               nb_var_locales++ ; 
      }
      ts_depiler();
      nbVarTmpCourant--;
      ts_ajouter($1, nom_fonc, flagConst, 1); 
      fprintf(fp, "COP %d %d\n", ts_addr($1, nom_fonc), $3);
      ligneAsmCourant++;
  } 
  else { 
      logger_lerror(yylineno, "fonction %s : Symbole %s déjà déclarée\n", nom_fonc, $1); 
 }
} VariablesDeclarations
;


Instructions: Instruction  Instructions 
| IfBloc Instructions
| WhileBloc Instructions
|
;

Instruction:  Affichage tFININSTRUCTION
| Affectation tFININSTRUCTION
| AppelFonction 
| error  tFININSTRUCTION	{ yyerrok; }
;

// gestion de l'appel à une fonction 
AppelFonction:	VAR {nb_args = 0 ;} tPARO ListeArgsFct tPARF tFININSTRUCTION 
{ 
  if(fct_exist($1, nb_args) == 1) {
    fprintf(fp, "CALL %s %s %d %d\n", MARQUEUR_FCT, $1, nb_args, nb_var_locales+nb_var_globales);  
  ligneAsmCourant++;
  logger_info ("Fonction %s appelée \n", $1) ;   
  }
  else if (fct_exist($1, nb_args) == 2) {
    logger_lerror(yylineno, "Fonction %s existe mais avec un nombre différent d'arguments \n", $1) ;
  }
 else  {
    logger_lerror(yylineno, "Fonction %s n'existe pas \n", $1) ;
  }
} 
; 

ListeArgsFct: ArgFct ArgsFct | ; 

ArgsFct: tVIRGULE ArgFct ArgsFct | ;  

ArgFct: Expression { 
  nb_args++ ; 
  fprintf(fp, "PUSH %d\n", $1); // empile l'argument en question 
  ligneAsmCourant++;
  ts_depiler();
  nbVarTmpCourant--;
}; 
// fin gestion de l'appel d'une fonction 

Affichage: tECHO tPARO ContenuAffichage tPARF ; 

ContenuAffichage: Expression      
{
  fprintf(fp, "PRI %d\n", $1); // afficher un integer
  ligneAsmCourant++;
  ts_depiler();
  nbVarTmpCourant--;
}
|                 TXT          // BETA version affichage string  
{
  fprintf(fp, "PRI %s\n", $1); // afficher une chaîne de caractères
  ligneAsmCourant++;
}
;

Affectation:   VAR tEGAL Expression { 
  if(ts_addr($1, nom_fonc) != -1) { 
    if (!est_constant($1, nom_fonc) || ((est_constant($1, nom_fonc)) && (!est_initialise($1, nom_fonc)))) {
      ts_affect($1, nom_fonc); 
      fprintf(fp, "COP %d %d \n", ts_addr($1, nom_fonc), $3);
      ligneAsmCourant++;
      ts_depiler();
      nbVarTmpCourant--;
    }
    else {
      logger_lerror(yylineno, "fonction %s : Constante %s initialisée détectée, modification impossible, est_constant($1, nom_fonc) = %d \n", nom_fonc, $1, est_constant($1, nom_fonc))  ; 	
    }
  }
  else {
    logger_lerror(yylineno, "fonction %s : Variable %s non définie \n", nom_fonc, $1)  ;
  }							
}
;


Expression: 
NOMBRE                          
{ 
  sprintf(nomVarTmpCourant, "var_tmp%d", nbVarTmpCourant);
  logger_info("# Stocker nombre %d dans var temporaire %s\n", $1, nomVarTmpCourant);
  ts_ajouter(nomVarTmpCourant, nom_fonc, 1, 0); 
  nbVarTmpCourant++;
  fprintf(fp, "AFC %d %d\n", ts_addr(nomVarTmpCourant, nom_fonc), $1);
  ligneAsmCourant++;
  $$=ts_addr(nomVarTmpCourant, nom_fonc) ; 
}
| VAR                           
{
  if (ts_addr($1, nom_fonc) == -1) {
    logger_lerror(yylineno, "fonction %s : Variable %s non déclarée\n", nom_fonc, $1);    
  } else if (est_initialise($1, nom_fonc) == 0) {
    logger_lerror(yylineno, "fonction %s : Variable %s non initialisée\n", nom_fonc, $1); 
  } else { 
    sprintf(nomVarTmpCourant, "var_tmp%d", nbVarTmpCourant);
    logger_info("Stocker var %s dans var temporaire %s\n", $1, nomVarTmpCourant);
    ts_ajouter(nomVarTmpCourant, nom_fonc, 1, 0); 
    nbVarTmpCourant++;
    fprintf(fp, "COP %d %d\n", ts_addr(nomVarTmpCourant, nom_fonc), ts_addr($1, nom_fonc)); 
    ligneAsmCourant++;
    $$=ts_addr(nomVarTmpCourant, nom_fonc) ;
  }
}
| tPARO Expression tPARF	{ $$=$2 ; } 
| Expression tPLUS Expression 	
{ 
  fprintf(fp, "ADD %d %d %d\n", $1, $1, $3) ; 
  ligneAsmCourant++;
  ts_depiler(); 
  nbVarTmpCourant--; 
  $$ = $1;
}  
| Expression tMOINS Expression	
{ 
  fprintf(fp, "SOU %d %d %d\n", $1, $1, $3) ; 
  ligneAsmCourant++;
  ts_depiler(); 
  nbVarTmpCourant--; 
  $$ = $1;
} 
| Expression tFOIS Expression	
{ 
  fprintf(fp, "MUL %d %d %d\n", $1, $1, $3) ; 
  ligneAsmCourant++;
  ts_depiler(); 
  nbVarTmpCourant--; 
  $$ = $1;
}
| Expression tDIVISE Expression	{ 
  fprintf(fp, "DIV %d %d %d\n", $1, $1, $3) ; 
  ligneAsmCourant++;
  ts_depiler(); 
  nbVarTmpCourant--; 
  $$ = $1;
}
| tMOINS Expression		
{ 
  logger_info("# Faire la négation d'une expression\n");
  fprintf(fp, "SOU %d %d %d\n", $2, ts_addr(NOM_VAR_ZERO, nom_fonc), $2);
  ligneAsmCourant++;
  $$ = $2; 
}   %prec tFOIS // priorité de la négation sur la multiplication
; 




/* Détection du IF */ 
IfBloc: tIF tPARO Expression 
{ 
  fprintf(fp, "JMF %d %s\n", ts_addr(nomVarTmpCourant, nom_fonc), MARQUEUR_TIC);
  // depiler la var tmp cree par Expression
  ts_depiler();
  nbVarTmpCourant--;

  // empiler dans la table tic
  tic_ajouter_s(ligneAsmCourant);
  ligneAsmCourant++;

}
tPARF tACCO Instructions SuiteIf
; 

SuiteIf : tACCF 
{
  tic_set_dest(ligneAsmCourant+1);
  tic_ajouter_s(ligneAsmCourant);
  fprintf(fp, "JMP %s\n", MARQUEUR_TIC);
  ligneAsmCourant++;
} tELSE tACCO Instructions tACCF
{
  tic_set_dest(ligneAsmCourant);
}
| tACCF
{
  tic_set_dest(ligneAsmCourant);
};	 



/* Détection du WHILE */ 
WhileBloc : tWHILE tPARO
{
  tic_ajouter_d(ligneAsmCourant);
}
Expression
{
  // empiler dans la table tic
  tic_ajouter_s(ligneAsmCourant);

  fprintf(fp, "JMF %d %s\n", ts_addr(nomVarTmpCourant, nom_fonc), MARQUEUR_TIC);
  ligneAsmCourant++;	

  // depiler la var tmp cree par Expression
  ts_depiler();
  nbVarTmpCourant--;
}
tPARF tACCO Instructions tACCF
{
  tic_set_source(ligneAsmCourant);
  fprintf(fp, "JMP %s\n", MARQUEUR_TIC);
  ligneAsmCourant++;
  tic_set_dest(ligneAsmCourant);
}

%%

/* Affichage de la ligne C où un problème de parsing avec YACC survient */ 
int yyerror(char *s) {
  logger_lerror(yylineno, "%s\n",s);
}


/* fonction permettant d'affecter les bonnes valeurs d'arguments pour les instructions ASM liées aux fonctions */ 
void remplacerMarqueursFCT(FILE* fileAsm, char* finalFilename) {
  char* line = NULL;
  char possibleMarqueur[strlen(MARQUEUR_FCT)];
  char c;
  int lineNum = 1;
  int read;
  size_t len;
  char instruction[WORD_CAPACITY];
  char nom_fct[WORD_CAPACITY];
  int nombre_arguments ; 
  int nb_variables ; 
  FILE* fp2 = fopen(finalFilename, "w");
  
  logger_info("\n Remplacement des marqueurs FCT  \n") ;	
  // read all lines	
  while((read = getline(&line, &len, fileAsm)) != -1) {
    logger_info("%2d : %s", lineNum, line);
    // read each word of line
    c = sscanf(line,"%s %s %s %d %d",instruction, possibleMarqueur, nom_fct, &nombre_arguments, &nb_variables);   // parse line to 3 parts 
    if (!strcmp(possibleMarqueur, MARQUEUR_FCT)) {
      // Marqueur trouvé !
      // XXX: cette technique suppose une telle format de l'instruction : INSTRUCTION MARQUEUR NOM_FCT 
      if(get_start(nom_fct, nombre_arguments) != -1) {
	logger_info("Marqueur trouvé à la ligne %d, remplacement par %d\n", lineNum, get_start(nom_fct, nombre_arguments));
	/* afficher nom fonction et nombre arguments  
           fprintf(fp2, "%s %d %s %d \n", instruction, get_start(nom_fct, nombre_arguments), nom_fct, nombre_arguments);
        */
        fprintf(fp2, "%s %d %d\n", instruction, get_start(nom_fct, nombre_arguments), nb_variables);  
      }
      else {
	fprintf(fp2, "%s", line);
      }
    }
    else {
      // Sinon, juste copie toute la ligne
      fprintf(fp2, "%s", line);
    }

    // erase possibleMarqueur
    strcpy(possibleMarqueur, "000");   
    lineNum++; 
  }
  fclose(fp2);
  if (line) {
    free(line);
  }

}

/* fonction permettant d'affecter les bonnes valeurs d'arguments pour les instructions ASM liées aux IF et While */ 
void remplacerMarqueursTIC(FILE* fileAsm, char* finalFilename) {
  char* line = NULL;
  char possibleMarqueur[strlen(MARQUEUR_TIC)];
  char c;
  int lineNum = 1;
  int read;
  size_t len;
  char instruction[WORD_CAPACITY];
  int arg1;

  FILE* fp2 = fopen(finalFilename, "w");
  logger_info("\n Remplacement des marqueurs TIC  \n") ; 	
  // read all lines	
  while((read = getline(&line, &len, fileAsm)) != -1) {
    logger_info("%2d : %s", lineNum, line);
    // read each word of line
    c = sscanf(line,"%s %d %s",instruction, &arg1, possibleMarqueur);   // parse line to 3 parts 
    if (!strcmp(possibleMarqueur, MARQUEUR_TIC)) {
      // Marqueur trouvé !
      // XXX: cette technique suppose une telle format de l'instruction : INSTRUCTION NUMBER MARQUEUR 
      logger_info("Marqueur trouvé ligne %d, remplacement par %d\n", lineNum, tic_get_dest(lineNum));
      fprintf(fp2, "%s %d %d\n", instruction, arg1, tic_get_dest(lineNum));
    }
    else {
      c = sscanf(line,"%s %s",instruction, possibleMarqueur);
      if (!strcmp(possibleMarqueur, MARQUEUR_TIC)) {
	// Marqueur trouve' !
	// XXX: cette technique suppose une telle format de l'instruction : INSTRUCTION MARQUEUR 
	logger_info("Marqueur trouvé ligne %d, remplacement par %d\n", lineNum, tic_get_dest(lineNum));
	fprintf(fp2, "%s %d\n", instruction, tic_get_dest(lineNum));
      }
      else {
	// Sinon, juste copie toute la ligne
	fprintf(fp2, "%s", line);
      }
    }
    // erase possibleMarqueur
    strcpy(possibleMarqueur, "000");   
    lineNum++;
  }

  fclose(fp2);
  if (line) {
    free(line);
  }
}



int main(int argc, char** argv) { 

  int opt;
  char* outputFilename = "o.asm";
  char* outputInt1 = "o1.asm";  
  char* outputFinalFilename = "output.asm";
  FILE* inputFile;
  
  nom_fonc = GLOBAL  ; 
  nb_var_globales = 1 ; 
  nb_var_locales = 0 ;  

  /* gestion des flags de la commande terminal */ 
  while ((opt = getopt(argc, argv, "vo:")) != -1) {
    switch (opt) {
    case 'v' : 
      // enables verbose mode
      logger_set_level(LOGGER_VERBOSE);
      break;
    case 'o' : 
      //final output target, default to output.asm
      outputFinalFilename = optarg;
      break;
    }
  }

  if (optind == argc) {
    logger_error("No input file specified\n");
    return EXIT_FAILURE;
  }
  if ((inputFile = fopen(argv[optind], "r")) == NULL) {
    logger_error("Cannot open input file %s\n", argv[optind]);
    return EXIT_FAILURE;
  }
  yyin = inputFile;
  strcpy(inputFileName, argv[optind]);
  logger_set_nom_fichier(inputFileName) ; 
	
  // open file on mode read write
  fp = fopen(outputFilename,"w+");

  // initialiser tab symboles 
  ts_init();
  // pour réaliser des négations nous devons affecter un symbole VAR_ZERO à 0
  fprintf(fp, "AFC %d 0\n", ts_addr(NOM_VAR_ZERO, nom_fonc));
  ligneAsmCourant++;


  // initaliser table des instructions et des tables des fonctions
  tic_init();
  tab_fct_init() ; 
	
  // parser
  yyparse();
   
  // remplacer les marqueurs d'instruction par les valeurs correctes 
  rewind(fp);
  remplacerMarqueursTIC(fp, outputInt1);
  fclose(fp);

  // ouvrir le nouveau fichier avec les marqueurs remplacés puis remplacer les marqueurs de fonctions par les valeurs correctes 
  fp = fopen(outputInt1,"a+");
  rewind(fp);
  remplacerMarqueursFCT(fp, outputFinalFilename);
  fclose(fp);
        
  // supprime les fichiers ASM temporaires
  remove(outputFilename); // fichier brut apres parser
  remove(outputInt1) ;   // fichier avec marqueurs TIC remplacés uniquement 
 
  // affichage table des symboles, table des instructions et table des fonctions
  ts_print() ;
  tic_print();
  tab_fct_print() ; 
  // logger_info("Nb var temporaires : %d\n", nbVarTmpCourant); // doit toujours etre égal à 0 à la fin 

  if(get_nb_errors_occured()){
  printf("Echec de la compilation : %d erreur(s) rencontrée(s)\n", get_nb_errors_occured());
  remove(outputFinalFilename) ; 
  }
  else { 
  printf("Compilation terminée sans erreurs ! \nLe programme assembleur se trouve dans le fichier %s\n", outputFinalFilename);
  logger_info("Nombre de lignes du fichier ASM : %d\n", ligneAsmCourant);
  }

  return EXIT_SUCCESS;
}
