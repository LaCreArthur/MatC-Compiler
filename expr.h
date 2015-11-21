//int yydebug=1;

struct symbol* tds; // the table of symbols
struct quad* code; // the intermediar code
extern int line; // the line which is parse, for error debugging
char* filename; // the exec prg name
FILE* out; // the output file stream

float op_calc(char op, struct symbol* arg1, struct symbol* arg2);
void temp_add(struct symbol** result, float value);
void expr_add(char op, struct symbol** res_result, struct quad** res_code,
											 struct symbol* arg1_result, struct quad* arg1_code,
											 struct symbol* arg2_result, struct quad* arg2_code);
struct symbol* affectation(char* type, char* id, struct symbol* res, struct quad* code, int size, int rows);
