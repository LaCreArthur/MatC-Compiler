#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "expr.h"
#include "symbol.h"
#include "quad.h"
#include "matrix.h"

void temp_add(struct symbol** result){
  if(tds == NULL) {
    tds = symbol_newtemp(&tds);
    *result = tds;
  } else {
    *result = symbol_newtemp(&tds);
  }
}

void expr_add(int op, struct symbol** res_result, struct quad** res_code,
                       struct symbol* arg1_result, struct quad* arg1_code,
                       struct symbol* arg2_result, struct quad* arg2_code) {
  *res_result = symbol_newtemp(&tds);
  (*res_result)->value = op_calc(op, arg1_result, arg2_result);
  (*res_result)->type = arg1_result->type;
  *res_code = arg1_code;
  quad_add(res_code,arg2_code);
  quad_add(res_code, quad_gen( op,arg1_result,arg2_result,*res_result));
}

struct symbol* affectation(int type, char* id, struct symbol* res, struct quad** code, struct quad* q, int declare){
  quad_add(code, q); // store the E code
  struct symbol* new_id; // declare the possible new id
  if((new_id = symbol_find(tds, id)) != NULL){ // new id already existe
    if (declare) { // try to redeclare
      return NULL;
    }
    else { // reaffectation
      quad_add(code, quad_gen(eq, res,NULL, new_id)); // store this affectation stmnt code
    }
  }
  else { // new id do not exist in tds
    if (!declare) { // call a id that not exist
      return NULL; // new_id == NULL when it is not a declaration
    }
    new_id = symbol_add(tds, id); // add the id in the tds
    if (type == t_int || type == t_bool) {
      new_id->type = t_int;
      new_id->value = (int)res->value; // cast to int before mips generation
    }
    else if (type == t_float) {
      if (res->arr != NULL) {
        new_id->type = t_arr;
        new_id->arr = res->arr;
      }
      else {
        new_id->type = t_float;
        new_id->value = res->value; // copie the E value into the id value
      }
    }
    else if (type == t_mat) {
      new_id->type = t_arr;
      new_id->arr = res->arr; // copie the E value into the id value
    }
  }
  return new_id;
}


float op_calc(int op, struct symbol* arg1, struct symbol* arg2){
  switch (op) {
    case add: return arg1->value + arg2->value;
    case mult: return arg1->value * arg2->value;
    case sub: return arg1->value - arg2->value;
    case divi: return arg1->value / arg2->value;
    default : return 0;
  }
}

void exit_msg(int status){
  if (status == FAIL) {
    fprintf(stderr,"%*c %s\n",column+5,' ',"^");
    exit(EXIT_FAILURE);
  }
}

char* safeId(char* id){
  size_t len = strlen(id);
  char *newid = malloc(len + 1 + 1 ); /* one for extra char, one for trailing zero */
  strcpy(newid, id);
  newid[len] = '_';
  newid[len + 1] = '\0';
  return newid;
}

/* error handling */

void error_undeclared(char *filename, int line, int column, char *id) {
      fprintf(stderr,
              "%s:%d:%d: error: '%s' undeclared (first use in this function)\n",
              filename, line, column, id);
}
