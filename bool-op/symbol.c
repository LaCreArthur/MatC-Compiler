#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"

struct symbol* symbol_alloc() {
  struct symbol* new = malloc(sizeof(*new));
  if(new == NULL) perror("symbol_alloc new fail : ");
  new->id = NULL;
  new->value = 0;
  new->next = NULL;
  return new;
}

struct symbol* symbol_newtemp(struct symbol** tds) {
    static int nb_symbol = 0;
    char temp_name[32];
    snprintf(temp_name, 32, "temp_%d", nb_symbol);
    nb_symbol++;
    return symbol_add(*tds, temp_name);
}

struct symbol* symbol_add (struct symbol* symb, char* id) {
  char *id_dup = strdup(id);
  struct symbol* temp = symb;
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

struct symbol* symbol_newcst(struct symbol** tds, int val){
  char temp_name[32];
  snprintf(temp_name, 32, "%d", val);
  return symbol_add(*tds, temp_name);
}

struct symbol* symbol_find(struct symbol* tds, char* id){
  struct symbol* temp = tds;
  while (temp != NULL) {
    if (strcmp(temp->id, id) == 0) return temp;
    else temp = temp->next;
  }
  return NULL;
}

void symbol_print (struct symbol* list){ // only print float and int for now
  if (list == NULL) printf("table null\n");
	while (list != NULL) {
    printf("%s %d\n", list->id, list->value);
    list = list->next;
	}
}

void symbol_free (struct symbol* list){
  struct symbol* tmp;
  while (list != NULL)
   {
      tmp = list;
      list = list->next;
      free(tmp->id);
      free(tmp);
   }
}
