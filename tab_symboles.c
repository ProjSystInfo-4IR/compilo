#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h> 
#include "tab_symboles.h"
#include "dumb-logger/logger.h"
#define TAILLE 1024
#define MIN_TAILLE 1

char* NOM_VAR_ZERO = "VAR_ZERO"; // déclaration du zéro (utile pour les négations)
char* GLOBAL = "_GLOBAL" ; // nom de fonction pour variables globales

// Tableau des symboles -> 4 paramètres : nom, initialisé ? , constant ? , adresse mémoire
struct ts_parametres {
  char * nom ; 
  char * func ; // fonction à laquelle la variable est associée 
  int is_initialized ; 
  int is_constant ; 
  int adrMem ;   // on définit : l'index = l'adresse mémoire
} ; 


// tableau des symboles, mémorisation des variables en mémoire 
// ATTENTION ! Limitation à 1024 variables !
// index_tab est l'index courant dans le tableau
int index_tab ; 
struct ts_parametres table_symboles[TAILLE] ; 


//fonction qui met a zero l'index et qui alloue mémoire au tableau et l'initialise (memset)
void ts_init() {
  index_tab = 0 ; 
  memset(table_symboles, 0 , TAILLE*sizeof(struct ts_parametres)) ; 
  ts_ajouter(NOM_VAR_ZERO, GLOBAL, 1, 1);
  logger_info("# Initialisation du tableau de symboles\n");
}


// retourner adresse mémoire variable
// retourne -1 si la variable n'existe pas 
int ts_addr(char * nom, char * func) {
  int i ; 
  int adresseMemoireVariable = -1 ;   
  for(i = 0 ; i < index_tab ; i++){
    if (strcmp(table_symboles[i].nom,nom) == 0 && ( strcmp(table_symboles[i].func,func) == 0 ||  strcmp(table_symboles[i].func, GLOBAL) == 0  )) {
      adresseMemoireVariable = table_symboles[i].adrMem ; 
    }
  }
  return adresseMemoireVariable ; 
}


// ajout dans table des symboles 
void ts_ajouter(char * nom, char * func , int est_constant, int est_initialise) {
  table_symboles[index_tab].nom = nom ; 
  table_symboles[index_tab].func = func ; 
  table_symboles[index_tab].is_constant = est_constant ; 
  table_symboles[index_tab].is_initialized = est_initialise ; 
  table_symboles[index_tab].adrMem = index_tab ; 
  index_tab++ ;   
}


// supprimer variable en mémoire (pas de désallocation)
void ts_depiler() {
  if (index_tab == MIN_TAILLE) {
    logger_error("Erreur table symbole : Action dépiler impossible\n");
    return;
  }
  index_tab-- ;   
}

/*  GETTERS  */  

int est_constant(char * nom, char * func) {   
  return table_symboles[ts_addr(nom, func)].is_constant  ; 
}

int est_initialise(char * nom, char * func) {   
  return table_symboles[ts_addr(nom, func)].is_initialized  ; 
}


void ts_print() {
  int i ; 
  logger_info("\nAFFICHAGE TABLE DES SYMBOLES \n") ;
  logger_info("    Nom     -   Fonction  -   Initialise - Constant - Adresse\n") ;
 
  for(i = 0 ; i < index_tab ; i++){
    logger_info("%10s  %10s  %10d  %10d  %10d\n", table_symboles[i].nom, table_symboles[i].func, table_symboles[i].is_initialized, table_symboles[i].is_constant, table_symboles[i].adrMem) ; 
  }
  logger_info("\n") ;
}


/*  SETTERS  */  

// affecter, initialiser
void ts_affect(char * nom, char * func) {   
  table_symboles[ts_addr(nom, func)].is_initialized = 1 ; 
}

void ts_setConstant(char * nom, char * func) {   
  table_symboles[ts_addr(nom, func)].is_constant = 1 ; 
}






#ifdef _TEST_TAB_SYMBOLES
int main() {
  ts_init() ; 
  logger_set_level(LOGGER_VERBOSE);
  ts_ajouter("i", GLOBAL, 0 , 0) ; 
  ts_ajouter("j", "fct2", 0 , 0) ; 
  ts_ajouter("k", "fct1", 0 , 0) ;
  ts_depiler() ; 
  ts_ajouter("l", "main" , 0 , 0) ;
  printf("Variable i : %d\n", ts_addr("i", "fct1"));
  printf("Variable i : %d\n", ts_addr("i", "fct2"));
  printf("Variable j : %d\n", ts_addr("j", "fct1"));
  printf("Variable k : %d\n", ts_addr("k", "fct1")); 
  printf("Variable l : %d\n", ts_addr("l", "main")); 
  ts_print() ; 
  return 0 ; 
}
#endif
