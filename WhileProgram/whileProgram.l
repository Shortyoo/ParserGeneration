%{/* C Declarations*/
#include "whileProgram.tab.h"

#define yyterminate() return END

int print = 0;
int printSpaceTab = 0;
%}

%%
"WHILE" {yylval.str = strdup(yytext); return WHILE;}
[A-Za-z]+ {yylval.str = strdup(yytext); return STRING;}
[0-9]+ {yylval.str = strdup(yytext); return NUMBER;}
"+" {yylval.str = strdup(yytext); return PLUS;}
"-" {yylval.str = strdup(yytext); return MINUS;}
"=" {yylval.str = strdup(yytext); return EQUALS;}
"(" {yylval.str = strdup(yytext); return OPEN_PAREN;}
")" {yylval.str = strdup(yytext); return CLOSED_PAREN;}
"{" {yylval.str = strdup(yytext); return OPEN_BRACKET;}
"}" {yylval.str = strdup(yytext); return CLOSED_BRACKET;}
"/" {yylval.str = strdup(yytext); return SLASH;}
"_" {yylval.str = strdup(yytext); return UNDERSCORE;}
";" {return SEMICOLON;}
"~" {return TILDE;} // To write strings by hand
" " {}
\t {}
\n {}
. {}

%%

int yywrap() {}