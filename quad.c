#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symbol.h"
#include "quad.h"

struct quad* quad_gen(int op,struct symbol* arg1,struct symbol* arg2,struct symbol* res){
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
		if(list->res != NULL) {
			if (list->op == prnt) printf("print(%s)", list->res->id);
			else printf("%7s = ", list->res->id);
		}
		if(list->arg1 != NULL)
			printf("%7s ", list->arg1->id);
		if (list->arg2 != NULL)
			printf("%s%7s",quad_opToStr(list->op), list->arg2->id); // when id = expr, arg2 is NULL
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
			if (list->res->type == t_float) { 
				fprintf(out,"#load\n\tl.s $f0, %s\n", list->res->id); // load res into $f0
				if (list->arg1 != NULL) fprintf(out,"\tl.s $f1, %s\n", list->arg1->id); // load arg1 into $f1
				if (list->arg2 != NULL) fprintf(out,"\tl.s $f2, %s\n", list->arg2->id); // load arg2 into $f2
				switch (list->op) {
					case prnt: {fprintf(out, "#print float\n\tli $v0, 2\n\tmov.s $f12, $f0\n\tsyscall\n");
			    					 fprintf(out, "\tli $v0 4\n\tla $a0, newline\n\tsyscall\n"); break;}
					case add: {fprintf(out, "\t#addition      \n\tadd.s $f0, $f1, $f2\n"); break;}
					case sub: {fprintf(out, "\t#substraction  \n\tsub.s $f0, $f1, $f2\n"); break;}
					case mult: {fprintf(out, "\t#multiplication\n\tmul.s $f0, $f1, $f2\n"); break;}
					case divi: {fprintf(out, "\t#division      \n\tdiv.s $f0, $f1, $f2\n"); break;}
					case eq: {fprintf(out, "\t#affectation   \n\tmov.s $f1, $f0\n");      break;}
					default: break;
				}
				fprintf(out, "\ts.s $f0, %s\n",list->res->id); // store the new res into the res data seg
			}
			else { // else mean int => only int and float is supported for now
				fprintf(out,"#load\n\tlw $t0, %s\n", list->res->id);
				if (list->arg1 != NULL) fprintf(out,"\tlw $t1, %s\n", list->arg1->id);
				if (list->arg2 != NULL) fprintf(out,"\tlw $t2, %s\n", list->arg2->id);
				switch (list->op) {
					case prnt: {fprintf(out, "#print int\n\tli $v0, 1\n\tmove $a0, $t0\n\tsyscall\n");
				  					 fprintf(out, "\tli $v0 4\n\tla $a0, newline\n\tsyscall\n"); break;}
					case add: {fprintf(out, "\t#addition      \n\tadd $t0, $t1, $t2\n"); break;}
					case sub: {fprintf(out, "\t#substraction  \n\tsub $t0, $t1, $t2\n"); break;}
					case mult: {fprintf(out, "\t#multiplication\n\tmult $t0, $t1, $t2\n");break;}
					case divi: {fprintf(out, "\t#division      \n\tdiv $t0, $t1, $t2\n"); break;}
					case eq: {fprintf(out, "\t#affectation   \n\tmove $t1, $t0\n");     break;}
					default: break;
				}
				fprintf(out, "\tsw $t0, %s\n",list->res->id);
			}
		}
		list = list->next;
	}
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
		case seq:  { return "==";}
		case sne:  { return "!=";}
		case sgt:  { return ">"; }
		case slt:  { return "<"; }
		case sge:  { return ">=";}
		case sle:  { return "<=";}
		case not:  { return "!"; }
		case and:  { return "&&";}
		case or:   { return "||";}
		default: break;
	}
	return ""; // avoid warning
}
