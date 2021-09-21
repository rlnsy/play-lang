
%{
	#include <stdio.h>
    #include <string.h>
    #include <stdlib.h>

    #include "codes.h"

	int yylex(void);
	void yyerror(char *);
	extern char *yytext;

    int parsed_count = 0;

    struct {
        char *game;
        int quarter;
        float time;
        int play_type;
        char *team;
        int points_gained;
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
        int shot_result;
        int clock_event;
        int rebound_type;
        int team_rebound;
        char *jump_ball_player_1;
        char *jump_ball_player_2;
        char *jump_ball_winner;
        int shot_type;
        int shot_distance;
        int free_throw_number;
        int free_throw_total;
        int team_turnover;
        int team_foul;
        int double_foul;
        int shot_value;
        int turnover_type;
        int team_ejected;
        int oob_type;
        int foul_type;
        int tech_type;
    } data;

    void init() {
        memset(&data, 0, sizeof(data));
    }

#define TABLE_NAME "plays"
#define NULL_TOKEN "NULL"

#define DISPLAY

    char *str_buf;

#define quote(str) ((str_buf = malloc(strlen(str) + 2)), \
                        sprintf(str_buf, "\"%s\"", str), str_buf)

#define maybe(str) (str ? quote(str) : NULL_TOKEN)

#define itoa(num) ((str_buf = malloc(strlen("99"))), sprintf(str_buf, "%d", num), str_buf)

#define nonzero(i) (i ? itoa(i) : NULL_TOKEN)
#define nonneg(i) (i ? itoa(i) : NULL_TOKEN)

    void display() {
        parsed_count++;
#ifdef DISPLAY
        // record prefix
        printf("insert into %s values("

        // schema - most are of type string since we print NULL as string
        "%s,%d,%f,%s,%s,%d,%s,%s,%s,%s,"
        "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,"
        "%s,%s,%s,%d,%s,%s,%s,%s,%s,%s,"
        "%s,%d,%d,%d,%s,%s,%d,%s,%s,%s"

        // record suffix
        ");\n",

        TABLE_NAME,

        // data
            quote(data.game),
            data.quarter,
            data.time,
            nonzero(data.play_type),
            maybe(data.team),
            data.points_gained,
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
            maybe(data.ejected),
            nonzero(data.shot_result),
            nonzero(data.clock_event),
            nonzero(data.rebound_type),
            data.team_rebound,
            maybe(data.jump_ball_player_1),
            maybe(data.jump_ball_player_2),
            maybe(data.jump_ball_winner),
            nonzero(data.shot_type),
            nonneg(data.shot_distance),
            nonzero(data.free_throw_number),
            nonzero(data.free_throw_total),
            data.team_turnover,
            data.team_foul,
            data.double_foul,
            nonzero(data.shot_value),
            nonzero(data.turnover_type),
            data.team_ejected,
            nonzero(data.oob_type),
            nonzero(data.foul_type),
            nonzero(data.tech_type)
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
%type<num> PTS
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

playdiff:   NUM                                             { data.points_gained = $1; }

game:       STR                                             { data.game = $1; }
            ;

play:       clockevt                                        { data.play_type = PLAY_TYPE_CLOCKEVT; }
            | rebound                                       { data.play_type = PLAY_TYPE_REBOUND; }
            | jumpball                                      { data.play_type = PLAY_TYPE_JUMPBALL; }
            | shotattmpt                                    { data.play_type = PLAY_TYPE_SHOTATT; }
            | turnover                                      { data.play_type = PLAY_TYPE_TURNOVER; }
            | foul                                          { data.play_type = PLAY_TYPE_FOUL; }
            | timeout                                       { data.play_type = PLAY_TYPE_TIMEOUT; }
            | substitution                                  { data.play_type = PLAY_TYPE_SUBST; }
            | violation                                     { data.play_type = PLAY_TYPE_VIOLATION; }
            | replay                                        { data.play_type = PLAY_TYPE_REPLAY; }
            | ejection                                      { data.play_type = PLAY_TYPE_EJECTION; }
            ;

clockevt:   START NUM QUARTER                               { data.clock_event = CLOCKEVT_QSTART; }
            | END NUM QUARTER                               { data.clock_event = CLOCKEVT_QEND; }
            | START NUM OVERTIME                            { data.clock_event = CLOCKEVT_OSTART; }
            | END NUM OVERTIME                              { data.clock_event = CLOCKEVT_OEND; }
            ;

rebound:    rbndtype REBOUND BY rebounder
            ;

rbndtype:   DEFENSIVE                                       { data.rebound_type = REBOUND_TYPE_DEFENSIVE; }
            | OFFENSIVE                                     { data.rebound_type = REBOUND_TYPE_OFFENSIVE; }
            ;

rebounder:  player                                          { data.rebounder = $1; }
            | TEAM                                          { data.team_rebound = 1; }
            ;

jumpball:   JUMP_BALL player VS player jumpballres           {
                                                                data.jump_ball_player_1 = $2;
                                                                data.jump_ball_player_2 = $4;
                                                             }
            | JUMP_BALL VS                                   { BAD; }
            | JUMP_BALL player VS                            { BAD; }
            ;

player:     STR
            ;

jumpballres: player GAIN_POSSESSION                         { data.jump_ball_winner = $1; }
                |
                ;

shotattmpt: shooter shotres shot
            ;

shooter:    player                                          { data.shooter = $1; }
            |                                               { BAD; }
            ;

shotres:    MISS                                            { data.shot_result = SHOT_RESULT_MISS; }
            | MAKE                                          { data.shot_result = SHOT_RESULT_MAKE; }
            ;

shot:       PTS shot_type shotloc shotextra                 { data.shot_value = $1; }
            | FREE_THROW NUM OF NUM                         { data.free_throw_number = $2; data.free_throw_total = $4; }
            | FLAGRANT_FREE_THROW                           { data.free_throw_number = 1; data.free_throw_total = 1; }
            | FLAGRANT_FREE_THROW NUM OF NUM                { data.free_throw_number = $2; data.free_throw_total = $4; }
            | CLEAR_PATH_FREE_THROW NUM OF NUM              { data.free_throw_number = $2; data.free_throw_total = $4; }
            | TECHNICAL_FREE_THROW                          { data.free_throw_number = 1; data.free_throw_total = 1; }
            ;

shot_type:  JUMP_SHOT                                       { data.shot_type = SHOT_TYPE_JUMP_SHOT; }
            | LAYUP                                         { data.shot_type = SHOT_TYPE_LAYUP; }
            | HOOK_SHOT                                     { data.shot_type = SHOT_TYPE_HOOK_SHOT; }
            | DUNK                                          { data.shot_type = SHOT_TYPE_DUNK; }
            | TIP_IN                                        { data.shot_type = SHOT_TYPE_TIP_IN; }
            ;

shotloc:    FROM NUM FEET                                   { data.shot_distance = $2; }
            | AT_RIM                                        { data.shot_distance = 0; }
            |                                               {
                                                                data.shot_distance = -1; // unknown
                                                            }
            ;

shotextra:  block
            | assist
            |
            ;

block:      BLOCK BY player                                 { data.blocked_by = $3; }
            ;

assist:     ASSIST BY player                                { data.assist_by = $3; }
            ;

turnover:   TURNOVER BY player player_turnover              { data.turnover_by = $3; }
            | TURNOVER BY TEAM team_turnover                { data.team_turnover = 1; }
            | TURNOVER BY player_turnover
            ;

player_turnover: pturnoverc steal
                | pturnoverc
                ;

team_turnover: teamv                                        { data.turnover_type = TURNOVER_TYPE_TEAM_VIOLATION; }
                | pturnoverc
                ;

outofbounds: 
            | STEP_OUT_OF_BOUNDS                            { data.oob_type = OOB_TYPE_STEP_OUT_OF_BOUNDS; }
            | OUT_OF_BOUNDS lost_ball                       { data.oob_type = OOB_TYPE_LOST_BALL; }
            | OUT_OF_BOUNDS
            ;

lost_ball:  LOST_BALL
            | possible LOST_BALL
            ;

possible:   POSS

pturnoverc:  bad_pass                                       { data.turnover_type = TURNOVER_TYPE_BAD_PASS; }
            | lost_ball                                     { data.turnover_type = TURNOVER_TYPE_LOST_BALL; }
            | playerv                                       { data.turnover_type = TURNOVER_TYPE_PLAYER_VIOLATION; }
            | foulname                                      { data.turnover_type = TURNOVER_TYPE_FOUL; }
            | TURNOVER
            | NO                            { BAD; }
            ;

bad_pass:   BAD_PASS

steal:      STEAL BY player                                 { data.steal_by = $3; }
            ;

foul:       foulname BY foulplrs
            | foulname BY TEAM                              { data.team_foul = 1; }
            | doublefoul BY player AND player               {
                                                                data.double_foul = 1;
                                                                data.double_foul_by_1 = $3,
                                                                data.double_foul_by_2 = $5;
                                                            }
            | doublefoul BY TEAM                            { data.double_foul = 1; data.team_foul = 1; }
            ;

foulname:   foultype FOUL
            | FLAGRANT_FOUL_TYPE_1                          { data.foul_type = FOUL_TYPE_FLAGRANT_1; }
            | FLAGRANT_FOUL_TYPE_2                          { data.foul_type = FOUL_TYPE_FLAGRANT_2; }
            | DEFENSIVE_THREE_SECONDS                       { data.foul_type = FOUL_TYPE_DEF_3_SEC; }
            | EIGHT_SECOND                                  { data.foul_type = FOUL_TYPE_EIGHT_SEC; }
            | THREE_SECOND                                  { data.foul_type = FOUL_TYPE_THREE_SEC; }
            | DOUBLE foultype
            ;

foultype:   SHOOTING                                        { data.foul_type = FOUL_TYPE_SHOOTING; }
            | OFFENSIVE                                     { data.foul_type = FOUL_TYPE_OFFENSIVE; }
            | LOOSE_BALL                                    { data.foul_type = FOUL_TYPE_LOOSE_BALL; }
            | PERSONAL                                      { data.foul_type = FOUL_TYPE_PERSONAL; }
            | PERSONAL_TAKE                                 { data.foul_type = FOUL_TYPE_PERSONAL_TAKE; }
            | AWAY_FROM_PLAY                                { data.foul_type = FOUL_TYPE_AWAY_FROM_PLAY; }
            | PERSONAL_BLOCK                                { data.foul_type = FOUL_TYPE_PERSONAL_BLOCK; }
            | OFFENSIVE_CHARGE                              { data.foul_type = FOUL_TYPE_OFFENSIVE_CHARGE; }
            | SHOOTING_BLOCK                                { data.foul_type = FOUL_TYPE_SHOOTING_BLOCK; }
            | INBOUND                                       { data.foul_type = FOUL_TYPE_INBOUND; }
            | PUNCHING                                      { data.foul_type = FOUL_TYPE_PUNCHING; }
            | CLEAR_PATH                                    { data.foul_type = FOUL_TYPE_CLEAR_PATH; }
            | techfoul                                      { data.foul_type = FOUL_TYPE_TECHNICAL; }
            ;

techfoul:   techtype TECHNICAL
            | DEFENSIVE_3_SECOND_TECH                       { data.tech_type = TECH_TYPE_DEF_3_SEC; }
            ;

techtype: TAUNTING                                          { data.tech_type = TECH_TYPE_TAUNTING; }
           | DELAY                                          { data.tech_type = TECH_TYPE_DELAY; }
           | NON_UNSPORT                                    { data.tech_type = TECH_TYPE_NON_UNSPORT; }
           | HANGING                                        { data.tech_type = TECH_TYPE_HANGING; }
           | EXCESS_TIMEOUT                                 { data.tech_type = TECH_TYPE_EXCESS_TIMEOUT; }
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
            | OFFICIAL_TIMEOUT
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
            | SHOT_CLOCK
            | EXCESSIVE_TIMEOUT
            ;

playerv:    DOUBLE_LANE
            | jumpball_violation
            | goaltend
            | KICKED_BALL
            | lane_violation
            | DISCONTINUED_DRIBBLE
            | TRAVEL
            | BACK_COURT
            | DOUBLE_DRIBBLE
            | PALMING
            | outofbounds
            | inbound_violation
            | ILLEGAL_ASSIST
            | PUNCHED_BALL
            | ILLEGAL_SCREEN
            | SWINGING_ELBOWS
            | SCORE_IN_OPP_BASKET
            | ENTER_BASKET_FROM_BELOW
            | NO                                { BAD; }
            ;

jumpball_violation: JUMP_BALL
                    | JUMP_BALL_VIOLATION
                    ;

inbound_violation: INBOUND
                    | FIVE_SECOND INBOUND
                    | FIVE_SECOND
                    ;

lane_violation: LANE
                | LANE_VIOLATION
                ;

goaltend:   OFFENSIVE_GOALTEND
            | DEFENSIVE_GOALTEND
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
                | TEAM EJECTED                              { data.team_ejected = 1; }
                | EJECTED                                   { BAD; }
                ;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s; [line %d]\n", s, parsed_count + 1);
}
