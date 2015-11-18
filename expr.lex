%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int DEBUG = 0;
int line = 1;
%}

number				[0-9]
int						{number}+
exp						[Ee][+-]?{number}
float					{int}("."{int})?{exp}?
char		    	[a-zA-Z]
id			    	{char}({char}|{int})*
op						[+*/()=-]
noaplha				[\'\"\{\};]

indice				("["{int}"]")+
types					matrix|int|float
keyword 	   	else|if|for|while|matrix|return

comment 	  	\/\*([^\*]*\*[\*]*[^\/\*])*[^\*]*\*[\*]*\/
newline				"\n"
escapesec   	"\a"|"\\b"|"\t"|"\\t"|"\b"|"\\a"|([ ])+
string				\"([^"])*\"

%%

{newline}			{ printf("%s", yytext); line++;}
{escapesec}   { printf("%s", yytext);}
{types}		    { printf("%s", yytext); yylval.str_value = yytext; return TYPE;}
"main"				{	printf("main"); return MAIN;}
"print"				{	printf("%s", yytext); return PRINT;}
"printf"			{	printf("%s", yytext); return PRINTF;}
"printm"			{	printf("%s", yytext); return PRINTM;}

{int}					{ yylval.int_value = atoi(yytext);return(INT);}
{float}				{ yylval.float_value=atof(yytext);return(FLOAT);}
{id}					{ if(DEBUG) printf(" id_");  printf("%s", yytext); yylval.str_value = strdup(yytext); return ID;}

"++"|"--"			{ printf("%s", yytext); yylval.str_value = yytext; return INCRorDECR;}
{string}			{ if(DEBUG) printf(" str_");  printf("%s", yytext); yylval.str_value = strdup(yytext); return STR;}
{op}					{ printf("%c", yytext[0]); return(yytext[0]);}
{noaplha}			{ printf("%c", yytext[0]); return(yytext[0]);}

{comment}     { printf("%s", yytext); }
. 						{ printf("[lex] unknonw char : %s\n", yytext);}

%%
