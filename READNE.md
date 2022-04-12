Cat (C@) 
========

A programming language based on category theory.

The key feature of this system is the presence of a high power kinding system. A kind is just a category.

Kinds are needed to work with functors, in the same way types are needed to work with functions.
The key insight is that kinds provide the management tools for structural typing systems, whilst type classes define abstractions and bind instances to representations.

Example: functor composition
-----------------------------
Consider the following functors:
```
typedef pair = fun (A:TYPE, B:TYPE):TYPE => A * B;
typedef diag = fun (X: TYPE): TYPE * TYPE => X, X;
```
`pair` is the standard value tuple constructor for two arguments,
`diag` is the functor which takes a type, and produces
a pair of the same type. Note that this pair is not
a tuple but a type tuple: the same **kind** as the domain of `pair`.

Here is a way to compose two functors, using eta-expansion and application:
```
typefun comp<J,K,L>
(f: K->J, g :L -> K):L -> J
  =>  fun (t:L):J => f(g(t))
;
```
where J,K and L are kinds. Here is our composition with the kinds given explicitly along with a demonstration that it works:

```
typedef pairofdiag2 = comp<TYPE,TYPE * TYPE, TYPE> (pair, diag);

var y : pairofdiag2 int = 1,2;
println$ y;
```
and here is the same composition, in which the kinds are deduced from the argument functors:
```
typedef pairofdiag3 = comp(pair, diag);
```
We have here defined a fully general generic composition operator. Kinding systems are mandatory for the specification of generics.

Example: uniqueness typing
--------------------------
Consider the function:
```
fun dup[T:TYPE} (x:T): T * T => x,x;
```
This is just fine in a standard type system, but if we allow T to bind to a type designating exclusive ownership of a reference, type checking will pass but we have allows an alias to be created, so the system would be unsound. To prevent this we add an overload:
```
fun dup[T:LINEAR) (x:T) => let y = unbox x in y,y
```
where `unbox` discards the uniqueness property.  We can only call this overload with a unique type, because `unbox` fails if given a non-unique type.

Example: compact products
-------------------------
The standard product functor produces a sequence of addressable objects aligned and padded, according to C layout rules. However there is another useful product, a compact linear product, defined as follows: let the types 0 and 1 be the void type and canonical unit, specify they're compact linear, and then specify any compact product or sum of a compact arguments is compact. We use the notation `5` to mean the type `1+1+1+1+1`.

A compact product is then simply an integer, formed by the usual variable radix number system. Using the notation `+ for the compact product type, and `, for a compact value, the type ```5`+3``` is then the integer subrange 0..14 with projections `x/3` and `x%3`. And so
```
fun pair[X:COMPACT, Y:COMPACT] (x:X, y:Y): X`+Y => x`,y;
```
can be used to construct a compact pair. Note that the kind `COMPACT` is mandatory, since `+ can only operate on compact types.

It is tempting to think a kind is then a constraint. This is no more or less true than saying the domain of a function is a constraint: we prefer to think of a kind as a specification of the domain category of a functor.

