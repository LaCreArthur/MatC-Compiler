%{

#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "expr.h"
#define PREDEFIDS {"matrix","int","float","main"}
#define PREDEFIDS_SIZE 4
#define SIMPLELEX {"else","if","while","for",","(",")","*","+",",","-","/",";",=","[","]","{","}"
#define SIMPLELEX_SIZE 17}

%}

comment 	  	\/\*([^\*]*\*[\*]*[^\/\*])*[^\*]*\*[\*]*\/
escapesec   	"\a"|"\\n"|"\\b"|"\t"|"\\t"|"\b"|"\\a"
notlexunit		[ ]|{comment}|{escapesec}

char		    	[a-zA-Z]
digit					[0-9]
ident		    	{char}({char}|{digit})*
int						{digit}+
exp						[Ee][+-]?{digit}
float					{int}("."{int})?{exp}?

op						[()*/+-]
notalpha			[+*\/|()\[\]\{\};\=-]
predefid	  	("int"|"float"|"main")
keyword 	   	(else|if|for|while)

%%

{comment}     {if(DEBUG) printf("_/* com */_");}
{notlexunit}  {if(DEBUG) printf("%s", yytext);}
{int}					{yylval.int_value = atoi(yytext);return(INT);} // ok
{float}				{yylval.int_value = atof(yytext);}

{op}					{return yytext[0];}
\n						{return yytext[0];}
. 						{ printf("[lex] unknonw char : %s\n", yytext);}

%%
