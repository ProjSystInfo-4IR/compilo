//fonction qui met a 0 l'index 
void tab_fct_init() ; 

// tester existance fonction 
// returne 0 si elle n'existe pas , 1 si elle existe deja
int fct_exist(char* name) ;

// ajout d'une fonction 
void ajout_fct(char* name) ;

// informer que la fonction est définie 
void set_code_decl(char* name) ;

// obtenir la ligne ASM où commence la fonction
int get_start(char* name) ; 

// informer la ligne ASM où commence la fonction 
void set_start(char* name, int start) ;

// imprimer table des fonctions
void tab_fct_print() ;
