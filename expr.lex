%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int DEBUG = 0;

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
predefid			matrix|int|float
keyword 	   	else|if|for|while|matrix|return

comment 	  	\/\*([^\*]*\*[\*]*[^\/\*])*[^\*]*\*[\*]*\/
escapesec   	"\a"|"\\b"|"\t"|"\\t"|"\b"|"\\a"|"\n"|([ ])+
string				\"([^"])*\"
print					print"("{int}")"
printf				printf"("{string}")"
printmat			printmat"("{ident}")"
%%

{escapesec}   { printf("%s", yytext);}
{predefid}    { printf("%s", yytext); yylval.int_value = yytext[0]; return TYPE;}
"main"				{	printf("main"); return MAIN;}
{int}					{ yylval.int_value = atoi(yytext);return(INT);}
{float}				{ yylval.float_value=atof(yytext);return(FLOAT);}
{id}					{ if(DEBUG) printf(" id_");  printf("%s", yytext); yylval.str_value = strdup(yytext); return ID;}
"++"					{ printf("%s", yytext); return INCR;}
"--"					{ printf("%s", yytext); return DECR;}
{op}					{ printf("%c", yytext[0]); return(yytext[0]);}
{noaplha}			{ printf("%c", yytext[0]); return(yytext[0]);}

{comment}     { printf("%s", yytext); }
. 						{ printf("[lex] unknonw char : %s\n", yytext);}

%%
