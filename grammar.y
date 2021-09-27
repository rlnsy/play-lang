
%{
	#include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdarg.h>

    #include "codes.h"

    typedef unsigned char byte;
    typedef byte tinyuint;
    typedef char * text;
    typedef byte boolean;
    typedef float real;

	int yylex(void);
	void yyerror(char *);
	extern char *yytext;

    int parsed_count = 0;
    int shot_count;

    struct {
        int game_year;
        tinyuint game_month;
        tinyuint game_day;
        text game_home;
        tinyuint game_num;
        int play_num;
        tinyuint quarter;
        real time;
        tinyuint play_type;
        text team_name;
        int team_year;
        int shot_num;
        tinyuint points_gained;
        text rebounder;
        text shooter;
        text blocked_by;
        text assist_by;
        text turnover_by;
        text steal_by;
        text double_foul_by_1;
        text double_foul_by_2;
        text foul_by;
        text foul_drawn_by;
        text foul_by_coach;
        text sub_out;
        text sub_in;
        text violation_by;
        text ejected;
        text coach_ejected;
        tinyuint shot_result;
        tinyuint clock_event;
        tinyuint rebound_type;
        boolean team_rebound;
        text jump_ball_player_1;
        text jump_ball_player_2;
        text jump_ball_winner;
        tinyuint shot_type;
        tinyuint shot_distance;
        tinyuint free_throw_number;
        tinyuint free_throw_total;
        boolean team_turnover;
        boolean team_foul;
        boolean double_foul;
        tinyuint shot_value;
        tinyuint turnover_type;
        boolean team_ejected;
        tinyuint oob_type;
        tinyuint foul_type;
        tinyuint tech_type;
        tinyuint timeout_type;
        boolean team_violation;
        tinyuint violation_type;
        tinyuint replay_type;
        tinyuint replay_result;
    } data;

    void init() {
        memset(&data, 0, sizeof(data));
    }

#define NULL_TOKEN "NULL"

    char *str_buf;

#define quote(str) ((str_buf = malloc(strlen(str) + 2)), \
                        sprintf(str_buf, "\"%s\"", str), str_buf)

#define maybe(str) (str ? quote(str) : NULL_TOKEN)

#define MAX_BYTE_STRLEN (strlen("255"))

#define itoa(num) ((str_buf = malloc(MAX_BYTE_STRLEN)), sprintf(str_buf, "%d", num), str_buf)

#define nonzero(i) (i ? itoa(i) : NULL_TOKEN)
#define nonneg(i) (i ? itoa(i) : NULL_TOKEN)

#define itob(x) (x ? "TRUE" : "FALSE")

    void print_values(int count, ...) {
        count *= 2;
        va_list ap;
        va_start(ap, count);
        char *f;
        union {
            int i;
            double r;
            char *s;
        } v;
        for (int i = 0; i < count; i+=2) {
            f = va_arg(ap, char *);
            if (!strcmp(f, "%d")) {
                v.i = va_arg(ap, int);
                printf("%d", v.i);
            } else if (!strcmp(f, "%f")) {
                v.r = va_arg(ap, double);
                printf("%f", v.r);
            } else if (!strcmp(f, "%s")) {
                v.s = va_arg(ap, char *);
                printf("%s", v.s);
            }
            printf(i < count - 2 ? "," : "\n");
        }
        va_end(ap);
    }

    void display() {
        parsed_count++;

        if (data.quarter == 1 && data.time == 720 && data.play_type == PLAY_TYPE_JUMPBALL) {
            // this is the first play in a game
            shot_count = 0;
        }

        if (data.play_type == PLAY_TYPE_SHOTATT) {
            shot_count++;
            data.shot_num = shot_count;
            printf("SHOT ");
            print_values(17,
            "%d", data.game_year,
            "%d", data.game_month,
            "%d", data.game_day,
            "%s", quote(data.game_home),
            "%d", data.game_num,
            "%d", data.shot_num,
            "%d", data.quarter,
            "%f", data.time,
            "%s", maybe(data.shooter),
            "%s", maybe(data.blocked_by),
            "%s", maybe(data.assist_by),
            "%s", nonzero(data.shot_result),
            "%s", nonzero(data.shot_type),
            "%s", nonneg(data.shot_distance),
            "%s", nonzero(data.shot_value),
            "%s", NULL_TOKEN,
            "%s", NULL_TOKEN
            );
        }

        printf("PLAY ");
        print_values(47,
            "%d", data.game_year,
            "%d", data.game_month,
            "%d", data.game_day,
            "%s", quote(data.game_home),
            "%d", data.game_num,
            "%d", data.play_num,
            "%d", data.quarter,
            "%f", data.time,
            "%s", nonzero(data.play_type),
            "%s", maybe(data.team_name),
            "%s", nonzero(data.team_year),
            "%d", data.points_gained,
            "%s", maybe(data.rebounder),
            "%s", maybe(data.turnover_by),
            "%s", maybe(data.steal_by),
            "%s", maybe(data.double_foul_by_1),
            "%s", maybe(data.double_foul_by_2),
            "%s", maybe(data.foul_by),
            "%s", maybe(data.foul_drawn_by),
            "%s", maybe(data.foul_by_coach),
            "%s", maybe(data.sub_out),
            "%s", maybe(data.sub_in),
            "%s", maybe(data.violation_by),
            "%s", maybe(data.ejected),
            "%s", maybe(data.coach_ejected),
            "%s", nonzero(data.clock_event),
            "%s", nonzero(data.rebound_type),
            "%s", itob(data.team_rebound),
            "%s", maybe(data.jump_ball_player_1),
            "%s", maybe(data.jump_ball_player_2),
            "%s", maybe(data.jump_ball_winner),
            "%s", nonzero(data.free_throw_number),
            "%s", nonzero(data.free_throw_total),
            "%s", itob(data.team_turnover),
            "%s", itob(data.team_foul),
            "%s", itob(data.double_foul),
            "%s", nonzero(data.turnover_type),
            "%s", itob(data.team_ejected),
            "%s", nonzero(data.oob_type),
            "%s", nonzero(data.foul_type),
            "%s", nonzero(data.tech_type),
            "%s", nonzero(data.timeout_type),
            "%s", itob(data.team_violation),
            "%s", nonzero(data.violation_type),
            "%s", nonzero(data.replay_type),
            "%s", nonzero(data.replay_result),
            "%s", nonzero(data.shot_num)
        );
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
%type<str> coach
%type<x> TIMESTAMP

%%

plays:	    plays playl
            |
            ;

playl:      game SEP play_num SEP playqtr SEP playtime SEP playteam SEP playdiff SEP play '\n' { display();}

playqtr:    NUM                                             { data.quarter = $1; }

playtime:   TIMESTAMP                                       { data.time = $1; }

playteam: playteam_name SEP playteam_year

playteam_name:   STR                                        { data.team_name = $1; }
            | NONE
            ;

playteam_year: NUM                                          { data.team_year = $1; }
            | NONE
            ;

playdiff:   NUM                                             { data.points_gained = $1; }

game:       NUM SEP NUM SEP NUM SEP NUM SEP STR             {
                                                                data.game_year = $1;
                                                                data.game_month = $3;
                                                                data.game_day = $5;
                                                                data.game_num = $7;
                                                                data.game_home = $9;
                                                            }
            ;

play_num:   NUM                                             { data.play_num = $1; }

play:       clockevt                                        { data.play_type = PLAY_TYPE_CLOCKEVT; }
            | rebound                                       { data.play_type = PLAY_TYPE_REBOUND; }
            | jumpball                                      { data.play_type = PLAY_TYPE_JUMPBALL; }
            | shotattmpt                                    { data.play_type = PLAY_TYPE_SHOTATT; }
            | free_throw                                    { data.play_type = PLAY_TYPE_FREE_THR; }
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

player:     PLAYER STR                                      { $$ = $2; }

coach:      COACH STR                                       { $$ = $2; }

jumpballres: player GAIN_POSSESSION                         { data.jump_ball_winner = $1; }
                | UNKNOWN GAIN_POSSESSION                   { BAD; }
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

free_throw: shooter shotres free_throw_type

free_throw_type: FREE_THROW NUM OF NUM                         { data.free_throw_number = $2; data.free_throw_total = $4; }
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
            | SHOT
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
            | foulname BY coach                        { data.foul_type = FOUL_TYPE_TECHNICAL; data.foul_by_coach = $3; }
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
            | UNKNOWN
            ;

doublefoul: DOUBLE foulname
            ;

timeout:    OFFICIAL_TIMEOUT                    { data.timeout_type = TIMEOUT_TYPE_OFFICIAL; }
            | team TWENTY_SECOND_TIMEOUT        { data.timeout_type = TIMEOUT_TYPE_20_SEC; }
            | team NO TIMEOUT
            | fulltimeout                       { data.timeout_type = TIMEOUT_TYPE_FULL; }
            ;

fulltimeout: FULL_TIMEOUT
            | team FULL_TIMEOUT
            | team SLASH team FULL_TIMEOUT
            ;

team:       STR
            | STR STR
            ;

substitution: player SUBSTITUTE player                         { data.sub_in = $1, data.sub_out = $3; }
                | player SUBSTITUTE                            { BAD; }
                ;

violation:  VIOLATION BY TEAM teamv                            { data.team_violation = 1; }
            | VIOLATION BY player playerv                      { data.violation_by = $3; }
            | VIOLATION BY playerv
            ;

teamv:      DELAY_OF_GAME                                      { data.violation_type = VIOLATION_TYPE_DELAY_OF_GAME; }
            | SHOT_CLOCK                                       { data.violation_type = VIOLATION_TYPE_SHOT_CLOCK; }
            | EXCESSIVE_TIMEOUT                                { data.violation_type = VIOLATION_TYPE_EXCESS_TIMEOUT; }
            | VIOLATION
            | playerv
            ;

playerv:    jumpball_violation                                 { data.violation_type = VIOLATION_TYPE_JUMP_BALL; }
            | goaltend                                         { data.violation_type = VIOLATION_TYPE_GOALTEND; }
            | KICKED_BALL                                      { data.violation_type = VIOLATION_TYPE_KICKED_BALL; }
            | lane_violation                                   { data.violation_type = VIOLATION_TYPE_LANE; }
            | DISCONTINUED_DRIBBLE                             { data.violation_type = VIOLATION_TYPE_DISC_DRIBBLE; }
            | TRAVEL                                           { data.violation_type = VIOLATION_TYPE_TRAVEL; }
            | BACK_COURT                                       { data.violation_type = VIOLATION_TYPE_BACK_COURT; }
            | DOUBLE_DRIBBLE                                   { data.violation_type = VIOLATION_TYPE_DOUBLE_DRIBBLE; }
            | PALMING                                          { data.violation_type = VIOLATION_TYPE_PALMING; }
            | outofbounds                                      { data.violation_type = VIOLATION_TYPE_OOB; }
            | inbound_violation                                { data.violation_type = VIOLATION_TYPE_INBOUND; }
            | ILLEGAL_ASSIST                                   { data.violation_type = VIOLATION_TYPE_ILLEGAL_ASSIST; }
            | PUNCHED_BALL                                     { data.violation_type = VIOLATION_TYPE_PUNCHED_BALL; }
            | ILLEGAL_SCREEN                                   { data.violation_type = VIOLATION_TYPE_ILLEGAL_SCREEN; }
            | SWINGING_ELBOWS                                  { data.violation_type = VIOLATION_TYPE_SWINGIN_ELBOWS; }
            | SCORE_IN_OPP_BASKET                              { data.violation_type = VIOLATION_TYPE_SCORE_OPP_BSKT; }
            | ENTER_BASKET_FROM_BELOW                          { data.violation_type = VIOLATION_TYPE_ENTR_BSKT_BELOW; }
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
                | DOUBLE_LANE
                ;

goaltend:   OFFENSIVE_GOALTEND
            | DEFENSIVE_GOALTEND
            ;

replay:     INSTANT_REPLAY replay_reason replay_result
            | INSTANT_REPLAY
            ;

replay_reason: CHALLENGE                                    { data.replay_type = REPLAY_TYPE_CHALLENGE; }
                | REQUEST                                   { data.replay_type = REPLAY_TYPE_REQUEST; }
                ;

replay_result: RULING_STANDS                                { data.replay_result = REPLAY_RESULT_RULING_STANDS; }
                |
                ;

ejection:       player EJECTED                              { data.ejected = $1; }
                | coach EJECTED                             { data.coach_ejected = $1; }
                | TEAM EJECTED                              { data.team_ejected = 1; }
                | EJECTED                                   { BAD; }
                ;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s; [line %d]\n", s, parsed_count + 1);
}
