const int b = 4 ; // constante globale
//int variable = 3 *  b / 2 ;  // variable initialisée à -6
int variable = b  ; 

// déclaration de fonction 
ok3(int a) ; ok4() ; 

// définition de la fonction ok(const int b) 
ok(const int b2, int c, int d){   
  printf("fonction ok") ; 
  variable = 77 ; 
  printf(4+2) ; 
}

ok5() ; 

ok2(){ 
  int z = 14 ; 
  int cpt = 4 ;  

  printf("fonction ok2") ; 
  
  printf("cpt =") ; 
  printf(cpt) ;

  ok(5,7,2) ; 

  printf("cpt =") ; 
  printf(cpt) ;

  ok3(5+z/(b+b)) ; 

  printf("cpt =") ; 
  printf(cpt) ;

  printf(variable) ; 

  if (b/7) { 
    z = 7 ; 
  }   
  printf("cpt =") ; 
  printf(cpt) ;

  while(0) {
    variable = -cpt * 5 + 2 / b ; 
    cpt = cpt - 1 ; 
    printf(cpt) ; 
  }
} 

// programme principal 
main() { 
  const int c1,c2,c3 = 1 ; 
  int a = 1, j, i = 7, z = 12;  
  int test1 = 3 *  b / 2 + 15/5 ; // 9 
  printf(test1) ; 
  test1 = b - 2 + -7 * 2 ; // -12 
  printf(test1) ; 
  variable = ( z + a ) + 2 * -5 +  1  ; // égal à 4
  printf(variable) ; 
  ok2() ;   ok((z*b*2+9-a),4/3+c3,111)  ;
  variable = 2 ; printf(variable) ; 
  if(variable) { 
   a = 444; 
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
  printf("fonction ok3") ; 
  while(z) {
  z = z - 1 ; 
  printf(z-1) ;
  } 
} 
