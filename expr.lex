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
escapesec   	"\a"|"\\b"|"\t"|"\\t"|"\b"|"\\a"
notlexunit		" "|{escapesec}

char		    	[a-zA-Z]
digit					[0-9]
ident		    	{char}({char}|{digit})*
int						{digit}+
exp						[Ee][+-]?{digit}
float					{int}("."{int})?{exp}?

incr					"++"
decr					"--"
op						[*/+()-]
notalpha			[~|\[\]\{\};\=,"]
predefid			matrix|int|float|main
keyword 	   	else|if|for|while|matrix

%%

{int}					{if(DEBUG) printf("(int)%s", yytext); yylval.int_value = atoi(yytext); return(INT);}
{float}				{if(DEBUG) printf("(float)%s", yytext); yylval.int_value = atof(yytext); return(INT);}
{incr}				{if(DEBUG) printf("(op)%s", yytext); return INCR;}
{decr}				{if(DEBUG) printf("(op)%s", yytext); return DECR;}
{op}					{if(DEBUG) printf("(op)%s", yytext); return yytext[0];}


{notlexunit}  {if(DEBUG) printf("(!lex)%s", yytext); yylval.print = yytext[0]; return OTHER;}
{notalpha}		{if(DEBUG) printf("(!al)%s", yytext); yylval.print = yytext[0]; return OTHER;}

{predefid}		{if(DEBUG) printf("(pre)%s", yytext); yylval.string = yytext; return STR;}
{keyword}			{if(DEBUG) printf("(key)%s", yytext); yylval.string = yytext; return STR;}
{ident}				{if(DEBUG) printf("(ident)%s", yytext); yylval.string = yytext; return ID;}
{comment}     {if(DEBUG) printf("_com_"); yylval.string = yytext; return STR;}

\n						{if(DEBUG) printf("(\\n)%s", yytext); return yytext[0];}
. 						{ printf("[lex] unknonw char : %s\n", yytext); return(OTHER);}

%%
