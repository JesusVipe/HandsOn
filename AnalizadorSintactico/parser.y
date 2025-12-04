/* parser.y */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;
extern int linea;   /* contador de lineas definido en lexer.l */
%}

/* ------------------------------
   VALORES SEMANTICOS
   ------------------------------ */
%union {
    int ival;     /* para NUMBER */
    char *str;    /* para ID */
}

/* ------------------------------
   TOKENS (deben coincidir con lexer.l)
   ------------------------------ */
%token INCLUDE
%token DEFINE

%token INT FLOAT DOUBLE CHAR VOID SHORT
%token RETURN

%token IF ELSE
%token INCREMENT

%token <str> ID
%token <ival> NUMBER

/* Precedencia de operadores */
%left '+' '-'
%left '*' '/'

%type <ival> expr

%%

/* programa = lineas de preprocesador + globales + funciones */
program:
      preprocessor_opt global_list function_list
    {
        printf("=== Analisis sintactico completado ===\n");
    }
    ;

/* lineas de preprocesador: includes y defines (opcionales) */
preprocessor_opt:
      /* vacio */
    | preprocessor_opt preprocessor_line
    ;

/* Aqui usamos los tokens que realmente produce tu lexer:
   '#' INCLUDE '<' ID '.' ID '>' para #include <stdlib.h>
   '#' DEFINE ID NUMBER        para #define SCALE_FACTOR 2
*/
preprocessor_line:
      '#' INCLUDE '<' ID '.' ID '>'
        { printf("Include: <%s.%s>\n", $4, $6); }
    | '#' INCLUDE '<' ID '>'
        { printf("Include: <%s>\n", $4); }
    | '#' DEFINE ID NUMBER
        { printf("Define: %s = %d\n", $3, $4); }
    | '#' DEFINE ID
        { printf("Define: %s\n", $3); }
    ;

/* declaraciones globales (opcionales) */
global_list:
      /* vacio */
    | global_list global_decl
    ;

global_decl:
      type ID ';'
    {
        printf("Declaracion global: %s\n", $2);
    }
    ;

/* tipos de dato */
type:
      INT
    | FLOAT
    | DOUBLE
    | CHAR
    | VOID
    | SHORT
    ;

/* lista de funciones (al menos 1) */
function_list:
      function_def
    | function_list function_def
    ;

/* definicion de funcion: tipo id (parametros) { ... } */
function_def:
      type ID '(' param_list_opt ')' block
    {
        printf("Funcion: %s\n", $2);
    }
    ;

/* parametros */
param_list_opt:
      /* vacio */
    | param_list
    ;

param_list:
      param
    | param_list ',' param
    ;

param:
      type ID
    {
        printf("Parametro: %s\n", $2);
    }
    ;

/* bloque con declaraciones locales y sentencias */
block:
      '{' local_decls stmt_list '}'
    {
        printf("Bloque de codigo\n");
    }
    ;

local_decls:
      /* vacio */
    | local_decls local_decl
    ;

local_decl:
      type ID ';'
    {
        printf("Variable local: %s\n", $2);
    }
    | type ID '=' expr ';'
    {
        printf("Variable local con asignacion: %s\n", $2);
    }
    ;

/* lista de sentencias */
stmt_list:
      /* vacio */
    | stmt_list stmt
    ;

/* sentencias */
stmt:
      ID '=' expr ';'
    {
        printf("Asignacion a %s\n", $1);
    }
    | RETURN expr ';'
    {
        printf("Sentencia return\n");
    }
    | expr ';'
    {
        /* Sentencia de expresion, por ejemplo print(expr); */
        printf("Sentencia de expresion\n");
    }
    | ';'
    {
        printf("Sentencia vacia\n");
    }
    | block
    ;

/* llamada a funcion */
func_call:
      ID '(' arg_list_opt ')'
    {
        printf("Llamada a funcion: %s\n", $1);
    }
    ;

arg_list_opt:
      /* vacio */
    | arg_list
    ;

arg_list:
      expr
    | arg_list ',' expr
    ;

/* expresiones aritmeticas con precedencia */
expr:
      expr '+' expr   { $$ = $1 + $3; }
    | expr '-' expr   { $$ = $1 - $3; }
    | expr '*' expr   { $$ = $1 * $3; }
    | expr '/' expr   { $$ = $1 / $3; }
    | NUMBER          { $$ = $1; }
    | ID              { $$ = 0; }
    | func_call       { $$ = 0; }
    | '(' expr ')'    { $$ = $2; }
    ;

%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("No se pudo abrir el archivo");
            return 1;
        }
    }

    printf("Iniciando analisis sintactico...\n");

    if (yyparse() == 0) {
        printf("Analisis sintactico finalizado sin errores.\n");
    } else {
        printf("Analisis sintactico con errores.\n");
    }

    if (yyin) fclose(yyin);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico en linea %d: %s\n", linea, s);
}
