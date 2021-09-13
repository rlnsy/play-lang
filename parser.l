            /* DEFINITIONS */
%{
    #include "y.tab.h"

    #define RSTRIP_NUM(x)        \
        yytext[yyleng - x] = 0; \
        yylval = atoi(yytext);
        
%}

digit   [0-9]

%%
               /* RULES */

[: \(\)]              ;

\t                      return *yytext;                           ;
\n                      return *yytext;                           ;

{digit}+                {
                            yylval = atoi(yytext);
                            return NUM;
                        }

{digit}+(st|nd|rd|th)   {
                            RSTRIP_NUM(2);
                            return NUM;
                        }

[sS]tart\ of            return Q_START;
[eE]nd\ of              return Q_END;
quarter                 return Q_QTR;

[dD]efensive\ rebound   return DEF_RBND;
by                      return BY;
[jJ]ump\ ball           return JMP_BALL;
vs\.                    return VS;
gains\ possession       return GAIN_POSS;
misses                  return MISS;
jump\ shot              return JMP_SHOT;
from                    return FROM;
ft                      return FEET;
block                   return BLOCK;
layup                   return LAYUP;

{digit}-pt              {
                            RSTRIP_NUM(3);
                            return PTS;
                        }

[^: \(\)\t\n]+          return STR;

%%
            /* SUBROUTINES */

int yywrap(void)
{
	return 1;
}