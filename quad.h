#ifndef __QUAD__H__
#define __QUAD__H__

enum Op{
	eq, add, sub, mult, divi, 		// binary op
	neg, incr, decr, 							// unary op
	seq, sne, sgt, slt, sge, sle, // rel op
	not, and, or,	Goto,	label,		// bool op
	prnt, prntf, prntm						// print op
} Op;

struct quad {
	int label;
	enum Op op;
	struct symbol* arg1;
	struct symbol* arg2;
	struct symbol* res;
	struct quad* next;
};

struct quad_list {
	struct quad* node;
	struct quad_list* next;
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
// get str from enum
char* quad_opToStr(enum Op op);

/*********************************\
| quad_list for conditionnal expr |
\*********************************/

// init a quad_list : quad is the first node
struct quad_list* quad_list_new(struct quad* node);
// concatenation of two list, first one can be empty
void quad_list_add(struct quad_list**, struct quad_list*);
// for each quad of the quad_list : add label into the res symbol of this quad
void quad_list_complete(struct quad_list*, struct symbol* label);
// print...
void quad_list_print(struct quad_list*);

#endif
