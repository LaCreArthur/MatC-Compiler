%{
  #ifdef YYDEBUG
    int yydebug = 1;
  #endif
  #include <stdio.h>
  #include <stdlib.h>
	#include <string.h>
	#include <math.h>
  #include "symbol.h"
  #include "quad.h"
  #include "matrix.h"
  #include "expr.h"
  #include "testmatrix.h"

  int yylex();
  int yyerror();
  float tmp_arr[100] = { [0 ... 99] = INFINITY};
  int tmp_arr_index = 0;
  int tmp_dims[10];
  int tmp_dims_index = 0;

  void tmp_arr_clear() {
	tmp_arr_index = 0;
    tmp_dims_index = 0;
    for (int i=0; i<ARRAY_MAX_SIZE; i++) {
      tmp_arr[i] = INFINITY;
    }
    for (int i=0; i<DIMS_MAX_SIZE; i++) {
      tmp_dims[i] = 0;
    }
  }

  int compute_offset(array* arr) {
	  // float a[m][n][o];
	  // a [i][j][k] = 3.0;
	  // offset = i*n + j*n + o;

	  int offset = 0;
	  int i;
	  for (i=0; i < tmp_dims_index - 1; i++) {
		  offset += tmp_dims[i] * arr->dims[i+1];
	  }
	  offset += tmp_dims[i];
	  offset *= 4; // size of float
	  return offset;
  }

%}

%union {
  int int_value;
  int* dims;
  float* values;
  float float_value;
  char* str_value;
	struct {
		struct symbol* result;
		struct quad* code;
	} codegen;
  struct {
    struct quad_list* truelist;
    struct quad_list* falselist;
    struct quad* code;
  } quadlist;
}

%type <codegen> expression affect statement block
%type <dims> dimensions
%type <values> values
%type <quadlist> condition

%token <int_value> INT TYPE
%token <int_value> RELOP NOT AND OR
%token <float_value> FLOAT
%token <str_value> ID INCRorDECR STR
%token MAIN PRINT PRINTF PRINTM IF ELSE WHILE
%token '+' '-' '*' '/'
%token '(' ')' '[' ']'
%token END

%left '+' '-'
%left '*' '/'
%left NEG
%left RELOP NOT AND OR

%right INCRorDECR

%start axiom

%%

axiom:

	| main

	;
main:
  TYPE MAIN '(' ')' '{' block
  ;

block:
   statement block
  {
    if($1.code != NULL) {
      $$.code = $1.code;
      if($2.code != NULL) {
        quad_add(&$$.code, $2.code);
      }
    }
    else $$.code = $2.code;
    code = $$.code;
  }

  | WHILE '(' condition ')' '{' block block
  {
    struct quad* jump_loop;
    struct quad* label_loop;
    struct quad* label_true; // equivaut a tag dans "if cond tag stmnt next"
    struct quad* label_next; // next block label

    label_loop = quad_gen(label, NULL, NULL,symbol_newcst(&tds, $3.code->label));
    jump_loop       = quad_gen(jump, NULL, NULL, label_loop->res);
    label_true = quad_gen(label, NULL, NULL,symbol_newcst(&tds, $6.code->label));
    label_next = quad_gen(label, NULL, NULL,symbol_newcst(&tds, $7.code->label));

    quad_list_complete($3.truelist, label_true->res);  // backpatching truelist with label_true
    quad_list_complete($3.falselist, label_next->res); // backpatching falselist with label_false

    $$.code = label_loop;           // label before condition
    quad_add(&$$.code, $3.code);    // condition code
    quad_add(&$$.code, label_true); // label for true
    quad_add(&$$.code, $6.code);    // stmnt for true
    quad_add(&$$.code, jump_loop);  // jump before condition
    quad_add(&$$.code, label_next); // label after stmnt true
    quad_add(&$$.code, $7.code);    // the rest of the code
  }

  | IF '(' condition ')' '{' block block
  {
    struct quad* label_true;  // equivaut a tag dans "if cond tag stmnt next"
    struct quad* label_next;  // next block label

    // label of the stmnt
    label_true = quad_gen(label, NULL, NULL,symbol_newcst(&tds, $6.code->label));
    // goto after stmnt
    label_next = quad_gen(label, NULL, NULL,symbol_newcst(&tds, $7.code->label));

    quad_list_complete($3.truelist, label_true->res);  // backpatching truelist with label_true
    quad_list_complete($3.falselist, label_next->res); // backpatching falselist with label_false

    $$.code = $3.code;              // condition code
    quad_add(&$$.code, label_true); // label for true
    quad_add(&$$.code, $6.code);    // stmnt for true
    quad_add(&$$.code, label_next); // label after stmnt true
    quad_add(&$$.code, $7.code);    // the rest of the code
  }

  | IF '(' condition ')' '{' block ELSE '{' block block
  {
    struct quad*   q_jump;
    struct quad* label_true;  // equivaut a tag dans "if cond tag stmnt else tagoto stmnt next"
    struct quad* label_false; // equivaut a tagoto
    struct quad* label_next;  // next block label
    // if($4.code == NULL) printf("nothing in the if block ! \n");
    // if($7.code == NULL) printf("nothing in the else block ! \n");

    // label of the 1st stmnt
    label_true  = quad_gen(label, NULL, NULL,symbol_newcst(&tds, $6.code->label));
    // goto after 2nd stmnt : jump after stmnt false
    label_next  = quad_gen(label, NULL, NULL,symbol_newcst(&tds, $10.code->label));
    q_jump      = quad_gen(jump, NULL, NULL, label_next->res);
    // label of the 2nd stmnt
    label_false = quad_gen(label, NULL, NULL,symbol_newcst(&tds, $9.code->label));

    quad_list_complete($3.truelist, label_true->res);  // backpatching truelist with label_true
    quad_list_complete($3.falselist, label_false->res); // backpatching falselist with label_false

    $$.code = $3.code;              // condition code
    quad_add(&$$.code, label_true); // label for true
    quad_add(&$$.code, $6.code);    // stmnt for true
    quad_add(&$$.code, q_jump);     // jump after stmnt false if true
    quad_add(&$$.code, label_false);// label for false
    quad_add(&$$.code, $9.code);    // stmnt for false
    quad_add(&$$.code, label_next); // label after stmnt false
    quad_add(&$$.code, $10.code);   // the rest of the code
  }

  | '}' {$$.code = NULL;}
  ;

condition:
  expression RELOP expression
  {
    // printf("relop %d \n", $2);
    struct quad* goto_true   = quad_gen($2, $1.result, $3.result, NULL);
    struct quad* goto_false  = quad_gen(jump, NULL, NULL, NULL);
    $$.code = $1.code;
    quad_add(&$$.code, $3.code);
    quad_add(&$$.code, goto_true);
    quad_add(&$$.code, goto_false);
    $$.truelist   = quad_list_new(goto_true);
    $$.falselist  = quad_list_new(goto_false);
  }

  | '(' condition ')'
  {
    $$.truelist = $2.truelist;
    $$.falselist = $2.falselist;
    $$.code = $2.code;
  }

  | NOT condition
  {
    $$.truelist = $2.falselist;
    $$.falselist = $2.truelist;
    $$.code = $2.code;
  }

  | condition OR condition
  {
    printf("cond -> expr OR expr\n");
    struct quad* label_false  =
      quad_gen(label, NULL, NULL, symbol_newcst(&tds, $3.truelist->node->label));

    quad_list_complete($1.falselist, label_false->res);
    $$.code = $1.code;               // first condition
    quad_add(&$$.code, label_false); // if first is false goto second
    quad_add(&$$.code, $3.code);     // second cond
    $$.falselist = $3.falselist;
    $$.truelist = $1.truelist;
    quad_list_add(&$$.truelist, $3.truelist); // first or second cond true same jump
  }

  | condition AND condition
  {
    printf("cond -> expr AND expr\n");
    struct quad* label_true  =
      quad_gen(label, NULL, NULL, symbol_newcst(&tds, $3.truelist->node->label));

    quad_list_complete($1.truelist, label_true->res);
    $$.code = $1.code;               // first condition
    quad_add(&$$.code, label_true);  // if first is true goto second
    quad_add(&$$.code, $3.code);     // second cond
    $$.falselist = $1.falselist;
    $$.truelist = $3.truelist;
    quad_list_add(&$$.falselist, $3.falselist); // first or second cond false same jump
  }
  ;

statement:
  ';' {$$.code = NULL;}// do nothing

  | TYPE ID affect
  { // printf(" Type : %d !\n", $1);
    struct symbol* new_id;
    if ( (new_id = affectation($1,$2,$3.result, &$$.code, $3.code,1)) == NULL) {
      fprintf(stderr,"%s:%d: error: redeclaration of '%s' with no linkage\n",
			  filename, line, $2);
      exit_status = FAIL;
      YYABORT;
    }
    quad_add(&$$.code, quad_gen(eq, $3.result,NULL, new_id)); // store this stmnt code
  }

  | TYPE ID dimensions affect
  {
    if($1 == t_int || $1 == t_bool){ // wrong array type
      fprintf(stderr,"%s:%d:%d: error: expected 'float' or 'matrix' but argument is of "
                     "type '%s'\n",filename, line, column, symbol_typeToStr($1));
      exit_status = FAIL;
    }
    else {
      // array_print(tmp_arr, stdout);
      if(tmp_arr_index > $4.result->arr->size){
        // declare too many values inside the "{}"
        fprintf(stderr,"%s:%d:%d: error: excess elements in array initializer\n"
                      ,filename, line, column);
        exit_status = FAIL;
      }
      struct symbol* new_id;
      if ( (new_id = affectation($1,$2,$4.result, &$$.code, $4.code,1)) == NULL) {
        fprintf(stderr,"%s:%d: error: redeclaration of '%s' with no linkage\n",
				filename, line, $2);
        exit_status = FAIL;
        YYABORT;

      }
      quad_add(&$$.code, quad_gen(eq, $4.result,NULL, new_id));
    }

    tmp_arr_index = 0;
    tmp_dims_index = 0;
    for (int i=0; i<ARRAY_MAX_SIZE; i++) {
      tmp_arr[i] = INFINITY;
    }
    for (int i=0; i<DIMS_MAX_SIZE; i++) {
      tmp_dims[i] = 0;
    }
  }

  | ID indexes affect
  {
	  // affectation in array element

	  struct symbol* sym_arr;

	  // temp int for the offset
	  struct symbol* sym_offset = symbol_alloc();
	  sym_offset = symbol_newtemp(&tds);
	  sym_offset->type = t_int;

	  // retrieve the existing array
	  if ((sym_arr = symbol_find(tds, $1)) == NULL) {
	      error_undeclared(filename, line, column, $1);
		  exit_status = FAIL;
		  return 1;
	  }

	  /* compute the offset */


	  sym_offset->value = compute_offset(sym_arr->arr);
	  quad_add(&$$.code, quad_gen(arr_aff, sym_offset, $3.result, sym_arr));

	  tmp_arr_clear();


  }

  | ID affect
  {
    if (affectation(0,$1,$2.result, &$$.code, $2.code,0) == NULL) { // arg char* type is not needed
          column-=strlen($1)+3;
          fprintf(stderr,"%s:%d:%d: error: '%s' undeclared (first use in this function)\n",
                  filename, line, column, $1);
          exit_status = FAIL;
          return 1;
    }
    // printf("affectation ok \n");
  }

  | expression INCRorDECR	';'
  { //printf("expr -> expr++\n");
    int op = ($2[0] == '+' ? incr : decr); // to add or remove 1
    // a temp with value 1
    struct symbol* incrOrDecr_tmp = (struct symbol*)calloc(1,sizeof(struct symbol));
    temp_add(&incrOrDecr_tmp);
    incrOrDecr_tmp->value = 1;
    // add a quad E = E +/- 1
    quad_add(&$1.code, quad_gen( op,$1.result,incrOrDecr_tmp,$1.result));
    //$1.result->value = op_calc(op, $1.result, incrOrDecr_tmp);
    quad_add(&code, $1.code);
  }

  | PRINT '(' ID ')' ';'
  {
    struct symbol* id;
    if ((id = symbol_find(tds,$3)) != NULL) {
      // printf("___found !");
      quad_add(&$$.code,quad_gen(prnt,NULL,NULL,id));
    }
    else {
      column-=strlen($3)+3;
      fprintf(stderr,"%s:%d:%d: error: '%s' undeclared (first use in this function)\n",
              filename, line, column, $3);
      exit_status = FAIL;
      YYABORT;
    }
  }

  | PRINT '(' ID indexes ')' ';'
  {
	  struct symbol* sym_arr;
	  struct symbol* sym_offset = symbol_alloc();
	  sym_offset = symbol_newtemp(&tds);
	  sym_offset->type = t_int;

	  if ((sym_arr = symbol_find(tds, $3)) == NULL) {
		  error_undeclared(filename, line, column, $3);
		  exit_status = FAIL;
		  return 1;
	  }

	  sym_offset->value = compute_offset(sym_arr->arr);
	  quad_add(&$$.code, quad_gen(prnt, sym_offset, NULL, sym_arr));

	  tmp_arr_clear();
  }

  | PRINTF '(' STR ')' ';'
  {
    printf(" PRINTF match ! \n");
  }

  | PRINTM '(' ID ')' ';'
  {
    printf(" PRINTM match ! \n");
  }
  ;

affect:
    ';'
  { $$.result = NULL; $$.code = NULL;} // not tested

  | '=' expression ';'
  { $$ = $2;}

  | '=' '{' brackets '}' ';'
  {
    temp_add(&$$.result);
    $$.code = NULL;
    $$.result->type = t_arr;
    $$.result->value = INFINITY; // no float value for arrays
    $$.result->arr = array_new(tmp_dims, tmp_dims_index);
    $$.result->arr->values=arr_cpy_tmp(tmp_arr,$$.result->arr->size);
    $$.result->arr->values[$$.result->arr->size] = INFINITY;
  }
  ;


brackets:
    values
  {
  }

  | '{' values '}' ',' '{' brackets '}'
  {
  }
  ;

values:
    FLOAT
  {
  if ($$ == NULL) {
    printf("$$ is null");
  }
  tmp_arr[tmp_arr_index] = $1;
  tmp_arr_index++;
  printf("%.2f",$1);
  }

  | values ',' FLOAT
  {
  tmp_arr[tmp_arr_index] = $3;
  tmp_arr_index++;
  printf("%.2f",$3);
  }
  ;

indexes:
    '[' expression ']'
	{
		tmp_dims[tmp_dims_index] = $2.result->value;
		tmp_dims_index++;
	}

    | indexes '[' expression ']'
	{
		tmp_dims[tmp_dims_index] = $3.result->value;
		tmp_dims_index++;

	}
;
    
 // store multiple indexes for multiple dimensions arrays
dimensions:
      '[' INT ']'
    {
      tmp_dims[tmp_dims_index] = $2;
      tmp_dims_index++;
    }

    | dimensions '[' INT ']'
    {
      tmp_dims[tmp_dims_index] = $3;
      tmp_dims_index++;
    }
    ;

expression:
  expression '+' expression
  { //printf("expr -> expr + expr\n");
    expr_add(add, &$$.result, &$$.code,
                   $1.result, $1.code,
                   $3.result, $3.code);
  }

  | expression '-' expression
  { //printf("expr -> expr - expr\n");
		expr_add(sub, &$$.result, &$$.code,
									 $1.result, $1.code,
									 $3.result, $3.code);
  }

  | expression '*' expression
  { //printf("expr -> expr * expr\n");
    expr_add(mult, &$$.result, &$$.code,
                  $1.result, $1.code,
                  $3.result, $3.code);
  }

  | expression '/' expression
  { //printf("expr -> expr / expr\n");
    expr_add(divi, &$$.result, &$$.code,
                  $1.result, $1.code,
                  $3.result, $3.code);
  }

  | '-' expression %prec NEG
  {
    //printf("-%d",$2.result->value);
    $$ = $2;
    $$.result->value = -$2.result->value;
  }

  | '(' expression ')'
  { $$ = $2; }

  | INT
  { //printf("expr -> INT\n");
    printf("%d",$1);
    temp_add(&$$.result);
    $$.code = NULL;
    $$.result->type = t_float;
    $$.result->value = $1;
  }

  | FLOAT
  { //printf(expr -> INT\n");
    printf("%.2f",$1);
    temp_add(&$$.result);
    $$.code = NULL;
    $$.result->type = t_float;
    $$.result->value = $1;
  }

  | ID indexes
  {
  //printf("___array[%d] spoted\n", $2);
  }

  | ID
  { //printf("expr -> ID\n");
		//printf("ID = %s",$1);
    struct symbol* id;
    //printf("____(look for %s ... ", $1);
    if ((id = symbol_find(tds,$1)) != NULL) {
      //printf("found !)");
      $$.result = id;
    }
    else {
      column-=strlen($1)+3;
      fprintf(stderr,"%s:%d:%d: error: '%s' undeclared (first use in this function)\n",
              filename, line, column, $1);
      exit_status = FAIL;
      return 1;
    }
		$$.code = NULL;
	}
  ;



%%

int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
}

int main(int argc, char *argv[]){
  if (argc < 2) {
     fprintf(stderr," usage : %s <file.cpp> [-debug]\n", argv[0]);
     exit(EXIT_FAILURE);
   }
  // yydebug=1;
  extern int DEBUG;
  if ((argc == 2 && strcmp(argv[1], "-debug") == 0) ||
      (argc == 3 && strcmp(argv[2], "-debug") == 0)) {
    DEBUG = 1;
    printf("DEBUG MODE\n..........\n");
  }

  // read a file
  extern int yylex();
  extern FILE* yyin;
  if (argc > 1 && strcmp(argv[1], "-debug") != 0){
    if ((yyin = fopen(argv[1],"r")) == NULL){
      perror("fopen code :");
    };
    // save the name of the file
    filename = strdup(argv[1]);
    if(yyin == NULL) perror("yacc_fopen ");
  }

  // the result asm file
  char asm_file[50];
  strncpy(asm_file,filename,sizeof(filename)-1);
  strncat(asm_file,".asm",4);
  if ((out = fopen(asm_file,"w")) == NULL) {
    perror("failed to open `asm_file`:");
    printf("asm_file: %s\n", asm_file);
  }
  exit_status = SUCCESS;
  /////////////////////////////
  yyparse();
  /////////////////////////////
  exit_msg (exit_status);

  printf("\ntable :\n");
  symbol_print(tds);
  printf("\ncode :\n");
  quad_print(code);

  tds_toMips(tds,out);
  quad_toMips(code,out);
  fprintf(out,"exit:\n\tli $v0 4\n\tla $a0, end_msg\n\tsyscall"); // print end_msg
  fprintf(out,"\n\tli $a0 1\n\tli $v0 1\n\tsyscall\n"); // end of asm code
  fprintf(out, "\tli $v0 4\n\tla $a0, newline\n\tsyscall\n\tj $ra"); // print a newline

  printf("Assembler code successfully written to %s\n", asm_file);

  quad_free(code);
  symbol_free(tds);

  // // tests dans testmatrix.c
  //test();
}
