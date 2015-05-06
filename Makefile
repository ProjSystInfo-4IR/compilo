SHELL=bash
TARGETS=cible
OBJECTS=
LDFLAGS=
CFLAGS=-Wall -Werror -c

all: $(TARGETS)

cible: y.tab.c lex.yy.c tab_symboles.o tab_ic.o logger.o
	gcc y.tab.c lex.yy.c tab_symboles.o tab_ic.o logger.o -ll -o $@ 

y.tab.o: y.tab.c  lex.yy.o
	gcc $(CFLAGS) y.tab.c -o $@

lex.yy.o: lex.yy.c
	gcc $(CFLAGS) lex.yy.c -o $@

logger.o: dumb-logger/logger.c dumb-logger/logger.h
	gcc $(CFLAGS) dumb-logger/logger.c -o $@

tab_symboles.o: tab_symboles.c tab_symboles.h 
	gcc $(CFLAGS) tab_symboles.c -o $@

tab_ic.o: tab_ic.c tab_ic.h
	gcc $(CFLAGS) tab_ic.c -o $@

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