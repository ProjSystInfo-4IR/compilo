%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <errno.h>  // error code
#include <unistd.h> // getopt
#include "tab_symboles.h"
#include "tab_ic.h"
#include "dumb-logger/logger.h"

extern FILE * yyin;

#define NB_VAR_TEMPORAIRE_MAX 50
// Nb maximum de characteres dans une ligne de code assembleur que le compilateur peut générer
#define LINE_CAPACITY 100
#define WORD_CAPACITY 32

int ligneAsmCourant = 1;
int flagConst ;
int nbVarTmpCourant = 0;
char nomVarTmpCourant[NB_VAR_TEMPORAIRE_MAX];
const char* MARQUEUR_TIC = "???";
FILE* fp ;

%}

%token  EXP TXT 
%token  tEGAL tPLUS tMOINS tFOIS  tDIVISE
%token  tPARO tPARF tACCO tACCF
%token  tINT tCONST  
%token  tSPACE tVIRGULE tFININSTRUCTION tDEUXPOINTS
%token  tECHO tMAIN tIF tELSE tWHILE
%error-verbose

%token <chaine> VAR
%union {char* chaine;} 

%token <nombre> NOMBRE
%union {int nombre;}

%type <expr> Expression
%union {int expr;}


%left tPLUS  tMOINS
%left tFOIS  tDIVISE
%right tEGAL

%start Input
%%

Input:			Debut ; 

Debut:			tMAIN tPARO tPARF tACCO Operations Fin ; 

Operations:		Declarations Instructions ;   

Declarations:		Declaration Declarations
			| 
			; 

Declaration: tINT  {flagConst = 0;} VariablesDeclarations                 
			| tCONST tINT {flagConst = 1;} VariablesDeclarations	
			;

VariablesDeclarations:  VAR tFININSTRUCTION {if (ts_addr($1) == -1) { 
		  										ts_ajouter($1, flagConst, 0);
		  									  } else { 
		  									  	logger_error("Symbole déjà déclarée\n"); 
		  									  }}
					  | VAR tEGAL NOMBRE tFININSTRUCTION {if (ts_addr($1) == -1) { 
					  										ts_ajouter($1, flagConst, 1);  
					  										fprintf(fp, "AFC %d %d\n", ts_addr($1), $3);
					  										ligneAsmCourant++;
					  									  } else { 
					  									  	logger_error("Symbole déjà déclarée\n"); 
					  									  }}
					  | VAR tVIRGULE VariablesDeclarations {if (ts_addr($1) == -1) { 
					  										ts_ajouter($1, flagConst, 0);
					  									  } else { 
					  									  	logger_error("Symbole déjà déclarée\n"); 
					  									  }}
					  | VAR tEGAL NOMBRE tVIRGULE VariablesDeclarations {if (ts_addr($1) == -1) { 
					  														ts_ajouter($1, flagConst, 1); 
					  														fprintf(fp, "AFC %d %d\n", ts_addr($1), $3);
					  														ligneAsmCourant++;
					  									  				} else { 
					  									  					logger_error("Symbole déjà déclarée\n"); 
					  									  				}}
					  ;


Instructions: Instruction  Instructions 
			| IfBloc Instructions
			| WhileBloc Instructions
			|
			;

Instruction:  Affichage tFININSTRUCTION
			| Affectation tFININSTRUCTION
			|  error  tFININSTRUCTION	{ yyerrok; }
			;

Affichage : tECHO tPARO Expression tPARF     
			{
				fprintf(fp, "PRI %d\n", $3);
				ligneAsmCourant++;
				ts_depiler();
				nbVarTmpCourant--;
			}
			;

Affectation:		VAR tEGAL Expression		{ if(ts_addr($1) != -1) { 
								if (!est_constant($1) || ((est_constant($1)) && (!est_initialise($1)))) {
									ts_affect($1); 
									fprintf(fp, "COP %d %d \n", ts_addr($1), $3);
									ligneAsmCourant++;
									ts_depiler();
									nbVarTmpCourant--;
							        }
								else {
									logger_error("Constante initialisée détectée, modification impossible \n ")  ; 	
								}
							  }
							  else {
								logger_error("Variable non définie \n")  ;
							  }							
                                                        }
                    ;


Expression:
			NOMBRE				{ 
								  sprintf(nomVarTmpCourant, "var_tmp%d", nbVarTmpCourant);
								  logger_info("# Stocker nombre %d dans var temporaire %s\n", $1, nomVarTmpCourant);
								  ts_ajouter(nomVarTmpCourant, 1, 0); 
								  nbVarTmpCourant++;
								  fprintf(fp, "AFC %d %d\n", ts_addr(nomVarTmpCourant), $1);
								  ligneAsmCourant++;
								  $$=ts_addr(nomVarTmpCourant) ; 
								}
            | VAR               {if (ts_addr($1) == -1) {
									logger_error("Variable non déclarée\n");		
								} else if (est_initialise($1) == 0) {
									logger_error("Variable non initialisée\n");	
								} else { 
                                 	sprintf(nomVarTmpCourant, "var_tmp%d", nbVarTmpCourant);
                                 	logger_info("Stocker var %s dans var temporaire %s\n", $1, nomVarTmpCourant);
								    ts_ajouter(nomVarTmpCourant, 1, 0); 
								    nbVarTmpCourant++;
								    fprintf(fp, "COP %d %d\n", ts_addr(nomVarTmpCourant), ts_addr($1)); 
								    ligneAsmCourant++;
							     	$$=ts_addr(nomVarTmpCourant) ;
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
			| tMOINS Expression		{ logger_info("# Faire la négation d'une expression\n");
									  fprintf(fp, "SOU %d %d %d\n", $2, ts_addr(NOM_VAR_ZERO), $2);
									  ligneAsmCourant++;
									  $$ = $2; 
									}   %prec tFOIS
			; 


IfBloc: tIF tPARO Expression 
		{ 
		  	fprintf(fp, "JMF %d %s\n", ts_addr(nomVarTmpCourant), MARQUEUR_TIC);
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

Fin:			tACCF		{ logger_info ("Fin du programme \n") ; }  

WhileBloc : tWHILE tPARO
		{
			tic_ajouter_d(ligneAsmCourant);
		}
			 Expression
        {

        	// empiler dans la table tic
		  	tic_ajouter_s(ligneAsmCourant);

        	fprintf(fp, "JMF %d %s\n", ts_addr(nomVarTmpCourant), MARQUEUR_TIC);
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

void remplacerMarqueursTIC(FILE* fileAsm) {
	char* line = NULL;
	char possibleMarqueur[strlen(MARQUEUR_TIC)];
	char c;
	int lineNum = 1;
	int read;
	size_t len;
	char instruction[WORD_CAPACITY];
	int arg1;

	FILE* fp2 = fopen("o2.asm", "w");
	// read all line
	
	while((read = getline(&line, &len, fileAsm)) != -1) {
		logger_info("%2d : %s", lineNum, line);
		// read each word of line
      	c = sscanf(line,"%s %d %s",instruction, &arg1, possibleMarqueur);   // parse line to 3 parts 
      	if (!strcmp(possibleMarqueur, MARQUEUR_TIC)) {
      		// Marqueur trouve' !
      		// XXX: cette technique suppose une telle format de l'instruction : INSTRUCTION NUMBER MARQUEUR 
      		logger_info("Marker found on line %d, to be replaced by %d\n", lineNum, tic_get_dest(lineNum));

      		fprintf(fp2, "%s %d %d\n", instruction, arg1, tic_get_dest(lineNum));
      	} else {
	      	c = sscanf(line,"%s %s",instruction, possibleMarqueur);
	      	if (!strcmp(possibleMarqueur, MARQUEUR_TIC)) {
	      		// Marqueur trouve' !
	      		// XXX: cette technique suppose une telle format de l'instruction : INSTRUCTION MARQUEUR 
	      		logger_info("Marker found on line %d, to be replaced by %d\n", lineNum, tic_get_dest(lineNum));

	      		fprintf(fp2, "%s %d\n", instruction, tic_get_dest(lineNum));
	      	} else {
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

	char* outputFilename = "o.asm";
	FILE* inputFile;
	while ((opt = getopt(argc, argv, "vo:")) != -1) {
		switch (opt) {
			case 'v' : 
				// enables verbose mode
				logger_set_level(LOGGER_VERBOSE);
				break;
			case 'o' : 
				// output target, default to o.asm
				outputFilename = optarg;
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
  	fprintf(fp, "AFC %d 0\n", ts_addr(NOM_VAR_ZERO));
  	ligneAsmCourant++;

  	// initaliser tab IC
  	tic_init();
  	
  	// parser
  	yyparse();

 	// affichage table des symboles 
  	ts_print() ;

  	logger_info("Nb var temporaires : %d\n", nbVarTmpCourant);
  	logger_info("Nb lignes asm : %d\n", ligneAsmCourant);
  
  	// prepare fp to be read by remplacerMarqueursTIC
  	rewind(fp);
  	remplacerMarqueursTIC(fp);

  	fclose(fp);
  	
  	// affichage table TIC
  	tic_print();

  	printf("Compilation finished.\n");
  	
  	return EXIT_SUCCESS;
}
