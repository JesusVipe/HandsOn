%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
%}

%option yylineno

DIGIT       [0-9]
LETTER      [a-zA-Z_]
IDENTIFIER  {LETTER}({LETTER}|{DIGIT})*
INTEGER     [-]?{DIGIT}+
FLOAT       [-]?{DIGIT}+\.{DIGIT}+
WHITESPACE  [ \t]+
NEWLINE     \n

%x COMMENT

%%

 /* Palabras reservadas */
"int"       { printf("Linea %d: PALABRA_RESERVADA - int\n", yylineno); }
"float"     { printf("Linea %d: PALABRA_RESERVADA - float\n", yylineno); }
"double"    { printf("Linea %d: PALABRA_RESERVADA - double\n", yylineno); }
"char"      { printf("Linea %d: PALABRA_RESERVADA - char\n", yylineno); }
"void"      { printf("Linea %d: PALABRA_RESERVADA - void\n", yylineno); }
"short"     { printf("Linea %d: PALABRA_RESERVADA - short\n", yylineno); }
"return"    { printf("Linea %d: PALABRA_RESERVADA - return\n", yylineno); }
"include"   { printf("Linea %d: PALABRA_RESERVADA - include\n", yylineno); }
"define"    { printf("Linea %d: PALABRA_RESERVADA - define\n", yylineno); }
"main"      { printf("Linea %d: PALABRA_RESERVADA - main\n", yylineno); }
"print"     { printf("Linea %d: PALABRA_RESERVADA - print\n", yylineno); }

 /* Identificadores y números */
{IDENTIFIER} { printf("Linea %d: IDENTIFICADOR - %s\n", yylineno, yytext); }
{INTEGER}    { printf("Linea %d: ENTERO - %s\n", yylineno, yytext); }
{FLOAT}      { printf("Linea %d: FLOTANTE - %s\n", yylineno, yytext); }

 /* Operadores - versión mejorada */
"++"         { printf("Linea %d: OPERADOR - incremento (++)\n", yylineno); }
"--"         { printf("Linea %d: OPERADOR - decremento (--)\n", yylineno); }
"+="         { printf("Linea %d: OPERADOR - suma y asignacion (+=)\n", yylineno); }
"-="         { printf("Linea %d: OPERADOR - resta y asignacion (-=)\n", yylineno); }
"<="         { printf("Linea %d: OPERADOR - menor o igual (<=)\n", yylineno); }
">="         { printf("Linea %d: OPERADOR - mayor o igual (>=)\n", yylineno); }
"=="         { printf("Linea %d: OPERADOR - igualdad (==)\n", yylineno); }
"!="         { printf("Linea %d: OPERADOR - desigualdad (!=)\n", yylineno); }
"&&"         { printf("Linea %d: OPERADOR - and logico (&&)\n", yylineno); }
"||"         { printf("Linea %d: OPERADOR - or logico (||)\n", yylineno); }
"="          { printf("Linea %d: OPERADOR - asignacion (=)\n", yylineno); }
"+"          { printf("Linea %d: OPERADOR - suma (+)\n", yylineno); }
"-"          { printf("Linea %d: OPERADOR - resta (-)\n", yylineno); }
"*"          { printf("Linea %d: OPERADOR - multiplicacion (*)\n", yylineno); }
"/"          { printf("Linea %d: OPERADOR - division (/)\n", yylineno); }

 /* Delimitadores */
[(){}[\];,<>#] { printf("Linea %d: DELIMITADOR - %s\n", yylineno, yytext); }

 /* Caracteres especiales */
"."          { printf("Linea %d: PUNTO\n", yylineno); }

 /* Directivas de preprocesador */
"#include"   { printf("Linea %d: DIRECTIVA_PREPROCESADOR - include\n", yylineno); }
"#define"    { printf("Linea %d: DIRECTIVA_PREPROCESADOR - define\n", yylineno); }

 /* Comentarios */
"//".*       { printf("Linea %d: COMENTARIO_LINEA - %s\n", yylineno, yytext); }
"/*"         { BEGIN(COMMENT); printf("Linea %d: COMENTARIO_BLOQUE_INICIO\n", yylineno); }
<COMMENT>{
"*/"         { BEGIN(INITIAL); printf("Linea %d: COMENTARIO_BLOQUE_FIN\n", yylineno); }
.            { /* Ignorar contenido */ }
\n           { /* yylineno se incrementa automáticamente */ }
}

{WHITESPACE} { /* Ignorar espacios */ }
{NEWLINE}    { /* yylineno se incrementa automáticamente */ }

.            { printf("Linea %d: CARACTER_NO_RECONOCIDO - '%s'\n", yylineno, yytext); }

%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            printf("Error: No se pudo abrir el archivo %s\n", argv[1]);
            return 1;
        }
        yyin = file;
    }
    
    printf("=== INICIO DEL ANALISIS LEXICO ===\n");
    yylex();
    printf("=== FIN DEL ANALISIS LEXICO ===\n");
    printf(">>> Total de lineas: %d\n", yylineno);
    
    return 0;
}

int yywrap() {
    return 1;
}
