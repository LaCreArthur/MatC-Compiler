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

// generate a new quad res = arg1 op arg2
struct quad* quad_gen(int op,struct symbol* arg1,struct symbol* arg2,struct symbol* res);

// add a quad to a list of quads
void quad_add 	 (struct quad** list, struct quad* new);

// print a list of quads
void quad_print  (struct quad* list);

// free'd a list of quads
void quad_free   (struct quad* list);

// transforme quads into mips instructions
void quad_toMips (struct quad* list, FILE* out);

char* quad_opToStr(enum Op op);

#endif
