%{
#define YYSTYPE double
/* data type of yacc stack
the default data type is int
so we override it and set it to double
*/    
%}
/* Syntactic classes begin with %
any string with more than one char needs a syntactic class defined
single chars don't need them */
%token NUMBER
/* 
these clarify the associativity, basically how the order of operations works
left association will parse a-b-c as (a-b)-c
 */
%left '+' '-' /* left associative, same precendence */
%left '*' '/' '%' /* left associative, same precendence */
%left UNARYMINUS /* negative sign */
%left UNARYPLUS
%%
list: /* nothing */
    | list '\n'
    | list expr '\n' { printf("\t%.8g\n", $2); }
    ;
expr:   NUMBER  { $$ = $1; }
    | '-' expr %prec UNARYMINUS { $$ = -$2; }
    /* declare that a - has the precedence of a unary minus op */
    | '+' expr %prec UNARYPLUS { $$ = $2; }
    | expr '+' expr { $$ = $1 + $3; }
    | expr '-' expr { $$ = $1 - $3; }
    | expr '*' expr { $$ = $1 * $3; }
    | expr '/' expr { $$ = $1 / $3; }
    | expr '%' expr { $$ = fmod($1, $3); }
    | '(' expr ')'  { $$ = $2; }
    ;
%%

#include <stdio.h>
#include <ctype.h>

/* for error messages */
char* progname; 
int lineno = 1;

main(argc, argv)
    char* argv[];
{
    progname = argv[0];
    yyparse();
}

yylex()
{
    // holds a single char
    int c;

    // trim whitespace
    while ((c=getchar())) == ' ' || c == '\t');
    // if we've reached EOF, end parsing
    if (c == EOF)
        return 0;
    // if the char is . or a number
    if (c == '.' || isdigit(c))
    {
        // push it back into stdin using ungetc
        ungetc(c, stdin);
        // and read it with scanf
        // and store it in &yylval
        scanf("%lf", &yylval);

        // then return the value
        return NUMBER;
    }
    // if the char is a newline,
    // advance line number
    if (c == '\n')
        lineno++;
    return c;
}