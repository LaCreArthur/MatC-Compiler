FILE 		= expr
CFLAGS 	= -g -Wall -Wextra -Wno-unused-function
LIBS		= -ll -ly -lfl
CFILES	=	symbol.c quad.c matrix.c testmatrix.c

all : $(FILE).y $(FILE).lex $(CFILES)
	yacc -d $(FILE).y --verbose
	lex $(FILE).lex
	gcc $(CFLAGS) *.c $(LIBS)

clean :
	rm y.tab.* lex.yy.c a.out
