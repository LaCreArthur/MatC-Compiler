#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "symbol.h"
#include "quad.h"

#define mips_l(line, ...) fprintf(out, "\t" line "\n", ##__VA_ARGS__)
#define mips_label(label, ...) fprintf(out, label ":\n", ##__VA_ARGS__)
#define mips_comment(line, ...) fprintf(out, "#" line "\n", ##__VA_ARGS__)


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
		if (list->op >= beq && list-> op <= ble) { // relop
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
			case t_int:
				quad_toMips_intOrFloat(list, out);
				break;

			case t_float:
				quad_toMips_intOrFloat(list, out);
				break;

			case t_arr:
				quad_toMips_array(list, out);
				break;

			default:
				fprintf(stderr, "quad_toMips : missing case : type %s\n",
						symbol_typeToStr(list->res->type));
				break;
			}
			list = list->next;
		}
	}
}

void quad_toMips_relop (struct quad* q, FILE* out) {
	mips_comment("---- (%s, %s, %s, %s) ---- ",
				 (q->res != NULL) ? q->res->id: "--",
				 quad_opToStr(q->op),
				 (q->arg1 != NULL) ? q->arg1->id: "--",
				 (q->arg2 != NULL) ? q->arg2->id: "--");
	mips_l("\n");

	mips_comment("relop branch and jump");

	if (q->arg1 != NULL) {
		// load arg1 into $f1
		mips_l("l.s $f1, %s", q->arg1->id);

		if (q->arg1->type == t_int)
			mips_l("cvt.s.w $f1, $f1");
	}

	if (q->arg2 != NULL) {
		// load arg2 into $f2
		mips_l("l.s $f2, %s", q->arg2->id);

		if (q->arg2->type == t_int)
			mips_l("cvt.s.w $f2, $f2");
	}

	switch (q->op) {
		// exist
	case beq:
		mips_l("c.eq.s $f1, $f2");
		mips_l("bc1t label%d", (int)q->res->value);
		break;


		// neq = !eq
	case bne:
		mips_l("c.eq.s $f1, $f2");
		mips_l("bc1f label%d", (int)q->res->value);
		break;

		// gt = !le
	case bgt:
		mips_l("c.le.s $f1, $f2");
		mips_l("bc1f label%d", (int)q->res->value);
		break;

		// exist
	case blt:
		mips_l("c.lt.s $f1, $f2\n\tbc1t label%d\n", (int)q->res->value);
		break;

		// ge = !lt
	case bge:
		mips_l("c.lt.s $f1, $f2\n\tbc1f label%d\n", (int)q->res->value);
		break;

		// exist
	case ble:
		mips_l("c.le.s $f1, $f2\n\tbc1t label%d\n", (int)q->res->value);
		break;

	case jump:
		mips_l("j label%d\n", (int)q->res->value);
		break;

	case label:
		mips_l("label%d:", (int)q->res->value);
		break;

	default:
		fprintf(stderr, "quad_toMips_relop: unknow op %s\n", quad_opToStr(q->op));

	}
	mips_comment("---- end of quad ----");
	mips_l("\n");
}

void quad_toMips_intOrFloat (struct quad* q, FILE* out){
	// branch to relop
	if (q->op >= beq && q-> op <= ble) {
		quad_toMips_relop(q, out);
		return;
	}
	mips_comment("---- (%s, %s, %s, %s) ---- ",
				 q->res->id,
				 quad_opToStr(q->op),
				 (q->arg1 != NULL) ? q->arg1->id: "--",
				 (q->arg2 != NULL) ? q->arg2->id: "--");
	mips_l("\n");
	mips_comment("load");
	mips_l("l.s $f0, %s", q->res->id); // load res into $f0

	if (q->arg1 != NULL)
		// load arg1 into $f1
		mips_l("l.s $f1, %s", q->arg1->id);

	if (q->arg2 != NULL)
		// load arg2 into $f2
		mips_l("l.s $f2, %s", q->arg2->id);

	// convert for prnt and eq cause non-predictible issues
	if (q->op != prnt && q->op != eq) {
		if (q->arg1->type == t_int)
			// convert f1 to float for operation
			mips_l("cvt.s.w $f1, $f1");

		if (q->arg2->type == t_int)
			// convert f2 to float for operation
			mips_l("cvt.s.w $f2, $f2");
	}
	switch (q->op) {
	case prnt:
		if(q->res->type == t_int) {
			mips_comment("print int");
			mips_l("mfc1 $t0, $f0");
			mips_l("move $a0, $t0");
			mips_l("li $v0, 1");
			mips_l("syscall");
		} else {
			mips_comment("print float");
			mips_l("mov.s $f12, $f0");
			mips_l("li $v0, 2");
			mips_l("syscall");
		}
		mips_l("li $v0 4");
		mips_l("la $a0, newline");
		mips_l("syscall");
		return;
		break;
	case add:
		mips_comment("addition");
		mips_l("add.s $f0, $f1, $f2");
		break;

	case sub:
		mips_comment("subtraction");
		mips_l("sub.s $f0, $f1, $f2");
		break;

	case mult:
		mips_comment("multiplication");
		mips_l("mul.s $f0, $f1, $f2");
		break;

	case divi:
		mips_comment("division");
		mips_l("div.s $f0, $f1, $f2");
		break;

	case eq:
		if (q->res->type == t_int) {
			// conversion float->int
			mips_comment("conversion");
			mips_l("cvt.w.s $f1, $f1");
		}
		mips_comment("affectation");
		mips_l("mov.s $f0, $f1");
		break;

	default:
		fprintf(stderr, "quad_toMips_float: unknow op %s\n", quad_opToStr(q->op));
	}
	// store the new res into the res data seg
	mips_comment("store new res in res data segment");
	mips_l("s.s $f0, %s", q->res->id);
	mips_l("\n");
}


void quad_toMips_array (struct quad* q, FILE* out) {
	mips_comment("---- (%s, %s, %s, %s) ---- ",
				 q->res->id,
				 quad_opToStr(q->op),
				 (q->arg1 != NULL) ? q->arg1->id: "--",
				 (q->arg2 != NULL) ? q->arg2->id: "--");
	mips_l("\n");

	mips_comment("load %s", q->res->id);

	switch (q->op) {
	case arr_aff:
		mips_comment("%s []= %d %s", q->res->id,
					 (int) q->arg1->value, q->arg2->id);
		mips_l("l.s $f0, %s", q->arg2->id);
		mips_l("s.s $f0, %s + %d", q->res->id, (int) q->arg1->value);
		break;
	case prnt:
		mips_l("l.s $f12 %s + %d", q->res->id, (int) q->arg1->value);
		mips_l("li $v0, 2"); // print float
		mips_l("syscall");

		mips_l("addi $a0,$0,10"); // print space
		mips_l("li $v0, 11");
		mips_l("syscall");
		break;
	default:
		mips_l("#unhandled op: %s", quad_opToStr(q->op));
	}
	mips_comment("---- end quad ----\n");
	mips_l("\n");
}

void quad_toMips_matrix (struct quad* q, FILE* out) {
	switch (q->op) {
	case prnt:
		mips_comment("print array");
		mips_l("li $t0, %d", q->res->arr->size); // load array size in t0
		mips_l("li $t1 0\n"); // loop counter

		mips_label("print_loop");
		mips_l("l.s $f12 ($a1)"); // load array into $a1
		mips_l("li $v0, 2"); //
		mips_l("syscall");

		mips_l("la $a0, 32"); // print space
		mips_l("li $v0, 11");
		mips_l("syscall");

		mips_l("addi $t1, $t1, 1"); // increment counter
		mips_l("addi $a1, $a1, 4"); // move to next element in array
		mips_l("blt $t1, $t0, print_loop"); // loop
		break;
	default:
		break;
	}

}

char* quad_opToStr(enum Op op){
	switch (op) {
	case eq:
		return "=";
		break;

	case add:
		return "+";
		break;

	case sub:
		return "-";
		break;

	case mult:
		return "*";
		break;

	case divi:
		return "/";
		break;

	case neg:
		return "-";
		break;

	case incr:
		return "++";
		break;

	case decr:
		return "--";
		break;

	case beq:
		return "==";
			break;

	case bne:
		return "!=";
			break;

	case bgt:
		return ">";
		break;

	case blt:
		return "<";
		break;

	case bge:
		return ">=";
		break;

	case ble:
		return "<=";
		break;

	case not:
		return "!";
		break;

	case and:
		return "&&";
		break;

	case or:
		return "||";
		break;

	case jump:
		return "jump";
		break;

	case label:
		return "label";
		break;

	case arr_aff:
		return "[]=";
		break;
	case prnt:
		return "print";
		break;
	default:
		break;
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
