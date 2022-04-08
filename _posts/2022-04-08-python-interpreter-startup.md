---
title: Custom Python interpreter startup
last_modified_at: 2022-04-08T17:03:33+02:00
tags: python
accept_comments: true
---

# Custom Python interpreter startup

It is possible to run custom code for every Python interpreter at start.
There may be various reasons to do so.

## Where to put the code

It can be done per-user or globally on the system, depending on where it is in the [search path](2021-05-08-python-search-path.html).
- To do it per-user, put your python code in `usercustomize.py` in the user [site](https://docs.python.org/3/library/site.html) dir, for example in `~/.local/lib/python3.9/site-packages`.
- To do it globally, use `sitecustomize.py` of the global site dir, for instance in `/usr/lib/python3.9`.

The site dirs can be found by running `python3 -m site`.

## Example use: don't read bytecode if not writing bytecode either

When passing [`-B`](https://docs.python.org/3/using/cmdline.html#cmdoption-B) to python interpreter command (or setting [`PYTHONDONTWRITEBYTECODE=y`](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONDONTWRITEBYTECODE)), python will not write `.pyc` files.
It may also be desirable not to read `.pyc` files either in that case.
Add this to relevant `*customize.py`:

```python
import sys

if sys.flags.dont_write_bytecode:
    # if we don't write bytecode, we probably don't want to read it either.
    # prevent it to read __pycache__ by choosing a name nobody uses
    # (it shouldn't be mkdir'ed since writing is disabled)
    sys.pycache_prefix = "__dont.reuse.bytecode__"
```

Starting Python 3.8, this could be done by setting `$PYTHONPYCACHEPREFIX`, but adding it in the customize code sets them in tandem automatically.

## Speed advice

Since the code in those files is run for every interpreter, avoid adding slow code in them.
For example, avoid imports (except for modules that are almost always imported anyway, like `sys`).

## Example use: developer debug helpers

We probably don't want to run debug stuff for every python program but only our programs, so we should make it conditional, with an env variable:

```python
import os

# only enable loading more modules with side-effects if opt-in
if os.environ.get("MYPYTHONDEBUG"):
    # show deprecation warnings
    import warnings
    warnings.resetwarnings()

    # better tracebacks using https://pypi.org/project/stack-data/
    try:
        import stack_data.formatting
    except ImportError as e:
        pass
    else:
        stack_data.formatting.Formatter(
            show_variables=True, options=stack_data.Options(include_signature=True),
        ).set_hook()
```

When `$MYPYTHONDEBUG` env var is not empty, this will enable more warnings, and print better tracebacks using project [`stack_data`](https://pypi.org/project/stack-data/) if it's installed.
This may be useful when developing python programs, by setting `$MYPYTHONDEBUG`.
But we should not set the var for other apps, and their startup time should not be impacted a lot.
