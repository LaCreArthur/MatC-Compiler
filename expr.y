%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <string.h>
  #include "symbol.h"
  #include "quad.h"
  #include "matrix.h"
  #include "testmatrix.h"
  #include "expr.h"

  int yylex();
  int yyerror();
  void temp_add(struct symbol** result, float value);
  void expr_add(char op, struct symbol** res_result, struct quad** res_code,
                         struct symbol* arg1_result, struct quad* arg1_code,
                         struct symbol* arg2_result, struct quad* arg2_code);
  int op_calc(char op, struct symbol* arg1, struct symbol* arg2);
  //int yydebug=1;

  struct symbol* tds;
  struct quad* code;
  struct symbol* tmp_symb;
  struct quad* tmp_quad;

%}

%union {
  int int_value;
  char* string;
  struct {
    struct symbol* result;
    struct quad* code;
  } codegen;
  char print;
}

%token <int_value> INT
%token <string> ID
%token T_INT MAIN
%token INCR DECR PARENTH INDICE PRINT PRINTF PRINTM

%token <print> OTHER
%token <string> STR
%type <codegen> expr

%right INCR DECR INDICE
%left '+' '-'
%left '*' '/'
%nonassoc NEG

%%

axiom:
  //rien
  | axiom main
  ;

main:
  T_INT MAIN '(' ')' '{' block
  ;

block:
   ligne block
  | '}'
  ;

ligne :
    other
  | stmt
  ;

stmt:
  ID '=' expr             {
                            printf("id = expr");
                            code = $3.code;
                            symbol_add(tds, $1);
                          }
  | expr                  { //printf("  Match :~) !\n");
                            code = $1.code;
                            //printf("result id %s value = %d \n",$1.result->id,$1.result->value);
                          }
  ;

/* GRAMMAIRE POUR CALCUL DE CONSTANTE */
expr:
    INT                     { //printf("expr -> INT\n");
                              //printf("%d",$1);
                              temp_add(&$$.result, $1);
                              $$.code = NULL;
                            }
  | ID                      { //printf("expr -> ID\n");
                              //printf("%s",$1);
                              $$.result = symbol_add(tds, $1);
                              $$.code = NULL;
                            }
  | matrix                  { //printf("expr -> matrix\n");
                              //printf("%s",$1);
                              temp_add(&$$.result, 1); // matrix replace by 1 for dev test
                              $$.code = NULL;
                            }
  | '-' expr %prec NEG      {
                              //printf("-%d",$2.result->value);
                              $$ = $2;
                              $$.result->value = -$2.result->value;
                            }
  | expr '+' expr           { //printf("expr -> expr + expr\n");
                              expr_add('+', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            $3.result, $3.code);
                            }
  | expr '-' expr           { //printf("expr -> expr - expr\n");
                              expr_add('-', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            $3.result, $3.code);
                            }
  | expr '*' expr           { //printf("expr -> expr * expr\n");
                              expr_add('*', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            $3.result, $3.code);
                            }
  | expr '/' expr           { //printf("expr -> expr / expr\n");
                              expr_add('/', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            $3.result, $3.code);
                            }
  | '(' expr ')'            { //printf("expr -> ( expr )\n");
                              $$ = $2;
                            }

// ajouter un token de fin apres ++ et --, ils ne sont suivit d'aucune autre operations (conflit de expr-- avec expr-'-expr')
  | expr INCR               { //printf("expr -> expr++\n");
                              struct symbol* tmp_symb = (struct symbol*)calloc(1,sizeof(struct symbol));
                              temp_add(&tmp_symb, 1);
                              expr_add('+', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            tmp_symb, NULL);
                            }
  | expr DECR               { //printf("expr -> expr--\n");
                              struct symbol* tmp_symb = (struct symbol*)calloc(1,sizeof(struct symbol));
                              temp_add(&tmp_symb, -1);
                              expr_add('+', &$$.result, &$$.code,
                                            $1.result, $1.code,
                                            tmp_symb, NULL);
                            }
  ;

other:
  OTHER
  | STR
  | PARENTH
  | PRINT
  | PRINTF
  | PRINTM
  | '='
  | ';'
  | '{' block
  | T_INT
  ;

matrix:
  ID INDICE
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
  if (op != '=') {
    *res_result = symbol_newtemp(&tds);
    (*res_result)->value = op_calc(op, arg1_result, arg2_result);
  } else {
    *res_result = symbol_add(tds,(*res_result)->id);
    (*res_result)->value = arg1_result->value;
  }
  *res_code = arg1_code;
  quad_add(res_code,arg2_code);
  quad_add(res_code, quad_gen( op,arg1_result,arg2_result,*res_result));
}

int op_calc(char op, struct symbol* arg1, struct symbol* arg2){
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
    if(yyin == NULL) perror("yacc_fopen ");
  }
  yyparse();

  printf("table :\n");
  symbol_print(tds);
  printf("code :\n");
  quad_print(code);
  quad_free(code);
  symbol_free(tds);

  // // tests dans testmatrix.c
  //test();
}
