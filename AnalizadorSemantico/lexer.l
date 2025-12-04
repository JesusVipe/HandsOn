%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"   /* generado por bison */

int linea = 1;            /* contador de lineas para el parser */
%}

DIGITO          [0-9]
LETRA           [a-zA-Z_]
IDENTIFICADOR   {LETRA}({LETRA}|{DIGITO}|_)*
NUMERO          {DIGITO}+
ESPACIO         [ \t]+

%%

"//".*      { /* ignorar comentario de linea */ }

"int"       { return INT; }
"float"     { return FLOAT; }
"double"    { return DOUBLE; }
"char"      { return CHAR; }
"void"      { return VOID; }
"short"     { return SHORT; }

"return"    { return RETURN; }
"include"   { return INCLUDE; }
"define"    { return DEFINE; }
"if"        { return IF; }
"else"      { return ELSE; }
"for"       { return FOR; }
"while"     { return WHILE; }
"do"        { return DO; }

{IDENTIFICADOR} {
    yylval.str = strdup(yytext);
    return ID;
}

{NUMERO} {
    yylval.ival = atoi(yytext);
    return NUMBER;
}

"++"    { return INCREMENT; }
"+"     { return '+'; }
"-"     { return '-'; }
"*"     { return '*'; }
"/"     { return '/'; }
"="     { return '='; }

"("     { return '('; }
")"     { return ')'; }
"{"     { return '{'; }
"}"     { return '}'; }
";"     { return ';'; }
","     { return ','; }
"#"     { return '#'; }
"<"     { return '<'; }
">"     { return '>'; }
"."     { return '.'; }

{ESPACIO}   { /* ignorar espacios y tabs */ }
\n          { linea++; }

.           { /* ignorar caracteres desconocidos */ }

%%

int yywrap(void) {
    return 1;
}
