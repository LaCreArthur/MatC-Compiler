#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"

struct symbol* symbol_alloc() {
  struct symbol* new = malloc(sizeof(*new));
  if(new == NULL) perror("symbol_alloc fail : ");
  new->id = NULL;
  new->isConstant = false;
  new->value = 0;
  new->next = NULL;
  return new;
}

struct symbol* symbol_newtemp(struct symbol** tds) {
    static int nb_symbol = 0;
    char temp_name[SYMBOL_MAX_NAME];
    char* tmp = malloc(SYMBOL_MAX_NAME * sizeof(char));
    if (tmp == NULL) perror("symbol_newtemp fail : ");
    snprintf(temp_name, SYMBOL_MAX_NAME, "temp_%d", nb_symbol);
    strcpy(tmp, temp_name);
    nb_symbol++;
    return symbol_add(*tds, tmp);
}

struct symbol* symbol_add (struct symbol* symb, char* id) {
  struct symbol* temp = symb;
  if (temp == NULL) {
      temp = symbol_alloc();
      temp->id = id;
      return temp;
  }
  else {
      while (temp->next != NULL) temp = temp->next;
      temp->next = symbol_alloc();
      temp->next->id = id;
      return temp->next;
  }
}

void symbol_print (struct symbol* list){
  if (list == NULL) printf("table null\n");
	while (list != NULL) {
		printf("%s %d \n", list->id, list->value);
    list = list->next;
	}
}

void symbol_free (struct symbol* list){
  struct symbol* tmp;
  while (list != NULL)
   {
      tmp = list;
      printf("symbol free %s\n", list->id);
      list = list->next;
      free(tmp->id);
      free(tmp);
   }
}