%{/* C Declarations*/
#include "C-0.tab.h"

#define yyterminate() return END

int print = 0;
int printSpaceTab = 0;
%}

%%
"int" {yylval.str = strdup(yytext); return INT;}
"bool" {yylval.str = strdup(yytext); return BOOL;}
"char" {yylval.str = strdup(yytext); return CHAR;}
"string" {yylval.str = strdup(yytext); return C_STRING;}
"struct" {yylval.str = strdup(yytext); return STRUCT;}
[true|false] {yylval.str = strdup(yytext); return BOOLEAN_VALUE;}
[A-Za-z_]+ {yylval.str = strdup(yytext); return STRING;}
[0-9]+ {yylval.str = strdup(yytext); return NUMBER;}
"[" {yylval.str = strdup(yytext); return ARR_OPEN;}
"]" {yylval.str = strdup(yytext); return ARR_CLOSED;}
"{" {yylval.str = strdup(yytext); return BRACKET_OPEN;}
"}" {yylval.str = strdup(yytext); return BRACKET_CLOSED;}
"*"+ {yylval.str = strdup(yytext); return POINTER;}
"=" {yylval.str = strdup(yytext); return EQUALS;}
";" {yylval.str = strdup(yytext); return SEMICOLON;}
" " {}
\t {}
\n {}
. {}

%%

int yywrap() {}