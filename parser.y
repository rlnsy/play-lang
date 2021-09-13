
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
%token JMP_SHOT;
%token FROM;
%token FEET;
%token BLOCK;
%token ASSIST;
%token LAYUP;
%token TEAM;

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

play:       Q_START qnum Q_QTR                              { printf("START\n"); }
            | Q_END qnum Q_QTR                              { printf("END\n");}
            | rbndtype BY rebounder                         { printf("rebound\n"); }
            | JMP_BALL player VS player player GAIN_POSS    { printf("Jump ball\n"); }
            | shotdesc
            ;

rbndtype:   DEF_RBND
            | OFF_RBND
            ;

rebounder:  player
            | TEAM
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

shot_type:  JMP_SHOT
            | LAYUP
            ;

block:      BLOCK BY player
            ;

assist:     ASSIST BY player
            ;

player:     STR                                             { printf("player: %s\n", yytext); }
            ;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s; [%d]\n", s, parsed_count);
}
