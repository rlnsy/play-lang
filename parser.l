            /* DEFINITIONS */
%{
    #include "y.tab.h"
%}

    /* whitespace character */
wsc     [ \t\n]
    /* non-whitespace character */
c       [^ \t\n]

%%
               /* RULES */

\n                      return *yytext;

[\(\)\.; \t]            ; /* skip */

[dD]efensive\ rebound   return DEF_RBND;
by                      return BY;

{c}+                    return STR;

%%
            /* SUBROUTINES */

int yywrap(void)
{
	return 1;
}