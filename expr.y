%{
  #include <stdio.h>
  #include <stdlib.h>
	#include <string.h>
	#include <math.h>
  #include "symbol.h"
  #include "quad.h"
  #include "matrix.h"
  #include "expr.h"
  #include "testmatrix.h"

  int exit_status = SUCCESS;
  int yylex();
  int yyerror();
  float tmp_arr[100] = { [0 ... 99] = INFINITY};
  int tmp_arr_index = 0;
  int tmp_dims[10];
  int tmp_dims_index = 0;

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

}

%type <codegen> E affect
%type <dims> indice
%type <values> values

%token <int_value> INT INDEX TYPE
%token <float_value> FLOAT
%token <str_value> ID INCRorDECR STR
%token MAIN PRINT PRINTF PRINTM
%token <relop> RELOP
%token '+' '-' '*' '/'
%token '(' ')'
%token END

%left '+' '-'
%left '*' '/'
%left NEG

%right INCRorDECR
%right INDEX

%start axiom

%%

axiom:

	| main

	;
main:
  TYPE MAIN '(' ')' '{' block
  ;

block:
   stmnt block
  | '}'
  ;

stmnt:
  ';' // do nothing

  | TYPE ID affect
  { //printf(" Type : %d !\n", $1);
    struct symbol* new_id = affectation($1,$2,$3.result, $3.code,1);
    quad_add(&code, quad_gen(eq, $3.result,NULL, new_id)); // store this stmnt code
    int tested = 2.5 + 2.5;
    printf("test : %d\n ", tested);
  }
  | TYPE ID indice affect
  {
    if($1 == t_int || $1 == t_bool){ // wrong array type
      fprintf(stderr,"%s:%d:%d: error: expected 'float' or 'matrix' but argument is of "
                     "type '%s'",filename, line, column, symbol_typeToStr($1));
      exit_status = FAIL;
    }
    else {
      // array_print(tmp_arr, stdout);
      if(tmp_arr_index > $4.result->arr->size){
        // declare too many values inside the "{}"
        fprintf(stderr,"%s:%d:%d: error: excess elements in array initializer"
                      ,filename, line, column);
        exit_status = FAIL;
      }
      struct symbol* new_id = affectation($1,$2,$4.result, $4.code,1);
      quad_add(&code, quad_gen(eq, $4.result,NULL, new_id));
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
  | ID indice affect
  {
    // access to an element of the array
  }
  | ID affect
  {
    if (affectation(0,$1,$2.result, $2.code,0) == NULL) { // arg char* type is not needed
          column-=strlen($1)+3;
          fprintf(stderr,"%s:%d:%d: error: '%s' undeclared (first use in this function)",
                  filename, line, column, $1);
          exit_status = FAIL;
          return 1;
    }
  }
  | E INCRorDECR	';'
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
      quad_add(&code,quad_gen(prnt,NULL,NULL,id));
    }
    else {
      column-=strlen($3)+3;
      fprintf(stderr,"%s:%d:%d: error: '%s' undeclared (first use in this function)",
              filename, line, column, $3);
      exit_status = FAIL;
      return 1;
    }
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
  | '=' E ';'
  { $$ = $2;}
  | '=' '{' values '}' ';'
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

values: // tab is backward recorded
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

  indice: // store multiple indexs for multiple dimensions arrays
      INDEX
    {
      tmp_dims[tmp_dims_index] = $1;
      tmp_dims_index++;
    }
    | indice INDEX
    {
      tmp_dims[tmp_dims_index] = $1;
      tmp_dims_index++;
    }
    ;

E:
  //   E "or" E                      {
  //
  //                                 }
  // | E "and" E                     {
  //
  //                                 }
  // | E RELOP E                     {
  //
  //                                 }
  // | "not" E                       {
  //
  //                                 }
   E '+' E
   { //printf("expr -> expr + expr\n");
    expr_add(add, &$$.result, &$$.code,
                   $1.result, $1.code,
                   $3.result, $3.code);
  }
  | E '-' E
  { //printf("expr -> expr - expr\n");
		expr_add(sub, &$$.result, &$$.code,
									 $1.result, $1.code,
									 $3.result, $3.code);
	}
  | E '*' E
  { //printf("expr -> expr * expr\n");
    expr_add(mult, &$$.result, &$$.code,
                  $1.result, $1.code,
                  $3.result, $3.code);
  }
  | E '/' E
  { //printf("expr -> expr / expr\n");
    expr_add(divi, &$$.result, &$$.code,
                  $1.result, $1.code,
                  $3.result, $3.code);
  }
  | '-' E %prec NEG
  {
    //printf("-%d",$2.result->value);
    $$ = $2;
    $$.result->value = -$2.result->value;
  }
  | '(' E ')'
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
  | ID indice
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
    perror("fopen test.asm :");
  }

  /////////////////////////////
  yyparse();
  /////////////////////////////
  printf("\n");
  exit_msg (exit_status);

  printf("\ntable :\n");
  symbol_print(tds);
  printf("\ncode :\n");
  quad_print(code);

  tds_toMips(tds,out);
  quad_toMips(code,out);
  fprintf(out,"exit:\n\tli $v0 4\n\tla $a0, end_msg\n\tsyscall"); // print end_msg
  fprintf(out,"\n\tli $a0 1\n\tli $v0 1\n\tsyscall\n\tj $ra"); // end of asm code

  quad_free(code);
  symbol_free(tds);

  // // tests dans testmatrix.c
  //test();
}
