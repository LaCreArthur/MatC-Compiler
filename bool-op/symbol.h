#ifndef __SYMB__H__
#define __SYMB__H__

#include <stdbool.h>


struct symbol {
      char* id;
      int value;
      struct symbol* next;
};

struct symbol* symbol_alloc();
struct symbol* symbol_newtemp(struct symbol** tds);
struct symbol* symbol_newcst(struct symbol** tds, int val);
struct symbol* symbol_add(struct symbol* symb, char* id);
struct symbol* symbol_find(struct symbol* tds, char* id);
void symbol_print (struct symbol* list);
void symbol_free (struct symbol* list);

#endif
