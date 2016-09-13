%{
#include <string>
#include "ast.h"
#include "parser.h"
extern int yylineno;
void yyerror(const char* s, ...);
%}

%option noyywrap nodefault yylineno

digs [0-9]+
chars [a-zA-Z]+

%%

[ \t]                         ; //ignores spaces
{digs}                        {yylval.integer = std::atoi(yytext); return T_VINT;}
{chars}[{chars}|{digs}|\_]*   {yylval.id = std::atoi(yytext); return T_ID;}


 //Operadores
"+"                 {return T_PLUS;}
"-"                 {return T_MINUS;}
"*"                 {return T_TIMES;}
"/"                 {return T_DIV;}
","                 {return T_COMMA;}
"("                 {return T_OPAR;}
")"                 {return T_CPAR;}
"="                 {return T_ASSIGN;}

 //Tipos
"int"               {return T_INT;}


\n                  {return T_NL;}
.                   {yyerror("Unknown token! %c\n", *yytext);} /*complains about every unknown character*/

%%

void yyerror(const char *s, ...){
    va_list ap;
    va_start(ap, s);
    std::fprintf(stderr, "Line %d: error: ", yylineno);
    std::vfprintf(stderr, s, ap);
}
