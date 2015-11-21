%{
  #include <stdio.h>
  #include <stdlib.h>
	#include <string.h>
  #include "symbol.h"
  #include "quad.h"
  #include "matrix.h"
  #include "expr.h"
  #include "testmatrix.h"

  int yylex();
  int yyerror();

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

%token <int_value> INT INDICE
%token <float_value> FLOAT
%token <str_value> ID TYPE INCRorDECR STR
%type <codegen> E
%type <codegen> affect
%token MAIN PRINT PRINTF PRINTM
%token '+' '-' '*' '/'
%token '(' ')'
%token END

%left '+' '-'
%left '*' '/'
%left NEG
%right INCRorDECR
%right INDICE

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

  | TYPE ID affect               { //printf(" Type : %d !\n", $1);
                                    struct symbol* new_id = affectation($1,$2,$3.result, $3.code,0,0);
                                    quad_add(&code, quad_gen('=', $3.result,NULL, new_id)); // store this stmnt code
                                  }
  | TYPE ID INDICE affect         { printf("___array [%d] \n", $3);

                                  }
  | TYPE ID INDICE INDICE affect  { printf("___matrix spoted [%d][%d]\n", $3, $4);}
  | ID '=' E ';'                  {
                                    struct symbol* id;
                                    printf("___(look for %s ... ", $1);
                                    if ((id = symbol_find(tds,$1)) != NULL) {
                                      printf("found !)");
                                      id->isFloat?(id->value = $3.result->value):(id->value = (int)$3.result->value); // copie the E value into the id value
                                      quad_add(&code, quad_gen('=', $3.result,NULL, id)); // store this stmnt code
                                      printf("___(%s = %.2f)",$1 ,$3.result->value); // verification
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
                                    //$1.result->value = op_calc(op, $1.result, incrOrDecr_tmp);
                                    quad_add(&code, $1.code);
			                            }
  | E ';'                         { //printf("  Match :~) !\n");
				                            //printf("// %s = %.2f",$1.result->id,$1.result->value);
				                            quad_add(&code, $1.code);
				                          }
  | PRINT '(' ID ')' ';'          {
                                    struct symbol* id;
                                    if ((id = symbol_find(tds,$3)) != NULL) {
                                      printf("___found !");
                                      quad_add(&code,quad_gen('p',NULL,NULL,id));
                                    }
                                    else {
                                      fprintf(stderr,"%s:%d: error: '%s' undeclared (first use in this function)",filename, line, $3);
                                      exit(EXIT_FAILURE);
                                    }
                                  }
  | PRINTF '(' STR ')' ';'        {
                                    printf(" PRINTF match ! \n");
                                  }
  | PRINTM '(' ID ')' ';'         {
                                    printf(" PRINTM match ! \n");
                                  }
  ;

affect:
  ';'                             { $$.result = NULL; $$.code = NULL;} // not tested
  | '=' E ';'                     { $$ = $2;}
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
  | ID INDICE                     { printf("___array[%d] spoted\n", $2);}
  | ID INDICE INDICE              { printf("___matrix[%d][%d] spoted\n", $2, $3);}
	| ID                     			  { //printf("expr -> ID\n");
																		//printf("ID = %s",$1);
                                    struct symbol* id;
                                    printf("____(look for %s ... ", $1);
                                    if ((id = symbol_find(tds,$1)) != NULL) {
                                      printf("found !)");
                                      $$.result = id;
                                    }
                                    else {
                                      printf("not found !)");
  																		$$.result = symbol_add(tds, $1);
                                      $$.result->isConstant = true;
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
  extern FILE* yyin;

  printf("Welcome\n");

  if (argc > 1 && strcmp(argv[1], "-debug") != 0){
    if ((yyin = fopen(argv[1],"r")) == NULL){
      perror("fopen code :");
    };
    /* Read out the link to our file descriptor. */
    filename = strdup(argv[1]);

    if(yyin == NULL) perror("yacc_fopen ");
  }

  if ((out = fopen("test.asm","w")) == NULL) {
    perror("fopen test.asm :");
  }
  yyparse();
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
