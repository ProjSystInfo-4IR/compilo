TARGETS=cible
OBJECTS=
LDFLAGS=
CFLAGS=-Wall -Werror -c

all: $(TARGETS)

cible: y.tab.c lex.yy.c tab_symboles.o
	gcc y.tab.c lex.yy.c tab_symboles.o -ll -o $@ 

y.tab.o: y.tab.c  lex.yy.o
	gcc $(CFLAGS) y.tab.c -o $@

lex.yy.o: lex.yy.c
	gcc $(CFLAGS) lex.yy.c -o $@

tab_symboles.o: tab_symboles.c tab_symboles.h 
	gcc $(CFLAGS) tab_symboles.c -o $@

lex.yy.c: analyzer_lex.lex
	flex analyzer_lex.lex 

y.tab.c: syntaxic_analyzer.y
	yacc -v -d syntaxic_analyzer.y 

run:
	./cible

test:
	test_files/run-all-tests.sh

testTabTIC: 
	gcc -D_TEST_TAB_TIC tab_instruction_controle.c -o ./tab_instruction_controle_test.o -Wall