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
#define assignmentStr "ASSIGNMENT"
#define charsequenceStr "CHARSEQUENCE"
#define charStr "CHAR"
#define definitionStr "DEFINITION"
#define equalsStr "EQUALS"
#define operationStr "OPERATION"
#define expressionIntStr "EXPRESSION"

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
%type<str> branching semicolon assignment charsequence definition equals instructions
%type<str> expressionInt pointerRecursion operation
%token<str> C_INT C_BOOL C_CHAR C_STRING STRUCT BOOLEAN_VALUE STRING NUMBER ARR_OPEN ARR_CLOSED
%token<str> BRACKET_OPEN BRACKET_CLOSED SEMICOLON END EQUALS CHARSEQUENCE CHAR BOOLEAN_EQUALS
%token<str> PLUS MINUS TIMES DIVIDE

%%

startSymb: branching END
	{printf("\n\tParsetree: %s", $1); return 0;}
	;

branching:
	instructions {$$ = $1;}
	;
	
instructions:
	declaration instructions {$$ = $1;}
	| definition instructions {$$ = $1;}
	| struct instructions {$$ = $1;}
	| {$$ = "";} /*epsilon transition*/
	;
	

declaration:
	datatype name semicolon
	{
		char* string;
		string = add($1, $2);
		string = add(string, $3);
		$$ = buildPrefix(string, declarationStr);
	}
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
	
definition:
	datatype assignment
	{
		char* string = add($1, $2);
		$$ = buildPrefix(string, definitionStr);
	}
	;
	
assignment:
	name equals expressionInt semicolon
	{
		char* string = add($1, $2);
		string = add(string, $3);
		string = add(string, $4);
		$$ = buildPrefix(string, assignmentStr);
	}
	| name equals charsequence semicolon
	{
		char* string = add($1, $2);
		string = add($2, $3);
		$$ = buildPrefix(string, assignmentStr);
	}
	;
	
expressionInt:
	number {$$ = $1;}
	| number operation expressionInt
	{
		char* string;
		string = add($1, $2);
		string = add(string, $3);
		free($2);
		free($3);
		$$ = buildPrefix(string, expressionIntStr);
	}
	
operation:
	PLUS {$$ = buildPrefix($1, operationStr);}
	| MINUS {$$ = buildPrefix($1, operationStr);}
	| TIMES {$$ = buildPrefix($1, operationStr);}
	| DIVIDE {$$ = buildPrefix($1, operationStr);}
	;
	
charsequence:
	CHARSEQUENCE {$$ = buildPrefix($1, charsequenceStr);}
	| CHAR {$$ = buildPrefix($1, charStr);}
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
	C_INT {$$ = buildPrefix($1, primitiveDatatypeStr);}
	| C_BOOL {$$ = buildPrefix($1, primitiveDatatypeStr);}
	| C_CHAR {$$ = buildPrefix($1, primitiveDatatypeStr);}
	| C_STRING {$$ = buildPrefix($1, primitiveDatatypeStr);}
	;
	
pointer: pointerRecursion {$$ = $1;}
	| array {$$ = $1;}
	;
	
pointerRecursion: /*To get recursions on pointer, like int*** */
	TIMES {$$ = buildPrefix($1, pointerStr);}
	| TIMES pointerRecursion
	{
		$$ = add(buildPrefix($1, pointerStr), $2);
		free($2);
	}
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

equals:
	EQUALS {$$ = buildPrefix($1, equalsStr);}
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
	printf("\nBuilt: %s", s);
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