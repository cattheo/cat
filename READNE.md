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

A compact product is then simply an integer, formed by the usual variable radix number system. Using the notation ``` `*``` for the compact product type, and ``` `,``` for a compact tuple value, the type ```5`*3``` can then be represented by the integer subrange 0..14 with projections `x/3` and `x%3`. And so
```
fun pair[X:COMPACT, Y:COMPACT] (x:X, y:Y): X`*Y => x`,y;
```
can be used to construct a compact pair. Note that the kind `COMPACT` is mandatory, since `* can only operate on compact types.

It is tempting to think a kind is then a constraint. This is no more or less true than saying the domain of a function is a constraint: we prefer to think of a kind as a specification of the domain category of a functor.

Example: Arrays
---------------
We're now going to introduce an array functor:
```
typedef lineararray[T,I:UNITSUM] = T ^ I;
```
The indexing operator is an exponential, as is the usual function application, however we prefer to think of an array as a tuple in which all components have the same type. The use of the kind `UNITSUM` restricts the index type to a sum of units. For example `int^3` is an array of three integers, as usual, but the index type is a unitsum, not an integer. This is very nice because array bounds checks are never necessary.

However the `lineararray` functor is overly restrictive and this is perfectly good:
```
typedef array[T, I:COMPACT] = T^I;
var x : int ^ (3 `* 2) = (1,2),(3,4),(5,6);
var v = x . (2`,0); //5 
```
which is of course a matrix. Note the index is a compact tuple (not an ordinary tuple). This is very beautiful because it allows polyadic (rank independent) array computations.

Example: pointers
-----------------

We introduce a pointer type ```&T``` and provide pointer projections:
```
var x = 1,2;
var px = &x;
px . 0 <- 42;
```
Here, the 0'th projection of a pointer to a tuple is defined as the pointer than locates te first component of the object pointed at. Note this is not an ordinary projection, since pointers themselves are not products.

However we have a problem! What if a product is compact?
It turns out, a pointer to a component of a compact product exists, but it requires three machine words instead of one: one word is required to find the compact object, it is an ordinary pointer. If we throw in a divisor and modulus, we can now extract the component by the formula
```
*p / divisor % modulus
```

Therefore, even though the representation is quite different, we can do polymorphic operations on compact product pointers, however, the **kind** of the pointer is not the same as an ordinary pointer. 

We should now have a glimmer of an idea that kinds dictate representations of structural typing systems and are absolutely essential for specifying the domains of functors.

In our language, we will be primarily focussed on the role of kinding systems in allowing polymorphic substructural types, and in particular radically generalise the notion of substructural typing, to, in particular, allow kinding systems to control memory management. Our primary concern is that concurrent distributed systems and applications which must be hard real time, cannot use the normal solution for a cartesian closed category, namely garbage collection. C and C++ programmers regularly code for and document memory management rules, with a little poor quality help from data types like `shared_ptr` and `unique_ptr`. The quality is poor because enforcement is at run time, instead of what we really want, which is static type checking.

C++ programmers know you can make a list and use abstraction to isolate the node pointers. This is a special case of separation logic in which we can use orinary pointers and enforce proper memory management by correctly coding the appropriate methods. We contend kinding systems can be used, much better, for the same job.

Example: Subkinding
-------------------
This is of course the kinding analogue of subtyping, however it is much better defined in the sense that a subkind is precisely a subcategory. Clearly `UNITSUM` is a subkind of `COMPACT` which is a subkind of `TYPE`, which means a type which is a unitsum such as `42` is also a compact product as well as being an ordinary type.

Metarecursion principle
=======================

One of the biggest problems with kinding systems is that once you allow polymorphic kinds, you have kind variables which need they domain specified, and clearly this requires **sorts**, a classification system a metalevel higher than kinds. And sorts need to be classified too .. where will it ever end?

Some authors just have a univeral top level but this of course does not work and is only acceptable if the topic of interest is at a lower level. A much better solution is to observe that kinds are just categories, and so are sorts, so the meta-level distinction between them should be local and not global. For example, *Nat* the natural numbers is a type, a kind, and a sort as well, but it is also just a single category. The meta-recursion principle is based on the fact that categories can be used to describe categories, this scalability is one of the most fundamental reasons for interest in category theory.

Language Domain
===============

The domain of our language must cover the lowest level kernel development all the way to distributed concurrent computation. It is clear the structures involved to scale these heights will change as the computational level increases. However a set of distinct languages to cover narrow bands of scale is simply not acceptable: we must have distinctions but without losing overall coherence .. and category theory is the only known way to do this.

Project Objectives
==================

The Felix programming language has been used to illustrate the role of kinding systems. However whilst, unlike many other languages, Felix was designed from the ground up to support polymorphism, the kinding system has been bolted on after the fact. The requirement to manage heap allocated objects in a real time context has introduced difficulties which suggest a redesign and rewrite is needed.

Considerable theoretical work is still required. In partcular, category theory has a number of foundational issues, and software systems must be built with constructive, not intuitionistic methods. For example a product functor cannot merely pick out a representation type as suggested in the examples, where the product property requires the existence of projections, it must actually provide the projections. Unfortunately the obvious method is to provide a pair of functions, but this begs the question of how to form a product since such a pair is itself a product.

The relationship between the system and related features of high level languages such as Ocaml modules and functors, and Haskell type classes, must be established.

Category theory is ill suited for software development in the sense that it is an equational theory which constructive logic requires an equality operator, but arbitrary functions cannot be compared. We consider using Jay categories, which are categories with representations using Jay's lambda SF calculus.
