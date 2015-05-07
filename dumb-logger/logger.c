#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include "logger.h"

#define MAX_PREFIX_LEN 20

static int logger_level = LOGGER_SILENT;
static int require_prefix = 0;
static char prefix[MAX_PREFIX_LEN];

int nb_error_occured = 0 ;  
char* nom_fichier_C ; 

void logger_set_nom_fichier(char* name){
  nom_fichier_C = name ; 
} 

int logger_set_level(int mode) {
	if (mode < 0 || 1 < mode) {
		printf("logger_set_mode : argument invalid\n");
		return -1;
	}
	logger_level = mode;
	return 0;
}

int logger_get_level() {
	return logger_level;
}

int get_nb_errors_occured() {
	return nb_error_occured;
}


int logger_set_prefix(char* custom_prefix) {
	if (strlen(custom_prefix) == 0 ||  MAX_PREFIX_LEN < strlen(custom_prefix)) {
		printf("Prefix invalid. Please check prefix length (maximum %d)\n", MAX_PREFIX_LEN);
		return -1;
	}
	strcpy(prefix, custom_prefix);
	require_prefix = 1;
	return 0;
}

/* affichage d'une erreur san infos sur le fichier, ni la ligne */ 
int logger_error(const char* fmt, ...) {
        nb_error_occured++ ;
	va_list args;
	va_start(args, fmt);
	if (require_prefix) {
		printf("[%s]", prefix);
	}
	printf("[e] ");
 
	vprintf(fmt, args);
	va_end(args);
	return 0;
}

/* affichage d'une erreur avec infos sur le fichier et la ligne */ 
int logger_lerror(int lino, const char* fmt, ...) {
        nb_error_occured++ ;
	va_list args;
	va_start(args, fmt);
	if (require_prefix) {
		printf("[%s]", prefix);
	}
	printf("[e] [%s:%d] ",nom_fichier_C, lino);
 
	vprintf(fmt, args);
	va_end(args);
	return 0;
}


int logger_info(const char* fmt, ...) {
	if (logger_level != LOGGER_VERBOSE) {
		return 0;
	}
	va_list args;
	va_start(args, fmt);
	if (require_prefix) {
		printf("[%s]", prefix);
	}
	printf("[i] ");
	vprintf(fmt, args);
	va_end(args);
	return 0;
}
/*
int main() {
	char* a = "ASD";
	logger_error("I got %s %d\n", a, 5);
	logger_info("I got %s %d\n", a, 123);
	logger_set_level(LOGGER_VERBOSE);
	logger_error("I got %s %d\n", a, 5);
	logger_info("I got %s %d\n", a, 123);
	return 0;
}*/
