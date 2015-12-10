#ifndef __SYMB__H__
#define __SYMB__H__

#include <stdbool.h>
#include "matrix.h"
#define SYMBOL_MAX_NAME 64

enum Type {
  t_int, t_float, t_mat, t_bool, t_arr
};

struct symbol {
      char* id;
      enum Type type;
      float value;
      array* arr;
      struct symbol* next;

};

struct symbol* symbol_alloc();
struct symbol* symbol_newtemp(struct symbol** tds);
struct symbol* symbol_newcst(struct symbol** tds, int val);
struct symbol* symbol_add(struct symbol* symb, char* id);
struct symbol* symbol_find(struct symbol* tds, char* id);
void symbol_print (struct symbol* list);
void symbol_free (struct symbol* list);
void tds_toMips (struct symbol* list, FILE* out);
void symbol_toMips (struct symbol* s, FILE* out);
void symbol_tabAlloc (struct symbol* s, int size, int rows);
void symbol_tabSets (struct symbol* s, int size, int rows, char* values);

char* symbol_typeToStr(enum Type type);
void symbol_printVal(struct symbol* s);

#endif
