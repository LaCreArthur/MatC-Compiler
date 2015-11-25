#ifndef __EXPR__H__
#define __EXPR__H__


// exit status ---
#define FAIL 1
#define SUCCESS 2
// ---
struct symbol* tds; // the table of symbols
struct quad* code;  // the intermediar code
extern int line;    // the line which is parse, for error debugging
extern int column;  // the column in the line, for error debugging
char* filename;     // the exec prg name
FILE* out; 					// the output file stream

void arr_print( float* arr);
float* arr_cpy_tmp(float* tmp, int size);
// perfome the calcule of arg1 op arg2
float op_calc(int op, struct symbol* arg1, struct symbol* arg2);

// add a temp expression
void temp_add(struct symbol** result);

// add an expression in the tds
void expr_add(int op, struct symbol** res_result, struct quad** res_code,
											 struct symbol* arg1_result, struct quad* arg1_code,
											 struct symbol* arg2_result, struct quad* arg2_code);

// add a stmnt which is not an expr in the tds
void stmt_add(int op, struct symbol** res_result, struct quad** res_code,
                      struct symbol* arg1_result, struct quad* arg1_code);

// affect a value to an id
struct symbol* affectation(int type, char* id, struct symbol* res, struct quad* code, int declare);

// print an ending message
void exit_msg(int status);

#endif
