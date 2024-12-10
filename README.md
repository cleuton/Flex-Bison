![](giga.png)

# Cozinhando uma DSL à moda antiga: FLEX / BISON

[**Cleuton Sampaio**](https://linkedin.com/in/cleutonsampaio) - Me siga 

[**Rusting Crab**](https://rustingcrab.com) - Veja nosso repo de tecnologia **Rust**

[**Canal**](https://www.youtube.com/@CleutonSampaio) - Se inscreva no meu canal

O desenvolvimento de compiladores e interpretadores é uma tarefa complesa. Porém, existem ferramentas muito úteis para ajudar no processo, como o [**FLEX**](https://github.com/westes/flex) e o [**BISON**](https://www.gnu.org/software/bison/manual/bison.html).

## Flex

Foi desenvolvido por Vern Paxson em 1987, em linguagem C e é uma versão melhor do **Lex** (https://minnie.tuhs.org/cgi-bin/utree.pl?file=4BSD/usr/src/cmd/lex), sendo muito mais veloz que ele.

O Flex é uma ferramenta para gerar analisadores léxicos. Nele, são definidas regras para o reconhecimento de tokens da sua linguagem.

Essas regras são especificadas através de expressões regulares, com uma expressão para cada token. O Flex gera um programa em C chamado "lex.yy.c", que é o analisador léxico correspondente às regras descritas.

> O que é um **analisador léxico**? Em teoria dos compiladores, o analisador léxico, ou lexer, é a primeira fase do processo de compilação, responsável por transformar o código-fonte em uma sequência de tokens, que são unidades léxicas significativas, como palavras-chave, identificadores, números e operadores. Ele lê o código caractere por caractere, identifica padrões definidos por expressões regulares e agrupa esses caracteres em tokens, descartando espaços em branco, comentários e outros elementos irrelevantes. Além disso, o analisador léxico detecta erros léxicos e transmite os tokens para o analisador sintático, que realizará a próxima etapa do processo de compilação.

## BISON

**GNU Bison**, chamado apenas de **Bison**, é uma ferramenta que gera analisadores sintáticos para linguagens como C, C++ e Java. Desenvolvido por Robert Corbett em 1988, foi posteriormente aprimorado por Richard Stallman para ser compatível com o **yacc** (https://invisible-mirror.net/archives/byacc/), outra ferramenta de geração de analisadores sintáticos.

Bison processa gramáticas escritas na notação de **Backus-Naur**. Normalmente, a definição dos tokens é feita no analisador léxico, mas no caso do Bison, essa tarefa é invertida; os tokens devem ser definidos no próprio Bison.

A ferramenta gera o código-fonte do analisador sintático, que pode ser integrado a outros programas.

> A notação de Backus-Naur (**BNF**) é uma maneira formal de representar a sintaxe de linguagens de programação e linguagens formais em geral. Ela descreve as regras gramaticais por meio de produções que utilizam símbolos não-terminais (variáveis) e terminais (tokens literais). Cada produção define como um símbolo não-terminal pode ser expandido em uma sequência de símbolos terminais e/ou não-terminais. A BNF é amplamente utilizada em compiladores, linguagens formais e sistemas que dependem de definições sintáticas rigorosas, sendo a base de ferramentas como o Yacc e o Bison.

## Processo de interpretação de linguagens

![](fluxo%20interpretação.png)

O processo de interpretação (o de compilação tem o passo de gerar o código nativo) pode ser entendido desta maneira: 

1. **Lexer**: Transforma o código-fonte em tokens.
2. **Parser**: Organiza os tokens em uma AST.
3. **Interpreter**: Executa a AST, gerando resultados.

A entrada para o **Lexer** (analisador léxico) são linhas de texto com os caracteres dos comandos. Eles precisam ser transformados em algo mais "processável", como uma lista de tokens, o que é feito pelo Lexer, que gera tokens no formato esperado pelo **Parser**.

A entrada para o **Parser** (analisador sintático) é um vetor de **Tokens** gerados pelo Lexer. Ele analisa e cria uma árvore de sintaxe abstrata, ou **AST** contendo cada conjunto de tokens representados como uma árvore para execução. 

O **Interpreter** (interpretador) lê a **AST** e executa cada árvore. 

## Como podemos usar o Flex e o Bison para criar uma linguagem

Vou fornecer um exemplo simples de uma **Linguagem DSL** (Domain Specific Language) que interpreta expressões aritméticas básicas (adição, subtração, multiplicação e divisão) e que pode ser analisada usando **FLEX** e **BISON**.

### 1. Definição da DSL

Nossa DSL interpretará e executará expressões aritméticas como esta:

```
3 + 4 * (2 - 1)
```

### 2. Arquivo FLEX (`lexer.l`)

O começo de tudo é criarmos um **Lexer** e o **Flex** vai criar esse código em "C" para nós. A entrada para o **Flex** é um arquivo de definição léxica, geralmente com a extensão `.l`, que descreve padrões de texto e ações a serem executadas quando esses padrões são encontrados. O arquivo é dividido em três seções: **definições**, onde macros e cabeçalhos podem ser incluídos; **regras**, que mapeiam expressões regulares para ações em C; e **código do usuário**, que pode conter funções adicionais usadas nas ações.

Por exemplo, uma regra pode identificar números com `[0-9]+` e associar a ação de imprimir "Número encontrado". O Flex gera um analisador léxico em C que processa o texto de entrada com base nessas definições.

O FLEX será responsável por reconhecer os elementos da linguagem, como números, operadores e parênteses e gerar **Tokens** que possam ser processados pelo **Parser** criado pelo **Bison**, portanto, ele vai precisar do arquivo `parser.tab.h` gerado pelo Bison. Eis nosso arquivo de definição léxica: 

```flex
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
```

### 3. Arquivo BISON (`parser.y`)

Vamos utilizar o **Bison** para criar um **Parser** em "C" para nós. A entrada para o **Bison** é um arquivo de definição gramatical, geralmente com a extensão `.y`, que descreve as regras de gramática de uma linguagem e as ações associadas a elas. Esse arquivo é dividido em três seções: **declarações**, **regras** e **código auxiliar**, separadas por `%%`.

Na seção de declarações, você define tokens (como palavras-chave ou operadores) e os tipos de dados associados às produções gramaticais. Na seção de regras, as produções da gramática são escritas, especificando como os tokens e símbolos não-terminais se combinam. Cada produção pode ter ações em C associadas, como a construção de uma árvore sintática ou cálculos.

O BISON definirá a gramática da linguagem e como os tokens se combinam para formar expressões válidas e vai criar uma **AST**. Eis nosso arquivo de definição gramatical: 

```bison
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
      expression PLUS expression      { printf("%d + %d = %d\n", $1, $3, $1 + $3); }
    | expression MINUS expression     { printf("%d - %d = %d\n", $1, $3, $1 - $3); }
    | expression MULTIPLY expression  { printf("%d * %d = %d\n", $1, $3, $1 * $3); }
    | expression DIVIDE expression    { 
        if ($3 == 0) {
            yyerror("Divisão por zero!");
            exit(1);
        }
        printf("%d / %d = %d\n", $1, $3, $1 / $3); 
      }
    | LPAREN expression RPAREN         { $$ = $2; }
    | MINUS expression %prec UMINUS   { $$ = -$2; }
    | NUMBER                           { $$ = $1; }
    ;

%%

#include "lexer.l"

void yyerror(const char *s) {
    fprintf(stderr, "Erro: %s\n", s);
}

int main(void) {
    printf("Digite uma expressão aritmética:\n");
    yyparse();
    return 0;
}
```

### 4. Compilando e Executando

Para compilar e executar o analisador, siga os seguintes passos:

1. **Instale o FLEX e o BISON** se ainda não estiverem instalados. Em sistemas baseados em Debian, você pode usar:

    ```bash
    sudo apt-get install flex bison
    ```

2. **Salve os arquivos** `lexer.l` e `parser.y`.

3. **Compile o BISON** para gerar o arquivo de parser:

    ```bash
    bison -d parser.y
    ```

    Isso gerará `parser.tab.c` e `parser.tab.h`.

4. **Compile o FLEX** para gerar o arquivo de lexer:

    ```bash
    flex lexer.l
    ```

    Isso gerará `lex.yy.c`.

5. **Compile os arquivos gerados com o GCC**:

    ```bash
    gcc -o parser parser.tab.c lex.yy.c -lfl
    ```

    Compilamos a saída do **Flex** (`lex.yy.c`) junto com a saída do **Bison** (`parser.tab.c`) para criar um analisador/executor completo. 

6. **Execute o analisador**:

    ```bash
    ./parser
    ```

    **Exemplo de uso:**

    ```
    Digite uma expressão aritmética:
    3 + 4 * (2 - 1)
    2 - 1 = 1
    4 * 1 = 4
    3 + 4 = 7
    ```

### 5. Explicação

- **FLEX (`lexer.l`)**:
    - Ignora espaços em branco.
    - Reconhece números e operadores aritméticos.
    - Retorna tokens correspondentes para o BISON.

- **BISON (`parser.y`)**:
    - Define a gramática para expressões aritméticas.
    - Implementa ações para cada regra que calculam e exibem o resultado intermediário.
    - Trata a precedência e associatividade dos operadores.
    - Lida com erros, como divisão por zero.

Este exemplo fornece uma base simples para criar um analisador sintático usando FLEX e BISON para uma linguagem **DSL** específica. Você pode expandir essa linguagem adicionando mais funcionalidades conforme necessário.