#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.h"

struct symbol* symbol_alloc() {
  struct symbol* new = malloc(sizeof(*new));
  if(new == NULL) perror("symbol_alloc new fail : ");
  new->arr = NULL;
  new->id = NULL;
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

void symbol_print (struct symbol* list){ // only print float and int for now
  if (list == NULL) printf("table null\n");
	while (list != NULL) {
		printf("%s\t%s \t=", symbol_typeToStr(list->type), list->id);
    symbol_printVal(list);
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

void tds_toMips (struct symbol* list, FILE* out){ // only work for int and float by now
  fprintf(out,"\t.data\n"); // init data segment
	while (list != NULL) {
    switch (list->type) {
      case t_int:   { fprintf(out,"%s:\t.word %d\n",  list->id, (int)list->value); break;} // int vars, cast avoid warning
      case t_float: { fprintf(out,"%s:\t.float %f\n", list->id, list->value);      break;} // declare statics float vars
      case t_arr:   { fprintf(out,"%s:\t.float ",list->id); array_print(list->arr->values, out); break;}
      case t_mat:   { break; }
      case t_bool:  { break; }
      default: {break;}
    }
    list = list->next;
	}
  fprintf(out,"end_msg:\t.ascii \"\\nexit status:\" \n");
  fprintf(out,"newline:\t.ascii \"\\n\" \n");
  fprintf(out,"\n#end of data seg\n");
}

char* symbol_typeToStr (enum Type type){
  switch (type) {
    case t_int:   { return "int";    }
    case t_float: { return "float";  }
    case t_arr:   { return "float[]";}
    case t_mat:   { return "matrix"; }
    case t_bool:  { return "bool";   }
    default: {break;}
  }
  return "";
}

void symbol_printVal(struct symbol* s){
  switch (s->type) {
    case t_int:   { printf("%d\n", (int)s->value);   break;}
    case t_float: { printf("%.2f\n", s->value);      break;}
    case t_arr:   { array_print(s->arr->values,stdout);break;}
    case t_mat:   { array_print(s->arr->values,stdout);break;}
    case t_bool:  { printf("%d\n", (int)s->value);   break;}
    default: {break;}
  }
}
