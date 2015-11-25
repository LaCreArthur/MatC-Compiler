%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#define column_incr column+=strlen(yytext)
int DEBUG = 0;
int line = 1;
int column = 1;
%}

number				[0-9]
int						{number}+
exp						[Ee][+-]?{number}
float					{int}("."{int})?{exp}?
char		    	[a-zA-Z]
id			    	{char}({char}|{int})*
op						[+*/()=-]

newline				"\n"
escapesec   	"\a"|"\\b"|"\t"|"\\t"|"\b"|"\\a"|" "
types					matrix|int|float
keyword 	   	else|if|for|while|matrix|return
indice				("["{int}"]")

comment 	  	\/\*([^\*]*\*[\*]*[^\/\*])*[^\*]*\*[\*]*\/
string				\"([^"])*\"
noaplha				[\'\"\{\};]

%%

{newline}			{ printf("%s", yytext); line++; column = 1;}
"\t"					{ printf("%s", yytext); column += 4;}
{escapesec}   { printf("%s", yytext); column_incr;}
{types}		    { printf("%s", yytext); column_incr; yylval.str_value = yytext; return TYPE; }
"main"				{	printf("main"); column_incr; return MAIN;}
"print"				{	printf("%s", yytext); column_incr; return PRINT;}
"printf"			{	printf("%s", yytext); column_incr;; return PRINTF;}
"printm"			{	printf("%s", yytext); column_incr;; return PRINTM;}

{int}					{ yylval.int_value = atoi(yytext); column_incr; return(INT);}
{float}				{ yylval.float_value=atof(yytext); column_incr; return(FLOAT);}
{id}					{ if(DEBUG) printf(" id_");  printf("%s", yytext); column_incr; yylval.str_value = strdup(yytext); return ID;}
{indice}			{ printf("%s", yytext); yylval.int_value = atoi(yytext+1); column_incr; return(INDICE);}
"++"|"--"			{ printf("%s", yytext); yylval.str_value = yytext; column_incr; return INCRorDECR;}
{string}			{ if(DEBUG) printf(" str_");  printf("%s", yytext); yylval.str_value = strdup(yytext); column_incr; return STR;}
{op}					{ printf("%c", yytext[0]); column_incr; return(yytext[0]);}
{comment}     { printf("%s", yytext); column_incr;}

{noaplha}			{ printf("%c", yytext[0]); return(yytext[0]);}
. 						{ printf("[lex] unknonw char : %s\n", yytext);}

%%
