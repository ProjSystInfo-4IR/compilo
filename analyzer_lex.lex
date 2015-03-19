/*** Definition section ***/
 
%{
/* C code to be copied verbatim */
#include <stdio.h>
#include "y.tab.h"
%}

SPACE  [\t ]+
DIGITS [0-9]+
NOMVAR [a-zA-Z][a-zA-Z0-9_]* 
EXPONENTIEL {DIGITS}e{DIGITS}
STRING "[.]*"

/*** Comment handle ***/

%x COMMENT
%%

"/*" {BEGIN COMMENT;}
<COMMENT>"*/" {BEGIN INITIAL;printf("\n");}


     /*** Rules section ***/

[/t]+$ ; // élimine blancs et tabs en fin de ligne
 
{SPACE}    {  } //return tSPACE ;  
main       { return tMAIN  ; }
\{         { return tACCO  ; } 
\}         { return tACCF  ; } 
const      { return tCONST ; }
int        { return tINT   ; }
printf     { return tECHO  ; }
\+         { return tPLUS  ; } 
\-         { return tMOINS ; } 
\*         { return tFOIS  ; } 
\/         { return tDIVISE ; } 
\=         { return tEGAL ; } 
\:         { return tDEUXPOINTS ; } 
\(         { return tPARO ; } 
\)         { return tPARF ; } 
\n         { }      
,          { return tVIRGULE ; }
;          { return tFININSTRUCTION; }
\^         { return tPUISSANCE; }
{NOMVAR}   { yylval.chaine=strdup(yytext) ; return VAR ; }
{EXPONENTIEL} { return EXP /* printf("Entier (exponentiel): %s\n", yytext) */ ;}
{DIGITS} { /* [0-9]+ matches a string of one or more digits */ return NOMBRE ;}
{STRING} { return TXT ; }

.|\n    { printf("[LEX] : Non reconnu\n"); }
 
%%

/*** C Code section 
 
int main(void)
{
    // Call the lexer, then quit. 
    yylex();
    return 0;
}

 ***/
