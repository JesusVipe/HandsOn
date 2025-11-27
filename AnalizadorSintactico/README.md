# Analizador Sintáctico para Subconjunto de C

## Integrante del Equipo
Jesus Vidrio Perez

## Descripción General
Este analizador sintáctico implementado con **Bison (Yacc)** valida la estructura gramatical de un subconjunto del lenguaje C, 
comprobando que las declaraciones, definiciones de funciones, bloques, sentencias, expresiones y llamadas a funciones sigan un orden correcto 
según las reglas definidas en el archivo `parser.y`.

El analizador trabaja en conjunto con el analizador léxico creado en Flex (`lexer.l`), el cual suministra los tokens utilizados por las producciones.  
Cada producción incluye una acción que imprime mensajes informativos, facilitando el seguimiento del proceso sintáctico.

---

# Producciones y Elementos Sintácticos Validados

A continuación se describen todas las reglas implementadas en el analizador sintáctico y qué validan.

---

Valida que un programa esté compuesto por:

Directivas #include (opcionales)

Declaraciones globales (opcionales)

Lista de funciones obligatoria

Al finalizar imprime: 
=== Analisis sintactico completado ===

--Seccion de Includes
includes:
      /* vacío */
    | includes INCLUDE
Permite cero o más líneas de #include <...>.
No imprime mensajes; solo valida la presencia correcta.

--Declaraciones Globales
global_list:
      /* vacío */
    | global_list global_decl
Permite múltiples declaraciones globales.

global_decl
type ID ';'

Imprime: 
Declaracion global;
type ID '=' expr ';'
Declaracion global con asignacion;

Valida:
Variables globales simples
Variables globales declaradas con inicialización

--Tipos Permitidos
type: INT
El único tipo permitido en esta versión del analizador es int.

--Definición de Funciones
function_list:
      function_def
    | function_list function_def
Permite una o varias funciones.

function_def:
      type ID '(' param_list_opt ')' block

Valida:
Tipo de retorno (int)
Nombre de función
Lista de parámetros (opcional)
Cuerpo de función encerrado en llaves { }

Imprime: Funcion;

--Parámetros de Función
param_list_opt:
      /* vacío */
    | param_list

param_list:
      param
    | param_list ',' param

param:
      type ID
      { printf("Parametro;\n"); }

Valida parámetros en forma: 
int x
int valor

--Bloques de Código
block:
      '{' local_decls stmt_list '}'

Valida el contenido de un bloque { ... }.
Imprime:
Bloque de codigo;

--Declaraciones locales
local_decls:
      /* vacío */
    | local_decls local_decl
type ID ';'

imprime:
Variable local;
type ID '=' expr ';'
Variable local con asignacion;

Valida:
Variables locales simples
Variables locales inicializadas

--Sentencias
stmt_list:
      /* vacío */
    | stmt_list stmt

ID '=' expr ';'

Imprime:
Asignacion;
RETURN expr ';'

Imprime:
Sentencia return;
func_call ';'

Imprime: 
Llamada a funcion como sentencia;
';'

Imprime:
Sentencia vacia;
block

Permite bloques anidados.

Valida sentencias como:
x = 5;
return x;
foo(a, b);
;

--Llamadas a función
func_call:
      ID '(' arg_list_opt ')'
Imprime:
Llamada a funcion;

arg_list_opt:
      /* vacío */
    | arg_list

arg_list:
      expr
    | arg_list ',' expr

Valida llamadas como:
foo();
foo(a);
foo(a, b + c);

--Expresiones Aritmeticas
expr:
      expr '+' expr
    | expr '*' expr
    | NUMBER
    | ID
    | func_call

Valida expresiones de:

Suma
Multiplicación
Números
Identificadores
Llamadas a función dentro de expresiones

Ejemplos válidos:

a + b
x * 5
3 + foo(a)

##Instrucciones de Compilación y Ejecución
Generar el analizador

win_bison -d parser.y
win_flex lexer.l
gcc parser.tab.c lex.yy.c -o parser.exe

Ejecutar
parser.exe input.c

Ejemplo de Salida:
Iniciando analisis sintactico...
Parametro;
Variable local;
Asignacion;
Sentencia return;
Funcion;
Analisis sintactico finalizado sin errores.

##Notas Finales
Este analizador sintáctico valida correctamente estructuras básicas del lenguaje C, permitiendo trabajar con funciones, variables globales, variables locales, bloques, expresiones aritméticas y llamadas a funciones.
Está diseñado como un analizador educativo y puede extenderse fácilmente para soportar más características del lenguaje.
