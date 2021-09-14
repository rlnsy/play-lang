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

[:; \(\)]              ;

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
[oO]ffensive\ rebound   return OFF_RBND;
by                      return BY;
[jJ]ump\ ball           return JMP_BALL;
vs\.                    return VS;
gains\ possession       return GAIN_POSS;
misses                  return MISS;
makes                   return MAKE;
jump\ shot              return SHOT_TYPE_JUMP_SHOT;
from                    return FROM;
ft                      return FEET;
block                   return BLOCK;
layup                   return SHOT_TYPE_LAYUP;
assist                  return ASSIST;
[tT]eam                 return TEAM;
[tT]urnover             return TURNOVER;
shot\ clock             return SHOT_CLOCK;
bad\ pass               return BAD_PASS;
steal                   return STEAL;
lost\ ball              return LOST_BALL;

hook\ shot              return SHOT_TYPE_HOOK_SHOT;
dunk                    return SHOT_TYPE_DUNK;
tip-in                  return SHOT_TYPE_TIP_IN;

[sS]hooting\ foul               return FOUL_TYPE_SHOOTING;
[oO]ffensive\ foul              return FOUL_TYPE_OFFENSIVE;
[lL]oose\ ball\ foul            return FOUL_TYPE_LOOSE_BALL;
[pP]ersonal\ foul               return FOUL_TYPE_PERSONAL;
[pP]ersonal\ take\ foul         return FOUL_TYPE_PERSONAL_TAKE;
[aA]way\ from\ play\ foul       return FOUL_TYPE_AWAY_FROM_PLAY;
[pP]ersonal\ block\ foul        return FOUL_TYPE_PERSONAL_BLOCK;
[oO]ffensive\ charge\ foul      return FOUL_TYPE_OFFENSIVE_CHARGE;
[sS]hooting\ block\ foul        return FOUL_TYPE_SHOOTING_BLOCK;
[iI]nbound\ foul                return FOUL_TYPE_INBOUND;
[pP]unching\ foul               return FOUL_TYPE_PUNCHING;
[cC]lear\ path\ foul            return FOUL_TYPE_CLEAR_PATH;
[tT]echnical\ foul              return FOUL_TYPE_TECHNICAL;
[dD]efensive\ three\ seconds    return FOUL_TYPE_DEFENSIVE_THREE_SECONDS;

drawn\ by                return DRAWN_BY;
at\ rim                  return AT_RIM;
of                       return OF;
free\ throw              return FREE_THROW;
flagrant\ free\ throw    return FLAGRANT;
clear\ path              return CLEAR_PATH;
full\ timeout            return FULL_TIMEOUT;


{digit}-pt              {
                            RSTRIP_NUM(3);
                            return PTS;
                        }

[^:; \(\)\t\n]+          return STR;

%%
            /* SUBROUTINES */

int yywrap(void)
{
	return 1;
}