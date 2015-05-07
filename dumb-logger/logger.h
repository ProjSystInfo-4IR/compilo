
#define LOGGER_SILENT   0
#define LOGGER_VERBOSE  1

void logger_set_nom_fichier(char* name) ;

int logger_error(const char* fmt, ...) ;

int logger_lerror(int lino, const char* fmt, ...) ;

int logger_info(const char* fmt, ...);

int logger_set_level(int mode);

int logger_get_level();

int get_nb_errors_occured() ;

int logger_set_prefix(char* custom_prefix);
