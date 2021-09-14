
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
        printf("%d,%s,%d,%s,%s\n", ++parsed_count,
            data.game,
            state.quarter,
            data.player_1,
            data.team_name
        );
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

%token DRAWN_BY
%token AT_RIM
%token FREE_THROW
%token FLAGRANT
%token CLEAR_PATH
%token OF
%token FULL_TIMEOUT
%token SUB
%token TRAVEL
%token OFFENSIVE_GOALTEND DEFENSIVE_GOALTEND
%token VIOLATION
%token OUT_OF_BOUNDS
%token DELAY_OF_GAME
%token CHALLENGE REQUEST INSTANT_REPLAY RULING_STANDS

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
            | jmpblldesc
            | shotattmpt
            | turnover
            | foul
            | timeout
            | substitution
            | violation
            | replay
            ;

clockevt:   Q_START NUM Q_QTR                              { state.quarter = $2; }
            | Q_END NUM Q_QTR
            ;

jumpball:   JMP_BALL player VS player
            ;

jmpblldesc: jumpball
            | jumpball player GAIN_POSS
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
            | FLAGRANT FREE_THROW
            | FLAGRANT FREE_THROW NUM OF NUM
            | CLEAR_PATH FREE_THROW NUM OF NUM
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

turnoverc:  SHOT_CLOCK
            | BAD_PASS steal
            | LOST_BALL steal
            | FOUL_TYPE_OFFENSIVE
            | TRAVEL
            | OFFENSIVE_GOALTEND
            | OUT_OF_BOUNDS LOST_BALL
            | BAD_PASS
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
            ;

timeout:    team FULL_TIMEOUT
            |
            ;

team:       STR                     { data.team_name = $1; }
            ;

substitution: player SUB player
                ;

violation:  VIOLATION BY TEAM teamv;
            ;

teamv:      DEFENSIVE_GOALTEND
            | DELAY_OF_GAME
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

%%

void yyerror(char *s) {
	fprintf(stderr, "%s; [line %d]\n", s, parsed_count + 1);
}
