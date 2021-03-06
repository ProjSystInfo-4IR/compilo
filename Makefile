SHELL=bash
TARGETS=simpleGCC
OBJECTS=
LDFLAGS=
CFLAGS=-Wall -Werror -c

all: $(TARGETS)

simpleGCC: y.tab.c lex.yy.c tab_symboles.o tab_ic.o tab_fct.o logger.o
	gcc y.tab.c lex.yy.c tab_symboles.o tab_ic.o tab_fct.o logger.o -ll -o $@ 

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

tab_fct.o: tab_fct.c tab_fct.h
	gcc $(CFLAGS) tab_fct.c -o $@

lex.yy.c: analyzer_lex.lex
	flex analyzer_lex.lex 

y.tab.c: syntaxic_analyzer.y
	yacc -v -d syntaxic_analyzer.y 

run:
	./cible

test:
	test_files/run-all-tests.sh

testTabFCT: 
	gcc -D_TEST_TAB_FCT dumb-logger/logger.c tab_fct.c -Wall
