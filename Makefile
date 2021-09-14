parser: lex.yy.c y.tab.c y.tab.h main.c
	gcc -Wall main.c lex.yy.c y.tab.c -o parser
lexer: lex.yy.c lex.main.c y.tab.h
	gcc -Wall -o lexer lex.main.c lex.yy.c
lex.yy.c: parser.l
	lex parser.l
y.tab.h: parser.y
	yacc -d parser.y
y.tab.c: parser.y
	yacc parser.y
clean:
	rm -f lexer parser y.tab.c y.tab.h lex.yy.c
