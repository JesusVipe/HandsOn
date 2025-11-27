# Analizador Semántico para Subconjunto de C

## Integrante del Equipo
Jesus Vidrio Perez

## Descripción General
Este analizador semántico implementado con **Bison + Flex** extiende el trabajo del analizador sintáctico, incorporando ahora:

- Manejo de **tabla de símbolos**
- Soporte para **ámbitos (scopes)** anidados
- Validación semántica de:
  - Declaraciones de variables
  - Declaraciones de funciones
  - Parámetros
  - Uso correcto de identificadores
  - Correspondencia de argumentos en llamadas a funciones
  - Detección de redeclaraciones
  - Detección de variables no declaradas
  - Detección de funciones no declaradas
  - Coincidencia entre número de parámetros y argumentos

El sistema verifica el significado del programa más allá de su forma, asegurando que el código fuente analizado tenga coherencia semántica y un correcto uso de identificadores.

---

# Alcances del Análisis Semántico

El analizador semántico implementa un **conjunto de validaciones** basado en reglas formales del lenguaje C. A continuación se describen todas las funcionalidades y mecanismos incluidos.

---

# 1. Sistema de Tabla de Símbolos

Cada símbolo registrado contiene:

```c
typedef struct Symbol {
    char *name;
    SymKind kind;        // SYM_VAR o SYM_FUNC
    int param_count;     // número de parámetros si es función
    struct Symbol *next;
} Symbol;
```
Tipos manejados:
SYM_VAR → Variables
SYM_FUNC → Funciones

La tabla de símbolos se administra por listas enlazadas en cada ámbito.

--Manejo de Ámbitos (Scopes)

El lenguaje soporta:
Ámbito global
Ámbitos de funciones
Ámbitos de bloques internos {}

Cada ámbito apunta a su padre:
typedef struct Scope {
    Symbol *symbols;
    struct Scope *parent;
} Scope;

Se administra mediante:
enter_scope(); → Abre un nuevo ámbito
leave_scope(); → Cierra el ámbito actual
lookup_symbol() → Busca en todos los ámbitos
lookup_symbol_current() → Busca solo en el ámbito actual


--Declaración de Variables
Reglas verificadas:

No se permite redeclarar una variable en el mismo ámbito
Variables deben declararse antes de usarse
Se registran como SYM_VAR

Ejemplos válidos:
int x;
int y = 5;

Errores detectados:
Error semantico: redeclaracion de identificador 'x'
Error semantico: uso de variable no declarada 'z'

--Declaración de Funciones

Las funciones se registran como SYM_FUNC.
El analizador valida:

El nombre no esté redeclarado
Se registren antes de su uso
Se almacene su número de parámetros
Se abra un ámbito propio para su cuerpo

También se declara una función builtin:
print(x);

para evitar errores semánticos al analizar el código.

--Manejo de Parámetros

Los parámetros de función:
Son tratados como variables dentro del ámbito de la función
Aumentan el param_count de la función actual
Se verifican para evitar redeclaraciones

Ejemplo válidos
int add(int a, int b)
Mensajes generados:
Parametro;

--Validación de Uso de Variables
En las reglas de expresiones y asignaciones:
ID
{
    check_var_use($1);
}

La validación consiste en:

Verificar que la variable exista
Asegurar que el identificador no corresponde a una función

Errores detectados:
Error semantico: uso de variable no declarada 'valueX'
Error semantico: identificador no es una variable 'addValues'

--Validación de llamadas a función
Regla:
func_call:
    ID '(' arg_list_opt ')'

La función check_function_call(name, arg_count) valida:

Que la función exista
Que realmente sea una función
Que el número de argumentos coincida con param_count

Errores típicos:
Error semantico: llamada a funcion no declarada 'multiplica'
Error semantico: identificador no es una funcion 'x'
Error semantico: numero de argumentos incorrecto en llamada a funcion 'addValues'

--Validación de Expresiones
Se validan expresiones de:

Suma
Multiplicación
Números
Identificadores
Llamadas a funciones dentro de expresiones
Cada identificador dentro de una expresión se verifica semánticamente.

Ejemplo válido:
a + b * foo(3)

--Validación de Bloques Internos{}
Cada bloque interno abre un ámbito nuevo:
'{'
{
    enter_scope();
}
...
'}'
{
    leave_scope();
}

Permite variables internas:
{
    int x;
    print(x);
}

Detección de errores:
Error semantico: uso de variable no declarada 'x' (si está fuera del bloque)

--Mensajes de Depuración Semántica

El analizador imprime mensajes útiles como:

Declaracion global;
Variable local;
Parametro;
Funcion;
Asignacion;
Llamada a funcion;
Bloque de codigo;
Error semantico: ...

Al final:

Si no hubo errores:
Analisis sintactico y semantico finalizado sin errores.

Si hubo errores:
Analisis sintactico correcto, pero se encontraron N errores semanticos.

##Instrucciones de Compilación y Ejecución
Generar archivos del parser y lexer

win_bison -d parser.y
win_flex lexer.l
gcc parser.tab.c lex.yy.c -o semantico.exe

Ejecutar
semantico.exe input.c

##Notas
Este analizador semántico implementa un subsistema robusto de manejo de ámbitos y tabla de símbolos que permite validar la corrección semántica de un subconjunto importante del lenguaje C.
Detecta errores reales de programación y brinda retroalimentación clara al usuario.

Además, está diseñado para poder extenderse fácilmente con nuevos tipos, operadores, reglas y estructuras de control.

