# Makefile
do:
	flex C-0.l
	bison -d -t C-0.y -Wcounterexamples
	gcc lex.yy.c C-0.tab.c
	rm lex.yy.c
	rm C-0.tab.*