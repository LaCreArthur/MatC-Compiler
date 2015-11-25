#ifndef __QUAD__H__
#define __QUAD__H__

enum Op{
	eq, add, sub, mult, divi, 		// binary op
	neg, incr, decr, 							// unary op
	seq, sne, sgt, slt, sge, sle, // rel op
	not, and, or,									// bool op
	prnt, prntf, prntm						// print op
} Op;

struct quad {
	enum Op op;
	struct symbol* arg1;
	struct symbol* arg2;
	struct symbol* res;
	struct quad* next;
};

struct quad* quad_gen(int op,struct symbol* arg1,struct symbol* arg2,struct symbol* res);
void quad_add (struct quad** list, struct quad* new);
void quad_print (struct quad* list);
void quad_free (struct quad* list);
void quad_toMips (struct quad* list, FILE* out);

#endif
