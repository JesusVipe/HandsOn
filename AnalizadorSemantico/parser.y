/* parser.y - Analizador sintactico + semantico con scopes y estructuras de control */
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);
extern FILE *yyin;
extern int linea;   /* contador de lineas definido en lexer.l */

/* ============================
   TIPOS Y TABLA DE SIMBOLOS
   ============================ */

/* tipos semanticos como enteros */
enum {
    TYPE_INT = 1,
    TYPE_FLOAT,
    TYPE_DOUBLE,
    TYPE_CHAR,
    TYPE_VOID,
    TYPE_UNKNOWN
};

/* clase de simbolo */
enum {
    SYM_VAR = 1,
    SYM_FUNC
};

typedef struct Symbol {
    char      *name;
    int        kind;        /* SYM_VAR o SYM_FUNC */
    int        type;        /* uno de TYPE_* */
    int        param_count; /* solo para funciones */
    struct Symbol *next;
} Symbol;

/* Scope (ambito): lista de simbolos + padre */
typedef struct Scope {
    Symbol *symbols;
    struct Scope *parent;
} Scope;

/* Puntero al scope actual (pila de scopes encadenada) */
Scope *current_scope = NULL;

/* funcion actual (para guardar param_count) */
Symbol *current_function = NULL;

/* ultimo numero de parametros visto (para funciones) */
int last_param_count = 0;

int  semantic_errors = 0;

/* prototipos */
void    init_scopes(void);
void    enter_scope(void);
void    leave_scope(void);
Symbol *lookup_symbol(const char *name);          /* busca en todos los scopes */
Symbol *lookup_symbol_current(const char *name);  /* busca solo en scope actual */
Symbol *add_symbol(const char *name, int kind, int type);
void    sem_error(const char *msg, const char *id);

%}

/* ------------------------------
   VALORES SEMANTICOS
   ------------------------------ */
%union {
    int ival;        /* para NUMBER */
    char *str;       /* para ID */
    int ttype;       /* para tipos y expresiones (TYPE_*) */
    int nparams;     /* para contar parametros/argumentos */
}

/* ------------------------------
   TOKENS (deben coincidir con lexer.l)
   ------------------------------ */
%token INCLUDE
%token DEFINE

%token INT FLOAT DOUBLE CHAR VOID SHORT
%token RETURN

%token IF ELSE
%token FOR WHILE DO
%token INCREMENT

%token <str> ID
%token <ival> NUMBER

/* Precedencia de operadores aritmeticos */
%left '+' '-'
%left '*' '/'

/* Para resolver el "dangling else" */
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

/* Tipos semanticos de no terminales */
%type <ttype> expr type
%type <nparams> param_list param_list_opt param
%type <nparams> arg_list arg_list_opt

%%

/* programa = lineas de preprocesador + globales + funciones */
program:
      preprocessor_opt global_list function_list
    {
        printf("=== Analisis sintactico completado ===\n");
        if (semantic_errors == 0)
            printf("=== Analisis semantico: SIN ERRORES ===\n");
        else
            printf("=== Analisis semantico: %d error(es) ===\n", semantic_errors);
    }
    ;

/* lineas de preprocesador: includes y defines (opcionales) */
preprocessor_opt:
      /* vacio */
    | preprocessor_opt preprocessor_line
    ;

/* Directivas para include y define */
preprocessor_line:
      '#' INCLUDE '<' ID '.' ID '>'
        { printf("Include: <%s.%s>\n", $4, $6); }
    | '#' INCLUDE '<' ID '>'
        { printf("Include: <%s>\n", $4); }
    | '#' DEFINE ID NUMBER
        {
            printf("Define: %s = %d\n", $3, $4);
            /* tratamos #define ID NUM como constante entera global */
            if (lookup_symbol_current($3)) {
                sem_error("redeclaracion de constante/identificador", $3);
            } else {
                add_symbol($3, SYM_VAR, TYPE_INT);
            }
        }
    | '#' DEFINE ID
        {
            printf("Define: %s\n", $3);
            /* constante sin valor especifico */
            if (lookup_symbol_current($3)) {
                sem_error("redeclaracion de constante/identificador", $3);
            } else {
                add_symbol($3, SYM_VAR, TYPE_UNKNOWN);
            }
        }
    ;

/* declaraciones globales (opcionales) */
global_list:
      /* vacio */
    | global_list global_decl
    ;

global_decl:
      type ID ';'
    {
        /* redeclaracion solo si el nombre ya existe en el scope GLOBAL */
        if (lookup_symbol_current($2)) {
            sem_error("redeclaracion de variable global", $2);
        } else {
            add_symbol($2, SYM_VAR, $1);
        }
        printf("Declaracion global: %s\n", $2);
    }
    ;

/* tipos de dato */
type:
      INT    { $$ = TYPE_INT; }
    | FLOAT  { $$ = TYPE_FLOAT; }
    | DOUBLE { $$ = TYPE_DOUBLE; }
    | CHAR   { $$ = TYPE_CHAR; }
    | VOID   { $$ = TYPE_VOID; }
    | SHORT  { $$ = TYPE_INT; }   /* tratamos short como int */
    ;

/* lista de funciones (al menos 1) */
function_list:
      function_def
    | function_list function_def
    ;

/* definicion de funcion con manejo de scopes:
   - se declara la funcion en el scope global
   - se crea un scope para la funcion (parametros)
   - dentro del bloque se crea otro scope (variables locales y bloques anidados)
*/
function_def:
      type ID
      {
          /* estamos en scope global */
          Symbol *f = lookup_symbol_current($2);
          if (f) {
              if (f->kind == SYM_FUNC)
                  sem_error("redeclaracion de funcion", $2);
              else
                  sem_error("identificador ya usado como variable", $2);
          } else {
              f = add_symbol($2, SYM_FUNC, $1);
          }
          current_function = f;
      }
      '('
      {
          /* nuevo scope para parametros de la funcion */
          enter_scope();
          last_param_count = 0;
      }
      param_list_opt ')' block
    {
        if (current_function)
            current_function->param_count = last_param_count;

        /* al terminar el bloque, hemos regresado al scope de la funcion;
           ahora salimos del scope de la funcion */
        leave_scope();

        printf("Funcion: %s\n", $2);
        current_function = NULL;
    }
    ;

/* parametros */
param_list_opt:
      /* vacio */
    {
        $$ = 0;
        last_param_count = 0;
    }
    | param_list
    {
        $$ = $1;
        last_param_count = $1;
    }
    ;

param_list:
      param                { $$ = $1; }
    | param_list ',' param { $$ = $1 + $3; }
    ;

param:
      type ID
    {
        /* solo revisamos redeclaracion en el scope ACTUAL (de la funcion) */
        if (lookup_symbol_current($2)) {
            sem_error("redeclaracion de parametro/variable", $2);
        } else {
            add_symbol($2, SYM_VAR, $1);
        }
        printf("Parametro: %s\n", $2);
        $$ = 1;
    }
    ;

/* bloque con declaraciones locales y sentencias
   Cada bloque crea su propio scope (anidado).
*/
block:
      '{'
      {
          enter_scope();   /* nuevo scope para el bloque */
      }
      local_decls stmt_list
      '}'
    {
        printf("Bloque de codigo\n");
        leave_scope();     /* salir del scope del bloque */
    }
    ;

local_decls:
      /* vacio */
    | local_decls local_decl
    ;

local_decl:
      type ID ';'
    {
        /* redeclaracion solo en el scope actual (bloque o funcion) */
        if (lookup_symbol_current($2)) {
            sem_error("redeclaracion de variable local/local-global", $2);
        } else {
            add_symbol($2, SYM_VAR, $1);
        }
        printf("Variable local: %s\n", $2);
    }
    | type ID '=' expr ';'
    {
        if (lookup_symbol_current($2)) {
            sem_error("redeclaracion de variable local/local-global", $2);
        } else {
            Symbol *v = add_symbol($2, SYM_VAR, $1);
            if (v->type != $4 && $4 != TYPE_UNKNOWN) {
                printf("Advertencia semantica (linea %d): tipo incompatible en inicializacion de %s\n",
                       linea, $2);
            }
        }
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
        Symbol *v = lookup_symbol($1);
        if (!v) {
            sem_error("asignacion a variable no declarada", $1);
        } else if (v->kind != SYM_VAR) {
            sem_error("asignacion a identificador que no es variable", $1);
        } else if (v->type != $3 && $3 != TYPE_UNKNOWN) {
            printf("Advertencia semantica (linea %d): tipos distintos en asignacion a %s\n",
                   linea, $1);
        }
        printf("Asignacion a %s\n", $1);
    }
    | RETURN expr ';'
    {
        printf("Sentencia return\n");
    }
    | expr ';'
    {
        printf("Sentencia de expresion\n");
    }
    | ';'
    {
        printf("Sentencia vacia\n");
    }
    | block
    /* ====== ESTRUCTURAS SELECTIVAS ====== */
    | IF '(' expr ')' stmt  %prec LOWER_THAN_ELSE
    {
        if ($3 == TYPE_UNKNOWN) {
            printf("Advertencia semantica (linea %d): condicion de if con tipo desconocido\n",
                   linea);
        }
        printf("Sentencia if\n");
    }
    | IF '(' expr ')' stmt ELSE stmt
    {
        if ($3 == TYPE_UNKNOWN) {
            printf("Advertencia semantica (linea %d): condicion de if-else con tipo desconocido\n",
                   linea);
        }
        printf("Sentencia if-else\n");
    }
    /* ====== ESTRUCTURAS ITERATIVAS ====== */
    | WHILE '(' expr ')' stmt
    {
        if ($3 == TYPE_UNKNOWN) {
            printf("Advertencia semantica (linea %d): condicion de while con tipo desconocido\n",
                   linea);
        }
        printf("Sentencia while\n");
    }
    | DO stmt WHILE '(' expr ')' ';'
    {
        if ($5 == TYPE_UNKNOWN) {
            printf("Advertencia semantica (linea %d): condicion de do-while con tipo desconocido\n",
                   linea);
        }
        printf("Sentencia do-while\n");
    }
    | FOR '(' for_init_opt ';' for_cond_opt ';' for_iter_opt ')' stmt
    {
        printf("Sentencia for\n");
    }
    ;

/* inicializacion del for: solo una asignacion simple opcional */
for_init_opt:
      /* vacio */
    | ID '=' expr
    {
        Symbol *v = lookup_symbol($1);
        if (!v) {
            sem_error("asignacion en for a variable no declarada", $1);
        } else if (v->kind != SYM_VAR) {
            sem_error("asignacion en for a identificador que no es variable", $1);
        } else if (v->type != $3 && $3 != TYPE_UNKNOWN) {
            printf("Advertencia semantica (linea %d): tipos distintos en asignacion en for a %s\n",
                   linea, $1);
        }
    }
    ;

/* condicion del for: una expresion opcional */
for_cond_opt:
      /* vacio */
    | expr
    {
        if ($1 == TYPE_UNKNOWN) {
            printf("Advertencia semantica (linea %d): condicion de for con tipo desconocido\n",
                   linea);
        }
    }
    ;

/* actualizacion del for: asignacion o incremento opcional */
for_iter_opt:
      /* vacio */
    | ID '=' expr
    {
        Symbol *v = lookup_symbol($1);
        if (!v) {
            sem_error("asignacion en iteracion de for a variable no declarada", $1);
        } else if (v->kind != SYM_VAR) {
            sem_error("asignacion en iteracion de for a identificador que no es variable", $1);
        } else if (v->type != $3 && $3 != TYPE_UNKNOWN) {
            printf("Advertencia semantica (linea %d): tipos distintos en asignacion en for a %s\n",
                   linea, $1);
        }
    }
    | ID INCREMENT
    {
        Symbol *v = lookup_symbol($1);
        if (!v) {
            sem_error("incremento en for de variable no declarada", $1);
        } else if (v->kind != SYM_VAR) {
            sem_error("incremento en for de identificador que no es variable", $1);
        }
    }
    ;

/* llamada a funcion */
func_call:
      ID '(' arg_list_opt ')'
    {
        Symbol *f = lookup_symbol($1);
        if (!f) {
            sem_error("llamada a funcion no declarada", $1);
        } else if (f->kind != SYM_FUNC) {
            sem_error("identificador llamado como funcion pero no es funcion", $1);
        } else if (f->param_count != $3) {
            printf("Error semantico (linea %d): numero incorrecto de parametros en %s (esperado %d, recibido %d)\n",
                   linea, $1, f->param_count, $3);
            semantic_errors++;
        }
        printf("Llamada a funcion: %s\n", $1);
        /* asumimos que las funciones devuelven int */
    }
    ;

arg_list_opt:
      /* vacio */  { $$ = 0; }
    | arg_list     { $$ = $1; }
    ;

arg_list:
      expr               { $$ = 1; }
    | arg_list ',' expr  { $$ = $1 + 1; }
    ;

/* expresiones aritmeticas con precedencia */
expr:
      expr '+' expr
    {
        if ($1 != $3 && $1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            printf("Error semantico (linea %d): tipos incompatibles en suma\n", linea);
            semantic_errors++;
        }
        $$ = ($1 != TYPE_UNKNOWN) ? $1 : $3;
    }
    | expr '-' expr
    {
        if ($1 != $3 && $1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            printf("Error semantico (linea %d): tipos incompatibles en resta\n", linea);
            semantic_errors++;
        }
        $$ = ($1 != TYPE_UNKNOWN) ? $1 : $3;
    }
    | expr '*' expr
    {
        if ($1 != $3 && $1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            printf("Error semantico (linea %d): tipos incompatibles en multiplicacion\n", linea);
            semantic_errors++;
        }
        $$ = ($1 != TYPE_UNKNOWN) ? $1 : $3;
    }
    | expr '/' expr
    {
        if ($1 != $3 && $1 != TYPE_UNKNOWN && $3 != TYPE_UNKNOWN) {
            printf("Error semantico (linea %d): tipos incompatibles en division\n", linea);
            semantic_errors++;
        }
        $$ = ($1 != TYPE_UNKNOWN) ? $1 : $3;
    }
    | NUMBER
    {
        $$ = TYPE_INT;   /* constantes numericas como int */
    }
    | ID
    {
        Symbol *s = lookup_symbol($1);
        if (!s) {
            sem_error("uso de identificador no declarado", $1);
            $$ = TYPE_UNKNOWN;
        } else {
            $$ = s->type;
        }
    }
    | func_call
    {
        $$ = TYPE_INT;   /* asumimos retorno int */
    }
    | '(' expr ')'
    {
        $$ = $2;
    }
    ;

%%

/* ============================
   IMPLEMENTACION FUNCIONES C
   ============================ */

void init_scopes(void) {
    /* creamos scope global */
    current_scope = (Scope*)malloc(sizeof(Scope));
    current_scope->symbols = NULL;
    current_scope->parent  = NULL;
}

void enter_scope(void) {
    Scope *s = (Scope*)malloc(sizeof(Scope));
    s->symbols = NULL;
    s->parent  = current_scope;
    current_scope = s;
}

void leave_scope(void) {
    if (current_scope == NULL) return;
    Scope *old = current_scope;
    current_scope = current_scope->parent;
    (void)old; /* para esta practica no liberamos memoria */
}

/* busca un simbolo en el scope actual y sus padres */
Symbol *lookup_symbol(const char *name) {
    Scope *sc = current_scope;
    while (sc) {
        Symbol *s = sc->symbols;
        while (s) {
            if (strcmp(s->name, name) == 0)
                return s;
            s = s->next;
        }
        sc = sc->parent;
    }
    return NULL;
}

/* busca un simbolo SOLO en el scope actual */
Symbol *lookup_symbol_current(const char *name) {
    if (!current_scope) return NULL;
    Symbol *s = current_scope->symbols;
    while (s) {
        if (strcmp(s->name, name) == 0)
            return s;
        s = s->next;
    }
    return NULL;
}

/* agrega simbolo al scope actual */
Symbol *add_symbol(const char *name, int kind, int type) {
    if (!current_scope) {
        fprintf(stderr, "Error interno: no hay scope actual para agregar simbolos.\n");
        exit(1);
    }
    Symbol *s = (Symbol*)malloc(sizeof(Symbol));
    s->name = strdup(name);
    s->kind = kind;
    s->type = type;
    s->param_count = 0;
    s->next = current_scope->symbols;
    current_scope->symbols = s;
    return s;
}

void sem_error(const char *msg, const char *id) {
    if (id)
        printf("Error semantico (linea %d): %s '%s'\n", linea, msg, id);
    else
        printf("Error semantico (linea %d): %s\n", linea, msg);
    semantic_errors++;
}

int main(int argc, char *argv[]) {
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("No se pudo abrir el archivo");
            return 1;
        }
    }

    /* inicializar scopes (crea scope global) */
    init_scopes();

    /* registrar funcion builtin 'print(int)' para que input.c no marque error */
    Symbol *builtin_print = add_symbol("print", SYM_FUNC, TYPE_INT);
    builtin_print->param_count = 1;

    printf("Iniciando analisis sintactico + semantico...\n");

    if (yyparse() == 0) {
        printf("Analisis sintactico finalizado sin errores.\n");
    } else {
        printf("Analisis sintactico con errores.\n");
    }

    if (yyin) fclose(yyin);
    return 0;
}

void yyerror(const char *s) {
    printf("Error sintactico en linea %d: %s\n", linea, s);
}
