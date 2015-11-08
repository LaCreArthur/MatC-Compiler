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
  void expr_add(char op, struct symbol** res_result, struct quad** res_code,
                        struct symbol* arg1_result, struct quad* arg1_code,
                        struct symbol* arg2_result, struct quad* arg2_code);
  int op_calc(char op, struct symbol* arg1, struct symbol* arg2);
  //int yydebug=1;

  struct symbol* tds;
  struct quad* code;
%}

%union {
  int int_value;
  char* string;
  struct {
    struct symbol* result;
    struct quad* code;
  } codegen;
}

%token <string> ID
%token <int_value> INT
%type <codegen> Expr

%left '+' '*'

%%


axiom:
    '\n'
  | Expr '\n'             { printf("  Match :~) !\n");
                            printf("axiom : $1 code is");
                            if ($1.code == NULL) printf(" null\n");
                            else printf(" not null\n");
                            code = $1.code;
                            printf("result id %s value = %d \n",$1.result->id,$1.result->value);
                          }
  ;
/* GRAMMAIRE CALCUL DE CONSTANTE */
Expr:
    Expr '+' Expr           { printf("Expr -> Expr + Expr\n");
                              expr_add('+', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            $3.result, $3.code);
                            }
  | Expr '-' Expr           { printf("Expr -> Expr - Expr\n");
                              expr_add('-', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            $3.result, $3.code);
                            }
  | Expr '*' Expr           { printf("Expr -> Expr * Expr\n");
                              expr_add('*', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            $3.result, $3.code);

                              printf("Expr : $$ code is");
                              if ($$.code == NULL) printf(" null\n");
                              else printf(" not null\n");
                            }
  // | Expr '/' Expr           { printf("Expr -> Expr / Expr\n");
  //                             expr_add('/', $$.result, $$.code,
  //                                           $1.result, $1.code,
  //                                           $3.result, $3.code);
  //                           }
  | '(' Expr ')'            { printf("Expr -> ( Expr )\n");
                            }
  | ID                      { printf("Expr -> ID\n");
                              $$.result = symbol_add(tds, $1);
                              $$.code = NULL;
                            }
  | INT                     { printf("Expr -> INT\n");
                              if(tds == NULL) {
                                tds = symbol_newtemp(&tds);
                                $$.result = tds;
                              } else {
                                $$.result = symbol_newtemp(&tds);
                              }
                              $$.result->value = $1;
                              $$.code = NULL;
                            }
  ;


%%
int yyerror(char *s) {
  printf("%s\n",s);
  return 0;
}

void expr_add(char op, struct symbol** res_result, struct quad** res_code,
                      struct symbol* arg1_result, struct quad* arg1_code,
                      struct symbol* arg2_result, struct quad* arg2_code) {
  *res_result = symbol_newtemp(&tds);
  (*res_result)->value = op_calc(op, arg1_result, arg2_result);
  *res_code = arg1_code;
  quad_add(res_code,arg2_code);
  quad_add(res_code, quad_gen( op,arg1_result,arg2_result,*res_result));
}

int op_calc(char op, struct symbol* arg1, struct symbol* arg2){
  switch (op) {
    case '+': return arg1->value + arg2->value;
    case '*': return arg1->value * arg2->value;
    default : return 0;
  }
}

int main(){
  printf("Enter a expression\n");
  code = malloc(sizeof(struct quad*));

  if (code != NULL) printf("code init ok\n");
  yyparse();
  printf("table :\n");
  symbol_print(tds);
  printf("code :\n");
  quad_print(code);
  quad_free(code);  
  symbol_free(tds);
  test();

}
