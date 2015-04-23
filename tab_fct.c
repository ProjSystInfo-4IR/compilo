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
  char* name;       // nom fonction 
  int nb_args ;      // nombre d'arguments de la fonction 
  int  start;       // ligne ASM où la fnction commence 
  int  code_decl ;  // fonction définie
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

// tester existance fonction avec le nombre d'arguments en question
// returne 0 si elle n'existe pas , 1 si elle existe deja
int fct_exist(char* name, int nb_args) {
  int ret = 0 ;
  int i ; 
  for(i = 0 ; i < index_tab_fct ; i++) {
    if (!strcmp(name, pile_fct[i].name)){ 
      if(pile_fct[i].nb_args == nb_args) {
      ret = 1 ; 
      }
    }
  }
  return ret ; 
}

// ajout d'une fonction 
void ajout_fct(char* name, int nb_args) {
  if (fct_exist(name, nb_args) == 1) {
    logger_info("La fonction %s (%d arguments) a déjà été déclarée \n", name, nb_args);
  } 
  else { 
    pile_fct[index_tab_fct].name = name ; 
    pile_fct[index_tab_fct].nb_args = nb_args ; 
    pile_fct[index_tab_fct].start = -1 ; 
    pile_fct[index_tab_fct].code_decl = 0 ;
    index_tab_fct++ ; 
    logger_info("Déclaration de la fonction %s (%d arguments) effectuée \n", name, nb_args);
  }
}

// informer que la fonction est définie 
void set_code_decl(char* name, int nb_args) {
  int i ; 
  int ret = -1 ; 
  for(i = 0 ; i < index_tab_fct ; i++) {
    if (!strcmp(name, pile_fct[i].name) && pile_fct[i].nb_args == nb_args){ 
      if(pile_fct[i].code_decl == 1) {
	logger_error("La définition %s de la fonction (%d arguments) a déjà été déclarée \n", name, nb_args);  
	ret = -2 ;   
      } 
      else { 
	pile_fct[i].code_decl = 1 ;  
	ret = 0 ; 	
      }
    }
  } 
  if (ret == -1) {
    logger_error("La fonction %s (%d arguments) n'existe pas (il faut la déclarer) \n", name, nb_args);
  } 
}


// informer la ligne ASM où commence la fonction 
void set_start(char* name, int start, int nb_args) {
  int i ; 
  int ret = -1 ; 
  for(i = 0 ; i < index_tab_fct ; i++) {
    if (!strcmp(name, pile_fct[i].name) && pile_fct[i].nb_args == nb_args){ 
      pile_fct[i].start = start ;  
      ret = 0 ; 
    }
  } 
  if (ret == -1) {
    logger_error("La fonction %s n'existe pas (il faut la déclarer) \n", name);
  } 
}

// obtenir la ligne ASM où commence la fonction 
int get_start(char* name, int nb_args) {
  int ret = -1 ;
  int i ; 
  for(i = 0 ; i < index_tab_fct ; i++) {
    if (!strcmp(name, pile_fct[i].name) && pile_fct[i].nb_args == nb_args){ 			
      if (pile_fct[i].code_decl == 0) { 
	logger_error("La fonction %s (%d arguments) a été déclarée mais n'a pas été définie \n", name, nb_args);
        ret = -2 ; 
      } 
      else {
	ret = pile_fct[i].start ; 
      }
    }
  }
  if (ret == -1) {
     logger_error("La fonction %s (%d arguments) n'existe pas (il faut la déclarer) \n", name, nb_args);
  } 
  if (ret == -2) {
    ret = -1 ; 
  } 
  return ret ; 
}

void tab_fct_print() {
  int i ; 
  logger_info("\nAFFICHAGE TABLE DES FONCTIONS \n") ;
  logger_info("%15s       %15s       %15s       %15s\n", "NAME", "NB_ARGS", "START", "DECLARE" ) ; 
  for(i = 0 ; i < index_tab_fct ; i++){
    logger_info("%15s       %15d       %15d       %15d\n", pile_fct[i].name, pile_fct[i].nb_args, pile_fct[i].start, pile_fct[i].code_decl) ; 
  }
  logger_info("\n") ;
}


#ifdef _TEST_TAB_FCT
int main() {  
  logger_set_level(LOGGER_VERBOSE);
  tab_fct_init() ;    
  ajout_fct("fonction1", 2) ; 
  ajout_fct("fonction2", 0) ;  
  ajout_fct("fonction1", 1) ;
  ajout_fct("fonction1", 2) ;
  set_start("fonction1", 24, 2) ; 
  set_start("fonction3", 2, 4) ; 
  set_code_decl("fonction4", 12) ;
  set_code_decl("fonction1", 2) ;
  set_code_decl("fonction1", 8) ;
  printf("start fonction 2 : %d\n" , get_start("fonction2", 0)) ; 
  printf("start fonction 3 : %d\n" , get_start("fonction3", 1)) ; 
  printf("exist fonction 2 : %d\n" , fct_exist("fonction2", 0)) ; 
  printf("exist fonction 3 : %d\n" , fct_exist("fonction3", 4)) ;   
  tab_fct_print() ; 
  return 0;
}
#endif
