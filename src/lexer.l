%{
#include "parser.tab.h"  // Inclui as definições de tokens geradas pelo BISON
%}

%%

[ \t\n]+              ; // Ignora espaços em branco
[0-9]+                { yylval = atoi(yytext); return NUMBER; }
"+"                   return PLUS;
"-"                   return MINUS;
"*"                   return MULTIPLY;
"/"                   return DIVIDE;
"("                   return LPAREN;
")"                   return RPAREN;
.                     { printf("Caractere desconhecido: %s\n", yytext); }

%%

int yywrap(void) {
    return 1;
}