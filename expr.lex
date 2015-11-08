%{

#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

%}

ident		[a-zA-Z_][0-9a-zA-Z_]*
number	[0-9]
int			{number}+
exp			[Ee][+-]?{number}
float		{int}("."{int})?{exp}?
op			[()*/+-]

%%


{int}			{yylval.int_value = atoi(yytext);return(INT);} // ok
{op}			{return yytext[0];}
\n				{return yytext[0];}
. 				{ printf("[lex] unknonw char : %s\n", yytext);}

%%
