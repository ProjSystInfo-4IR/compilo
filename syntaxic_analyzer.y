%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "tab_symboles.h"
%}

%token  NOMBRE EXP TXT 
%token  tEGAL tPLUS tMOINS tFOIS  tDIVISE tPUISSANCE
%token  tPARO tPARF tACCO tACCF
%token  tINT tCONST  
%token  tSPACE tVIRGULE tFININSTRUCTION tDEUXPOINTS
%token  tECHO tMAIN
%error-verbose

%token <chaine> VAR
%union {char* chaine;} 


%left tPLUS  tMOINS
%left tFOIS  tDIVISE
%right tPUISSANCE tEGAL

%start Input
%%

Input:			Debut ; 

Debut:			tMAIN tPARO tPARF tACCO Operations Fin ; 

Operations:		Declarations Instructions ;   

Declarations:		Declaration Declarations
			| 
			; 

Declaration:		tCONST tINT VAR tFININSTRUCTION			{ ts_ajouter($3, 1, 0) ; printf ("Déclaration constante de %s faite ! \n", $3) ; }
			| tINT VAR tFININSTRUCTION			{ ts_ajouter($2, 0, 0) ; printf ("Déclaration de %s faite ! \n", $2) ;  }
			| tINT  VariablesDeclarations		        { printf ("Multiples déclarations faites ! \n") ; }             
			| tCONST tINT ConstVariablesDeclarations	{ printf ("Multiples déclarations constantes faites ! \n") ; }  		
			;


VariablesDeclarations:	VAR tVIRGULE VariablesDeclarations	{ ts_ajouter($1, 0, 0) ; }
			| VAR  tFININSTRUCTION                  { ts_ajouter($1, 0, 0) ; }
			; 

ConstVariablesDeclarations:	VAR tVIRGULE ConstVariablesDeclarations		{ ts_ajouter($1, 1, 0) ; }
				| VAR  tFININSTRUCTION				{ ts_ajouter($1, 1, 0) ; }
				;

Instructions:		Instruction 
			| Instruction  Instructions 
			|
			;

Instruction:		Affectation tFININSTRUCTION
			|  error  tFININSTRUCTION	{ yyerrok; }
			;

Affectation:		VAR tEGAL Expression		{ if(ts_addr($1) != -1) { 
								if(est_constant($1) == 0) {
									ts_affect($1) ; 
									printf(" \n Affectation effectuée \n ")  ; 
							        }
								else {
									printf(" \n Constante détectée, modification impossible \n ")  ; 	
								}
							  }
							  else {
								printf(" \n Variable non définie \n ")  ;
							  }							
                                                        }


Expression:
			NOMBRE				{ printf("NOMBRE ") /* $$=$1 */ ; }
			| tPARO Expression tPARF	{ printf("PARENTHESE ") /* $$=$2 */ ; } 
			| Expression tPLUS Expression 	{ printf("ADDITION ") /* $$=$1+$3 */ ; }  
			| Expression tMOINS Expression	{ printf("SOUSTRACTION ") /* $$=$1-$3 */ ; } 
			| Expression tFOIS Expression	{ printf("MULTIPLICATION ") /* $$=$1*$3 */ ; }
			| Expression tDIVISE Expression	{ printf("DIVISION ") /* $$=$1/$3 */ ; }
			| tMOINS Expression		{ printf("NEGATION ") /* $$=-$2 */ ; }   %prec tFOIS
			| Expression tPUISSANCE Expression	{ printf("PUISSANCE ") /* $$=pow($1,$3) */ ; } 
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
}
