const int b = 4 ; // constante globale
int variable = -3 *  b / 2 ;  // variable initialisée à -6


// déclaration de fonction 
ok3(int a) ; ok4() ; 


// définition de la fonction ok(const int b) 
ok(const int b2, int c, int d){   

  printf("\nfonction ok : ") ; 
  variable = 77 ; 

  // affichage des arguments
  printf(b2) ; printf(" ") ; 
  printf(c) ; printf(" ") ; 
  printf(d) ; printf(" ") ;
  printf((b2+c+d)*-5) ; 
  printf("\n") ;
}

ok5() ; 

ok2(){ 
  int z = 14 ;  
  int cpt = 4 ;  

  printf("\n");
  printf("fonction ok2\n") ; 
  
  printf("cpt = ") ; 
  printf(cpt) ;
  printf("\n"); 

  ok(5,7,2) ; 

  printf("\ncpt = ") ; 
  printf(cpt) ;
  printf("\n");

  ok3(5+z/(b+b)) ; 

  printf("\ncpt = ") ; 
  printf(cpt) ;
  printf("\n");


  if (b/7) { 
    z = 7 ; printf("changement valeur z à 7 \n") ; 
  }  
 
  variable = -z * 5 + 2 / (b+-2) ; // variable = -69 ou -34
  printf("variable = ") ; 
  printf(variable) ;
  printf("\n");

  while(cpt) {
    cpt = cpt - 1 ; 
    printf(cpt) ; 
    printf(" ") ; 
  }
  printf("\n");
} 

// programme principal 
main() { 
  const int c1,c2,c3 = 144 ; 
  int a = 1, j, i, z = 12;  
  int test1 = 3 *  -variable / 2 + 15/3 ; // 14 

  printf("\n") ;
  printf("Lancement programme\n ") ;   

  printf("\nvariable = ") ; printf(variable) ;
  printf("\n") ; 

  printf("test1 = ") ; 
  printf(test1) ; 
  printf("\n") ;
  
  variable = ( z + a )*2 + 2 * -5 +  1  ; // égal à 17  
  printf("variable - a = ") ; 
  printf(variable) ; printf(" - ") ; printf(a) ;
  printf("\nz = ") ;
  printf(z) ; 
  printf("\n") ; 

  // appel à deux fonctions  
  ok2() ;  
  
  printf("\n") ;  
  printf("z - b - a = ") ;
  printf(z) ; printf(" ") ;
  printf(b) ; printf(" ") ; 
  printf(a) ; printf("\n") ; 
  
  printf("variable = ") ; 
  printf(variable) ; printf("\n") ; 

  printf((z*b*2+9-a)) ; printf(" "); // donne 104 ! 
  printf(c3) ; printf(" \n") ; // donne 144 ! 

  ok(z,(((variable))),b)  ; // somme des args theorique = -53, affiche 265
  

  printf("\nz - b - a = ") ;
  printf(z) ; printf(" ") ;
  printf(b) ; printf(" ") ; 
  printf(a) ; 

  printf("\nvariable = ") ; 
  printf(variable) ; 

  variable = 0 ; 
  printf("\nvariable = ") ; 
  printf(variable) ; 
  printf("\n") ;
  
  if(variable) { 
    a = 444; 
    printf("Dans la boucle if\n") ; 
  } 
  else { 
    if(a-77) {
      printf("Dans la deuxième boucle if\n") ;
    }    
  }
}

/* ancienne définition de la fonction ok3(int a) précédemment déclarée
   ok3(int a){
   int z = 44 ;  
   while(111) {
   printf(z) ;
   } 
   } */


// définition de la fonction ok3(int a) précédemment déclarée
ok3(int a){
  int z = 4 ;  
  printf("\nfonction ok3") ;
  printf("\n") ;
  while(z) {
    z = z - 1 ; 
    printf(z) ;
    printf("\n") ;
    if(z) { 
      printf("z est différent de 0\n") ;
    }
    else { 
      printf("z = 0\n") ;
    }  
  } 
} 
