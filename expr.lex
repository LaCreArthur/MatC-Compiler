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
keyword 	   	(else|if|for|while|matrix)

%%

{comment}     {if(DEBUG) printf("_/* com */_");}
{notlexunit}  {if(DEBUG) printf("(!lex)%s", yytext);}

{notalpha}		{if(DEBUG) printf("(!al)%s", yytext);}
{predefid}		{if(DEBUG) printf("(pre)%s", yytext);}
{keyword}			{if(DEBUG) printf("(key)%s", yytext);}

{int}					{if(DEBUG) printf("(int)%s", yytext); yylval.int_value = atoi(yytext);return(INT);} // ok
{float}				{if(DEBUG) printf("(float)%s", yytext); yylval.int_value = atof(yytext);}
{char}				{if(DEBUG) printf("(char)%s", yytext);}

{op}					{if(DEBUG) printf("(op)%s", yytext); return yytext[0];}
\n						{if(DEBUG) printf("(\\n)%s", yytext); return yytext[0];}
. 						{ printf("[lex] unknonw char : %s\n", yytext);}

%%
