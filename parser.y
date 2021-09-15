
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

%token Q_START
%token Q_END
%token Q_QTR

%token DEF_RBND
%token OFF_RBND
%token BY
%token JMP_BALL
%token VS
%token GAIN_POSS
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

%token SHOT_TYPE_JUMP_SHOT
%token SHOT_TYPE_LAYUP
%token SHOT_TYPE_HOOK_SHOT
%token SHOT_TYPE_DUNK
%token SHOT_TYPE_TIP_IN

%token FOUL_TYPE_SHOOTING
%token FOUL_TYPE_OFFENSIVE
%token FOUL_TYPE_LOOSE_BALL
%token FOUL_TYPE_PERSONAL
%token FOUL_TYPE_PERSONAL_TAKE
%token FOUL_TYPE_AWAY_FROM_PLAY
%token FOUL_TYPE_PERSONAL_BLOCK
%token FOUL_TYPE_OFFENSIVE_CHARGE
%token FOUL_TYPE_SHOOTING_BLOCK
%token FOUL_TYPE_INBOUND
%token FOUL_TYPE_PUNCHING
%token FOUL_TYPE_CLEAR_PATH
%token FOUL_TYPE_TECHNICAL
%token FOUL_TYPE_DEFENSIVE_THREE_SECONDS
%token FOUL_TYPE_FLAGRANT
%token FOUL_TYPE_DEF_3_SEC_TECH
%token FOUL_TYPE_DOUBLE_TECHNICAL
%token FOUL_TYPE_TAUNTING_TECHNICAL
%token FOUL_TYPE_DOUBLE_PERSONAL
%token FOUL_TYPE_DELAY_TECHNICAL
%token FOUL_TYPE_NON_UNSPORT_TECHNICAL
%token FOUL_TYPE_HANGING_TECHNICAL

%token DRAWN_BY
%token AT_RIM
%token FREE_THROW
%token FLAGRANT_FREE_THROW CLEAR_PATH_FREE_THROW TECHNICAL_FREE_THROW
%token OF
%token FULL_TIMEOUT
%token SUB
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
%token THREE_SEC FIVE_SEC EIGHT_SEC
%token ILLEGAL_SCREEN
%token JUMP_BALL_VIOLATION
%token DOUBLE_PERSONAL
%token SWINGING_ELBOWS
%token SCORE_IN_OPP_BASKET
%token TWENTY_SEC_TIMEOUT
%token POSS
%token AND
%token NO
%token TIMEOUT

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

clockevt:   Q_START NUM Q_QTR                              { state.quarter = $2; }
            | Q_END NUM Q_QTR
            | Q_START NUM OVERTIME                         { state.quarter = 4 + $2; }
            | Q_END NUM OVERTIME
            ;

jumpball:   JMP_BALL player VS player
            | JMP_BALL player VS player player GAIN_POSS
            | JMP_BALL VS                                   { BAD; }
            | JMP_BALL player VS                            { BAD; }
            ;

rbndtype:   DEF_RBND
            | OFF_RBND
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

shot_type:  SHOT_TYPE_JUMP_SHOT
            | SHOT_TYPE_LAYUP
            | SHOT_TYPE_HOOK_SHOT
            | SHOT_TYPE_DUNK
            | SHOT_TYPE_TIP_IN
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
            | FOUL_TYPE_OFFENSIVE
            | TRAVEL
            | OFFENSIVE_GOALTEND
            | OUT_OF_BOUNDS LOST_BALL
            | BAD_PASS
            | STEP_OUT_OF_BOUNDS
            | DISCONTINUED_DRIBBLE
            | THREE_SEC
            | FIVE_SEC
            | EIGHT_SEC
            | BACK_COURT
            | DOUBLE_DRIBBLE
            | PALMING
            | TURNOVER
            | LANE_VIOLATION
            | INBOUND
            | ILLEGAL_ASSIST
            | TURNOVER steal
            | PUNCHED_BALL
            | FIVE_SEC INBOUND
            | KICKED_BALL
            | ILLEGAL_SCREEN
            | JUMP_BALL_VIOLATION
            | DOUBLE_PERSONAL
            | SWINGING_ELBOWS
            | SCORE_IN_OPP_BASKET
            | POSS LOST_BALL
            | POSS LOST_BALL steal
            | NO steal
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
            | FOUL_TYPE_FLAGRANT TYPE NUM BY foulplrs
            | foultype BY TEAM
            | doublefoul BY player AND player
            ;

doublefoul: FOUL_TYPE_DOUBLE_TECHNICAL
            | FOUL_TYPE_DOUBLE_PERSONAL
            ;

foultype:   FOUL_TYPE_SHOOTING
            | FOUL_TYPE_OFFENSIVE
            | FOUL_TYPE_LOOSE_BALL
            | FOUL_TYPE_PERSONAL
            | FOUL_TYPE_PERSONAL_TAKE
            | FOUL_TYPE_AWAY_FROM_PLAY
            | FOUL_TYPE_PERSONAL_BLOCK
            | FOUL_TYPE_OFFENSIVE_CHARGE
            | FOUL_TYPE_SHOOTING_BLOCK
            | FOUL_TYPE_INBOUND
            | FOUL_TYPE_PUNCHING
            | FOUL_TYPE_CLEAR_PATH
            | FOUL_TYPE_TECHNICAL
            | FOUL_TYPE_DEFENSIVE_THREE_SECONDS
            | FOUL_TYPE_DEF_3_SEC_TECH
            | FOUL_TYPE_TAUNTING_TECHNICAL
            | FOUL_TYPE_DELAY_TECHNICAL
            | FOUL_TYPE_NON_UNSPORT_TECHNICAL
            | FOUL_TYPE_HANGING_TECHNICAL
            ;

timeout:    team FULL_TIMEOUT
            | OFFICIAL_TIMEOUT
            | team TWENTY_SEC_TIMEOUT
            | team NO TIMEOUT
            ;

team:       STR
            | STR STR
            ;

substitution: player SUB player
                | player SUB                            { BAD; }
                ;

violation:  VIOLATION BY TEAM teamv;
            | VIOLATION BY player playerv
            | VIOLATION BY playerv                      { BAD; }
            ;

teamv:      DEFENSIVE_GOALTEND
            | DELAY_OF_GAME
            | KICKED_BALL
            | JMP_BALL
            | VIOLATION
            | DOUBLE_LANE
            ;

playerv:    DOUBLE_LANE
            | JMP_BALL
            | DEFENSIVE_GOALTEND
            | KICKED_BALL
            | LANE
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
