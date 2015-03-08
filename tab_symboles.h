
/*  tab_symboles.h  */ 

//fonction qui met a zero l'index et qui alloue mémoire au tableau et l'initialise (memset)
void ts_init() ;

// retourner adresse mémoire variable (retourne -1 si la variable n'existe pas) 
int ts_addr(char * nom) ;

// cherche si le nom de la variable existe déjà (si oui : erreur) puis ajout dans table des symboles 
void ts_ajouter(char * nom, int est_constant, int est_initialise) ; 

// supprimer variable en mémoire (pas de désallocation)
void ts_depiler() ;

// affecter
void ts_affect(char * nom);


/*  GETTERS  */ 
int est_constant(char * nom) ;
void est_initialise(char * nom) ;
void ts_print();

/*  SETTERS  */  
void ts_affect(char * nom) ;
void ts_setConstant(char * nom) ;
