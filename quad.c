#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symbol.h"
#include "quad.h"

struct quad* quad_gen(int op,struct symbol* arg1,struct symbol* arg2,struct symbol* res){
	static int current_label = 1;
	struct quad* new = malloc(sizeof(*new));
	if (new == NULL) perror("quad_gen fail : ");
	new->label = current_label++;
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
		printf("%d :\t", list->label);
		if (list->op > 7 && list-> op < 14) { // relop
			printf("if %s %s %s goto label%s",
			 	list->arg1->id, quad_opToStr(list->op), list->arg2->id, list->res->id);
		}
		else if (list->op == label) {
			printf("label %s:",list->res->id);
		}
		else {
			if(list->res != NULL) {
				if (list->op == prnt) printf("print(%s)", list->res->id);
				else if (list->op == jump){
					printf("goto label%s", list->res->id);
				}
				else printf("%7s = ", list->res->id);
			}
			if(list->arg1 != NULL) printf("%7s ", list->arg1->id);
			if (list->arg2 != NULL)  {
				printf("%s",quad_opToStr(list->op));
				printf("%7s",list->arg2->id); // when id = expr, arg2 is NULL
			}
	}
		printf("\n");
		list = list->next;
	}
}

void quad_free (struct quad* list){
	struct quad* tmp;
	while (list != NULL)
	 {
			tmp = list;
			printf("quad free %s\n", quad_opToStr(list->op));
			list = list->next;
			free(tmp);
	 }
}

void quad_toMips (struct quad* list, FILE* out){
	fprintf(out, "\t.text\nmain:\n"); // init code segment
	while (list != NULL) {
		if(list->res != NULL) {
			switch (list->res->type) {
				case t_int: { quad_toMips_intOrFloat(list, out); break;}
				case t_float: { quad_toMips_intOrFloat(list, out); break;}
				default: { fprintf(stderr, "quad_toMips : missing case : type %s\n",
										symbol_typeToStr(list->res->type)); break;}
			}
			list = list->next;
		}
	}
}

void quad_toMips_relop (struct quad* q, FILE* out){
	fprintf(out, "#relop branch and jump\n");
	if (q->arg1 != NULL ) fprintf(out,"\tlw $t1, %s\n", q->arg1->id);
	if (q->arg2 != NULL ) fprintf(out,"\tlw $t2, %s\n", q->arg2->id);
	switch (q->op) {
		case beq: {fprintf(out, "\tbeq $t1, $t2, label%d\n", (int)q->res->value); break;}
		case bne: {fprintf(out, "\tbne $t1, $t2, label%d\n", (int)q->res->value); break;}
		case bgt: {fprintf(out, "\tbgt $t1, $t2, label%d\n", (int)q->res->value); break;}
		case blt: {fprintf(out, "\tblt $t1, $t2, label%d\n", (int)q->res->value); break;}
		case bge: {fprintf(out, "\tbge $t1, $t2, label%d\n", (int)q->res->value); break;}
		case ble: {fprintf(out, "\tble $t1, $t2, label%d\n", (int)q->res->value); break;}
		case jump: {fprintf(out, "\tj label%d\n", (int)q->res->value); break;}
		case label: {fprintf(out, "\tlabel%d:\n", (int)q->res->value); break;}
		default: {fprintf(stderr, "quad_toMips_relop: unknow op %s\n", quad_opToStr(q->op));break;}
	}
}

void quad_toMips_intOrFloat (struct quad* q, FILE* out){
	fprintf(out,"#load\n\tl.s $f0, %s\n", q->res->id); // load res into $f0

	if (q->arg1 != NULL) fprintf(out,"\tl.s $f1, %s\n", q->arg1->id); // load arg1 into $f1
	if (q->arg2 != NULL) fprintf(out,"\tl.s $f2, %s\n", q->arg2->id); // load arg2 into $f2

	switch (q->op) {
		case prnt: {
			if (q->res->type == t_int) {
				fprintf(out, "#print int\n\t");
				fprintf(out,"mfc1 $t0, $f0\n\tmove $a0, $t0\n\tli $v0, 1\n\tsyscall\n");
			}
			else fprintf(out,"li $v0, 2\n\tmov.s $f12, $f0\n\tsyscall\n");
			fprintf(out, "\tli $v0 4\n\tla $a0, newline\n\tsyscall\n"); return;}
		case add: {
			if (q->arg1->type == t_int) fprintf(out,"\tcvt.s.w $f1, $f1\n"); // convert f1 to float for operation
			if (q->arg2->type == t_int) fprintf(out,"\tcvt.s.w $f2, $f2\n"); // convert f2 to float for operation
			fprintf(out, "\t#addition      \n\tadd.s $f0, $f1, $f2\n"); break;}
		case sub: {
			if (q->arg1->type == t_int) fprintf(out,"\tcvt.s.w $f1, $f1\n");
			if (q->arg2->type == t_int) fprintf(out,"\tcvt.s.w $f2, $f2\n");
			fprintf(out, "\t#substraction  \n\tsub.s $f0, $f1, $f2\n"); break;}
		case mult: {
			if (q->arg1->type == t_int) fprintf(out,"\tcvt.s.w $f1, $f1\n");
			if (q->arg2->type == t_int) fprintf(out,"\tcvt.s.w $f2, $f2\n");
			fprintf(out, "\t#multiplication\n\tmul.s $f0, $f1, $f2\n"); break;}
		case divi: {
			if (q->arg1->type == t_int) fprintf(out,"\tcvt.s.w $f1, $f1\n");
			if (q->arg2->type == t_int) fprintf(out,"\tcvt.s.w $f2, $f2\n");
			fprintf(out, "\t#division      \n\tdiv.s $f0, $f1, $f2\n"); break;}
		case eq: {
			if (q->res->type == t_int)
				fprintf(out, "\t#conversion \n\tcvt.w.s $f1, $f1\n"); // conversion float->int
			fprintf(out, "\t#affectation   \n\tmov.s $f0, $f1\n");break;
		}
		default: {fprintf(stderr, "quad_toMips_float: unknow op %s\n", quad_opToStr(q->op));break;}
	}
	fprintf(out, "\ts.s $f0, %s\n",q->res->id); // store the new res into the res data seg
}

char* quad_opToStr(enum Op op){
	switch (op) {
		case eq:   { return "="; }
		case add:  { return "+"; }
		case sub:  { return "-"; }
		case mult: { return "*"; }
		case divi: { return "/"; }
		case neg:  { return "-"; }
		case incr: { return "++";}
		case decr: { return "--";}
		case beq:  { return "==";}
		case bne:  { return "!=";}
		case bgt:  { return ">"; }
		case blt:  { return "<"; }
		case bge:  { return ">=";}
		case ble:  { return "<=";}
		case not:  { return "!"; }
		case and:  { return "&&";}
		case or:   { return "||";}
		case jump: { return "jump";}
		case label:{ return "label";}
		default: break;
	}
	return ""; // avoid warning
}

/*********************************\
| quad_list for conditionnal expr |
\*********************************/

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
