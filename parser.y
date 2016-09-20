%{
#include "ast.h"
#include "st.h"
ST::SymbolTable symtab;  /* main symbol table */
AST::Block *programRoot; /* the root node of our program AST:: */
extern int yylex();
extern void yyerror(const char* s, ...);
%}

%define parse.trace

/* yylval == %union
 * union informs the different ways we can store data
 */
%union {
    int vint;
    AST::Node *node;
    AST::Block *block;
    const char *id;
}

/* token defines our terminal symbols (tokens).
 */
%token <vint> T_VINT
%token <id> T_ID
%token T_PLUS T_MINUS T_TIMES T_DIV T_NL T_COMMA
%token T_OPAR T_CPAR T_ASSIGN
%token T_INT

/* type defines the type of our nonterminal symbols.
 * Types should match the names used in the union.
 * Example: %type<node> expr
 */
%type <node> expr line varlist
%type <block> lines program

/* Operator precedence for mathematical operators
 * The latest it is listed, the highest the precedence
 */
%left T_PLUS T_MINUS
%left T_TIMES T_DIV
%left UMINUS
%nonassoc error

/* Starting rule
 */
%start program

%%

program : lines { programRoot = $1; }
        ;

lines   : line { $$ = new AST::Block(); if($1 != NULL) $$->lines.push_back($1); }
        | lines line { if($2 != NULL) $1->lines.push_back($2); }
        | lines error T_NL { yyerrok; }
        ;

line    : T_NL { $$ = NULL; } /*nothing here to be used */
        | expr T_NL /*$$ = $1 when nothing is said*/
        | T_INT varlist T_NL { $$ = $2; }
        | T_ID T_ASSIGN expr {  AST::Node* node = symtab.assignVariable($1);
                                $$ = new AST::BinOp(node,AST::assign,$3); }
        ;

expr    : T_VINT { $$ = new AST::Integer($1); }
        | T_ID { $$ = symtab.useVariable($1); }
        | expr T_PLUS expr { $$ = new AST::BinOp($1,AST::plus,$3); }
        | expr T_MINUS expr { $$ = new AST::BinOp($1,AST::minus,$3); }
        | expr T_TIMES expr { $$ = new AST::BinOp($1,AST::times,$3); }
        | expr T_DIV expr { $$ = new AST::BinOp($1,AST::div,$3); }
        | UMINUS expr %prec UMINUS { $$ = new AST::UniOp($2, AST::uminus); }
        | T_OPAR expr T_CPAR { $$ = $2; }
        ;

varlist : T_ID { $$ = symtab.newVariable($1, NULL); }
        | T_ID T_ASSIGN expr { AST::Node* node  = symtab.assignVariable($1);
                               $$ = new AST::BinOp(node,AST::assign,$3); }
        | varlist T_COMMA T_ID { $$ = symtab.newVariable($3, $1); }
        ;

%%
