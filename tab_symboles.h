
/*  tab_symboles.h  */ 

extern char* NOM_VAR_ZERO;
extern char* GLOBAL ; // pour variables globales

//fonction qui met a zero l'index et qui alloue mémoire au tableau et l'initialise (memset)
void ts_init() ;

//fonction qui met a zero l'index de l'adressage mémoire (fonction utilisée en début de fonction)
void init_adr_mem(int N) ;

// cherche si le nom de la variable existe déjà (si oui : erreur) puis ajout dans table des symboles 
void ts_ajouter(char * nom, char * func, int est_constant, int est_initialise) ; 

// supprimer variable en mémoire (pas de désallocation)
void ts_depiler() ;

// affecter
void ts_affect(char * nom, char * func);


/*  GETTERS  */ 

int get_index(char * nom, char * func) ;
int ts_addr(char * nom, char * func) ; // retourner adresse mémoire variable (retourne -1 si la variable n'existe pas) 
int est_constant(char * nom, char * func) ;
int est_initialise(char * nom, char * func) ;
void ts_print();

/*  SETTERS  */  
void ts_affect(char * nom, char * func) ;
void ts_setConstant(char * nom, char * func) ;
