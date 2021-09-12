            /* DEFINITIONS */
%{
    #include "y.tab.h"
%}

    /* whitespace character */
wsc     [ \t\n]
    /* non-whitespace character */
c       [^ \t\n]

digit   [0-9]

%%
               /* RULES */

\n                      return *yytext;

[\(\)\.; \t]            ; /* skip */

{digit}+                {
                            yylval = atoi(yytext);
                            return NUM;
                        }

{digit}+(st|nd|rd|th)   {
                            /* strip off the number suffix */
                            yytext[yyleng - 2] = 0;
                            yylval = atoi(yytext);
                            return NUM;
                        }

[sS]tart\ of            return Q_START;
[eE]nd\ of              return Q_END;
quarter                 return Q_QTR;

[dD]efensive\ rebound   return DEF_RBND;
by                      return BY;

{c}+                    return STR;

%%
            /* SUBROUTINES */

int yywrap(void)
{
	return 1;
}