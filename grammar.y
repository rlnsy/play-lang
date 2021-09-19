
%{
	#include <stdio.h>
    #include <string.h>
    #include <stdlib.h>

	int yylex(void);
	void yyerror(char *);
	extern char *yytext;

    int parsed_count = 0;

    struct {
        char *game;
        int quarter;
        float time;
        char *team;
        char *rebounder;
        char *shooter;
        char *blocked_by;
        char *assist_by;
        char *turnover_by;
        char *steal_by;
        char *double_foul_by_1;
        char *double_foul_by_2;
        char *foul_by;
        char *foul_drawn_by;
        char *sub_out;
        char *sub_in;
        char *violation_by;
        char *ejected;
    } data;

    void init() {
        memset(&data, 0, sizeof(data));
    }

#define TABLE_NAME "plays"

#define DISPLAY

    char *str_buf;

#define quote(str) ((str_buf = malloc(strlen(str) + 2)), \
                        sprintf(str_buf, "\"%s\"", str), str_buf)

#define maybe(str) (str ? quote(str) : "NULL")

    void display() {
        parsed_count++;
#ifdef DISPLAY
        // record prefix
        printf("insert into %s values("

        // schema
        "%s,%d,%f,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s"

        // record suffix
        ");\n",

        TABLE_NAME,

        // data
            quote(data.game),
            data.quarter,
            data.time,
            maybe(data.team),
            maybe(data.rebounder),
            maybe(data.shooter),
            maybe(data.blocked_by),
            maybe(data.assist_by),
            maybe(data.turnover_by),
            maybe(data.steal_by),
            maybe(data.double_foul_by_1),
            maybe(data.double_foul_by_2),
            maybe(data.foul_by),
            maybe(data.foul_drawn_by),
            maybe(data.sub_out),
            maybe(data.sub_in),
            maybe(data.violation_by),
            maybe(data.ejected)
        );
#endif
        init();
    }

#define BAD NULL
%}

%union {
    char *str;
    int num;
    float x;
}

%type<num> NUM
%type<str> STR
%type<str> player
%type<x> TIMESTAMP

%%

plays:	    plays playl
            |
            ;

playl:      game SEP playqtr SEP playtime SEP playteam SEP playdiff SEP play '\n' { display();}

playqtr:    NUM                                             { data.quarter = $1; }

playtime:   TIMESTAMP                                       { data.time = $1; }

playteam:   STR                                             { data.team = $1; }
            | NONE
            ;

playdiff:   NUM

game:       STR                                             { data.game = $1; }
            ;

play:       clockevt
            | rebound
            | jumpball
            | shotattmpt
            | turnover
            | foul
            | timeout
            | substitution
            | violation
            | replay
            | ejection
            ;

clockevt:   START NUM QUARTER
            | END NUM QUARTER
            | START NUM OVERTIME
            | END NUM OVERTIME
            ;

rebound:    rbndtype REBOUND BY rebounder
            ;

rbndtype:   DEFENSIVE
            | OFFENSIVE
            ;

rebounder:  player                                          { data.rebounder = $1; }
            | TEAM
            ;

jumpball:   JUMP_BALL player VS player jumpballres
            | JUMP_BALL VS                                   { BAD; }
            | JUMP_BALL player VS                            { BAD; }
            ;

player:     STR
            ;

jumpballres: player GAIN_POSSESSION
                |
                ;

shotattmpt: shooter shotres shot
            ;

shooter:    player                                          { data.shooter = $1; }
            |                                               { BAD; }
            ;

shotres:    MISS
            | MAKE
            ;

shot:       PTS shot_type shotloc shotextra
            | FREE_THROW NUM OF NUM
            | FLAGRANT_FREE_THROW
            | FLAGRANT_FREE_THROW NUM OF NUM
            | CLEAR_PATH_FREE_THROW NUM OF NUM
            | TECHNICAL_FREE_THROW
            ;

shot_type:  JUMP_SHOT
            | LAYUP
            | HOOK_SHOT
            | DUNK
            | TIP_IN
            ;

shotloc:    FROM NUM FEET
            | AT_RIM
            |
            ;

shotextra:  block
            | assist
            |
            ;

block:      BLOCK BY player                                 { data.blocked_by = $3; }
            ;

assist:     ASSIST BY player                                { data.assist_by = $3; }
            ;

turnover:   TURNOVER BY turnovere turnoverc
            ;

turnovere:  player                                          { data.turnover_by = $1; }
            | TEAM
            |                                               { BAD; }
            ;

turnoverc:  SHOT_CLOCK
            | BAD_PASS steal
            | LOST_BALL steal
            | LOST_BALL
            | OFFENSIVE FOUL
            | TRAVEL
            | TRAVEL steal
            | OFFENSIVE_GOALTEND
            | OUT_OF_BOUNDS LOST_BALL
            | OUT_OF_BOUNDS
            | BAD_PASS
            | STEP_OUT_OF_BOUNDS
            | DISCONTINUED_DRIBBLE
            | THREE_SECOND
            | FIVE_SECOND
            | EIGHT_SECOND
            | BACK_COURT
            | DOUBLE_DRIBBLE
            | PALMING
            | TURNOVER
            | LANE_VIOLATION
            | INBOUND
            | ILLEGAL_ASSIST
            | TURNOVER steal
            | PUNCHED_BALL
            | FIVE_SECOND INBOUND
            | KICKED_BALL
            | ILLEGAL_SCREEN
            | JUMP_BALL_VIOLATION
            | JUMP_BALL_VIOLATION steal
            | DOUBLE PERSONAL
            | SWINGING_ELBOWS
            | SCORE_IN_OPP_BASKET
            | POSS LOST_BALL
            | POSS LOST_BALL steal
            | NO steal
            | EXCESSIVE_TIMEOUT
            | OFFENSIVE FOUL steal
            | ENTER_BASKET_FROM_BELOW
            | OUT_OF_BOUNDS LOST_BALL steal
            | NO                                { BAD; }
            ;

steal:      STEAL BY player                                 { data.steal_by = $3; }
            ;

foul:       foulname BY foulplrs
            | foulname BY TEAM
            | doublefoul BY player AND player               {
                                                                data.double_foul_by_1 = $3,
                                                                data.double_foul_by_2 = $5;
                                                            }
            | doublefoul BY TEAM
            ;

foulname:   foultype FOUL
            | FLAGRANT FOUL TYPE NUM
            | DEFENSIVE_THREE_SECONDS
            ;

foultype:   SHOOTING
            | OFFENSIVE
            | LOOSE_BALL
            | PERSONAL
            | PERSONAL_TAKE
            | AWAY_FROM_PLAY
            | PERSONAL_BLOCK
            | OFFENSIVE_CHARGE
            | SHOOTING_BLOCK
            | INBOUND
            | PUNCHING
            | CLEAR_PATH
            | techtype TECHNICAL
            | DEFENSIVE_3_SECOND_TECH
            ;

techtype: TAUNTING
           | DELAY
           | NON_UNSPORT
           | HANGING
           | EXCESS_TIMEOUT
           |
           ;

foulplrs:   foulby
            | foulby DRAWN_BY foulon
            |                                   { BAD; }
            ;

foulby:     player                              { data.foul_by = $1; }

foulon:     player                              { data.foul_drawn_by = $1; }

doublefoul: DOUBLE foulname
            ;

timeout:    team FULL_TIMEOUT
            | OFFENSIVEICIAL_TIMEOUT
            | team TWENTY_SECOND_TIMEOUT
            | team NO TIMEOUT
            | FULL_TIMEOUT
            ;

team:       STR
            | STR STR
            ;

substitution: player SUBSTITUTE player                         { data.sub_in = $1, data.sub_out = $3; }
                | player SUBSTITUTE                            { BAD; }
                ;

violation:  VIOLATION BY TEAM teamv;
            | VIOLATION BY player playerv                      { data.violation_by = $3; }
            | VIOLATION BY playerv                      { BAD; }
            ;

teamv:      DEFENSIVE_GOALTEND
            | DELAY_OF_GAME
            | KICKED_BALL
            | JUMP_BALL
            | VIOLATION
            | DOUBLE_LANE
            ;

playerv:    DOUBLE_LANE
            | JUMP_BALL
            | DEFENSIVE_GOALTEND
            | KICKED_BALL
            | LANE
            | NO                                { BAD; }
            ;

replay:     INSTANT_REPLAY replay_reason replay_result
            | INSTANT_REPLAY
            ;

replay_reason: CHALLENGE
                | REQUEST
                ;

replay_result: RULING_STANDS
                |
                ;

ejection:       player EJECTED                              { data.ejected = $1; }
                | TEAM EJECTED
                | EJECTED                                   { BAD; }
                ;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s; [line %d]\n", s, parsed_count + 1);
}
