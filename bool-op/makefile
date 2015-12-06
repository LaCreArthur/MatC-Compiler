
FILE 		= expr
CFLAGS 	= -g -Wall -Wextra -Wno-unused-function
LIBS		= -ll -ly -lfl
CFILES	=	symbol.c quad.c

all : $(FILE).y $(FILE).l $(CFILES)
	yacc -d $(FILE).y --verbose
	lex $(FILE).l
	gcc $(CFLAGS) *.c $(LIBS)

clean :
	rm y.tab.* lex.yy.c a.out
