# Object Semantics

## In C
### L- and R-value

- A variable is an lvalue.
- A dereferenced pointer is an lvalue.
- A struct field of an lvalue is an lvalue.
- Other expressions are rvalues.

### L- and R-context

- The outer LHS of an assignment is an L-context.
- The address of operator is an L-context.
- Other contexts are called R-contexts.

### Denotation

- When an L-value occurs in an L-context it denotes the 
underlying object.
- An R-value is not permitted in an L-context.
- Any expression in an R-contexts denotes a value.
If it is an L-value, then the value of the underlying object.

### Notes

The specifications above are purely syntactic.
The rules are fragile in that any syntactic externsion could lead
to an open issue with respect to denotation.

## In C++

In C++ an lvalue is an expression which is either a variable
or has reference type. The binding rules are complex. It has
been discovered that there are actually 5 contexts with slightly
different behaviours.

In short is an extreme mess.

## In Felix

### Variables
In Felix a value is put into an object with a system procedure:

```
proc storeat[T]: &<T * T
```

Here `&<T` denotes a write only pointer. It can be obtained from
a variable `v` by the expression
```
&<v
```

A read/write pointer has
the type
```
&T
```
and can be obtained from a variable `v` by
```
&v
```
Since a read/write pointer to T is a subtype of a write-only pointer to T,
the following statement:
```
storeat(&v,x);
```
stores the value `x` into the store denoted by `v` (provided it type checks of course!)

This can be abbreviated
```
&v <- x;
```
or in this case
```
v = x;
```

The *addressof* operators `&` and `&<` can only be applied to a variable.

### Products

But what if we wish to assign to a component of a product? In Felix there
are structs like C, tuples, and also records (and a few more!).

We define a new operation called a pointer projection. When a pointer
projection is applied to a pointer of a product type, the result is a 
poinhter pointing at a component of the product.

Felix overloads the usual syntactic sugar for projections so that
for example:

```
struct S { a: int; b:int; }
var s = S (1,2);
var ps = &s;
ps . a <- 42;

var x = 1,2;
var px = &x;
px . 0 <- 42; // x is now 42,2

var r = (a=1, b=2);
pr = &r;
pr . a <= 42; // r is now (a=42,b=2)
```

Finally note that in Felix 
```
f x = x . f
```
universally; that is, forward polish application is denoted by juxtaposition (operator whitespace),
whereas reverse polish application is denoted by an infix dot (.)

It should be noted then, that projections are first class functions, for example
```
a of S
proj 0 of (int * int)
a of (a:1, b:int)
```

Thus, the lvalue/rvalue distinction is completely eliminated by relying exclusively
on a value semantics including pointers. The underlying `storeat` operator is a compiler
intrinsic which could by hooked effecting a write barrier.


