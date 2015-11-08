#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symbol.h"
#include "quad.h"

struct quad* quad_gen(char op,struct symbol* arg1,struct symbol* arg2,struct symbol* res){
	struct quad* new = malloc(sizeof(*new));
	if (new == NULL) perror("quad_gen fail : ");
	new->op = op;
	new->arg1 = arg1;
	new->arg2 = arg2;
	new->res = res;
	new->next = NULL;
	return new;
}

void quad_add (struct quad** list, struct quad* new){
	if (*list == NULL) {
		*list = new;
		// printf("quad_add : list is null\n");
		// if (new == NULL) printf("quad_add : and so is new\n");
		// else printf("quad_add : and new is : %c\n", new->op);
	} else {
		// printf("quad_add : list not null\n");
		struct quad* scan = *list;
		while (scan->next != NULL) {
			scan = scan->next;
		}
		scan->next = new;
	}
}

void quad_print (struct quad* list){
	if (list == NULL) printf("quad_print : code null\n");
	while (list != NULL) {
		if(list->arg1 != NULL || list->arg2 != NULL || list->res != NULL)
			printf("%c %7s %7s %7s\n", list->op, list->arg1->id, list->arg2->id, list->res->id);
		list = list->next;
	}
}

void quad_free (struct quad* list){
	struct quad* tmp;
	while (list != NULL)
	 {
			tmp = list;
			printf("quad free %c\n", list->op);
			list = list->next;
			// if(tmp->arg1 != NULL) symbol_free(tmp->arg1);
			// if(tmp->arg1 != NULL) symbol_free(tmp->arg2);
			// if(tmp->arg1 != NULL) symbol_free(tmp->res);
			free(tmp);
	 }
}
