%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;

/* Tipos de simbolos */
typedef enum { SYM_VAR, SYM_FUNC } SymKind;

typedef struct Symbol {
    char *name;
    SymKind kind;
    int param_count;        /* solo para funciones */
    struct Symbol *next;
} Symbol;

typedef struct Scope {
    Symbol *symbols;
    struct Scope *parent;
} Scope;

Scope *current_scope = NULL;
Symbol *current_function = NULL;
int semantic_errors = 0;

/* Prototipos */
void init_scopes(void);
void enter_scope(void);
void leave_scope(void);
Symbol* lookup_symbol(const char *name);
Symbol* lookup_symbol_current(const char *name);
Symbol* add_symbol(const char *name, SymKind kind);
void declare_variable(const char *name);
Symbol* declare_function(const char *name);
void declare_param(const char *name);
void check_var_use(const char *name);
void check_function_call(const char *name, int arg_count);
void semantic_error(const char *msg, const char *name);
%}

/* Valores semanticos */
%union {
    char* str;
    int   num;
}

/* Tokens */
%token INCLUDE INT RETURN
%token <str> ID
%token <num> NUMBER

/* Tipos de no terminales */
%type <str> type
%type <num> arg_list_opt arg_list

%%

/* programa = includes + declaraciones globales + funciones */
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
        declare_variable($2);
        printf("Declaracion global;\n");
    }
    | type ID '=' expr ';'
    {
        declare_variable($2);
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
      INT         { $$ = "int"; }
    ;

/* definicion de funcion: int id ( params ) { ... } */
function_def:
      type ID '('
        {
            /* Declarar funcion en el scope global y abrir scope nuevo para su cuerpo */
            current_function = declare_function($2);
            enter_scope();
        }
      param_list_opt ')' block
        {
            /* cerrar scope de la funcion */
            current_function = NULL;
            leave_scope();
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
        declare_param($2);
        printf("Parametro;\n");
    }
    ;

/* bloque con vars locales e instrucciones */
block:
      '{' 
        {
            /* nuevo scope para el bloque */
            enter_scope();
        }
      local_decls stmt_list '}'
        {
            leave_scope();
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
        declare_variable($2);
        printf("Variable local;\n");
    }
    | type ID '=' expr ';'
    {
        declare_variable($2);
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
      ID '=' expr ';'
    {
        check_var_use($1);
        printf("Asignacion;\n");
    }
    | RETURN expr ';'
    {
        printf("Sentencia return;\n");
    }
    | func_call ';'
    {
        printf("Llamada a funcion como sentencia;\n");
    }
    | ';'
    {
        printf("Sentencia vacia;\n");
    }
    | block
    ;

/* llamada a funcion */
func_call:
      ID '(' arg_list_opt ')'
    {
        check_function_call($1, $3);
        printf("Llamada a funcion;\n");
    }
    ;

arg_list_opt:
      /* vacio */        { $$ = 0; }
    | arg_list
    ;

arg_list:
      expr               { $$ = 1; }
    | arg_list ',' expr  { $$ = $1 + 1; }
    ;

/* expresiones aritmeticas: + y * */
expr:
      expr '+' expr
    | expr '*' expr
    | NUMBER
    | ID
        {
            check_var_use($1);
        }
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

    printf("Iniciando analisis sintactico y semantico...\n");

    init_scopes();

    if (yyparse() == 0) {
        if (semantic_errors == 0) {
            printf("Analisis sintactico y semantico finalizado sin errores.\n");
        } else {
            printf("Analisis sintactico correcto, pero se encontraron %d errores semanticos.\n",
                   semantic_errors);
        }
    } else {
        printf("Analisis sintactico con errores.\n");
    }

    if (yyin) fclose(yyin);
    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error sintactico: %s\n", s);
}

/* ========= Implementacion de tabla de simbolos y scopes ========= */

void semantic_error(const char *msg, const char *name) {
    fprintf(stderr, "Error semantico: %s '%s'\n", msg, name);
    semantic_errors++;
}

void init_scopes(void) {
    current_scope = (Scope*)malloc(sizeof(Scope));
    current_scope->symbols = NULL;
    current_scope->parent = NULL;

    /* Funcion builtin: print(x) para evitar error por no declararla */
    Symbol *s = add_symbol("print", SYM_FUNC);
    if (s) s->param_count = 1;
}

void enter_scope(void) {
    Scope *s = (Scope*)malloc(sizeof(Scope));
    s->symbols = NULL;
    s->parent = current_scope;
    current_scope = s;
}

void leave_scope(void) {
    if (!current_scope) return;
    Scope *s = current_scope;
    current_scope = current_scope->parent;
    /* Nota: por simplicidad no liberamos todos los Symbol* aqui */
    free(s);
}

Symbol* lookup_symbol_current(const char *name) {
    if (!current_scope) return NULL;
    Symbol *sym = current_scope->symbols;
    while (sym) {
        if (strcmp(sym->name, name) == 0)
            return sym;
        sym = sym->next;
    }
    return NULL;
}

Symbol* lookup_symbol(const char *name) {
    Scope *scope = current_scope;
    while (scope) {
        Symbol *sym = scope->symbols;
        while (sym) {
            if (strcmp(sym->name, name) == 0)
                return sym;
            sym = sym->next;
        }
        scope = scope->parent;
    }
    return NULL;
}

Symbol* add_symbol(const char *name, SymKind kind) {
    if (!current_scope) return NULL;

    /* redeclaracion en el mismo scope */
    Symbol *exists = lookup_symbol_current(name);
    if (exists) {
        semantic_error("redeclaracion de identificador", name);
        return exists;
    }

    Symbol *sym = (Symbol*)malloc(sizeof(Symbol));
    sym->name = strdup(name);
    sym->kind = kind;
    sym->param_count = 0;
    sym->next = current_scope->symbols;
    current_scope->symbols = sym;
    return sym;
}

void declare_variable(const char *name) {
    add_symbol(name, SYM_VAR);
}

Symbol* declare_function(const char *name) {
    return add_symbol(name, SYM_FUNC);
}

void declare_param(const char *name) {
    Symbol *sym = add_symbol(name, SYM_VAR);
    if (current_function && sym) {
        current_function->param_count++;
    }
}

void check_var_use(const char *name) {
    Symbol *sym = lookup_symbol(name);
    if (!sym) {
        semantic_error("uso de variable no declarada", name);
    } else if (sym->kind != SYM_VAR) {
        semantic_error("identificador no es una variable", name);
    }
}

void check_function_call(const char *name, int arg_count) {
    Symbol *sym = lookup_symbol(name);
    if (!sym) {
        semantic_error("llamada a funcion no declarada", name);
        return;
    }
    if (sym->kind != SYM_FUNC) {
        semantic_error("identificador no es una funcion", name);
        return;
    }
    if (sym->param_count != arg_count) {
        semantic_error("numero de argumentos incorrecto en llamada a funcion", name);
    }
}
