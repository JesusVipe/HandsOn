%{
#include "parser.tab.h"
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


[a-zA-Z_][a-zA-Z0-9_]*  { return ID; }


[0-9]+                  { return NUMBER; }


[ \t\r\n]+              ;


.                       ;

%%

int yywrap(void) { return 1; }
