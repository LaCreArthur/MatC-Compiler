%{
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
%}

int						[0-9]+
char		    	[a-zA-Z]
id			    	{char}({char}|{int})*

%%

"else"	{return ELSE;}
{id}		{yylval.string = strdup(yytext); return ID;}
{int}		{yylval.value = atoi(yytext); return NUM;}
"&&"		{return AND;}
"||"		{return OR;}
"!"			{return NOT;}
">"			{return yytext[0];} /* condition */
"+"			{return yytext[0];} /* expression */
"="			{return yytext[0];} /* stmnt */
";"			{return yytext[0];} /* stmnt */
[()]		{return yytext[0];}
\n			{return yytext[0];}
[\t ]		{ }
.				{printf("(lex) unknow char : %s\n", yytext);}

%%

void lex_free() {
	yy_delete_buffer(YY_CURRENT_BUFFER);
	free(yy_buffer_stack);
}
