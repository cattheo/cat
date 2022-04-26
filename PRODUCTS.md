# Canonical Product

Apart from the nominally type `struct` construction, Felix has
a sophisticated product type called a *polyrecord* which we introduce
in stages below.

## Unit

The canonical unit is `()` and has type `unit` or `1`.

## Tuple

```
var x : int * string = 22, "Hello";
```
## Array
If all the components of a tuple are the same type, it is an linear array
admiting an unitsum type as an index:
```
var x = int ^ 3 = 1,2,3;
```
A unitsum is any sum of units such as `1+1+1` which has the shorthand 
notation `3`.

Arrays admit a generic projection function which accepts an expression
of its index type as an argument (whereas tuples only allow a constant).

## Record
A record is a collection of named components:
```
var x : (a:int, b:int, c:string) = (a=1,b=2,c="Hello");
```

Field names can be repeated:

```
var x : (a:int, b:int, a: double, c:string) = (a=1,a=42.7, b=2,c="Hello");
```

The order of fields with the same name matters. The order of fields
with different names does not. Felix converts records to a normal
form which happens to be the result of a stable sort on the field names,

A named projection refers to the first (leftmost) field with that name.

The name of a field can be an empty identifier, denoted `n""` or simply
elided, in which case the `=` sign can be elided as well except for
the first component (for parsing reasons):

```
var x = (n""=1, 42, 97, a=5, 100);
```

If all the fields are empty, for example
```
var x = (=1,2,3,4);
```
then the record is also a tuple, and in this case also an array.

Thus, we have a data type which unifies tuples, records and arrays.

## Polyrecord
Finally there is a radical further extension based on row polymohism:
```
(a=1, 4 | r)
```
Here we have a record `(a=1, 4)` which prepends some other value `r`
which can be any value, and in particular it can be a type variable:
```
fun right[T] (point:(x:int, y:int | r:T) : (x:int, y:int | T) =>
  (x=point.x+1, y=point.y | r)
;
var p = (x=1,y=2,color="red");
var moved_right = right p; // color is preserved
```
Note that unlike the standard presentation, `r` is **not** a row variable,
it is an ordinary variable.

If `r` turns out to be a record the fields are appended to the given ones.
If a polyrecord the rule is applied recursively.
If an ordinary value that is equivalent to a record with one field with
an empty name.

# Subtyping

Since products are covariant, polyrecords support depth subtyping.

However width subtyping is supported only for polyrecord which are
not tuples or arrays. The justification is that the user would be
very surprised if this worked:
```
fun f (x: int, y:int) => x + y;
println$ f (1,2,3);  // ERROR
```
and chopping the end off an array could be dangerous. In both these
cases, we can allow width subtyping with row polymorphism:
```
fun f[T] (x:int, y:int | T) => x + y;
println$ f (1,2,3);  // OK
```

# Compact Products

Felix also has another kind of product, which forms a *compact linear type*.
The types void denoted 0, the sum of nothing, and unit denoted 1, are compact linear.
The compact product, sum, or exponential of compact linear types are compact linear.

A compact product type like
```
var x : 3 `* 2 `* 4 = (`2:3`, `1:2`, `1:4);
```
is represented by the integer
```
(2 * 8) * (1 * 4) +1 
```
that is, the standard variadic radix form. Projections are given by shiting right by division
and then masking the top by modulus for example the middle component is
```
 x / 4 % 2
```
Sums are similarly scaled and added, exponentials work too. The primary utility of
compact linear types is to generalise array indicies from unit sumes:
```
var m : int ^ (3 `* 2) = ((1,2),(3,4),(5,6));
println$ m . (`2:3, `0:2); // 5
```
where `m` is of course a matrix and the index is thus a compact tuple.

The compact property is that all such types are represented by a subrange
of integers from 0 to $n-1$ where $n$ is the total number of valuies,
and the linearity property is from the fact integers are totally ordered.
In particular this means all the values can be scanned by a single loop
no matter what tyhe type is, which provides at least rank independent
array access. A large class of shape changing isomorphpisms can be
implemented by a cast, without physically moving any array elements.

Compact products admit pointers of three machine words: one a pointer
to the containing integer and a divisor and a modulus, and thus,
pointer projections. You can view this construction as a generalisation
of C bitfields (where shift ahd mask are replaced by division and modulus).





