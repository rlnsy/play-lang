#include "y.tab.h"
#include <stdio.h>

extern int yyparse();
extern void init();
extern int parsed_count;

int main(void) {
    init();
    yyparse();
    printf("parsed: %d\n", parsed_count);
    return 0;
}