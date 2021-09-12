
%{
	#include <stdio.h>
	int yylex(void);
	void yyerror(char *);
	extern char *yytext;
%}

%token STR

%%

program : program STR	{ printf("%s\n", yytext); }
	|
	;

%%

void yyerror(char *s) {
	fprintf(stderr, "%s\n", s);
}
