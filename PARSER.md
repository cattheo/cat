# The Parser
- We use a high power parser based on Dypgen. 
- Ocaml is required to build it.
- Dypgen is a scannerless GLR parser with extensions.
- A core bootstrap parser is used to load new grammar at run time.
- Parser action codes are written in Scheme.
- A cut down version of OCS Scheme R5RS is used.
- Syntax is based on EBNF with extensions. 
- A macro system is built in.
- Composable modules can be constructed using open recursion.

## Base Sytax
### Syntax Modules
We define groups of syntax with a *syntex* statement:
```
    syntax expressions {
      ...
    }
```

These modules are also called *Domain Specific Sub-Languages* or **DSSL**.

### Qualified names
The name of a DSSL can be used as a qualifier to refer to a public symbol
in another DSSL:
```
x := A::b =># '_1';
```

### Private symbols
A non-terminal which is used only as a local helper can be made
private to prevnt qualified access from another DSSL:
```
private helper := ...
```


### Priortities
Syntax like this defines a partial order of priorities:
```
  priority 
    ssum_pri <
    scompactsum_pri <
    ssubtraction_pri <
    sproduct_pri <
    scompactproduct_pri <
    s_term_pri 
; 
```

### Simple definitions
```
syntax mulexpr
{
  //$ multiplication: non-associative.
  x[sproduct_pri] := x[sproduct_pri] "*" x[>sproduct_pri] =># "(Infix)";
}

syntax addexpr
{
  //$ Addition: left associative.
  x[ssum_pri] := x[ssum_pri] "+" x[>ssum_pri] =># "(Infix)";

  //$ Subtraction: left associative.
  x[ssum_pri] := x[ssum_pri] "-" x[>ssum_pri] =># "(Infix)";
}

syntax divexpr
{
  //$ division: right associative low precedence fraction form
  x[stuple_pri] := x[>stuple_pri] "\over" x[>stuple_pri] =># "(Infix)";

  //$ division: left associative.
  x[sproduct_pri] := x[sproduct_pri] "/" x[>sproduct_pri] =># "(Infix)";

  //$ remainder: left associative.
  x[sproduct_pri] := x[sproduct_pri] "%" x[>sproduct_pri] =># "(Infix)";

  //$ remainder: left associative.
  x[sproduct_pri] := x[sproduct_pri] "\bmod" x[>sproduct_pri] =># "(Infix)";
}

syntax bitexpr
{
  //$ Bitwise or, left associative.
  x[sbor_pri] := x[sbor_pri] "\|" x[>sbor_pri] =># "(Infix)";

  //$ Bitwise xor, left associative.
  x[sbxor_pri] := x[sbxor_pri] "\^" x[>sbxor_pri] =># "(Infix)";

  //$ Bitwise exclusive and, left associative.
  x[sband_pri] := x[sband_pri] "\&" x[>sband_pri] =># "(Infix)";

  //$ Bitwise left shift, left associative.
  x[sshift_pri] := x[sshift_pri] "<<" x[>sshift_pri] =># "(Infix)";

  //$ Bitwise right shift, left associative.
  x[sshift_pri] := x[sshift_pri] ">>" x[>sshift_pri] =># "(Infix)";
}
```

#### Indexed terms
- A term like ` x[sbor_pri]` specifies a non-terminal at the indicated priority. 
- A term like `x[>sbor_pri[` specified a non-terminal at any priority higher than indicated.
- The priority system removes the need to know the next higher priority

### repetition operators

The EBNF repetition operators produce Scheme lists:
- `*` 0 or more repetitions
- `+` 1 or more repetitions
- `?` 0 or 1 occurrences

```
 //$ Tuple formation non-associative.
  x[stuple_pri] := x[>stuple_pri] ( "," x[>stuple_pri])+ =># 
    "(chain 'ast_tuple _1 _2)"
  ;
```

### Grouping
- A repetition operator applies to the symbol on its left.
- Groups can be defined using parentheses `()` and act as a single symbol

### Sequence and Alternation
- The usual EBNF sequencing operator is juxtaposition (operator whitespace)
- Alternation usea a vertical bar `|`
- Each alternative requires its own action code

### Attributes
- Attributes are refered to numerically so that `_1` is the attribute of the
first symbol in a production, `_2` is the second symbol, etc.
- The attribute is the evaluated Scheme expression associated with a non-terminal, or,
- a list of attributes if a repetition operator is applied to a group

## Example
Here is a conditional expression in Felix:
```
//$ Conditional expression (prefix).
  sconditional := "if" sexpr "then" sexpr selse_part =>#
      "`(ast_cond ,_sr (,_2 ,_4 ,_5))";

      selif := "elif" sexpr "then" sexpr =># "`(,_2 ,_4)";

      selifs := selif =># "`(,_1)";
      selifs := selifs selif =># "(cons _2 _1)";

      selse_part:= "else" sexpr =># "_2";
      selse_part:= selifs "else" sexpr =>#
          """
            (let ((f (lambda (result condthn)
              (let ((cond (first condthn)) (thn (second condthn)))
                `(ast_cond ,_sr (,cond ,thn ,result))))))
            (fold_left f _3 _1))
          """;
``` 
# Macros
Here is a simple example using macros it defined a comma separated list of anything:
```
syntax list 
{
  seplist1 sep a := a (sep a)* =># '(cons _1 (map second _2))'; 
  seplist0 sep a = seplist1<sep><a>;
  seplist0 sep a := sepsilon =># '()';

  commalist1 a = seplist1<","><a>;
  commalist0 a = seplist0<","><a>;

  snames = commalist1<sname>;
  sdeclnames = commalist1<sdeclname>;
}
```

A macro is an untyped higher order function, the arguments an be any symbol,
including a macro symbol.

Macros are applied by writing the macro name followed by an argument in
angle brackets `<>`.

## Assignment form
A special assignment form is allowed:
```
  snames = commalist1<sname>;
  commalist1 a = seplist1<","><a>;

```
which always defines a macro. It is expaned as if `_1` where written and can
only accepts a single term on the RHS.

## Open Recursion
TBD

## Regular definitions
All terminals are potential given by regular expressions.
Regular definitions can be given:
```
  /* integers */
  regdef bin_lit  = '0' ('b' | 'B') (dsep ? bindigit) +;
  regdef oct_lit  = '0' ('o' | 'O') (dsep ? octdigit) +;
  regdef dec_lit  = '0' ('d' | 'D') (dsep ? digit) +;
  regdef dflt_dec_lit  =  digit (dsep ? digit) *;
  regdef hex_lit  = '0' ('x' | 'X') (dsep ? hexdigit)  +;
  regdef int_prefix = bin_lit | oct_lit | dec_lit | dflt_dec_lit | hex_lit;
  ...
  regdef int_lit = int_prefix int_type_suffix;

```

A non-terminal can also be defined:
```
  literal int_prefix =># """
  (let* 
    (
      (val (stripus _1))
      (x (parse-int val))
      ;; (type (first x))
      (value (second x))
    )
    value
  )
  """; 
```
Note that the Scheme code is defining an S-expression attribute representing a 
literal to the felix compiler based on the actual string the symbol, considered
as a regular expression, has parsed.

# Requires clause
A DSSL can depend on others:
```
syntax X { 
  requires A, B, C;
}
```
Requirement is transitive.

# Using Syntax
DSSLs can be defined anywhere in the code statements are allowed, but
should generally be given at the top. The ability to parse a DSSL is a 
fixed part of the bootstrap grammar.

The initial grammar can be extended with DSSLs by opening them.
Merely defining a DSSL simply creates a saveable data structure
representing a grammar.
```
open syntax felix;
```
When a DSSL is opened, the transitive closure of dependencies
specified by require clauses is loaded. The parser builds
a completely new automaton which then takes over all parsing
from the point of the open statement.

Felix ensures the automaton is cached, and the parse automatically
uses the cached version if possible.

# SCHEME statement
The SCHEME statement is used to add definitions to the Scheme interpreter.
```
SCHEME """
(begin
  ;; lists
  (define (first x)(car x))
  (define (second x)(cadr x))
  (define (third x)(caddr x))
  (define (tail x)(cdr x))
  (define fold_left
    (lambda (f acc lst)
      (if (null? lst) acc (fold_left f (f acc (first lst)) (tail lst)))))
)
```


