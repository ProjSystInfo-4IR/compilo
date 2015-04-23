%{

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <errno.h>  // error code
#include <unistd.h> // fonction getopt

#include "tab_symboles.h" // table des symboles 
#include "tab_ic.h" // table des instructions 
#include "tab_fct.h" // table des fonctions
#include "dumb-logger/logger.h" // gestion des erreurs

#define NB_VAR_TEMPORAIRE_MAX 50  
#define LINE_CAPACITY 100 // Nb maximum de characteres dans une ligne de code assembleur que le compilateur peut générer
#define WORD_CAPACITY 32  // attention un nom de fonction ne peut excéder 32 caratères  

  extern FILE * yyin;
  int ligneAsmCourant = 1;
  int flagConst ;
  int nbVarTmpCourant = 0;
  int nb_args ; 
  int NB_ARGS_MAIN = 0 ; 
  int cpt ; 
  char nomVarTmpCourant[NB_VAR_TEMPORAIRE_MAX];
  char* nom_fonc  ; 
  char* MAIN = "main" ; 
  const char* MARQUEUR_TIC = "???";
  const char* MARQUEUR_FCT = "$$$" ; 
  FILE* fp ;

  %}

%token  EXP  
%token  tEGAL tPLUS tMOINS tFOIS  tDIVISE
%token  tPARO tPARF tACCO tACCF
%token  tINT tCONST  
%token  tSPACE tVIRGULE tFININSTRUCTION tDEUXPOINTS
%token  tECHO tMAIN tIF tELSE tWHILE
%error-verbose

%token <chaine> VAR
%union {char* chaine;} 

%token <string> TXT
%union {char* string;}

%token <nombre> NOMBRE
%union {int nombre;}

%type <expr> Expression
%union {int expr;}

%left tPLUS  tMOINS
%left tFOIS  tDIVISE
%right tEGAL

%start Input
%%

Input:			Declarations DebFonctions MainProg DebFonctions ; 

DebFonctions:           VAR {nb_args = 0 ; nom_fonc = $1 ;} tPARO ListeArgs tPARF { ajout_fct($1, nb_args) ; } SuiteFct DebFonctions | ; 

ListeArgs: Type Var Args | ; 

Args: tVIRGULE Type Var Args | ;  

Type: tINT ; 

Var: VAR {
  nb_args++;
  if (ts_addr($1, nom_fonc) == -1) { 
    ts_ajouter($1, nom_fonc, flagConst, 1);
  } else { 
    logger_info("fonction %s : Argument %s déjà déclaré\n", nom_fonc, $1); 
  }} ; 

SuiteFct:               DeclFonction | DefFonction ;

DeclFonction:		tFININSTRUCTION  { logger_info ("Fonction %s déclarée \n", nom_fonc) ; } ; 

DefFonction:	        tACCO { 
  set_code_decl(nom_fonc, nb_args) ; 
  set_start(nom_fonc, ligneAsmCourant, nb_args) ; 
  for(cpt=0 ; cpt < nb_args ; cpt++) {
     fprintf(fp, "POP\n"); // récupère argument (à revoir : comment faire après ?)  
     ligneAsmCourant++;
  }
} 
Operations tACCF 
{  
  fprintf(fp, "RET\n");	// retour fonction mère 
  ligneAsmCourant++;
  logger_info ("Fonction %s définie \n", nom_fonc) ; 
} ;

MainProg:		tMAIN { nom_fonc = MAIN ; ajout_fct(MAIN, NB_ARGS_MAIN) ; set_code_decl(MAIN, NB_ARGS_MAIN) ; set_start(MAIN, ligneAsmCourant, NB_ARGS_MAIN) ;} tPARO tPARF tACCO Operations tACCF {                         
  fprintf(fp, "LEAVE\n"); // fin du programme (quitter)
  ligneAsmCourant++;
  logger_info ("Fin du main à la ligne %d \n", ligneAsmCourant-1) ;
}  ;

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
  } else { 
    logger_error("fonction %s : Symbole %s déjà déclarée\n", nom_fonc, $1); 
  }}
| VAR tEGAL NOMBRE tFININSTRUCTION {
  if (ts_addr($1, nom_fonc) == -1) { 
    ts_ajouter($1, nom_fonc, flagConst, 1);  
    fprintf(fp, "AFC %d %d\n", ts_addr($1, nom_fonc), $3);
    ligneAsmCourant++;
  } else { 
    logger_error("fonction %s : Symbole %s déjà déclarée\n", nom_fonc, $1); 
  }}
| VAR tVIRGULE VariablesDeclarations {
  if (ts_addr($1, nom_fonc) == -1) { 
    ts_ajouter($1, nom_fonc, flagConst, 0);
  } else { 
   logger_error("fonction %s : Symbole %s déjà déclarée\n", nom_fonc, $1); 
  }}
| VAR tEGAL NOMBRE tVIRGULE VariablesDeclarations {
  if (ts_addr($1, nom_fonc) == -1) { 
    ts_ajouter($1, nom_fonc, flagConst, 1); 
    fprintf(fp, "AFC %d %d\n", ts_addr($1, nom_fonc), $3);
    ligneAsmCourant++;
  } else { 
  logger_error("fonction %s : Symbole %s déjà déclarée\n", nom_fonc, $1); 
  }}
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

AppelFonction:	VAR {nb_args = 0 ;} tPARO ListeArgsFct tPARF tFININSTRUCTION { 
  fprintf(fp, "CALL %s %s %d\n", MARQUEUR_FCT, $1, nb_args); // appel fonction 
  ligneAsmCourant++;
  logger_info ("Fonction %s appelée \n", $1) ;   
} 
; 

ListeArgsFct: ArgFct ArgsFct | ; 

ArgsFct: tVIRGULE ArgFct ArgsFct | ;  

ArgFct: Expression { 
  nb_args++ ; 
  fprintf(fp, "PUSH %d\n", $1); // (à revoir) empile l'argument en question 
  ligneAsmCourant++;
  ts_depiler();
  nbVarTmpCourant--;
}; 

Affichage: tECHO tPARO ContenuAffichage tPARF ; 

ContenuAffichage: Expression      
{
  fprintf(fp, "PRI %d\n", $1); // afficher un integer
  ligneAsmCourant++;
  ts_depiler();
  nbVarTmpCourant--;
}
|                 TXT          // BETA version affichage string ; à revoir ? 
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
      logger_error("fonction %s : Constante %s initialisée détectée, modification impossible \n ", nom_fonc, $1)  ; 	
    }
  }
  else {
    logger_error("fonction %s : Variable %s non définie \n", nom_fonc, $1)  ;
  }							
}
;


Expression: 
NOMBRE                          { 
  sprintf(nomVarTmpCourant, "var_tmp%d", nbVarTmpCourant);
  logger_info("# Stocker nombre %d dans var temporaire %s\n", $1, nomVarTmpCourant);
  ts_ajouter(nomVarTmpCourant, nom_fonc, 1, 0); 
  nbVarTmpCourant++;
  fprintf(fp, "AFC %d %d\n", ts_addr(nomVarTmpCourant, nom_fonc), $1);
  ligneAsmCourant++;
  $$=ts_addr(nomVarTmpCourant, nom_fonc) ; 
}
| VAR                           {
  if (ts_addr($1, nom_fonc) == -1) {
   logger_error("fonction %s : Variable %s non déclarée\n", nom_fonc, $1); 		
  } else if (est_initialise($1, nom_fonc) == 0) {
   logger_error("fonction %s : Variable %s non initialisée\n", nom_fonc, $1);	
  } else { 
    sprintf(nomVarTmpCourant, "var_tmp%d", nbVarTmpCourant);
    logger_info("Stocker var %s dans var temporaire %s\n", $1, nomVarTmpCourant);
    ts_ajouter(nomVarTmpCourant, nom_fonc, 1, 0); 
    nbVarTmpCourant++;
    fprintf(fp, "COP %d %d\n", ts_addr(nomVarTmpCourant, nom_fonc), ts_addr($1, nom_fonc)); 
    ligneAsmCourant++;
    $$=ts_addr(nomVarTmpCourant, nom_fonc) ;
  }}
| tPARO Expression tPARF	{ $$=$2 ; } 
| Expression tPLUS Expression 	{ 
  fprintf(fp, "ADD %d %d %d\n", $1, $1, $3) ; 
  ligneAsmCourant++;
  ts_depiler(); 
  nbVarTmpCourant--; 
  $$ = $1;
}  
| Expression tMOINS Expression	{ 
  fprintf(fp, "SUB %d %d %d\n", $1, $1, $3) ; 
  ligneAsmCourant++;
  ts_depiler(); 
  nbVarTmpCourant--; 
  $$ = $1;
} 
| Expression tFOIS Expression	{ 
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
| tMOINS Expression		{ 
  logger_info("# Faire la négation d'une expression\n");
  fprintf(fp, "SOU %d %d %d\n", $2, ts_addr(NOM_VAR_ZERO, nom_fonc), $2);
  ligneAsmCourant++;
  $$ = $2; 
}   %prec tFOIS
; 


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

int yyerror(char *s) {
  logger_error("%s\n",s);
}


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
  FILE* fp2 = fopen(finalFilename, "w");
  
  logger_info("\n Remplacement des marqueurs FCT  \n") ;	
  // read all lines	
  while((read = getline(&line, &len, fileAsm)) != -1) {
    logger_info("%2d : %s", lineNum, line);
    // read each word of line
    c = sscanf(line,"%s %s %s %d",instruction, possibleMarqueur, nom_fct, &nombre_arguments);   // parse line to 3 parts 
    if (!strcmp(possibleMarqueur, MARQUEUR_FCT)) {
      // Marqueur trouvé !
      // XXX: cette technique suppose une telle format de l'instruction : INSTRUCTION MARQUEUR NOM_FCT 
      if(get_start(nom_fct, nombre_arguments) != -1) {
	logger_info("Marker found on line %d, to be replaced by %d\n", lineNum, get_start(nom_fct, nombre_arguments));
	fprintf(fp2, "%s %d %s %d \n", instruction, get_start(nom_fct, nombre_arguments), nom_fct, nombre_arguments);
      }
      else {
	logger_info("Marker found on line %d, but impossible to replace", lineNum);
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
      logger_info("Marker found on line %d, to be replaced by %d\n", lineNum, tic_get_dest(lineNum));

      fprintf(fp2, "%s %d %d\n", instruction, arg1, tic_get_dest(lineNum));
    }
    else {
      c = sscanf(line,"%s %s",instruction, possibleMarqueur);
      if (!strcmp(possibleMarqueur, MARQUEUR_TIC)) {
	// Marqueur trouve' !
	// XXX: cette technique suppose une telle format de l'instruction : INSTRUCTION MARQUEUR 
	logger_info("Marker found on line %d, to be replaced by %d\n", lineNum, tic_get_dest(lineNum));

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



int main(int argc, char** argv) { int opt;
  
  nom_fonc = GLOBAL  ; 
  char* outputFilename = "o.asm";
  char* outputInt1 = "o1.asm";  
  char* outputFinalFilename = "output.asm";
  FILE* inputFile;
  while ((opt = getopt(argc, argv, "vo:")) != -1) {
    switch (opt) {
    case 'v' : 
      // enables verbose mode
      logger_set_level(LOGGER_VERBOSE);
      break;
    case 'o' : 
				
      //outputFilename = optarg;
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
	
  // open file on mode read write
  fp = fopen(outputFilename,"w+");

  // initialiser tab symboles 
  ts_init();
  // cette ligne est couple avec le tab symboles
  fprintf(fp, "AFC %d 0\n", ts_addr(NOM_VAR_ZERO, nom_fonc));
  ligneAsmCourant++;
  fprintf(fp, "JMP %s %s\n", MARQUEUR_FCT, MAIN);
  ligneAsmCourant++;


  // initaliser table des instructions et des tables des fonctions
  tic_init();
  tab_fct_init() ; 
	
  // parser
  yyparse();
   
  // prepare fp to be read by remplacerMarqueursTIC
  rewind(fp);
  remplacerMarqueursTIC(fp, outputInt1);
  fclose(fp);

  // open file on mode read append
  fp = fopen(outputInt1,"a+");
  rewind(fp);
  // prepare fp to be read by remplacerMarqueursFCT
  remplacerMarqueursFCT(fp, outputFinalFilename);
  fclose(fp);
        
  // supprime les fichiers temporaires (o.asm)
  remove(outputFilename);
  remove(outputInt1) ; 
  
  // A FAIRE
  // si on a une erreur, le fichier asm final n'est pas bon 
  // donc à supprimer 
  // remove(outputFinalFilename);
 
  // affichage table des symboles 
  ts_print() ;

  logger_info("Nb var temporaires : %d\n", nbVarTmpCourant);
  logger_info("Nb lignes asm : %d\n", ligneAsmCourant);

  // affichage table des instructions et table des fonctions
  tic_print();
  tab_fct_print() ; 
 
  printf("Compilation finished.\n");
  	
  return EXIT_SUCCESS;
}
