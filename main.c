#include "y.tab.h"

extern int yyparse();

int main(void) {
	yyparse();
	return 0;
}