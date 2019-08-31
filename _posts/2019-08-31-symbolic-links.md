---
layout: mine
title: Some notes on symbolic links
last_modified_at: 2019-08-31T12:31:45+02:00
tags: shell
---

# `ln` reminder

`ln EXISTING NEW` creates a **hardlink** of `EXISTING` with the new name `NEW`.

* `EXISTING` must be a file and must exist
* They will both point to the same file (same [inode](https://en.wikipedia.org/wiki/Inode)) and thus have same content, same metadata
  * it's not a copy, modifying `NEW`'s content will modify `EXISTING`'s content, and vice-versa
* `EXISTING` is not the "main file", it has the same importance as `NEW`
* `EXISTING` and `NEW` are just names (or "references") for the real file
* removing `EXISTING` or `new` will merely break their link to the real file, that's why the UNIX system call is named [`unlink`](https://pubs.opengroup.org/onlinepubs/9699919799/functions/unlink.html)
* the real file will be removed if there are no more references to it (like a [garbage collector](https://en.wikipedia.org/wiki/Garbage_collection_(computer_science)))
* `EXISTING` must be on the same filesystem than `NEW`

`ln -s POINTEE POINTER` creates a **symlink** of `POINTEE` with the name `POINTER`.

* no requirements on `POINTEE`, it does not need to be a file, an existing path, or anything
  * `POINTEE` can just be an arbitrary string, really! (except for filesystem limitations like file name maximum length)
* some system calls will follow `POINTEE` to `POINTER` automatically as if `POINTER` was used directly
  * for example, the `cat POINTER` shell command will read the `POINTEE` file, without `cat` doing anything special to follow it
* some others will not
  * for example, `rm POINTER` will just remove the symlink, not `POINTEE`
* removing the file at `POINTEE` (if it ever existed) makes `POINTER` a broken link
  * for example, `cat POINTER` will fail


# Relative symbolic links and `ln -rs`

It's easy to get wrong when building a relative symlink, because the `POINTEE` is relative to the `POINTER` path.

If there's a file `foo` in current directory and we would like to create a symlink to it at `./subdir/bar` then

	ln -s ./foo ./subdir/bar

is wrong!
When we do `cat ./subdir/bar`, the pointee is `./foo` evaluated **in the context of `./subdir/`**, which translates to `./subdir/foo`, but it does not exist.

The correct way is counterintuitive:

	ln -s ../foo ./subdir/bar

because our shell will autocomplete `./foo` but not `../foo`

Another solution which is both correct and allows autocompletion is:

	cd ./subdir
	ln -s ../foo ./bar

But fortunately, we don't have to remember to `cd` everytime we need a symbolic link, as `ln` offers an option to use the initial path arguments:

	ln -rs ./foo ./subdir/bar

And this works as we first expected.

# Rename to a symlink

When `mv` is used with a target which is a symbolic link, the pointee isn't touched and there's no symlink anymore, and the moved file has changed name.

Prepare:

	% echo foo > foo
	% echo quux > quux
	% ln -s foo slink
	% ll
	total 8
	-rw-r--r-- 1 user user 4 Aug 10 19:35 foo
	-rw-r--r-- 1 user user 5 Aug 10 19:35 quux
	lrwxrwxrwx 1 user user 3 Aug 10 19:35 slink -> foo


Replace:

	% mv quux slink
	% ll
	total 8
	-rw-r--r-- 1 user user 4 Aug 10 19:35 foo
	-rw-r--r-- 1 user user 5 Aug 10 19:35 slink
	% cat slink
	qux

# Copy to a symlink

When `cp` is used with a target which is a symbolic link, the pointer is opened in write mode, which opens pointee in write mode, so the pointer is untouched, and the pointee is modified.

	% cp quux slink
	% ll
	total 8
	-rw-r--r-- 1 ntome ntome 5 Aug 31 12:22 foo
	-rw-r--r-- 1 ntome ntome 5 Aug 31 12:22 quux
	lrwxrwxrwx 1 ntome ntome 3 Aug 31 12:22 slink -> foo

# Link to a symlink

`ln -s` will refuse to overwrite a symlink (actually it's the `link(2)` syscall which rejects it)

	% ln -s quux slink   
	ln: failed to create symbolic link 'slink': File exists

Adding `-f` will overwrite the pointer, not the pointee.

	% ln -fs quux slink
	% ll
	total 8
	-rw-r--r-- 1 ntome ntome 4 Aug 31 12:24 foo
	-rw-r--r-- 1 ntome ntome 5 Aug 31 12:22 quux
	lrwxrwxrwx 1 ntome ntome 4 Aug 31 12:29 slink -> quux

