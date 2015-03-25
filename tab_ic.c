#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h> 
#include "tab_ic.h"
#define TAILLE 1024
#define MIN_TAILLE 0

// Structure stockee dans le tableau
struct  tb_bloc {
  int addr_src;
  int addr_dst;
} ; 


// tableau des symboles, mémorisation des variables en mémoire 
// ATTENTION ! Limitation à 1024 variables !
// index_tab_tic est l'index courant dans le tableau
int index_tab_tic ; 
struct tb_bloc pile[TAILLE] ; 



void tic_init() {
  //fonction qui met a -4 l'index et qui alloue mémoire au tableau et l'initialise (memset)
  index_tab_tic = 0 ; 
  memset(pile, -1, TAILLE*sizeof(struct tb_bloc)) ; 
}


/* ajout dans table des instructions de controles, connaissant la source */ 
void tic_ajouter_s(int source) {
    pile[index_tab_tic].addr_src = source ; 
    index_tab_tic++ ;   
}

/* ajout dans table des instructions de controles, connaissant la destination */ 
void tic_ajouter_d(int dest) {
    pile[index_tab_tic].addr_dst = dest ; 
    index_tab_tic++ ;   
}


// supprimer variable en mémoire (pas de désallocation)
void tic_depiler() {
  if (index_tab_tic == MIN_TAILLE) {
    printf("Erreur : Dépiler impossible\n");
    return;
  }
  pile[index_tab_tic-1].addr_src = -1;
  pile[index_tab_tic-1].addr_dst = -1;
  index_tab_tic-- ;   
}


void tic_print() {
  int i ; 
  printf("\nAFFICHAGE TABLE DES INSTRUCTIONS CONTROLES \n") ;
  printf("Source - Destination\n") ;
 
  for(i = 0 ; i < index_tab_tic ; i++){
    printf("%4d       %4d\n", pile[i].addr_src, pile[i].addr_dst) ; 
  }
  printf("\n") ;
}





/*  SETTERS  */  
void tic_set_source(int source) {
  if (index_tab_tic == 0) {
    printf("TIC : Pas d'element pour affecter source %d\n", source);
    return;
  }
  pile[index_tab_tic-1].addr_src = source;
}

void tic_set_dest(int dest) {
  if (index_tab_tic == 0) {
    printf("TIC : Pas d'element pour affecter dest %d\n", dest);
    return;
  }
  pile[index_tab_tic-1].addr_dst = dest;
}

/* GETTERS */
int tic_get_dest(int src) {  int i;
  for (i = 0; i < index_tab_tic; i++) {
    if (pile[i].addr_src == src) {
      return pile[i].addr_dst;
    }
  }
  return -1;
}






#ifdef _TEST_TAB_TIC
int main() {
  tic_init() ; 
  tic_ajouter_s(1) ; 
  tic_ajouter_s(6) ;
  tic_print() ; 
  tic_ajouter_d(42) ;
  tic_print() ; 
  tic_depiler() ; 
  tic_ajouter_d(6) ;
  tic_print() ; 
  return 0;
}
#endif
