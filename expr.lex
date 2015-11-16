%{

#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "expr.h"

int DEBUG = 0;
%}

comment 	  	\/\*([^\*]*\*[\*]*[^\/\*])*[^\*]*\*[\*]*\/
escapesec   	"\a"|"\\b"|"\t"|"\\t"|"\b"|"\\a"|"\n"
blank					([ ])+
char		    	[a-zA-Z]
digit					[0-9]
ident		    	{char}({char}|{digit})*
int						{digit}+
exp						[Ee][+-]?{digit}
float					{int}("."{int})?{exp}?
indice				("["{int}"]")+

incr					"++"
decr					"--"
op						[*/+()-]
notalpha			[\(\)\{\}\~\|\[\]\;\,\"\=\/]
predefid			matrix|int|float|main
keyword 	   	else|if|for|while|matrix|return

string				\"([^"])*\"
print					print"("{int}")"
printf				printf"("{string}")"
printmat			printmat"("{ident}")"

%%

{blank}				{ printf("%s",yytext);}
"int"					{	printf("int"); return T_INT;}
"main"				{	printf("main"); return MAIN;}
{escapesec}   { printf("%s", yytext);}

{int}					{ printf("%s", yytext); yylval.int_value = atoi(yytext); return INT;}
{float}				{ printf("%s", yytext); yylval.int_value = atof(yytext); return INT;}

{incr}				{ printf("%s", yytext); return INCR;}
{decr}				{ printf("%s", yytext); return DECR;}
{op}					{ printf("%s", yytext); return yytext[0];}

{indice}			{ if(DEBUG) printf(" ind_"); printf("%s", yytext); return INDICE;}
{predefid}		{ if(DEBUG) printf(" pdi_"); printf("%s", yytext); yylval.string = yytext; return STR;}
{keyword}			{ if(DEBUG) printf(" kw_");  printf("%s", yytext); yylval.string = yytext; return STR;}
{print}				{ if(DEBUG) printf(" prt_");  printf("%s", yytext); return PRINT;}
{printf}			{ if(DEBUG) printf(" prtf_"); printf("%s", yytext); return PRINTF;}
{printmat}		{ if(DEBUG) printf(" prtm_"); printf("%s", yytext); return PRINTM;}

{ident}				{if(DEBUG) printf(" id_");  printf("%s", yytext); yylval.string = yytext; return ID;}

{comment}     { printf("%s", yytext); yylval.string = yytext; return STR;}
{notalpha}		{ printf("%s", yytext); return yytext[0];}
. 						{ printf("[lex] unknonw char : %s\n", yytext); return(OTHER);}

%%
