%{
#include <stdio.h>
#include <stdlib.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;
%}

/* Tokens sin valores semanticos */
%token INCLUDE INT RETURN ID NUMBER

%%

/* programa = includes opcionales + declaraciones globales + funciones */
program:
      includes global_list function_list
    {
        printf("=== Analisis sintactico completado ===\n");
    }
    ;

/* lineas de include (opcionales) */
includes:
      /* vacio */
    | includes INCLUDE
    ;

/* declaraciones globales */
global_list:
      /* vacio */
    | global_list global_decl
    ;

global_decl:
      type ID ';'
    {
        printf("Declaracion global;\n");
    }
    | type ID '=' expr ';'
    {
        printf("Declaracion global con asignacion;\n");
    }
    ;

/* lista de funciones */
function_list:
      function_def
    | function_list function_def
    ;

/* tipo base (solo int para simplificar) */
type:
      INT
    ;

/* definicion de funcion: int id ( params ) { ... } */
function_def:
      type ID '(' param_list_opt ')' block
    {
        printf("Funcion;\n");
    }
    ;

/* parametros de la funcion */
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
        printf("Parametro;\n");
    }
    ;

/* bloque con vars locales y sentencias */
block:
      '{' local_decls stmt_list '}'
    {
        printf("Bloque de codigo;\n");
    }
    ;

local_decls:
      /* vacio */
    | local_decls local_decl
    ;

local_decl:
      type ID ';'
    {
        printf("Variable local;\n");
    }
    | type ID '=' expr ';'
    {
        printf("Variable local con asignacion;\n");
    }
    ;

/* lista de sentencias */
stmt_list:
      /* vacio */
    | stmt_list stmt
    ;

/* sentencias (instrucciones) */
stmt:
      ID '=' expr ';'          /* asignacion */
    {
        printf("Asignacion;\n");
    }
    | RETURN expr ';'          /* return expr; */
    {
        printf("Sentencia return;\n");
    }
    | func_call ';'            /* llamada a funcion; */
    {
        printf("Llamada a funcion como sentencia;\n");
    }
    | ';'                      /* sentencia vacia */
    {
        printf("Sentencia vacia;\n");
    }
    | block                    /* bloque anidado */
    ;

/* llamada a funcion */
func_call:
      ID '(' arg_list_opt ')'
    {
        printf("Llamada a funcion;\n");
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

/* expresiones aritmeticas: + y * */
expr:
      expr '+' expr
    | expr '*' expr
    | NUMBER
    | ID
    | func_call
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
    fprintf(stderr, "Error sintactico: %s\n", s);
}
