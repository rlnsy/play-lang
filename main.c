#include "y.tab.h"

extern int yyparse();
extern void init();

int main(void) {
    init();
    yyparse();
    return 0;
}