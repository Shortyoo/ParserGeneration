%{
#include <stdio.h>
#include <string.h>

extern int yylex();
extern FILE *yyin;
int yyerror(char* s);

int parse_string(const char* in);
char* addDontFree(char* s1, char* s2);
char* add(char* s1, char* s2);
char* buildPrefix(char* s1, char* prefix);
char* allocString(size_t size);
char* parseFile(const char* filename);
%}

%union{
	char *str;
	int num;
}

%type<str> startSymb program variable integer assignment loop number condition
%token<str> STRING OTHER SEMICOLON EQUALS PLUS UNDERSCORE MINUS WHILE OPEN_PAREN CLOSED_PAREN SLASH OPEN_BRACKET CLOSED_BRACKET NUMBER END TILDE

%%

startSymb: program END{printf("\n\t\tSTART(%s)", $1);return 0;}
	| program TILDE{printf("\n\t\tSTART(%s)", $1);return 0;}

program:
	loop SEMICOLON program
		{
			char* str;
			str = add($1, ";");
			str = add(str, $2);
			$$ = str;
		}
	| assignment SEMICOLON program
		{
			char* str;
			str = add($1, ";");
			str = add(str, $2);
			$$ = str;
		}
	| loop {$$ = $1;}
	| assignment{$$ = $1;}
	
variable: 
	STRING UNDERSCORE number
		{
			char* string;
			
			char* stringPref = buildPrefix($1, "STRING");
			string = addDontFree("VARIABLE(", stringPref);
			free(stringPref);
			
			string = add(string, ",UNDERSCORE(_),");
			
			string = add(string, $3);
			free($3);
			
			string = add(string, ")");
			$$ = string;
		}
	;
integer: 
	number
		{
			char* str;
			str = buildPrefix($1, "INTEGER");
			$$ = str;
		}
	 | MINUS number 
		{
			char* str;
			char* tempStr = addDontFree($1, $2);
			str = buildPrefix(tempStr, "INTEGER");
			$$ = str;
		};
	
assignment:
	variable EQUALS variable PLUS integer
		{
			char* string;
			char* eqString = buildPrefix($2, "EQUALS");
			string = add($1, eqString);
			free(eqString);
			string = add(string, $3);
			char* plusString = buildPrefix($4, "PLUS");
			string = add(string, plusString);
			free(plusString);
			string = add(string, $5);
			free($3);
			free($5);
			$$ = string;
		}
	;
	
loop: 
	// 1	   2	      3 	         4            5          6          7         
	WHILE OPEN_PAREN  condition CLOSED_PAREN OPEN_BRACKET program CLOSED_BRACKET
	{
		char* string;
		char* brackets = addDontFree("{", $6);
		free($6);
		brackets = add(brackets, "}");
		
		char* conditionStr = addDontFree("OPEN_PAREN", $3);
		free($3);
		conditionStr = add(conditionStr, "CLOSED_PAREN");
		
		string = add(buildPrefix($1, "WHILE"), conditionStr);
		free(conditionStr);
		string = add(string, brackets);
		free(brackets);
		
		$$ = string;
		
	}
;


condition:
	variable SLASH EQUALS NUMBER
	{
		char* str;
		char* slashStr = buildPrefix($2, "SLASH");
		char* equalsStr = buildPrefix($3, "EQUALS");
		if(strcmp($4, "0") != 0){
			printf("\n\t\tFEHLER: Eine Bedingung kann nur gegen 0 prüfen!! %s übergeben!", $4);
			return -1;
		}
		char* zeroStr = buildPrefix($4, "ZERO");
		str = add($1, slashStr);
		str = add(str, equalsStr);
		str = add(str, zeroStr);
		$$ = str;
	}
	;

number:
	NUMBER
	{
		$$ = buildPrefix($1, "NUMBER");
	}

%%

int main(int argc, char* argv[]){
	printf("\n---MAIN---");
	if(argc != 1){
		for(int i = 1; i < argc; i++){
			printf("\n\tParsing: %s", argv[i]);
			printf("\n\t  Result: %s", parseFile(argv[i]));
		}
	}
	printf("\n--- END MAIN ---\n");
	if(argc == 1)
		yyparse();
	return 0;
}

char* parseFile(const char* filename){
	FILE *myFile = fopen(filename, "r");
	if(!myFile){
		return "ERROR: Could not open file!";
	}
	yyin = myFile;
	
	yyparse();
	return "File opened!";
}

int yyerror(char *s){
	printf("\nERROR %s", s);
	return 0;
}

char* addDontFree(char* s1, char* s2){
	size_t size = strlen(s1) + strlen(s2);
	char* s = allocString(size+1);
	strcat(s, s1);
	strcat(s, s2);
	//printf("\ns1 %d\t s2 %d\t s %d", strlen(s1), strlen(s2), strlen(s));
	//printf("\n\ts1 %s\n\ts2 %s\n\ts  %s", s1, s2, s);
	return s;
}

// This method also calls "addDontFree" and also "free(s1)" as of my calls "string = add(string, XX)".
// After execution, I wont have access to the old pointer anymore => memory leak
char* add(char* s1, char* s2){
	char* s = addDontFree(s1, s2);
	free(s1);
	return s;
}

char* buildPrefix(char* s1, char* prefix){
	char* s;
	char* scndThing = "(";
	s = addDontFree(prefix, scndThing);
	//printf("\nsizes:\n\ts: %d\n\tp: %d\n\te: %d\n\t", strlen(prefix), strlen(scndThing), strlen(s));
	//printf("\naddDontFree:\n\ts: %s\n\tp: %s\n\te: %s", prefix, "(", s);
	s = add(s, s1);
	s = add(s, ")");
	free(s1);
	return s;
}

char* allocString(size_t size){
	//printf("\nallocString:\n\tsize: %d", size);
	char* s = (char *)malloc(size);
	for(int i = 0; i < size; i++){
		s[i] = '\0';
	}
	return s;
}