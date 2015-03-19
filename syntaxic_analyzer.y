%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "tab_symboles.h"

#define NB_VAR_TEMPORAIRE_MAX 50

int flagConst ;
int nbVarTmpCourant = 0;
char nomVarTmpCourant[NB_VAR_TEMPORAIRE_MAX];

%}

%token  EXP TXT 
%token  tEGAL tPLUS tMOINS tFOIS  tDIVISE
%token  tPARO tPARF tACCO tACCF
%token  tINT tCONST  
%token  tSPACE tVIRGULE tFININSTRUCTION tDEUXPOINTS
%token  tECHO tMAIN
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
		  									  	printf("ERREUR : Symbole déjà déclarée\n"); 
		  									  }}
					  | VAR tEGAL NOMBRE tFININSTRUCTION {if (ts_addr($1) == -1) { 
					  										ts_ajouter($1, flagConst, 1);  printf("AFC %d %d\n", ts_addr($1), $3);
					  									  } else { 
					  									  	printf("ERREUR : Symbole déjà déclarée\n"); 
					  									  }}
					  | VAR tVIRGULE VariablesDeclarations {if (ts_addr($1) == -1) { 
					  										ts_ajouter($1, flagConst, 0);
					  									  } else { 
					  									  	printf("ERREUR : Symbole déjà déclarée\n"); 
					  									  }}
					  | VAR tEGAL NOMBRE tVIRGULE VariablesDeclarations {if (ts_addr($1) == -1) { 
					  														ts_ajouter($1, flagConst, 1); printf("AFC %d %d\n", ts_addr($1), $3);
					  									  				} else { 
					  									  					printf("ERREUR : Symbole déjà déclarée\n"); 
					  									  				}}
					  ;


Instructions: Instruction  Instructions 
			|
			;

Instruction:		Affectation tFININSTRUCTION
			|  error  tFININSTRUCTION	{ yyerrok; }
			;

Affectation:		VAR tEGAL Expression		{ if(ts_addr($1) != -1) { 
								if (!est_constant($1) || ((est_constant($1)) && (!est_initialise($1)))) {
									ts_affect($1); 
									printf("COP %d %d \n", ts_addr($1), $3)  ;
									ts_depiler();
							        }
								else {
									printf(" \n# Constante initialisée détectée, modification impossible \n ")  ; 	
								}
							  }
							  else {
								printf(" \n# Variable non définie \n")  ;
							  }							
                                                        }


Expression:
			NOMBRE				{ 
								  sprintf(nomVarTmpCourant, "var_tmp%d", nbVarTmpCourant);
								  ts_ajouter(nomVarTmpCourant, 1, 0); 
								  nbVarTmpCourant++;
								  printf("AFC %d %d\n", ts_addr(nomVarTmpCourant), NOMBRE); 
								  $$=ts_addr(nomVarTmpCourant) ; 
								}
            | VAR               {if (ts_addr($1) == -1) {
									printf("Erreur : variable non déclarée\n");		
								} else if (est_initialise($1) == 0) {
									printf("Erreur : variable non initialisée\n");	
								} else { 
                                 	printf("# Stocker var dans var temporaire\n");
                                 	sprintf(nomVarTmpCourant, "var_tmp%d", nbVarTmpCourant);
								    ts_ajouter(nomVarTmpCourant, 1, 0); 
								    nbVarTmpCourant++;
								    printf("COP %d %d\n", ts_addr(nomVarTmpCourant), ts_addr($1)); 
							     	$$=ts_addr(nomVarTmpCourant) ;
                             	}}
			| tPARO Expression tPARF	{ $$=$2 ; } 
			| Expression tPLUS Expression 	{ 
												printf("ADD %d %d %d\n", $1, $1, $3) ; 
											  	ts_depiler(); 
											  	nbVarTmpCourant--; 
											  	$$ = $1;
											}  
			| Expression tMOINS Expression	{ 
												printf("SUB %d %d %d\n", $1, $1, $3) ; 
											  	ts_depiler(); 
											  	nbVarTmpCourant--; 
											  	$$ = $1;
										     } 
			| Expression tFOIS Expression	{ 
												printf("MUL %d %d %d\n", $1, $1, $3) ; 
											  	ts_depiler(); 
											  	nbVarTmpCourant--; 
											  	$$ = $1;
											}
			| Expression tDIVISE Expression	{ 
												printf("DIV %d %d %d\n", $1, $1, $3) ; 
											  	ts_depiler(); 
											  	nbVarTmpCourant--; 
											  	$$ = $1;
											 }
			| tMOINS Expression		{ printf("# Faire la négation d'une expression\n");
									  printf("SOU %d %d %d\n", $2, ts_addr(NOM_VAR_ZERO), $2);
									  $$ = $2; 
									}   %prec tFOIS
			; 

Fin:			tACCF		{ printf ("Fin du programme \n") ; }  


%%


int yyerror(char *s) {
  printf("%s\n",s);
}



int main(void) {
  // initialiser tab symboles 
  ts_init() ; 

  // parser
  yyparse();

 // affichage table des symboles 
  ts_print() ; 

  return 0;
}