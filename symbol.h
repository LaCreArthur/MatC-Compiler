#include <stdbool.h>
#define SYMBOL_MAX_NAME 64

struct symbol {
      char* id;
      bool isConstant;
      bool isFloat;
      float value;
      struct symbol* next;
};

struct symbol* symbol_alloc();
struct symbol* symbol_newtemp(struct symbol** tds);
struct symbol* symbol_add(struct symbol* symb, char* id);
struct symbol* symbol_find(struct symbol* tds, char* id);
void symbol_print (struct symbol* list);
void symbol_free (struct symbol* list);
void tds_toMips (struct symbol* list, FILE* out);
void symbol_toMips (struct symbol* s, FILE* out);
