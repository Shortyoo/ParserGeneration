# Makefile
do:
	flex whileProgram.l
	bison -d -t whileProgram.y -Wcounterexamples
	gcc lex.yy.c whileProgram.tab.c
	rm lex.yy.c
	rm whileProgram.tab.*