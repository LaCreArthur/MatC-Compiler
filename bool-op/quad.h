#ifndef __QUAD__H__
#define __QUAD__H__

struct quad {
	int label;
	char op;
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
struct quad* 	quad_gen(int label, char op,struct symbol* arg1,struct symbol* arg2,struct symbol* res);
void 					quad_add(struct quad** list, struct quad* new);
void 					quad_print(struct quad* list);

struct quad_list* quad_list_new(struct quad*);
void quad_list_add(struct quad_list**, struct quad_list*);
void quad_list_complete(struct quad_list*, struct symbol*);
void quad_list_print(struct quad_list*);

#endif
