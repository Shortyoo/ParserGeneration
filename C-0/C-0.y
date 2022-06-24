%{
#include <stdio.h>
#include <string.h>

#define primitiveDatatypeStr "PRIMITIVE_DATATYPE"
#define datatypeStr "DATATYPE"
#define numberStr "NUMBER"
#define arrayStr "ARRAY"
#define pointerStr "POINTER"
#define nameStr "NAME"
#define declarationStr "DECLARATION"
#define structStr "STRUCT"
#define semicolonStr "SEMICOLON"

extern int yylex();
extern FILE *yyin;
int yyerror(char* s);

int parse_string(const char* in);
char* addDontFree(char* s1, char* s2);
char* add(char* s1, char* s2);
char* buildPrefix(char* s1, char* prefix);
char* allocString(size_t size);
int parseFile(const char* filename);
%}

%union{
	char *str;
	int num;
}

%type<str> startSymb datatype primitiveDatatype pointer struct array number declaration name
%type<str> branching semicolon
%token<str> INT BOOL CHAR C_STRING STRUCT BOOLEAN_VALUE STRING NUMBER ARR_OPEN ARR_CLOSED
%token<str> BRACKET_OPEN BRACKET_CLOSED POINTER SEMICOLON END EQUALS

%%

startSymb: branching END
	{printf("\n\tParsetree: %s", $1); return 0;}
	;

branching:
	declaration {$$ = $1;}
	| struct {$$ = $1;}
	;
	

datatype: primitiveDatatype {$$ = buildPrefix($1, datatypeStr);}
	| primitiveDatatype pointer
	{
		char* string;
		string = add($1, $2);
		string = buildPrefix(string, datatypeStr);
		$$ = string;
	}
	;
	
struct:
	STRUCT name BRACKET_OPEN declaration BRACKET_CLOSED
	{
		char* string;
		string = add($1, $2);
		string = add(string, $3);
		string = add(string, $4);
		string = add(string, $5);
		$$ = buildPrefix(string, structStr);
	}
	;
	
declaration:
	datatype name semicolon
	{
		char* string;
		string = add($1, $2);
		string = add(string, $3);
		$$ = buildPrefix(string, declarationStr);
	}
	| datatype name semicolon declaration
	{
		char* string;
		string = add($1, $2);
		string = add(string, $3);
		string = buildPrefix(string, declarationStr);
		string = add(string, ",");
		string = add(string, $4);
		$$ = string;
	}
	;
	
name: 
	STRING {$$ = buildPrefix($1, nameStr);}
	| STRING NUMBER
	{
		char* string;
		string = add($1, $2);
		$$ = buildPrefix(string, nameStr);
	}
	| STRING NUMBER name
	{
		char* string;
		string = add($1, $2);
		string = add(string, $3);
		$$ = buildPrefix(string, nameStr);
	}
	;
	
primitiveDatatype:
	INT {$$ = buildPrefix($1, primitiveDatatypeStr);}
	| BOOL {$$ = buildPrefix($1, primitiveDatatypeStr);}
	| CHAR {$$ = buildPrefix($1, primitiveDatatypeStr);}
	| C_STRING {$$ = buildPrefix($1, primitiveDatatypeStr);}
	;
	
pointer: POINTER {$$ = buildPrefix($1, pointerStr);}
	| array {$$ = $1;}
	;
	
array:
	ARR_OPEN number ARR_CLOSED 
	{
		char* string;
		$$ = buildPrefix($1, arrayStr);
	}
	;
	
number:
	NUMBER {$$ = buildPrefix($1, numberStr);}
	;
	
semicolon:
	SEMICOLON {$$ = buildPrefix($1, semicolonStr);}
	;

%%

int main(int argc, char* argv[]){
	//printf("\n---MAIN---");
	int result = -1;
	
	if(argc != 2){
		for(int i = 2; i < argc; i++){
			printf("\nParsing: %s", argv[i]);
			result = parseFile(argv[i]);
			char* resultString;
			if(result == 0)
				resultString = "Parsing successful!";
			else if(result == 1)
				resultString = "Syntax error!";
			else if(result == 2)
				resultString = "ERROR: Memory exhausted!";
			else if(result == -1)
				resultString = "ERROR: File not found!";
			else
				resultString = "ERROR: Unknown error!";
			printf("\nResult: %s", resultString);
		}
	}
	if(argc == 2)
	{
		printf("\nParsing input: %s", argv[1]);
		result = yyparse();
	}
	//printf("\n--- END MAIN ---\n");
	return result;
}

int parseFile(const char* filename){
	FILE *myFile = fopen(filename, "r");
	if(!myFile){
		return -1;
	}
	yyin = myFile;
	
	return yyparse();
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