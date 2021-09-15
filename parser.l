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

[sS]tart\ of            return START;
[eE]nd\ of              return END;
quarter                 return QUARTER;

[dD]efensive\ rebound   return DEFENSIVE_REBOUND;
[oO]ffensive\ rebound   return OFF_REBOUND;
by                      return BY;
[jJ]ump\ ball           return JUMP_BALL;
vs\.                    return VS;
gains\ possession       return GAIN_POSSESSION;
misses                  return MISS;
makes                   return MAKE;
jump\ shot              return JUMP_SHOT;
from                    return FROM;
ft                      return FEET;
block                   return BLOCK;
layup                   return LAYUP;
assist                  return ASSIST;
[tT]eam                 return TEAM;
[tT]urnover             return TURNOVER;
shot\ clock             return SHOT_CLOCK;
bad\ pass               return BAD_PASS;
steal                   return STEAL;
lost\ ball              return LOST_BALL;

hook\ shot              return HOOK_SHOT;
dunk                    return DUNK;
tip-in                  return TIP_IN;

[sS]hooting\ foul               return SHOOTING_FOUL;
[oO]ffensive\ foul              return OFFENSIVE_FOUL;
[lL]oose\ ball\ foul            return LOOSE_BALL_FOUL;
[pP]ersonal\ foul               return PERSONAL_FOUL;
[pP]ersonal\ take\ foul         return PERSONAL_TAKE_FOUL;
[aA]way\ from\ play\ foul       return AWAY_FROM_PLAY_FOUL;
[pP]ersonal\ block\ foul        return PERSONAL_BLOCK_FOUL;
[oO]ffensive\ charge\ foul      return OFFENSIVE_CHARGE_FOUL;
[sS]hooting\ block\ foul        return SHOOTING_BLOCK_FOUL;
[iI]nbound\ foul                return INBOUND_FOUL;
[pP]unching\ foul               return PUNCHING_FOUL;
[cC]lear\ path\ foul            return CLEAR_PATH_FOUL;
[tT]echnical\ foul              return TECHNICAL_FOUL;
[dD]efensive\ three\ seconds    return DEFENSIVE_THREE_SECONDS_FOUL;
[fF]lagrant\ foul               return FLAGRANT_FOUL;
[dD]ef\ 3\ sec\ tech\ foul return DEFENSIVE_3_SECOND_TECH_FOUL;
[dD]ouble\ technical\ foul         return DOUBLE_TECHNICAL_FOUL;
[tT]aunting\ technical\ foul         return TAUNTING_TECHNICAL_FOUL;
[dD]ouble\ personal\ foul         return DOUBLE_PERSONAL_FOUL;
[dD]elay\ tech\ foul         return DELAY_TECHNICAL_FOUL;
Non\ unsport\ tech\ foul         return NON_UNSPORT_TECHNICAL_FOUL;
Hanging\ tech\ foul         return HANGING_TECHNICAL_FOUL;
Excess\ timeout\ tech\ foul        return EXCESS_TIMEOUT_TECHNICAL_FOUL;

type                            return TYPE;

drawn\ by                return DRAWN_BY;
at\ rim                  return AT_RIM;
of                       return OF;
free\ throw              return FREE_THROW;
flagrant\ free\ throw    return FLAGRANT_FREE_THROW;
clear\ path\ free\ throw return CLEAR_PATH_FREE_THROW;
full\ timeout            return FULL_TIMEOUT;
Official\ timeout        return OFFICIAL_TIMEOUT;
20\ second\ timeout        return TWENTY_SECOND_TIMEOUT;
enters\ the\ game\ for          return SUBSTITUTE;
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
3\ sec                          return THREE_SECOND;
5\ sec                          return FIVE_SECOND;
8\ sec                          return EIGHT_SECOND;
illegal\ screen                 return ILLEGAL_SCREEN;
jump\ ball\ violation\.?        return JUMP_BALL_VIOLATION;
double\ personal                return DOUBLE_PERSONAL;
swinging\ elbows                return SWINGING_ELBOWS;
score\ in\ opp\.\ basket        return SCORE_IN_OPP_BASKET;
poss.                           return POSS;
and                             return AND;
no                              return NO;
timeout                         return TIMEOUT;
excessive\ timeout              return EXCESSIVE_TIMEOUT;
enter\ basket\ from\ below      return ENTER_BASKET_FROM_BELOW;


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