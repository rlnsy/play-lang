
%{
	#include <stdio.h>
	int yylex(void);
	void yyerror(char *);
	extern char *yytext;

    int parsed_count = 0;
%}

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


%%

plays:	    plays playl
            |
            ;

playl:      game '\t' play '\n'                             { parsed_count++; }
            ;

game:       STR                                             { printf("game: %s\n", yytext); }
            ;

qnum:       NUM                                             { printf("quarter: %d\n", yyval); }
            ;

play:       clockevt
            | rebound                                       { printf("rebound\n"); }
            | jmpblldesc                                  { printf("Jump ball\n"); }
            | shotdesc
            | turnover
            ;

clockevt:   Q_START qnum Q_QTR                              { printf("START\n"); }
            | Q_END qnum Q_QTR                              { printf("END\n");}
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

shotdesc:   shot
            | shot block
            | shot assist
            ;

shot:       player shotres PTS shot_type FROM NUM FEET        { printf("shot\n"); }
            ;

shotres:    MISS
            | MAKE
            ;

shot_type:  SHOT_TYPE_JUMP_SHOT
            | SHOT_TYPE_LAYUP
            ;

block:      BLOCK BY player
            ;

assist:     ASSIST BY player
            ;

player:     STR                                             { printf("player: %s\n", yytext); }
            ;

turnovere:  player
            | TEAM
            ;

turnover:   TURNOVER BY turnovere turnoverc

turnoverc:  SHOT_CLOCK
            | BAD_PASS steal
            | LOST_BALL steal
            ;

steal:      STEAL BY player
            ;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s; [line %d]\n", s, parsed_count + 1);
}
