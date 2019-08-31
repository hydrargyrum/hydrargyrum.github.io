---
layout: mine
title: Python name binding
last_modified_at: 2018-01-20T23:45:57+01:00
tags: python scope
---

# Python name binding

When a variable name is used in Python code, it is resolved by looking it up in multiple nested scopes.

# Definition of a scope

Each scope has a dictionary of variables declared in it. It is built at "compile-time", i.e. when the source code is parsed. At this moment, only the keys of the dictionary are set. These variables are called "bound variables".

A scope also has a reference to the parent scope.

## Scope types

Python defines a few types of scopes:

* module-level scope, the `global` scope
* function scope (including lambdas)
* class scope
* generator-expression scope
* (Python 3) list-comprehension scope

Unlike some languages, like C, `for`, `while`, `try` or `with` blocks do not create a scope.

## Nesting

Nested function definitions create a scope child of the scope in which the definition is made.

```
# A scope is created here, the global scope, without a parent

def a():
	# A scope is created here, its parent is the global scope

	def b():
		# A scope is created here, its parent is a's scope
		pass
```

Class scope is a little different, because it can never be a parent, as seen below.

## Lookup

In a block of code, Python looks up variable references by searching them in code block scope's dictionary. If a variable can't be found there, it is looked up in the parent scope's dictionary, recursively until it is found or there is no parent scope (which raises an error).

A variable which can't be found in the scope where it used but in a parent scope is called a "free variable".

## Binding in a scope

A variable name belongs to a scope if any of the following [applies](https://docs.python.org/3/reference/executionmodel.html#binding-of-names):

* it's a parameter of the function
* it is on the left-side of a `=` statement
* it is the iteration variable of a `for` statement or expression
* it is a context variable of a `with ... as` statement
* it is an exception of an `except ... as` statement
* it's the name of a function definition or a class definition
* it is in an `import`
* it is a single name of a `del` statement

# Example

```
import a

b = range(10)

# a, b and f are bound in this scope

def f(a, c):
	# a, c, i and g are bound in this scope
	# b is a free variable in this scope
	for i in b:
		pass

	def g():
		c = [j for j in b]
		# in Python 3, the list-comprehension above has a dedicated scope
		# where j is bound in the list-comprehension scope
		# and where a, b, c, f, g, i are free variables bound to ancestor scopes

		print(a)
		# c is a bound variable in this scope
		# in Python 2, j is also bound in this scope
		# a, b, i and g are free variables in this scope
		# a, i and g are bound in the parent scope
		# b and f are bound in the grand-parent scope
```

In Python 3, the scopes of this example would look like that:

![Example binding scopes](python-scopes.png)

# Class scope

Code contained in a class definition will build the class's namespace.
However, a class's scope is not a parent scope for other scopes.

```
class A(object):
	b = 1
	print(b) # will work

	def f(self):
		print(b) # will raise a NameError

	next(b for _ in [1]) # will also raise a NameError

	class C(object):
		print(b) # will also raise a NameError
```

# Unbinding with `del`

Though not documented extensively, the `del` statement unbinds a variable from the local scope.

However, it does not remove it from the local scope, it is still present but marked as deleted.
Accessing the name afterwards will not cause a lookup in the parent scope but a `NameError` instead:

```
a = 1

def f():
	a = 2
	print(a) # prints 2
	del a
	print(a) # raises a NameError

f()
print(a) # prints 1
```

# A common gotcha

Sometimes, one will try to build a bunch of closures in a loop:

```
l = []
for i in range(3):
	def closure():
		print(i)

	l.append(closure)
```

As with the `i` variable, the `closure` is overwritten at each iteration of the for-loop.
All functions created in the loop have `i` as a free variable, as expected.
The gotcha is that all functions created in the loop have the same parent scope, where `i`'s value changes.

At the end, all closures will just print `2`, because `i` was not captured at each iteration.

A solution is to create a different scope for all `closure` functions, and have `i` snapshot into that scope.
This can be done with a function parameter:

```
def build_closure(i):
	def closure():
		print(i)
	return closure

l = []
for i in range(3):
	l.append(build_closure(i))
```

Another [trick from the Python FAQ](https://docs.python.org/3/faq/programming.html#why-do-lambdas-defined-in-a-loop-with-different-values-all-return-the-same-result) is to use a default parameter value.

