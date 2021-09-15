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

[:; \(\)]              ;

\t                      return *yytext;                           ;
\n                      return *yytext;                           ;

{digit}+                {
                            yylval.num = atoi(yytext);
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
[fF]lagrant\ foul               return FOUL_TYPE_FLAGRANT;
[dD]ef\ 3\ sec\ tech\ foul return FOUL_TYPE_DEF_3_SEC_TECH;
[dD]ouble\ technical\ foul         return FOUL_TYPE_DOUBLE_TECHNICAL;
[tT]aunting\ technical\ foul         return FOUL_TYPE_TAUNTING_TECHNICAL;
[dD]ouble\ personal\ foul         return FOUL_TYPE_DOUBLE_PERSONAL;
[dD]elay\ tech\ foul         return FOUL_TYPE_DELAY_TECHNICAL;
Non\ unsport\ tech\ foul         return FOUL_TYPE_NON_UNSPORT_TECHNICAL;
Hanging\ tech\ foul         return FOUL_TYPE_HANGING_TECHNICAL;

type                            return TYPE;

drawn\ by                return DRAWN_BY;
at\ rim                  return AT_RIM;
of                       return OF;
free\ throw              return FREE_THROW;
flagrant\ free\ throw    return FLAGRANT_FREE_THROW;
clear\ path\ free\ throw return CLEAR_PATH_FREE_THROW;
full\ timeout            return FULL_TIMEOUT;
Official\ timeout        return OFFICIAL_TIMEOUT;
20\ second\ timeout        return TWENTY_SEC_TIMEOUT;
enters\ the\ game\ for          return SUB;
traveling                       return TRAVEL;
(off|offensive)\ goaltending    return OFFENSIVE_GOALTEND;
def\ goaltending                return DEFENSIVE_GOALTEND;
[vV]iolation                    return VIOLATION;
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
inbounds?                       return INBOUND;
double\ lane                    return DOUBLE_LANE;
illegal\ assist                 return ILLEGAL_ASSIST;
punched\ ball                   return PUNCHED_BALL;
lane                            return LANE;
3\ sec                          return THREE_SEC;
5\ sec                          return FIVE_SEC;
8\ sec                          return EIGHT_SEC;
illegal\ screen                 return ILLEGAL_SCREEN;
jump\ ball\ violation\.?        return JUMP_BALL_VIOLATION;
double\ personal                return DOUBLE_PERSONAL;
swinging\ elbows                return SWINGING_ELBOWS;
score\ in\ opp\.\ basket        return SCORE_IN_OPP_BASKET;
poss.                           return POSS;
and                             return AND;
no                              return NO;
timeout                         return TIMEOUT;


{digit}-pt              {
                            RSTRIP_NUM(3);
                            return PTS;
                        }

[^:; \(\)\t\n]+         {
                            yylval.str = strdup(yytext);
                            return STR;
                        }

%%
            /* SUBROUTINES */

int yywrap(void)
{
	return 1;
}