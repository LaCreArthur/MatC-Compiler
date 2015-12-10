#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symbol.h"
#include "quad.h"

struct quad* quad_gen(int label, char op,struct symbol* arg1,struct symbol* arg2,struct symbol* res){
	struct quad* new = malloc(sizeof(*new));
	if (new == NULL) perror("quad_gen fail : ");
	new->label = label;
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
	} else {
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
		printf("label %d :\t", list->label);
		if (list->op == ':') {
			if(list->res != NULL)
	 			printf("%s <= ", list->res->id);
			if(list->arg1 != NULL)
				printf("%s ", list->arg1->id);
		}
		else if (list->op == '>') {
			if(list->arg1 != NULL)
				printf("if %s ", list->arg1->id);
			if (list->arg2 != NULL)
				printf("%c %s then ",list->op, list->arg2->id);
			if(list->res != NULL)
				printf(" goto %s ", list->res->id);
		}
		else if (list->op == 'G') {
			if(list->res != NULL)
				printf(" goto %s ", list->res->id);
		}
		else {
			if(list->arg1 != NULL)
				printf("%s ", list->arg1->id);
			if (list->arg2 != NULL)
				printf("%c %s",list->op, list->arg2->id);
			if(list->res != NULL)
				printf(" = %s ", list->res->id);
		}
		printf("\n");
		list = list->next;
	}
}

struct quad_list* quad_list_new(struct quad* node){
	struct quad_list* new = malloc(sizeof(struct quad_list));
	new->node = node;
	new->next = NULL;
	return new;
}

void quad_list_add(struct quad_list** dest, struct quad_list* src){
	if (*dest==NULL) {
		*dest = src;
	} else {
		struct quad_list* new = *dest;
		while (new->next != NULL)
			new = new->next;
		new->next = src;
	}
}

void quad_list_complete(struct quad_list* list, struct symbol* label){
	while (list != NULL){
		list->node->res = label;
		list = list->next;
	}
}

void quad_list_print(struct quad_list* list){
	int i=0;
	while(list != NULL){
		printf("quad %d :\n",++i);
		quad_print(list->node);
		printf("\n");
		list=list->next;
	}
}
