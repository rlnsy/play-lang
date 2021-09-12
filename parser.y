
%{
	#include <stdio.h>
	int yylex(void);
	void yyerror(char *);
	extern char *yytext;
%}

%token DEF_RBND
%token BY
%token STR

%%

plays:	plays playl
		|
		;

playl:		play '\n'
		;

play:		DEF_RBND BY player	{ printf("def. rebound\n"); }
		;

player:        STR			{ printf("player: %s\n", yytext); }
		;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}
