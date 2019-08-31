---
layout: mine
title: Python iterators termination
last_modified_at: 2019-08-18T11:35:50+02:00
tags: python
---

# Iterators

Generators are functions returning elements lazily, which is useful to return a large number of elements (or even infinite). It's also possible to stop them in the middle when we're not interested by their output anymore, and without having to pay the potentially high price of producing the elements we'd like to discard.

For example:

    def f():
        print('locking')    # start something
        for i in range(5):
            v = i           # dummy, but we could perform some costly operation before yielding
            yield v
        print('unlocking')  # stop something

The generator will lock something, open some file, start a database query, obtain some resource, then yield values and in the end release the resource.

    >>> for v in f():
    ...     print(v)
    ...
    locking
    0
    1
    2
    3
    4
    unlocking

But what if we stop the iterator?

    >>> for v in f():
    ...     print(v)
    ...     break
    ...
    locking
    0

So the resource wasn't unlocked! Of course, if the resource is freed when the last variable reference is lost, it would be freed there, but our custom cleanup code wasn't executed.

How is the iterator stopped exactly? The generator is "sent" an exception, at the `yield` point.
With a small modification...

    def f():
        print('locking')    # start something
        for i in range(5):
            v = i           # perform some costly operation before yielding
            try:
                yield v
            except GeneratorExit:
                print('uh oh, the generator has been interrupted')
                raise
        print('unlocking')  # stop something

... we reveal the interruption:

    >>> for v in f():
    ...     print(v)
    ...     break
    ...
    locking
    0
    uh oh, the generator has been interrupted

When we `break`, the iterator is destroyed because we kept no reference to it.
The exception is really sent when the iterator is destroyed, not just on `break`, which incidentally were the same thing in the previous code.
We can demonstrate it by keeping a reference.

    >>> iterator = f()
    >>> for v in iterator:
    ...     print(v)
    ...     break
    ...
    locking
    0
    >>> del iterator
    uh oh, the generator has been interrupted

So, as for errors, the way to release resources is by using a `finally` block:

    def f():
        print('locking')        # start something
        try:
            for i in range(5):
                v = i           # perform some costly operation before yielding
                yield v
        finally:
            print('unlocking')  # stop something

# Context managers

Thanks to the `contextmanager` decorator, it's possible to turn a generator function into a context manager.

    from contextlib import contextmanager

    @contextmanager
    def locked_resource():
        print('locking')
        yield 42
        print('unlocking')

Then it can be used:

    def generate():
        with locked_resource() as resource:
            assert resource == 42           # here we could use the locked resource
            for i in range(10):
                yield i

Take care of exceptions and iterator stop:

    @contextmanager
    def locked_resource():
        print('locking')
        try:
            yield 42
        finally:
            print('unlocking')
