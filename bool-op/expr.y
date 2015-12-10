%{
  #include <stdio.h>
  #include <stdlib.h>
	#include <string.h>
	#include <math.h>
  #include "symbol.h"
  #include "quad.h"


  int yylex();
  int yyerror(char*);
  void lex_free();

  struct symbol* tds = NULL;
  struct quad* code = NULL;
  int next_quad = 0;
%}

%union {
  char* string;
  int value;
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

%token OR AND NOT '(' ')' ELSE
%token '>' '+' '=' ';'
%token <string> ID
%token <value> NUM
%type <codegen> expr
%type <codegen> stmnt
%type <quadlist> condition
%left OR
%left AND
%left NOT
%left '+' '='

%%

axiom:
    condition stmnt ELSE stmnt'\n'
      {
        printf("Match !\n");
        struct quad* jump;
        struct symbol* label_true;  // equivaut au premier tag dans if then tag else tagoto
        struct symbol* label_false; // deuxieme tag : tagoto

        label_true          = symbol_newcst(&tds, $2.code->label);          // label of the 1st stmnt
        // nextquad a la valeur du dernier label du 2nd stmnt donc +1 jump juste après
        struct symbol* next = symbol_newcst(&tds, next_quad+1);             // goto after 2nd stmnt
        jump                = quad_gen(next_quad++, 'G', NULL, NULL, next); // jump after stmnt false
        label_false         = symbol_newcst(&tds, $4.code->label);          // label of the 2nd stmnt

        quad_list_complete($1.truelist, label_true);
        quad_list_complete($1.falselist, label_false);

        code = $1.code;           // condition code
        quad_add(&code, $2.code); // stmnt for true
        quad_add(&code, jump);
        quad_add(&code, $4.code); // stmnt for false
        return 0;
      }
  ;

condition:
    expr '>' expr // remplacer '>' par bool_op
      {
        printf("cond -> expr > expr\n");
        quad_add(&$$.code, goto_false);
                                        // remplacer char par enum bool_op
        struct quad* goto_true   = quad_gen(next_quad++, '>', $1.result, $3.result, NULL); // res null -> trou
        struct quad* goto_false  = quad_gen(next_quad++, 'G', NULL, NULL, NULL);
        $$.code = $1.code;
        quad_add(&$$.code, $3.code);
        quad_add(&$$.code, goto_true);
        $$.truelist   = quad_list_new(goto_true);
        $$.falselist  = quad_list_new(goto_false);
      }
  | condition OR condition
      {
        printf("cond -> expr OR expr\n");
        struct symbol* tag  = symbol_newcst(&tds, $3.truelist->node->label);
        quad_list_complete($1.falselist, tag);
        $$.code = $1.code;
        quad_add(&$$.code, $3.code);
        $$.falselist = $3.falselist;
        $$.truelist = $1.truelist;
        quad_list_add(&$$.truelist, $3.truelist);
        // false liste de 1er expr est pack patch au debut du deuxieme
      }
  | condition AND condition
      {
        printf("cond -> expr AND expr\n");
        struct symbol* tag  = symbol_newcst(&tds, $3.truelist->node->label);
        quad_list_complete($1.truelist, tag);
        $$.code = $1.code;
        quad_add(&$$.code, $3.code);
        $$.falselist = $1.falselist;
        $$.truelist = $3.truelist;
        quad_list_add(&$$.falselist, $3.falselist);
      }
  | NOT condition
      {
        printf("cond -> NOT expr\n");
        $$.code = $2.code;
        $$.truelist = $2.falselist;
        $$.falselist = $2.truelist;
      }
  | '(' condition ')'
      {
        printf("cond -> ( expr ) \n");
        $$.code = $2.code;
        $$.truelist = $2.truelist;
        $$.falselist = $2.falselist;
      }
  ;

expr:
  expr '+' expr
      {
        $$.code = $1.code;
        quad_add(&$$.code,$3.code);
        quad_add(&$$.code, quad_gen(next_quad++,'+',$1.result,$3.result,$$.result));
      }
  | expr '=' expr
      {
        $$.code = $1.code;
        quad_add(&$$.code,$3.code);
        quad_add(&$$.code, quad_gen(next_quad++,'=',$1.result,$3.result,$$.result));
      }
  | ID
      {
        printf("expr -> ID (%s)\n", $1);
        $$.result = symbol_find(tds, $1);
        if ($$.result == NULL)
          $$.result = symbol_add(tds, $1);
        $$.code = NULL;
      }
  | NUM
      {
        printf("expr -> NUM (%d)\n", $1);
        if(tds == NULL) {
          tds = symbol_newcst(&tds, $1);
          $$.result = tds;
        }
        else
          $$.result = symbol_newcst(&tds, $1);
        $$.code=NULL;
      }
  ;


stmnt:
  expr ';'
      {
        $$.code = $1.code;
      }
  | expr ';' stmnt
      {
        $$.code = $1.code;
        quad_add(&$$.code,$3.code);
      }
  | ';' {$$.code = NULL;}

  // | expr '=' expr
  //     {
  //       struct symbol* new_id;
  //       quad_add(&$$.code, $3.code); // store the E code
  //
  //       if((new_id = symbol_find(tds, $1.result->id)) != NULL){ // new id already existe
  //           fprintf(stderr,"error: redeclaration of with no linkage");
  //           exit(EXIT_FAILURE);
  //       } else {
  //           new_id = symbol_add(tds, $1.result->id);
  //           new_id->value = (int)$3.result->value; }
  //
  //       quad_add(&$$.code, quad_gen(next_quad++,'=', $3.result,NULL, new_id)); // store this stmnt code
  //     }
  // |
  //     {
  //       $$.code = NULL;
  //     }
  ;

  %%


  int yyerror(char *s) {
    printf("%s\n",s);
    return 0;
  }

  int main(int argc, char *argv[]){
    /////////////////////////////
    yyparse();
    /////////////////////////////
    printf("\n");

    // printf("\ntable :\n");
    // symbol_print(tds);
    printf("\ncode :\n");
    quad_print(code);

    // quad_free(code);
    // symbol_free(tds);

  }
