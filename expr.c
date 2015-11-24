#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "expr.h"
#include "symbol.h"
#include "quad.h"
#include "matrix.h"

void temp_add(struct symbol** result, float value){
  if(tds == NULL) {
    tds = symbol_newtemp(&tds);
    *result = tds;
  } else {
    *result = symbol_newtemp(&tds);
  }
  (*result)->value = value;
}

void expr_add(char op, struct symbol** res_result, struct quad** res_code,
                       struct symbol* arg1_result, struct quad* arg1_code,
                       struct symbol* arg2_result, struct quad* arg2_code) {
  *res_result = symbol_newtemp(&tds);
  (*res_result)->value = op_calc(op, arg1_result, arg2_result);
  (*res_result)->isFloat = arg1_result->isFloat;
  *res_code = arg1_code;
  quad_add(res_code,arg2_code);
  quad_add(res_code, quad_gen( op,arg1_result,arg2_result,*res_result));
}

void stmt_add(char op, struct symbol** res_result, struct quad** res_code,
                       struct symbol* arg1_result, struct quad* arg1_code) {
  *res_result = symbol_add(tds,(*res_result)->id);
  (*res_result)->value = arg1_result->value;
  *res_code = arg1_code;
  // quad_add(res_code,NULL);
  quad_add(res_code, quad_gen( op,arg1_result,NULL,*res_result));
}

struct symbol* affectation(char* type, char* id, struct symbol* res, struct quad* q, int size, int rows, int declare){
  quad_add(&code, q); // store the E code
  struct symbol* new_id;
  // printf("___(look for %s ... ", id);
  if((new_id = symbol_find(tds, id)) != NULL){ // id already declared
    if (declare) {
      fprintf(stderr,"%s:%d: error: redeclaration of '%s' with no linkage",filename, line, id);
      exit(EXIT_FAILURE);
    }
    else {
      // printf("found !)");
      new_id->isFloat?(new_id->value = res->value):(new_id->value = (int)res->value); // copie the E value into the id value
      quad_add(&code, quad_gen('=', res,NULL, new_id)); // store this stmnt code
      printf("___(%s = %.2f)", id, res->value); // verification
    }
  }
  else {
    if (!declare) { // new_id == NULL when it is not a declaration
      return NULL;
    }
    new_id = symbol_add(tds, id); // add the id in the tds
    if (type[0] == 'f'){ // 'f' mean TYPE = float
      new_id->isFloat = 1;
      new_id->value = res->value; // copie the E value into the id value
      printf("___(%s = %.2f)",id ,res->value); // verification
    }
    else {
      new_id->isFloat = 0;
      new_id->value = (int)res->value; // cast to int before mips generation
      printf("___(%s = %d)",id ,(int)res->value); // verification
    }
  }
  return new_id;
}


float op_calc(char op, struct symbol* arg1, struct symbol* arg2){
  switch (op) {
    case '+': return arg1->value + arg2->value;
    case '*': return arg1->value * arg2->value;
    case '-': return arg1->value - arg2->value;
    case '/': return arg1->value / arg2->value;
    default : return 0;
  }
}

void exit_msg(int status){
  if (status == FAIL) {
    fprintf(stderr,"%*c %s",column+1,' ',"^^^\n");
    exit(EXIT_FAILURE);
  }
  exit(0);
}
