const int b = 4 ; 

ok3(int a) ; 
ok4() ; 

ok(const int b){
  int a = 1 ; 
  if(a) {
    printf(a+b) ; 
  } 
  printf(b) ;  
}

ok5() ; 

ok2(){ 
  int z = 14 ;  
  ok(z) ; 
  ok2() ; 
  if (2) { 
    z = 7 ; 
  }   
  while(1) {
    printf(2) ; 
  }
} 

main() { 
  int a = 1 ; 
  int z = 12;  
  ok2() ; 
  ok(z)  ;
  if(1) { 
   a = 444; 
  } 
}


ok3(int a){
  int z = 44 ;  
  printf("test") ; 
} 

