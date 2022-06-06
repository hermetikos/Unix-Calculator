%{
double mem[26]; // for variables a-z
%}
%union {
    double val; // the actual value
    int index;  // the index into mem[]
    // this makes it so that stack elements are either an double (a number)
    // or a character (a variable, we are only using single chars as vars)
}
/* Syntactic classes begin with %
any string with more than one char needs a syntactic class defined
single chars don't need them */
%token <val> NUMBER
/* 
these clarify the associativity, basically how the order of operations works
left association will parse a-b-c as (a-b)-c
 */
%token <index> VAR
%type <val> expr
%left '+' '-' /* left associative, same precendence */
%left '*' '/' '%' /* left associative, same precendence */
%left UNARYMINUS /* negative sign */
%%
list: /* nothing */
    | list '\n'
    | list expr '\n' { printf("\t%.8g\n", $2); }
    | list error { yyerrok; }
    ;
expr:   NUMBER
    | VAR { $$ = mem[$1]; }
    | VAR '=' expr { $$ = mem[$1] = $3; }
    | expr '+' expr { $$ = $1 + $3; }
    | expr '-' expr { $$ = $1 - $3; }
    | expr '*' expr { $$ = $1 * $3; }
    | expr '/' expr { 
        if ($3 == 0.0)
            execerror("division by zero", "");
        $$ = $1 / $3; 
    }    
    | expr '%' expr { 
        if ($3 == 0.0)
            execerror("modulo by zero", "");
        $$ = fmod($1, $3);
    }
    | '(' expr ')'  { $$ = $2; }    
    | '+' expr %prec UNARYMINUS { $$ = $2; }
    | '-' expr %prec UNARYMINUS { $$ = -$2; }
    /* declare that a - has the precedence of a unary minus op */
    ;
%%

#include <stdio.h>
#include <ctype.h>
#include <math.h>

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
    while ((c=getchar()) == ' ' || c == '\t');
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

// handles yacc syntax error
yyerror(s)
    char* s;
{
    warning(s, (char*) 0);
}

// print warning message
warning(s, t)
    char *s, *t;
{
    fprintf(stderr, "%s: %s", progname, s);
    if(t)
    {
        fprintf(stderr, " %s", t);
        fprintf(stderr, " near line %d\n", lineno);
    }
}