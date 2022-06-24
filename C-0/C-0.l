%{/* C Declarations*/
#include "C-0.tab.h"

#define yyterminate() return END

int print = 0;
int printSpaceTab = 0;
%}

%%
"int" {yylval.str = strdup(yytext); return C_INT;}
"bool" {yylval.str = strdup(yytext); return C_BOOL;}
"char" {yylval.str = strdup(yytext); return C_CHAR;}
"string" {yylval.str = strdup(yytext); return C_STRING;}
"struct" {yylval.str = strdup(yytext); return STRUCT;}
(true|false) {yylval.str = strdup(yytext); return BOOLEAN_VALUE;}
[A-Za-z_]+ {yylval.str = strdup(yytext); return STRING;}
[0-9]+ {yylval.str = strdup(yytext); return NUMBER;}
"[" {yylval.str = strdup(yytext); return ARR_OPEN;}
"]" {yylval.str = strdup(yytext); return ARR_CLOSED;}
"{" {yylval.str = strdup(yytext); return BRACKET_OPEN;}
"}" {yylval.str = strdup(yytext); return BRACKET_CLOSED;}
"==" {yylval.str = strdup(yytext); return BOOLEAN_EQUALS;}
"=" {yylval.str = strdup(yytext); return EQUALS;}
"+" {yylval.str = strdup(yytext); return PLUS;}
"-" {yylval.str = strdup(yytext); return MINUS;}
"*" {yylval.str = strdup(yytext); return TIMES;}
"/" {yylval.str = strdup(yytext); return DIVIDE;}
";" {yylval.str = strdup(yytext); return SEMICOLON;}
"&" {yylval.str = strdup(yytext); return LOGICAL_AND;}
(\".*\") {yylval.str = strdup(yytext); return CHARSEQUENCE;}
(\'.\') {yylval.str = strdup(yytext); return CHAR;}
" " {}
\t {}
\n {}
. {}

%%

int yywrap() {}