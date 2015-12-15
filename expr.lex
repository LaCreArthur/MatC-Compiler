%{
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "expr.h"
#define column_incr column+=strlen(yytext)
int DEBUG = 0;
int line = 1;
int column = 1;
%}

number				[0-9]
int						{number}+
exp						[Ee][+-]?{number}+
float					{number}*"."{number}*
char		    	[a-zA-Z]
id			    	{char}({char}|{int})*
op						[+*/()=-]
/*relop					"=="|"!="|">"|"<"|">="|"<="*/
newline				"\n"
escapesec   	"\a"|"\\b"|"\t"|"\\t"|"\b"|"\\a"|" "
types					matrix|int|float
keyword 	   	else|if|for|while|matrix|return

comment 	  	\/\*([^\*]*\*[\*]*[^\/\*])*[^\*]*\*[\*]*\/
string				\"([^"])*\"
noaplha				[\'\"\{\};,]

%%

{newline}			{ printf("%s", yytext); line++; column = 1;}
"\t"					{ printf("%s", yytext); column += 4;}
{escapesec}   { printf("%s", yytext); column_incr;}
"int"		  	  { printf("%s", yytext); column_incr; yylval.int_value = 0; return TYPE; }
"float"		    { printf("%s", yytext); column_incr; yylval.int_value = 1; return TYPE; }
"matrix"	    { printf("%s", yytext); column_incr; yylval.int_value = 2; return TYPE; }
"main"				{	printf("main"); column_incr; return MAIN;}
"print"				{	printf("%s", yytext); column_incr; return PRINT;}
"printf"			{	printf("%s", yytext); column_incr; return PRINTF;}
"printmat"		{	printf("%s", yytext); column_incr; return PRINTM;}
"if"					{	printf("%s", yytext); column_incr; return IF;}
"else"				{	printf("%s", yytext); column_incr; return ELSE;}
"while"				{	printf("%s", yytext); column_incr; return WHILE;}
"for"				{	printf("%s", yytext); column_incr; return FOR;}
"=="					{	printf("%s", yytext); column_incr; yylval.int_value = 8;  return RELOP;} /* 9 : int code for the enum */
"!="					{	printf("%s", yytext); column_incr; yylval.int_value = 9; return RELOP;}
">"						{	printf("%s", yytext); column_incr; yylval.int_value = 10; return RELOP;}
"<"						{	printf("%s", yytext); column_incr; yylval.int_value = 11; return RELOP;}
">="					{	printf("%s", yytext); column_incr; yylval.int_value = 12; return RELOP;}
"<="					{	printf("%s", yytext); column_incr; yylval.int_value = 13; return RELOP;}
"!"						{	printf("%s", yytext); column_incr; yylval.int_value = 14; return NOT;}
"&&"					{	printf("%s", yytext); column_incr; yylval.int_value = 15; return AND;}
"||"					{	printf("%s", yytext); column_incr; yylval.int_value = 16; return OR;}
"]"                {    printf("%s", yytext); column_incr; return ']';}
"["                {    printf("%s", yytext); column_incr; return '[';}


{int}					{ yylval.int_value = atoi(yytext); column_incr; return(INT);}
{float}+({exp})?	{ yylval.float_value=atof(yytext); column_incr; return(FLOAT); }
{float}*({exp})?  { yylval.float_value=atof(yytext); column_incr; return(FLOAT); }
{id}					{ if(DEBUG) printf(" id_");  printf("%s", yytext); column_incr;
								yylval.str_value = safeId(strdup(yytext)); return ID;}

"++"|"--"			{ printf("%s", yytext); yylval.str_value = yytext; column_incr; return INCRorDECR;}
{string}			{ if(DEBUG) printf(" str_");  printf("%s", yytext); yylval.str_value = strdup(yytext);
								column_incr; return STR;}
{op}					{ printf("%c", yytext[0]); column_incr; return(yytext[0]);}
{comment}     { printf("%s", yytext); column_incr;}


{noaplha}			{ printf("%c", yytext[0]); return(yytext[0]);}
. 						{ printf("[lex] unknown char : %s\n", yytext);}

%%
