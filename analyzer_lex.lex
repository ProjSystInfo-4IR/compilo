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

/* %x : exclusive start condition >< %s : exclusive start condition */
%x BLOCK_COMMENT
%x LINE_COMMENT
%%

"/*" 					{BEGIN BLOCK_COMMENT;}
<BLOCK_COMMENT>"*/" 	{BEGIN INITIAL;}
<BLOCK_COMMENT>.		{}                // consume all characters 
<BLOCK_COMMENT>\n     	{}                // consume all lines


"//"         			{BEGIN LINE_COMMENT;}
<LINE_COMMENT>\n 		{BEGIN INITIAL;}
<LINE_COMMENT>.         {}                // consume all characters

 /*** Rules section ***/

[/t]+$ ; // élimine blancs et tabs en fin de ligne
 
{SPACE}    {  } //return tSPACE ;  
main       { return tMAIN  ; }
\{         { return tACCO  ; } 
\}         { return tACCF  ; } 
const      { return tCONST ; }
int        { return tINT   ; }
printf     { return tECHO  ; }
if         { return tIF	   ; }
else       { return tELSE  ; }
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
{NOMVAR}   { yylval.chaine=strdup(yytext) ; return VAR ; }
{EXPONENTIEL} { return EXP /* printf("Entier (exponentiel): %s\n", yytext) */ ;}   
{DIGITS} { /* [0-9]+ matches a string of one or more digits */ yylval.nombre=atoi(yytext) ; return NOMBRE ;}
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
