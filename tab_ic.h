
//fonction qui met a -1 l'index et qui alloue mémoire au tableau et l'initialise (memset)
void tic_init() ;

// ajout dans table des instructions de controles, connaissant la source
void tic_ajouter_s(int source) ; 

/* ajout dans table des instructions de controles, connaissant la destination */ 
void tic_ajouter_d(int dest);

// supprimer variable en mémoire (pas de désallocation)
void tic_depiler() ;

// affecter
void tic_affect(char * nom);

/* SETTERS */
void tic_set_source(int source);

// Assigner dest a la derniere valeur qui n'est pas resolue
void tic_set_dest(int dest);

/*  GETTERS  */ 
int tic_get_dest(int src);

// printer
void tic_print();
