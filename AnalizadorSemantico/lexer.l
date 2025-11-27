%{
#include "parser.tab.h"
#include <stdlib.h>
#include <string.h>
%}

%%

"#include"[^\n]*        { return INCLUDE; }
"#define"[^\n]*         ;   

"int"                   { return INT; }
"return"                { return RETURN; }

"("                     { return '('; }
")"                     { return ')'; }
"{"                     { return '{'; }
"}"                     { return '}'; }
";"                     { return ';'; }
","                     { return ','; }
"="                     { return '='; }
"+"                     { return '+'; }
"*"                     { return '*'; }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.str = strdup(yytext); return ID; }

[0-9]+                  { yylval.num = atoi(yytext); return NUMBER; }

[ \t\r\n]+              ;

.                       ;

%%

int yywrap(void) { return 1; }
