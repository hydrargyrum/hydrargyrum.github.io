---
layout: mine
title: Tips for debugging a Python program with GDB
last_modified_at: 2019-05-05T11:32:41+02:00
tags: python debugging gdb
---

# Tips for debugging a Python program with GDB

Occasionally, one encounters segfaults when running a Python program, not Python exceptions, but crashes in a library.
To find the reason of the crash, let's do like any non-Python program: use [`gdb`](https://en.wikipedia.org/wiki/GNU_Debugger)!

## Starting

If the crashing program is run like this:

	./foo.py --bar

Use instead:

	gdb --arg $(which python3) ./foo.py --bar

You should get an initial GDB prompt, just enter `run` command (or `r` for short).
Your program will start, though slower than usual.

## Crashing

Run everything required to reproduce the crash.
At some point, when the program crashes, GDB will prompt you back, like this

	Thread 1 "python3" received signal SIGABRT, Aborted.
	0x00007ffff7a1085b in raise () from /lib/x86_64-linux-gnu/libc.so.6
	(gdb)

If it's a graphical program, the program UI will also cease to respond.

To start, run the `backtrace` command (or `bt` for short).

## Debug symbols

If you see a lot of "`??`" (or at least in the most important places), you will
need to install the debug symbols of the relevant libraries in order to see the function names.

For example, if you see:

	#141 0x00007ffff6ac2304 in ?? () from /usr/lib/x86_64-linux-gnu/libQt5Widgets.so.5

The library of which you should install the debug symbols is `libQt5Widgets.so.5`.
Under Debian, the normal package is `libqt5widgets5` (found with `dpkg -S <file>`)
and so the corresponding [debug](https://wiki.debian.org/DebugPackage) package is `libqt5widgets5-dbgsym`.

## Python backtrace in GDB

The usual `backtrace` command will return the C-level backtrace, not the Python one (though it's contained within).
By installing the right packages (like `python3-dbg` in Debian), you will get helpers for Python in `/usr/share/gdb/auto-load`.

Then, GDB will have new commands like `py-bt`, `py-list`, `py-up`, `py-down`, `py-print`, the Python counterparts of `bt`, `list`, `up`, `down`, `print` commands.
A few more commands are available, like `py-locals` or `py-bt-full`.
