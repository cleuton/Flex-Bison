%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *s);
int yylex(void);
%}

%token NUMBER
%token PLUS MINUS MULTIPLY DIVIDE
%token LPAREN RPAREN

%left PLUS MINUS
%left MULTIPLY DIVIDE
%nonassoc UMINUS

%start expression

%%

expression:
      expression PLUS expression      { printf("%d + %d = %d\n", $1, $3, $1 + $3); $$ = $1 + $3; }
    | expression MINUS expression     { printf("%d - %d = %d\n", $1, $3, $1 - $3); $$ = $1 - $3; }
    | expression MULTIPLY expression  { printf("%d * %d = %d\n", $1, $3, $1 * $3); $$ = $1 * $3; }
    | expression DIVIDE expression    { 
        if ($3 == 0) {
            yyerror("Divisão por zero!");
            exit(1);
        }
        printf("%d / %d = %d\n", $1, $3, $1 / $3); 
        $$ = $1 / $3;
      }
    | LPAREN expression RPAREN         { $$ = $2; }
    | MINUS expression %prec UMINUS   { $$ = -$2; }
    | NUMBER                           { $$ = $1; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    printf("Digite uma expressão aritmética:\n");
    yyparse();
    return 0;
}
