#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h> 
#include "tab_fct.h"
#include "dumb-logger/logger.h"
#define TAILLE 1024
#define MIN_TAILLE 0



// Structure stockee dans le tableau
struct  tb_fct {
  char* name;
  int  start;
  int  code_decl ; 
} ; 



// tableau des fonctions, mémorisation des variables en mémoire 
// ATTENTION ! Limitation à 1024 variables !
// index_tab_fct est l'index courant dans le tableau
int index_tab_fct ; 
struct tb_fct pile_fct[TAILLE] ; 


//fonction qui met a 0 l'index
void tab_fct_init() { 
  index_tab_fct = 0 ; 
}

// tester existance fonction 
// returne 0 si elle n'existe pas , 1 si elle existe deja
int fct_exist(char* name) {
  int ret = 0 ;
  int i ; 
  for(i = 0 ; i < index_tab_fct ; i++) {
    if (!strcmp(name, pile_fct[i].name)){ 
      ret = 1 ; 
    }
  }
  return ret ; 
}

// ajout d'une fonction 
void ajout_fct(char* name) {
  if (fct_exist(name) == 1) {
    logger_info("La fonction %s a déjà été déclarée \n", name);
  } 
  else { 
    pile_fct[index_tab_fct].name = name ; 
    pile_fct[index_tab_fct].start = -1 ; 
    pile_fct[index_tab_fct].code_decl = 0 ;
    index_tab_fct++ ; 
  }
}

// informer que la fonction est définie 
void set_code_decl(char* name) {
  int i ; 
  int ret = -1 ; 
  for(i = 0 ; i < index_tab_fct ; i++) {
    if (!strcmp(name, pile_fct[i].name)){ 
      if(pile_fct[i].code_decl == 1) {
	logger_error("La définition %s de la fonction a déjà été déclarée \n", name);  
	ret = -2 ;   
      } 
      else { 
	pile_fct[i].code_decl = 1 ;  
	ret = 0 ; 	
      }
    }
  } 
  if (ret == -1) {
    logger_error("La fonction %s n'existe pas (il faut la déclarer) \n", name);
  } 
}


// informer la ligne ASM où commence la fonction 
void set_start(char* name, int start) {
  int i ; 
  int ret = -1 ; 
  for(i = 0 ; i < index_tab_fct ; i++) {
    if (!strcmp(name, pile_fct[i].name)){ 
      pile_fct[i].start = start ;  
      ret = 0 ; 
    }
  } 
  if (ret == -1) {
    logger_error("La fonction %s n'existe pas (il faut la déclarer) \n", name);
  } 
}

// obtenir la ligne ASM où commence la fonction 
int get_start(char* name) {
  int ret = -1 ;
  int i ; 
  for(i = 0 ; i < index_tab_fct ; i++) {
    if (!strcmp(name, pile_fct[i].name)){ 			
      if (pile_fct[i].code_decl == 0) { 
	logger_error("La fonction %s a été déclarée mais n'a pas été définie \n", name);
        ret = -2 ; 
      } 
      else {
	ret = pile_fct[i].start ; 
      }
    }
  }
  if (ret == -1) {
    logger_error("La fonction %s n'existe pas (il faut la déclarer) \n", name);
  } 
  if (ret == -2) {
    ret = -1 ; 
  } 
  return ret ; 
}

void tab_fct_print() {
  int i ; 
  logger_info("\nAFFICHAGE TABLE DES FONCTIONS \n") ;
  logger_info("%15s       %15s       %15s\n", "NAME", "START", "DECLARE" ) ; 
  for(i = 0 ; i < index_tab_fct ; i++){
    logger_info("%15s       %15d       %15d\n", pile_fct[i].name, pile_fct[i].start, pile_fct[i].code_decl) ; 
  }
  logger_info("\n") ;
}


#ifdef _TEST_TAB_FCT
int main() {  
  logger_set_level(LOGGER_VERBOSE);
  tab_fct_init() ;    
  ajout_fct("fonction1") ; 
  ajout_fct("fonction2") ;  
  ajout_fct("fonction1") ;
  set_start("fonction1", 24) ; 
  set_start("fonction3", 2) ; 
  set_code_decl("fonction4") ;
  set_code_decl("fonction1") ;
  set_code_decl("fonction1") ;
  printf("start fonction 2 : %d\n" , get_start("fonction2")) ; 
  printf("start fonction 3 : %d\n" , get_start("fonction3")) ; 
  printf("exist fonction 2 : %d\n" , fct_exist("fonction2")) ; 
  printf("exist fonction 3 : %d\n" , fct_exist("fonction3")) ;   
  tab_fct_print() ; 
  return 0;
}
#endif
