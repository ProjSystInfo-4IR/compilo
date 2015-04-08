
#define LOGGER_SILENT   0
#define LOGGER_VERBOSE  1

int logger_error(const char* fmt, ...) ;

int logger_info(const char* fmt, ...);

int logger_set_level(int mode);

int logger_get_level();

int logger_set_prefix(char* custom_prefix);