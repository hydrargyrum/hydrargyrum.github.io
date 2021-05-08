---
layout: mine
title: Python search paths
last_modified_at: 2021-05-08T23:02:15+02:00
tags: python path
accept_comments: true
---

# Python search paths

Python [looks up modules](https://docs.python.org/3/reference/import.html) in many places.
Hooking importers will not be covered here
(see [RealPython](https://realpython.com/python-import/) or
[`importlib.abc`](https://docs.python.org/3/library/importlib.html#module-importlib.abc)).

The effective search path is in [`sys.path`](https://docs.python.org/3/library/sys.html#sys.path).
An easy way to list all entries in the search path is:

	% python -m site

# `$PYTHONPATH`

The most known module search path is the environment variable [`PYTHONPATH`](https://docs.python.org/3/using/cmdline.html#envvar-PYTHONPATH).
It's easy to modify it for a command only: `PYTHONPATH=/some/where python ...`.

# Sites

Third-party (non standard library) packages are installed in Python ["site"](https://docs.python.org/3/library/site.html) directories.
The most common sites are:
- system site
    - often located in something like `/usr/lib/python3/site-packages`
    - where [`pip install`](https://pip.pypa.io/en/stable/cli/pip_install/) will write (except on Debian where `--system` is required)
- [user site](https://docs.python.org/3/library/site.html#site.USER_SITE)
    - often located in `~/.local/lib/python3.<minor>/site-packages`
    - where `pip install --user` will write

See:

	>>> import site
	>>> site.getsitepackages()
	['/usr/local/lib/python3.9/site-packages', '/usr/lib/python3/site-packages', '/usr/lib/python3.9/site-packages']
	>>> site.getusersitepackages()
	'/home/xxx/.local/lib/python3.9/site-packages'

## Debian specificity

Debian packages a [modified Python interpreter](https://wiki.debian.org/Python#Deviations_from_upstream)
which looks system site in `/usr/lib/python3/dist-packages` instead of `/usr/lib/python3/site-packages`.

Also, `pip` will install with `--user` by default.

# Example

	% pwd
	/tmp/plop-2335880
	% PYTHONPATH=/foo:/bar python -m site
	sys.path = [
	    '/tmp/plop-2335880',				← current directory
	    '/foo',						← PYTHONPATH
	    '/bar',						← PYTHONPATH
	    '/usr/lib/python39.zip',				← standard lib
	    '/usr/lib/python3.9',				← standard lib
	    '/usr/lib/python3.9/lib-dynload',			← standard lib
	    '/home/xxx/.local/lib/python3.9/site-packages',	← user site
	    '/usr/local/lib/python3.9/dist-packages',		← system-local site
	    '/usr/lib/python3/dist-packages',			← system site
	    '/usr/lib/python3.9/dist-packages',			← system site
	]
	USER_BASE: '/home/xxx/.local' (exists)
	USER_SITE: '/home/xxx/.local/lib/python3.9/site-packages' (exists)
	ENABLE_USER_SITE: True

# Limiting options

The Python interpreter has [options](https://docs.python.org/3/using/cmdline.html#miscellaneous-options).

`python -s` (equivalent to setting `$PYTHONNOUSERSITE`) disables the user site:

	% PYTHONPATH=/foo:/bar python -s -m site
	sys.path = [
	    '/tmp/plop-2335880',
	    '/foo',
	    '/bar',
	    '/usr/lib/python39.zip',
	    '/usr/lib/python3.9',
	    '/usr/lib/python3.9/lib-dynload',
	    '/usr/local/lib/python3.9/dist-packages',
	    '/usr/lib/python3/dist-packages',
	    '/usr/lib/python3.9/dist-packages',
	]
	USER_BASE: '/home/xxx/.local' (exists)
	USER_SITE: '/home/xxx/.local/lib/python3.9/site-packages' (exists)
	ENABLE_USER_SITE: False

`python -S` disables all sites:

	% PYTHONPATH=/foo:/bar python -S -m site
	sys.path = [
	    '/tmp/plop-2335880',
	    '/foo',
	    '/bar',
	    '/usr/lib/python39.zip',
	    '/usr/lib/python3.9',
	    '/usr/lib/python3.9/lib-dynload',
	]
	USER_BASE: '/home/xxx/.local' (exists)
	USER_SITE: '/home/xxx/.local/lib/python3.9/site-packages' (exists)
	ENABLE_USER_SITE: None

`python -E` disables `$PYTHONPATH` and `$PYTHONHOME`:

	sys.path = [
	    '/tmp/plop-2335880',
	    '/usr/lib/python39.zip',
	    '/usr/lib/python3.9',
	    '/usr/lib/python3.9/lib-dynload',
	    '/home/xxx/.local/lib/python3.9/site-packages',
	    '/usr/local/lib/python3.9/dist-packages',
	    '/usr/lib/python3/dist-packages',
	    '/usr/lib/python3.9/dist-packages',
	]
	USER_BASE: '/home/xxx/.local' (exists)
	USER_SITE: '/home/xxx/.local/lib/python3.9/site-packages' (exists)
	ENABLE_USER_SITE: True

`python -I` combines `-s` and `-E` but also prevents current directory from being added:

	% PYTHONPATH=/foo:/bar python -I -m site
	sys.path = [
	    '/usr/lib/python39.zip',
	    '/usr/lib/python3.9',
	    '/usr/lib/python3.9/lib-dynload',
	    '/usr/local/lib/python3.9/dist-packages',
	    '/usr/lib/python3/dist-packages',
	    '/usr/lib/python3.9/dist-packages',
	]
	USER_BASE: '/home/xxx/.local' (exists)
	USER_SITE: '/home/xxx/.local/lib/python3.9/site-packages' (exists)
	ENABLE_USER_SITE: False

# `*.pth`

When Python loads a site, it will load files with `pth` extension to try to find additional paths.
Those files can either contain:
- paths (or names) of more folders to add to path
    - example: `~/.local/lib/python3.9/site-packages/easy-install.pth`
- Python source code which may add entries to the path
    - example: `<virtualenv>/lib/python3.9/site-packages/_virtualenv.pth`

This lets the possibility to have arbitrary code run when the Python interpreter is started, by default, unless restrictive options are given (see above).
This can be a security threat since it makes it easy to inject malicious code into every Python program.

# virtualenv

In a virtualenv created with `--system-site-packages`:

	% virtualenv --system-site-packages env-system
	[...]
	% . env-system/bin/activate
	% PYTHONPATH= python -s -m site
	sys.path = [
	    '/tmp/plop-2335880',
	    '/usr/lib/python39.zip',
	    '/usr/lib/python3.9',
	    '/usr/lib/python3.9/lib-dynload',
	    '/tmp/plop-2335880/env-system/lib/python3.9/site-packages',
	    '/usr/local/lib/python3.9/dist-packages',
	    '/usr/lib/python3/dist-packages',
	    '/usr/lib/python3.9/dist-packages',
	]
	USER_BASE: '/home/xxx/.local' (exists)
	USER_SITE: '/home/xxx/.local/lib/python3.9/site-packages' (exists)
	ENABLE_USER_SITE: False

The virtualenv has its own site dir (`/tmp/plop-2335880/env-system/lib/python3.9/site-packages`),
in addition to the system site dirs (as `--system-site-packages` let it point to the system).

In a virtualenv created without:

	% virtualenv env-no-system
	[...]
	% . env-no-system/bin/activate
	% PYTHONPATH= python -s -m site
	sys.path = [
	    '/tmp/plop-2335880',
	    '/usr/lib/python39.zip',
	    '/usr/lib/python3.9',
	    '/usr/lib/python3.9/lib-dynload',
	    '/tmp/plop-2335880/env-no-system/lib/python3.9/site-packages',
	]
	USER_BASE: '/home/xxx/.local' (exists)
	USER_SITE: '/home/xxx/.local/lib/python3.9/site-packages' (exists)
	ENABLE_USER_SITE: False


See this [PyCon 2011 video](https://archive.org/details/pyvideo_389___reverse-engineering-ian-bicking-s-brain-inside-pip-and-virtualenv)
on the internals of virtualenv.

