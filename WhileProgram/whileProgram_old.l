%{/* C Declarations*/
#define YYSTYPE char *
#include "whileProgram.tab.h"

int print = 0;
int printSpaceTab = 0;
%}

%%
"WHILE" {if(print)printf("While");yylval.str = strdup(yytext); return WHILE;}
[A-Za-z]+ {if(print)printf("String"); return STRING;}
[0-9]+ {if(print)printf("Number");return NUMBER;}
"+" {if(print)printf("Plus"); return PLUS;}
"-" {if(print)printf("Minus");return MINUS;}
"=" {if(print)printf("Equals"); return EQUALS;}
"(" {if(print)printf("Open_Paren"); return OPEN_PAREN;}
")" {if(print)printf("Closed_Paren"); return CLOSED_PAREN;}
"{" {if(print)printf("Open_Bracket"); return OPEN_BRACKET;}
"}" {if(print)printf("Closed_Bracket"); return CLOSED_BRACKET;}
"/" {if(print)printf("Slash"); return SLASH;}
"_" {if(print)printf("Underscore"); return UNDERSCORE;}

" "+ {if(printSpaceTab)printf("Spaces");}
\t+ {if(printSpaceTab)printf("Tabs");}
\n {if(printSpaceTab)printf("Enter");}

%%

int yywrap() {}