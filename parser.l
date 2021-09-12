	/* DEFINITIONS */
%{
	#include "y.tab.h"
%}

	/* whitespace character */
wsc 	[ \t\n]
	/* non-whitespace character */
c	[^ \t\n]

%%
	/* RULES */

{c}+	return STR;
{wsc}+	; /* skip all whitespace */

%%
	/* SUBROUTINES */

int yywrap(void)
{
	return 1;
}