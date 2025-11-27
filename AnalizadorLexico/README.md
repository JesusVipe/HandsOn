# Analizador Léxico para Subconjunto de C

## Integrantes del Equipo
Jesus Vidrio Perez

## Descripción
Este analizador léxico implementado en Flex es capaz de reconocer los siguientes elementos del lenguaje C:

- **Palabras reservadas**: int, float, double, char, void, short, return, include, define, main, print
- **Identificadores**: Nombres de variables, funciones, constantes
- **Literales numéricos**: Enteros y flotantes
- **Operadores**: +, -, *, /, =, ++, --, +=, -=
- **Delimitadores**: (), {}, [], ;, ,, #, <, >
- **Comentarios**: // (una línea) y /* */ (múltiples líneas)
- **Directivas de preprocesador**: #include, #define

## Instrucciones de Compilación y Ejecución
Microsoft Windows [Versión 10.0.19045.6575]
(c) Microsoft Corporation. Todos los derechos reservados.

C:\Users\jesvp>cd OneDrive

C:\Users\jesvp\OneDrive>cd documentos

C:\Users\jesvp\OneDrive\Documentos>cd Codeblocks

C:\Users\jesvp\OneDrive\Documentos\Codeblocks>cd AnalizadorLexico

C:\Users\jesvp\OneDrive\Documentos\Codeblocks\AnalizadorLexico>win_flex lexer.l

C:\Users\jesvp\OneDrive\Documentos\Codeblocks\AnalizadorLexico>gcc lex.yy.c -o lexer.exe

C:\Users\jesvp\OneDrive\Documentos\Codeblocks\AnalizadorLexico>lexer.exe input.c
=== INICIO DEL ANALISIS LEXICO ===
Linea 1: DIRECTIVA_PREPROCESADOR - include
Linea 1: DELIMITADOR - <
Linea 1: IDENTIFICADOR - stdlib
Linea 1: PUNTO
Linea 1: IDENTIFICADOR - h
Linea 1: DELIMITADOR - >
Linea 2: DIRECTIVA_PREPROCESADOR - define
Linea 2: IDENTIFICADOR - SCALE_FACTOR
Linea 2: ENTERO - 2
Linea 4: PALABRA_RESERVADA - int
Linea 4: IDENTIFICADOR - globalA
Linea 4: DELIMITADOR - ;
Linea 5: PALABRA_RESERVADA - int
Linea 5: IDENTIFICADOR - globalB
Linea 5: DELIMITADOR - ;
Linea 7: PALABRA_RESERVADA - int
Linea 7: IDENTIFICADOR - addValues
Linea 7: DELIMITADOR - (
Linea 7: PALABRA_RESERVADA - int
Linea 7: IDENTIFICADOR - first
Linea 7: DELIMITADOR - ,
Linea 7: PALABRA_RESERVADA - int
Linea 7: IDENTIFICADOR - second
Linea 7: DELIMITADOR - )
Linea 7: DELIMITADOR - {
Linea 8: PALABRA_RESERVADA - int
Linea 8: IDENTIFICADOR - resultLocal
Linea 8: DELIMITADOR - ;
Linea 9: IDENTIFICADOR - resultLocal
Linea 9: OPERADOR - asignacion (=)
Linea 9: IDENTIFICADOR - first
Linea 9: OPERADOR - suma (+)
Linea 9: IDENTIFICADOR - second
Linea 9: DELIMITADOR - ;
Linea 10: PALABRA_RESERVADA - return
Linea 10: IDENTIFICADOR - resultLocal
Linea 10: DELIMITADOR - ;
Linea 11: DELIMITADOR - }
Linea 13: PALABRA_RESERVADA - int
Linea 13: IDENTIFICADOR - processValue
Linea 13: DELIMITADOR - (
Linea 13: PALABRA_RESERVADA - int
Linea 13: IDENTIFICADOR - value
Linea 13: DELIMITADOR - )
Linea 13: DELIMITADOR - {
Linea 14: PALABRA_RESERVADA - int
Linea 14: IDENTIFICADOR - temporaryVal
Linea 14: DELIMITADOR - ;
Linea 15: IDENTIFICADOR - temporaryVal
Linea 15: OPERADOR - asignacion (=)
Linea 15: IDENTIFICADOR - value
Linea 15: OPERADOR - multiplicacion (*)
Linea 15: IDENTIFICADOR - SCALE_FACTOR
Linea 15: DELIMITADOR - ;
Linea 17: DELIMITADOR - {
Linea 17: COMENTARIO_BLOQUE_INICIO
Linea 17: COMENTARIO_BLOQUE_FIN
Linea 18: PALABRA_RESERVADA - int
Linea 18: IDENTIFICADOR - innerResult
Linea 18: DELIMITADOR - ;
Linea 19: IDENTIFICADOR - innerResult
Linea 19: OPERADOR - asignacion (=)
Linea 19: IDENTIFICADOR - temporaryVal
Linea 19: OPERADOR - suma (+)
Linea 19: ENTERO - 5
Linea 19: DELIMITADOR - ;
Linea 20: PALABRA_RESERVADA - print
Linea 20: DELIMITADOR - (
Linea 20: IDENTIFICADOR - innerResult
Linea 20: DELIMITADOR - )
Linea 20: DELIMITADOR - ;
Linea 21: DELIMITADOR - }
Linea 23: PALABRA_RESERVADA - return
Linea 23: IDENTIFICADOR - temporaryVal
Linea 23: DELIMITADOR - ;
Linea 24: DELIMITADOR - }
Linea 26: PALABRA_RESERVADA - int
Linea 26: PALABRA_RESERVADA - main
Linea 26: DELIMITADOR - (
Linea 26: DELIMITADOR - )
Linea 26: DELIMITADOR - {
Linea 27: PALABRA_RESERVADA - int
Linea 27: IDENTIFICADOR - resultMain
Linea 27: DELIMITADOR - ;
Linea 28: PALABRA_RESERVADA - int
Linea 28: IDENTIFICADOR - auxValue
Linea 28: DELIMITADOR - ;
Linea 30: IDENTIFICADOR - globalA
Linea 30: OPERADOR - asignacion (=)
Linea 30: ENTERO - 3
Linea 30: DELIMITADOR - ;
Linea 31: IDENTIFICADOR - globalB
Linea 31: OPERADOR - asignacion (=)
Linea 31: ENTERO - 4
Linea 31: DELIMITADOR - ;
Linea 33: IDENTIFICADOR - resultMain
Linea 33: OPERADOR - asignacion (=)
Linea 33: IDENTIFICADOR - addValues
Linea 33: DELIMITADOR - (
Linea 33: IDENTIFICADOR - globalA
Linea 33: DELIMITADOR - ,
Linea 33: IDENTIFICADOR - globalB
Linea 33: DELIMITADOR - )
Linea 33: DELIMITADOR - ;
Linea 34: PALABRA_RESERVADA - print
Linea 34: DELIMITADOR - (
Linea 34: IDENTIFICADOR - resultMain
Linea 34: DELIMITADOR - )
Linea 34: DELIMITADOR - ;
Linea 36: IDENTIFICADOR - auxValue
Linea 36: OPERADOR - asignacion (=)
Linea 36: IDENTIFICADOR - processValue
Linea 36: DELIMITADOR - (
Linea 36: IDENTIFICADOR - resultMain
Linea 36: DELIMITADOR - )
Linea 36: DELIMITADOR - ;
Linea 37: PALABRA_RESERVADA - print
Linea 37: DELIMITADOR - (
Linea 37: IDENTIFICADOR - auxValue
Linea 37: DELIMITADOR - )
Linea 37: DELIMITADOR - ;
Linea 39: DELIMITADOR - {
Linea 40: PALABRA_RESERVADA - int
Linea 40: IDENTIFICADOR - finalOutput
Linea 40: DELIMITADOR - ;
Linea 41: IDENTIFICADOR - finalOutput
Linea 41: OPERADOR - asignacion (=)
Linea 41: IDENTIFICADOR - auxValue
Linea 41: OPERADOR - suma (+)
Linea 41: IDENTIFICADOR - resultMain
Linea 41: DELIMITADOR - ;
Linea 42: PALABRA_RESERVADA - print
Linea 42: DELIMITADOR - (
Linea 42: IDENTIFICADOR - finalOutput
Linea 42: DELIMITADOR - )
Linea 42: DELIMITADOR - ;
Linea 43: DELIMITADOR - }
Linea 45: PALABRA_RESERVADA - return
Linea 45: ENTERO - 0
Linea 45: DELIMITADOR - ;
Linea 46: DELIMITADOR - }
=== FIN DEL ANALISIS LEXICO ===
>>> Total de lineas: 47

C:\Users\jesvp\OneDrive\Documentos\Codeblocks\AnalizadorLexico>

### Prerrequisitos
1. Instalar Flex para Windows:
   - Descargar WinFlexBison desde: https://github.com/lexxmark/winflexbison
   - Extraer en `C:\win_flex_bison` o similar
   - Agregar `C:\win_flex_bison` al PATH del sistema
