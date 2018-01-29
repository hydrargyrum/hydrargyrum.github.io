---
layout: mine
title: "Python 2: a few notes on super()"
tags: python
---

# Python 2: don't pass `self.__class__` in super() call

In Python 2, when needing to call a super method. The [`super`](https://docs.python.org/2/library/functions.html#super)
function should take 2 arguments, the current class, and the object instance, and returns the object instance wrapped.

### The right way

```
class B(A):
    def __init__(self):
        super(B, self).__init__()
```

### Don't do this

```
class A(object):
    def __init__(self):
        print("A")
        super(self.__class__, self).__init__()


class B(A):
    def __init__(self):
        print("B")
        super(self.__class__, self).__init__()


class C(B):
    def __init__(self):
        print("C")
        super(self.__class__, self).__init__()
```

### Why doesn't it work?

Because `super` is used to find the parent class in the hierarchy, we must give it the class we're escalating: in `C.__init__` we want to find `B.__init__`, and in `B.__init__`, we need to find `A.__init__`.
So `super` must know which class to look for its parent.
For a given `C` instance, `self.__class__` will always be `C`, which means, that in `C.__init__`, `super(self.__class__, self)` will find `B`, but in `B.__init__`, `super(self.__class__, self)` will be back to finding `B`, not `A`, giving an infinite recursion.

# Python 2: `super()` and the MRO

For each class, Python sets its [Method Resolution Order](https://www.python.org/download/releases/2.3/mro/) (MRO), which is the order in which all super-classes (recursively) are checked to resolve an attribute.
It contains each class of the inheritance graph exactly once, even if it appears multiple times in the graph, the most common being the `object` class, which is at the top.
The `object` class is always the last class in the MRO (except if some classes don't inherit `object`!).

Let's define a few classes (with diamond inheritance):

```
class T(object): pass
class A(T): pass
class B(T): pass
class C(A, B): pass
```

The MRO of a class can be fetched with the class-method [`mro()`](https://docs.python.org/2/library/stdtypes.html#class.mro).

```
C.mro()  # [__main__.C, __main__.A, __main__.B, __main__.T, object]
B.mro()  # [__main__.B, __main__.T, object]
A.mro()  # [__main__.A, __main__.T, object]
```

## Why use `super()`?

Without `super()`, we would have to call the parent class manually:

```
class T(object):
    def __init__(self):
        print('T')

class A(T):
    def __init__(self):
        T.__init__(self)
        print('A')

class B(object):
    def __init__(self):
        T.__init__(self)
        print('B')

class C(A, B):
    def __init__(self):
        A.__init__(self)
        B.__init__(self)
        print('C')
```

`C` would call both `A` and `B`, and each in turn would call `T`, because they wouldn't know about each other.

## `super()`

As we've just seen, `A` and `B` are independant so their parent might be called twice, when called manually.
However, the MRO of a class have an uniqued, ordered list of ancestors, which is good thing to prevent a class being called twice.

And this is what `super` uses. It looks the MRO of the object class, finds the given "current class" in the MRO, takes the next class in the MRO, and then does some stuff to wrap the object instance with the super class found.

We've seen that only considering the "parent class of the current class" is not a good thing, we need to consider the whole hierarchy (thanks to the MRO).
That's why the `super` functions takes a `self` argument, to have the class hierarchy of the object.

Here's a naive implementation of the lookup:

```
def super_class_lookup(current_class, instance):
    mro = type(instance).mro()
    idx = mro.index(current_class)
    return mro[idx + 1]
```

```
super_class_lookup(C, C()) # __main__.A
super_class_lookup(A, C()) # __main__.B
super_class_lookup(B, C()) # __main__.T
```

```
super_class_lookup(A, A()) # __main__.T
super_class_lookup(B, B()) # __main__.T
```

A `super`-naive implementation:

```
class super(object):
    def __init__(self, current_class, instance):
        self.__instance = instance
        self.__class = super_class_lookup(current_class, instance)

    def __getattribute__(self, attr):
        if attr.startswith('_super__'):
            return object.__getattribute__(self, attr)

        value = getattr(self.__class, attr)
        if not callable(value):
            return value

        # doesn't account for staticmethod, classmethod, properties, etc.
        def method(*args, **kwargs):
            return value(self.__instance, *args, **kwargs)
        return method
```

## Why do you need to inherit `object` when using `super`?

With this code:

```
class A(object):
    def __init__(self):
        print 'A',
        super(A, self).__init__()

class B:
    def __init__(self):
        print 'B',

class C(A, B):
    def __init__(self):
        print 'C',
        super(C, self).__init__()
```

`C`'s MRO will be `[__main__.C, __main__.A, object, __main__.B]`. `object` will not be the last class in the MRO, but `object` assumes it is, so `object` never calls `super`.
The consequence is that instanciating a `C` will print `C A`, thus `B.__init__` isn't called.

Inverting the inheritance order of `C` to `B, A` will make `C()` print `C B`, thus `A.__init__` isn't called.

## How to deal with legacy classes that don't inherit `object`?

In the previous example, if you can't modify class `B` (for example, if it's in a third-party module, a standard Python module, etc.), you can create a temp class to wrap it:

```
class A(object):
    def __init__(self):
        print 'A',
        super(A, self).__init__()

class B: # this class cannot be modified in any way
    def __init__(self):
        print 'B',

class BObject(B, object):
    def __init__(self):
        print '(BObject)',
        super(BObject, self).__init__()

class C(A, BObject):
    def __init__(self):
        print 'C',
        super(C, self).__init__()
```

This time, `C`'s MRO will be `[__main__.C, __main__.A, __main__.BObject, <class __main__.B at 0x7fc5a3779e88>, object]`,
and `C()` will print `C A (BObject) B` which is good.

Note that `B` doesn't call `super`, so classes after `BObject` in `C`'s inheritance won't be called.
If there's more than one class which doesn't inherit `object` in `C`'s graph, that's another story...
