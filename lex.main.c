#include <stdio.h>

extern int yylex();
extern char *yytext;

int yylval;

int main()
{
	while (yylex()) {
		printf("token: %s\n", yytext);
	}
	return 0;
}