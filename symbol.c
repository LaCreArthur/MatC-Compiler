#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"

struct symbol* symbol_alloc() {
  struct symbol* new = malloc(sizeof(*new));
  if(new == NULL) perror("symbol_alloc new fail : ");
  new->tab = NULL;
  new->id = NULL;
  new->isConstant = false;
  new->isFloat = false;
  new->isMatrix = 0;
  new->value = 0;
  new->next = NULL;
  return new;
}

struct symbol* symbol_newtemp(struct symbol** tds) {
    static int nb_symbol = 0;
    char temp_name[SYMBOL_MAX_NAME];
    snprintf(temp_name, SYMBOL_MAX_NAME, "temp_%d", nb_symbol);
    nb_symbol++;
    return symbol_add(*tds, temp_name);
}

struct symbol* symbol_add (struct symbol* symb, char* id) {
  struct symbol* temp = symb;
  char *id_dup = strdup(id);
  if (temp == NULL) {
      temp = symbol_alloc();
      temp->id = id_dup;
      return temp;
  }
  else {
      while (temp->next != NULL) temp = temp->next;
      temp->next = symbol_alloc();
      temp->next->id = id_dup;
      return temp->next;
  }
}

struct symbol* symbol_find(struct symbol* tds, char* id){
  struct symbol* temp = tds;
  while (temp != NULL) {
    // printf("\nsymbol_find : compare %s and %s", temp->id, id);
    if (strcmp(temp->id, id) == 0) return temp;
    else temp = temp->next;
  }
  return NULL;
}

void symbol_print (struct symbol* list){
  if (list == NULL) printf("table null\n");
	while (list != NULL) {
		printf("%s\t%s \t= %.2f\n",(list->isFloat ? "float" : "int"), list->id, list->value);
    list = list->next;
	}
}

void symbol_free (struct symbol* list){
  struct symbol* tmp;
  while (list != NULL)
   {
      tmp = list;
      //printf("symbol free %s\n", list->id);
      list = list->next;
      free(tmp->id);
      free(tmp);
   }
}

void tds_toMips (struct symbol* list, FILE* out){
  fprintf(out,"\t.data\n"); // init data segment
	while (list != NULL) {
		if (list->isFloat) fprintf(out,"%s:\t.float %f\n", list->id, list->value); // declare statics float vars
    else fprintf(out,"%s:\t.word %d\n", list->id, (int)list->value); // int vars, cast avoid warning
    list = list->next;
	}
  fprintf(out,"end_msg:\t.ascii \"\\nexit status:\" \n");
  fprintf(out,"newline:\t.ascii \"\\n\" \n");
  fprintf(out,"\n#end of data seg\n");
}

void symbol_tabAlloc (struct symbol* s, int size, int rows) {
  s->tab = malloc(size*sizeof(float));
  if(s->tab == NULL) perror("symbol_alloc tab fail : ");
  s->isMatrix = rows;
}
