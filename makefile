FILE 		= expr
CFLAGS 	= -g -Wall -Wextra -Wno-unused-function
LIBS		= -ll -ly -lfl
CFILES	=	symbol.c quad.c matrix.c
DEBUG		= -DYYDEBUG

all : $(FILE).y $(FILE).lex $(CFILES)
	yacc -d $(FILE).y --verbose
	lex $(FILE).lex
	gcc $(CFLAGS) *.c $(LIBS)

debug : $(FILE).y $(FILE).lex $(CFILES)
	yacc -d $(FILE).y --verbose
	lex $(FILE).lex
	gcc $(CFLAGS) *.c $(LIBS) $(DEBUG)

clean :
	rm y.tab.* lex.yy.c a.out *.asm
