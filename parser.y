
%{
	#include <stdio.h>
	int yylex(void);
	void yyerror(char *);
	extern char *yytext;
%}

%token NUM

%token Q_START
%token Q_END
%token Q_QTR

%token DEF_RBND
%token BY
%token STR

%%

plays:	    plays playl
            |
            ;

playl:      play '\n'
            ;

qnum:       NUM                     { printf("quarter: %d\n", yyval); }
            ;

play:       Q_START qnum Q_QTR      { printf("START\n"); }
            | Q_END qnum Q_QTR      { printf("END\n");}
            | DEF_RBND BY player    { printf("Def. rebound\n"); }
            ;

player:     STR                     { printf("player: %s\n", yytext); }
            ;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}
