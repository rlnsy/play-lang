            /* DEFINITIONS */
%{
    #include "y.tab.h"

    #define RSTRIP_NUM(x)        \
        yytext[yyleng - x] = 0; \
        yylval.num = atoi(yytext);
        
%}

digit   [0-9]

%%
               /* RULES */

{digit}+:{digit}+\.{digit}      {
                                    int min, sec, dec;
                                    sscanf(yytext, "%d:%d.%d", &min, &sec, &dec);
                                    yylval.x = (min * 60) + sec + (dec / 10.0);
                                    return TIMESTAMP;
                                }

    /* Skip these characters */
[:; \(\)]              ;

    /* Recognized whitespace, pass them along */
\t                      return *yytext;                           ;
\n                      return *yytext;                           ;


\|                      return SEP;

{digit}+                {
                            yylval.num = atoi(yytext);
                            return NUM;
                        }

    /* Friendly english representations of numeric indices */
{digit}+(st|nd|rd|th)   {
                            RSTRIP_NUM(2);
                            return NUM;
                        }

    /* Point description */
(2|3)-pt                {
                            RSTRIP_NUM(3);
                            return PTS;
                        }

    /* Other patterns */
[sS]tart\ of                    return START;
[eE]nd\ of                      return END;
quarter                         return QUARTER;
[dD]efensive                    return DEFENSIVE;
[rR]ebound                      return REBOUND;
by                              return BY;
[jJ]ump\ ball                   return JUMP_BALL;
vs\.                            return VS;
gains\ possession               return GAIN_POSSESSION;
misses                          return MISS;
makes                           return MAKE;
jump\ shot                      return JUMP_SHOT;
shot                            return SHOT;
from                            return FROM;
ft                              return FEET;
block                           return BLOCK;
layup                           return LAYUP;
assist                          return ASSIST;
[tT]eam                         return TEAM;
[tT]urnover                     return TURNOVER;
shot\ clock                     return SHOT_CLOCK;
bad\ pass                       return BAD_PASS;
stolen\ pass                    return STOLEN_PASS;
steal                           return STEAL;
lost\ ball                      return LOST_BALL;
hook\ shot                      return HOOK_SHOT;
dunk                            return DUNK;
tip-in                          return TIP_IN;
foul                            return FOUL;
[sS]hooting                     return SHOOTING;
[oO]ffensive                    return OFFENSIVE;
[lL]oose\ ball                  return LOOSE_BALL;
[pP]ersonal                     return PERSONAL;
[pP]ersonal\ take               return PERSONAL_TAKE;
[aA]way\ from\ play             return AWAY_FROM_PLAY;
[pP]ersonal\ block              return PERSONAL_BLOCK;
[oO]ffensive\ charge            return OFFENSIVE_CHARGE;
[sS]hooting\ block              return SHOOTING_BLOCK;
[pP]unching                     return PUNCHING;
[cC]lear\ path                  return CLEAR_PATH;
[tT]ech(nical)?                 return TECHNICAL;
[dD]efensive\ three\ seconds    return DEFENSIVE_THREE_SECONDS;
[fF]lagrant\ foul\ type\ 1      return FLAGRANT_FOUL_TYPE_1;
[fF]lagrant\ foul\ type\ 2      return FLAGRANT_FOUL_TYPE_2;
[dD]ef\ 3\ sec\ tech            return DEFENSIVE_3_SECOND_TECH;
[tT]aunting                     return TAUNTING;
[dD]elay                        return DELAY;
Non\ unsport                    return NON_UNSPORT;
Hanging                         return HANGING;
Excess\ timeout                 return EXCESS_TIMEOUT;
[dD]ouble                       return DOUBLE;
type                            return TYPE;
drawn\ by                       return DRAWN_BY;
at\ rim                         return AT_RIM;
of                              return OF;
free\ throw                     return FREE_THROW;
flagrant\ free\ throw           return FLAGRANT_FREE_THROW;
clear\ path\ free\ throw        return CLEAR_PATH_FREE_THROW;
full\ timeout                   return FULL_TIMEOUT;
Official\ timeout               return OFFICIAL_TIMEOUT;
20\ second\ timeout             return TWENTY_SECOND_TIMEOUT;
enters\ the\ game\ for          return SUBSTITUTE;
traveling                       return TRAVEL;
(off|offensive)\ goaltending    return OFFENSIVE_GOALTEND;
def\ goaltending                return DEFENSIVE_GOALTEND;
[vV]iolation\.?                 return VIOLATION;
out\ of\ bounds                 return OUT_OF_BOUNDS;
delay\ of\ game                 return DELAY_OF_GAME;
[iI]nstant\ [rR]eplay           return INSTANT_REPLAY;
[cC]hallenge                    return CHALLENGE;
[rR]equest                      return REQUEST;
([rR]uling)?\ [sS]tands         return RULING_STANDS;
[tT]echnical\ free\ throw       return TECHNICAL_FREE_THROW;
[sS]tep\ out\ of\ bounds        return STEP_OUT_OF_BOUNDS;
discontinued\ dribble           return DISCONTINUED_DRIBBLE;
kicked\ ball                    return KICKED_BALL;
sec                             return SECOND;
ejected\ from\ game             return EJECTED;
back\ court                     return BACK_COURT;
overtime                        return OVERTIME;
dbl\ dribble                    return DOUBLE_DRIBBLE;
palming                         return PALMING;
lane\ violation\.?              return LANE_VIOLATION;
[iI]nbounds?                    return INBOUND;
double\ lane                    return DOUBLE_LANE;
illegal\ assist                 return ILLEGAL_ASSIST;
punched\ ball                   return PUNCHED_BALL;
lane                            return LANE;
3\ sec                          return THREE_SECOND;
5\ sec                          return FIVE_SECOND;
8\ sec                          return EIGHT_SECOND;
illegal\ screen                 return ILLEGAL_SCREEN;
jump\ ball\ violation\.?        return JUMP_BALL_VIOLATION;
swinging\ elbows                return SWINGING_ELBOWS;
score\ in\ opp\.\ basket        return SCORE_IN_OPP_BASKET;
poss.                           return POSS;
and                             return AND;
no                              return NO;
timeout                         return TIMEOUT;
excessive\ timeout              return EXCESSIVE_TIMEOUT;
enter\ basket\ from\ below      return ENTER_BASKET_FROM_BELOW;
NA                              return NONE;
\/                              return SLASH;
player                          return PLAYER;
coach                           return COACH;
unknown                         return UNKNOWN;
isolation                       return ISOLATION;
[eE]lbow                        return ELBOW;

    /* This is an arbitrary length string of allowed characters */
[^:; \(\)\t\n\|\/]+     {
                            yylval.str = strdup(yytext);
                            return STR;
                        }
%%
            /* SUBROUTINES */

int yywrap(void)
{
	return 1;
}