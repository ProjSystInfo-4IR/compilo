#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h> 
#include "tab_symboles.h"
#define TAILLE 1024
#define MIN_TAILLE 1

char* NOM_VAR_ZERO = "VAR_ZERO";
// Tableau des symboles -> 4 paramètres : nom, initialisé ? , constant ? , adresse mémoire
struct ts_parametres {
  char * nom ; 
  int is_initialized ; 
  int is_constant ; 
  int adrMem ;   // on définit : l'index = l'adresse mémoire
} ; 


// tableau des symboles, mémorisation des variables en mémoire 
// ATTENTION ! Limitation à 1024 variables !
// index_tab est l'index courant dans le tableau
int index_tab ; 
struct ts_parametres table_symboles[TAILLE] ; 



void ts_init() {
  //fonction qui met a zero l'index et qui alloue mémoire au tableau et l'initialise (memset)
  index_tab = 0 ; 
  memset(table_symboles, 0 , TAILLE*sizeof(struct ts_parametres)) ; 
  ts_ajouter(NOM_VAR_ZERO, 1, 1);
  printf("# Initialisation du tableau de symboles\n");
}


// retourner adresse mémoire variable
// retourne -1 si la variable n'existe pas 
int ts_addr(char * nom) {
  int i ; 
  int adresseMemoireVariable = -1 ;   
  for(i = 0 ; i < index_tab ; i++){
    if (strcmp(table_symboles[i].nom,nom) == 0) {
      adresseMemoireVariable = table_symboles[i].adrMem ; 
    }
  }
  return adresseMemoireVariable ; 
}


// ajout dans table des symboles 
void ts_ajouter(char * nom, int est_constant, int est_initialise) {
    table_symboles[index_tab].nom = nom ; 
    table_symboles[index_tab].is_constant = est_constant ; 
    table_symboles[index_tab].is_initialized = est_initialise ; 
    table_symboles[index_tab].adrMem = index_tab ; 
    index_tab++ ;   
}


// supprimer variable en mémoire (pas de désallocation)
void ts_depiler() {
  if (index_tab == MIN_TAILLE) {
    printf("Erreur : Dépiler impossible\n");
    return;
  }
  index_tab-- ;   
}





/*  GETTERS  */  

int est_constant(char * nom) {   
  return table_symboles[ts_addr(nom)].is_constant  ; 
}

int est_initialise(char * nom) {   
  return table_symboles[ts_addr(nom)].is_initialized  ; 
}

void ts_print() {
  int i ; 
  printf("\nAFFICHAGE TABLE DES SYMBOLES \n") ;
  printf("    Nom     -    Initialise - Constant - Adresse\n") ;
 
  for(i = 0 ; i < index_tab ; i++){
    printf("%10s  %10d  %10d  %10d\n", table_symboles[i].nom, table_symboles[i].is_initialized, table_symboles[i].is_constant, table_symboles[i].adrMem) ; 
  }
  printf("\n") ;
}





/*  SETTERS  */  

// affecter, initialiser
void ts_affect(char * nom) {   
  table_symboles[ts_addr(nom)].is_initialized = 1 ; 
}

void ts_setConstant(char * nom) {   
  table_symboles[ts_addr(nom)].is_constant = 1 ; 
}






#ifdef _TEST_TAB_SYMBOLES
int main() {
  ts_init() ; 
  ts_ajouter("i", 0 , 0) ; 
  ts_ajouter("j", 0 , 0) ; 
  ts_ajouter("k", 0 , 0) ;
  ts_depiler() ; 
  ts_ajouter("l", 0 , 0) ;
  printf("Variable i : %d\n", ts_addr("i")); 
  printf("Variable k : %d\n", ts_addr("k")); 
  printf("Variable l : %d\n", ts_addr("l")); 
  ts_print() ; 
}
#endif
