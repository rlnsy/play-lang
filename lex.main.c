#include <stdio.h>

extern int yylex();
extern char *yytext;

int main()
{
	while (yylex()) {
		printf("%s\n", yytext);
	}
	return 0;
}