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

