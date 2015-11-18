%{
  #include <stdio.h>
  #include <stdlib.h>
	#include <string.h>
  #include "symbol.h"
  #include "quad.h"
  #include "matrix.h"
  #include "testmatrix.h"

  int yylex();
  int yyerror();

	void temp_add(struct symbol** result, float value);
  void expr_add(char op, struct symbol** res_result, struct quad** res_code,
                         struct symbol* arg1_result, struct quad* arg1_code,
                         struct symbol* arg2_result, struct quad* arg2_code);
  float op_calc(char op, struct symbol* arg1, struct symbol* arg2);
  //int yydebug=1;

  struct symbol* tds;
  struct quad* code;
  struct symbol* tmp_symb;
  struct quad* tmp_quad;
  extern int line;
  char* filename;
%}

%union {
  int int_value;
  float float_value;
  char* str_value;
	struct {
		struct symbol* result;
		struct quad* code;
	} codegen;
}

%token <int_value> INT
%token <float_value> FLOAT
%token <str_value> ID TYPE INCRorDECR STR
%type <codegen> E
%token MAIN PRINT PRINTF PRINTM
%token '+' '-' '*' '/'
%token '(' ')'
%token END

%left '+' '-'
%left '*' '/'
%left NEG
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
   stmnt block
  | '}'
  ;

stmnt:
  ';'

  | TYPE ID '=' E ';'             { //printf(" Type : %d !\n", $1);
                                    quad_add(&code, $4.code); // store the E code
                                    struct symbol* new_id = symbol_add(tds, $2); // add the id in the tds
                                    new_id->value = $4.result->value; // copie the E value into the id value
                                    new_id->isFloat = ($1[0] == 'f' ? 1 : 0); // 'f' mean TYPE = float
                                    quad_add(&code, quad_gen('=', $4.result,NULL, new_id)); // store this stmnt code
                                    printf(" (%s = %.2f)",$2 ,$4.result->value); // verification
                                  }
  | ID '=' E ';'                  {
                                    struct symbol* id;
                                    printf(" (look for %s ... ", $1);
                                    if ((id = symbol_find(tds,$1)) != NULL) {
                                      printf("found !)");
                                      id->value = $3.result->value; // copie the E value into the id value
                                      quad_add(&code, quad_gen('=', $3.result,NULL, id)); // store this stmnt code
                                      printf(" (%s = %.2f)",$1 ,$3.result->value); // verification
                                    }
                                    else {
                                      fprintf(stderr,"%s:%d: error: '%s' undeclared (first use in this function)",filename, line, $1);
                                      exit(EXIT_FAILURE);
                                    }
                                  }
  | E INCRorDECR	';'	      			{ //printf("expr -> expr++\n");
                                    char op = ($2[0] == '+' ? '+' : '-'); // to add or remove 1
                                    // a temp with value 1
			                              struct symbol* incrOrDecr_tmp = (struct symbol*)calloc(1,sizeof(struct symbol));
			                              temp_add(&incrOrDecr_tmp, 1);
                                    // add a quad E = E +/- 1
                                    quad_add(&$1.code, quad_gen( op,$1.result,incrOrDecr_tmp,$1.result));
                                    $1.result->value = op_calc(op, $1.result, incrOrDecr_tmp);
                                    quad_add(&code, $1.code);
			                            }
  | E ';'                         { //printf("  Match :~) !\n");
				                            //printf("// %s = %.2f",$1.result->id,$1.result->value);
				                            quad_add(&code, $1.code);
				                          }
  | PRINT '(' ID ')' ';'          {
                                    printf(" PRINT match ! \n");
                                    // do a specifique quad or directly a mips code ?
                                  }
  | PRINTF '(' STR ')' ';'        {
                                    printf(" PRINTF match ! \n");
                                  }
  | PRINTM '(' ID ')' ';'         {
                                    printf(" PRINTM match ! \n");
                                  }
  ;

E:
    E '+' E                 			{ //printf("expr -> expr + expr\n");
			                              expr_add('+', &$$.result, &$$.code,
			                                             $1.result, $1.code,
			                                             $3.result, $3.code);
			                            }
  | E '-' E                 			{ //printf("expr -> expr - expr\n");
																		expr_add('-', &$$.result, &$$.code,
																									 $1.result, $1.code,
																									 $3.result, $3.code);
																	}
  | E '*' E                 			{ //printf("expr -> expr * expr\n");
			                              expr_add('*', &$$.result, &$$.code,
			                                            $1.result, $1.code,
			                                            $3.result, $3.code);
			                            }
  | E '/' E                 			{ //printf("expr -> expr / expr\n");
			                              expr_add('/', &$$.result, &$$.code,
			                                            $1.result, $1.code,
			                                            $3.result, $3.code);
			                            }
  | '-' E %prec NEG         			{
			                              //printf("-%d",$2.result->value);
			                              $$ = $2;
			                              $$.result->value = -$2.result->value;
			                            }
  | '(' E ')'               			{$$ = $2;}
  | INT                     			{ //printf("expr -> INT\n");
			                              printf("%d",$1);
			                              temp_add(&$$.result, $1);
			                              $$.code = NULL;
                                    $$.result->isFloat = 0;
			                            }
  | FLOAT                     		{ //printf("expr -> INT\n");
			                              printf("%.2f",$1);
			                              temp_add(&$$.result, $1);
			                              $$.code = NULL;
                                    $$.result->isFloat = 1;
			                            }
	| ID                     			  { //printf("expr -> ID\n");
																		//printf("ID = %s",$1);
                                    struct symbol* id;
                                    printf(" (look for %s ... ", $1);
                                    if ((id = symbol_find(tds,$1)) != NULL) {
                                      printf("found !)");
                                      $$.result = id;
                                    }
                                    else {
                                      printf("not found !)");
  																		$$.result = symbol_add(tds, $1);
                                    }
  																	$$.code = NULL;
																	}
  ;


%%
int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
}


void temp_add(struct symbol** result, float value){
  if(tds == NULL) {
    tds = symbol_newtemp(&tds);
    *result = tds;
  } else {
    *result = symbol_newtemp(&tds);
  }
  (*result)->value = value;
}

void expr_add(char op, struct symbol** res_result, struct quad** res_code,
                       struct symbol* arg1_result, struct quad* arg1_code,
                       struct symbol* arg2_result, struct quad* arg2_code) {
  *res_result = symbol_newtemp(&tds);
  (*res_result)->value = op_calc(op, arg1_result, arg2_result);
  (*res_result)->isFloat = arg1_result->isFloat;
  *res_code = arg1_code;
  quad_add(res_code,arg2_code);
  quad_add(res_code, quad_gen( op,arg1_result,arg2_result,*res_result));
}

void stmt_add(char op, struct symbol** res_result, struct quad** res_code,
                       struct symbol* arg1_result, struct quad* arg1_code) {
  *res_result = symbol_add(tds,(*res_result)->id);
  (*res_result)->value = arg1_result->value;
  *res_code = arg1_code;
  // quad_add(res_code,NULL);
  quad_add(res_code, quad_gen( op,arg1_result,NULL,*res_result));
}

float op_calc(char op, struct symbol* arg1, struct symbol* arg2){
  switch (op) {
    case '+': return arg1->value + arg2->value;
    case '*': return arg1->value * arg2->value;
    case '-': return arg1->value - arg2->value;
    case '/': return arg1->value / arg2->value;
    default : return 0;
  }
}


int main(int argc, char *argv[]){
  // if (argc < 2) {
  //    fprintf(stderr," usage : %s <file.cpp> [-debug]\n", argv[0]);
  //    exit(EXIT_FAILURE);
  //  }
  // yydebug=1;
  extern int DEBUG;
  if ((argc == 2 && strcmp(argv[1], "-debug") == 0) ||
      (argc == 3 && strcmp(argv[2], "-debug") == 0)) {
    DEBUG = 1;
    printf("DEBUG MODE\n..........\n");
  }

  extern int yylex();
  // extern int yyparse();
  extern FILE *yyin;

  printf("Welcome\n");

  if (argc > 1 && strcmp(argv[1], "-debug") != 0){
    yyin = fopen(argv[1],"r");
    /* Read out the link to our file descriptor. */
    filename = strdup(argv[1]);

    if(yyin == NULL) perror("yacc_fopen ");
  }
  yyparse();

  printf("\ntable :\n");
  symbol_print(tds);
  printf("\ncode :\n");
  quad_print(code);
  quad_free(code);
  symbol_free(tds);

  // // tests dans testmatrix.c
  //test();
}
