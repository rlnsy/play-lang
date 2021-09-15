
%{
	#include <stdio.h>
    #include <string.h>
	int yylex(void);
	void yyerror(char *);
	extern char *yytext;

    int parsed_count = 0;

    struct {
        int quarter;
    } state;

    struct {
        char *game;
        char *player_1;
        char *team_name;
    } data;

    void init() {
        memset(&data, 0, sizeof(data));
    }

    void display() {
        parsed_count++;
#ifdef DISPLAY
        printf("%d,%s,%d,%s,%s\n", parsed_count,
            data.game,
            state.quarter,
            data.player_1,
            data.team_name
        );
#endif
        init();
    }

    #define BAD NULL
%}

%union {
    char *str;
    int num;
}

%type<num> NUM
%type<str> STR

%token NUM
%token STR

%token START
%token END
%token QUARTER

%token DEFENSIVE_REBOUND
%token OFF_REBOUND
%token BY
%token JUMP_BALL
%token VS
%token GAIN_POSSESSION
%token PTS
%token MISS;
%token MAKE;
%token FROM;
%token FEET;
%token BLOCK;
%token ASSIST;
%token TEAM;
%token TURNOVER;
%token SHOT_CLOCK;
%token BAD_PASS;
%token STEAL;
%token LOST_BALL;

%token JUMP_SHOT
%token LAYUP
%token HOOK_SHOT
%token DUNK
%token TIP_IN

%token SHOOTING_FOUL
%token OFFENSIVE_FOUL
%token LOOSE_BALL_FOUL
%token PERSONAL_FOUL
%token PERSONAL_TAKE_FOUL
%token AWAY_FROM_PLAY_FOUL
%token PERSONAL_BLOCK_FOUL
%token OFFENSIVE_CHARGE_FOUL
%token SHOOTING_BLOCK_FOUL
%token INBOUND_FOUL
%token PUNCHING_FOUL
%token CLEAR_PATH_FOUL
%token TECHNICAL_FOUL
%token DEFENSIVE_THREE_SECONDS_FOUL
%token FLAGRANT_FOUL
%token DEFENSIVE_3_SECOND_TECH_FOUL
%token DOUBLE_TECHNICAL_FOUL
%token TAUNTING_TECHNICAL_FOUL
%token DOUBLE_PERSONAL_FOUL
%token DELAY_TECHNICAL_FOUL
%token NON_UNSPORT_TECHNICAL_FOUL
%token HANGING_TECHNICAL_FOUL
%token EXCESS_TIMEOUT_TECHNICAL_FOUL

%token DRAWN_BY
%token AT_RIM
%token FREE_THROW
%token FLAGRANT_FREE_THROW CLEAR_PATH_FREE_THROW TECHNICAL_FREE_THROW
%token OF
%token FULL_TIMEOUT
%token SUBSTITUTE
%token TRAVEL
%token OFFENSIVE_GOALTEND DEFENSIVE_GOALTEND
%token VIOLATION
%token OUT_OF_BOUNDS
%token DELAY_OF_GAME
%token CHALLENGE REQUEST INSTANT_REPLAY RULING_STANDS
%token STEP_OUT_OF_BOUNDS
%token DISCONTINUED_DRIBBLE
%token TYPE
%token KICKED_BALL
%token SECOND
%token EJECTED
%token BACK_COURT
%token OVERTIME
%token DOUBLE_DRIBBLE
%token PALMING
%token LANE_VIOLATION
%token INBOUND
%token DOUBLE_LANE
%token ILLEGAL_ASSIST
%token PUNCHED_BALL
%token LANE
%token OFFICIAL_TIMEOUT
%token THREE_SECOND FIVE_SECOND EIGHT_SECOND
%token ILLEGAL_SCREEN
%token JUMP_BALL_VIOLATION
%token DOUBLE_PERSONAL
%token SWINGING_ELBOWS
%token SCORE_IN_OPP_BASKET
%token TWENTY_SECOND_TIMEOUT
%token POSS
%token AND
%token NO
%token TIMEOUT
%token EXCESSIVE_TIMEOUT
%token ENTER_BASKET_FROM_BELOW

%%

plays:	    plays playl
            |
            ;

playl:      game '\t' play '\n'                             { display();}
            ;

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
            | MISS FREE_THROW NUM OF NUM                   { BAD; }
            ;

clockevt:   START NUM QUARTER                              { state.quarter = $2; }
            | END NUM QUARTER
            | START NUM OVERTIME                         { state.quarter = 4 + $2; }
            | END NUM OVERTIME
            ;

jumpball:   JUMP_BALL player VS player
            | JUMP_BALL player VS player player GAIN_POSSESSION
            | JUMP_BALL VS                                   { BAD; }
            | JUMP_BALL player VS                            { BAD; }
            ;

rbndtype:   DEFENSIVE_REBOUND
            | OFF_REBOUND
            ;

rebounder:  player
            | TEAM
            ;

rebound:    rbndtype BY rebounder
            ;

shotextra:  block
            | assist
            |
            ;

shotloc:    FROM NUM FEET
            | AT_RIM
            |
            ;

shot:       PTS shot_type shotloc shotextra
            | FREE_THROW NUM OF NUM
            | FLAGRANT_FREE_THROW
            | FLAGRANT_FREE_THROW NUM OF NUM
            | CLEAR_PATH_FREE_THROW NUM OF NUM
            | TECHNICAL_FREE_THROW
            ;

shotattmpt: player shotres shot
            ;

shotres:    MISS
            | MAKE
            ;

shot_type:  JUMP_SHOT
            | LAYUP
            | HOOK_SHOT
            | DUNK
            | TIP_IN
            ;

block:      BLOCK BY player
            ;

assist:     ASSIST BY player
            ;

player:     STR                                             { data.player_1 = $1; }
            ;

turnovere:  player
            | TEAM
            ;

turnover:   TURNOVER BY turnovere turnoverc
            | TURNOVER BY turnoverc                         { BAD; }
            ;

turnoverc:  SHOT_CLOCK
            | BAD_PASS steal
            | LOST_BALL steal
            | LOST_BALL
            | OFFENSIVE_FOUL
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
            | DOUBLE_PERSONAL
            | SWINGING_ELBOWS
            | SCORE_IN_OPP_BASKET
            | POSS LOST_BALL
            | POSS LOST_BALL steal
            | NO steal
            | EXCESSIVE_TIMEOUT
            | OFFENSIVE_FOUL steal
            | ENTER_BASKET_FROM_BELOW
            | OUT_OF_BOUNDS LOST_BALL steal
            | NO                                { BAD; }
            ;

steal:      STEAL BY player
            ;

foulon:     player

foulby:     player

foulplrs:   foulon
            | foulon DRAWN_BY foulby
            |                                   { BAD; }
            ;

foul:       foultype BY foulplrs
            | FLAGRANT_FOUL TYPE NUM BY foulplrs
            | foultype BY TEAM
            | doublefoul BY player AND player
            | doublefoul BY TEAM
            ;

doublefoul: DOUBLE_TECHNICAL_FOUL
            | DOUBLE_PERSONAL_FOUL
            ;

foultype:   SHOOTING_FOUL
            | OFFENSIVE_FOUL
            | LOOSE_BALL_FOUL
            | PERSONAL_FOUL
            | PERSONAL_TAKE_FOUL
            | AWAY_FROM_PLAY_FOUL
            | PERSONAL_BLOCK_FOUL
            | OFFENSIVE_CHARGE_FOUL
            | SHOOTING_BLOCK_FOUL
            | INBOUND_FOUL
            | PUNCHING_FOUL
            | CLEAR_PATH_FOUL
            | TECHNICAL_FOUL
            | DEFENSIVE_THREE_SECONDS_FOUL
            | DEFENSIVE_3_SECOND_TECH_FOUL
            | TAUNTING_TECHNICAL_FOUL
            | DELAY_TECHNICAL_FOUL
            | NON_UNSPORT_TECHNICAL_FOUL
            | HANGING_TECHNICAL_FOUL
            | EXCESS_TIMEOUT_TECHNICAL_FOUL
            ;

timeout:    team FULL_TIMEOUT
            | OFFICIAL_TIMEOUT
            | team TWENTY_SECOND_TIMEOUT
            | team NO TIMEOUT
            | FULL_TIMEOUT
            ;

team:       STR
            | STR STR
            ;

substitution: player SUBSTITUTE player
                | player SUBSTITUTE                            { BAD; }
                ;

violation:  VIOLATION BY TEAM teamv;
            | VIOLATION BY player playerv
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

ejection:       player EJECTED
                | TEAM EJECTED
                | EJECTED                                   { BAD; }
                ;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s; [line %d]\n", s, parsed_count + 1);
}
