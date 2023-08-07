---
title: Shebang on non-scripts
last_modified_at: 2022-11-17T21:49:51+01:00
tags: shell
accept_comments: true
---

# Shebang on non-scripts

## Brief reminder on shebangs

Executable scripts start with a [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)), a line specifying how to execute that script.
It will often contain the interpreter path.
The path must be absolute, thus often [`env(1)`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/env.html) is used to wrap the command name, because `env` indirectly does a `$PATH` search.
The most common interpreters passed in shebang are:
- `sh`/`zsh`/`bash` for shell scripts, with `#!/bin/sh -eu` for example
- `python`/`python3` for python scripts, with `#!/usr/bin/env python3`
- also `perl`, `ruby`, etc.

Less common but equally useful are `sed(1)` scripts or `awk(1)` scripts, that can have a shebang too, so:
- they can be made executable
- the user doesn't have to pass the interpreter each time
- the user doesn't care if it's a `sed` or `awk` script, the shebang hides it and makes it runnable

Shebang can also be used for Makefiles, typically with `#!/usr/bin/make -f`.

## Additional args

One of the good things of shebangs is they don't prevent passing additional args.

For instance, when the shebang is:

	#!/usr/bin/my-interpreter -A

and this is launched:

	./my-script foo bar

then this is what will actually be run:

	/usr/bin/my-interpreter -A ./my-script foo bar

## Idea

As an extension, a shebang can be used as a shortcut if there's a dedicated command used to interpret the file (other than a text editor, of course).
For example:
- [`docker-compose.yml`](https://docs.docker.com/compose/compose-file/compose-file-v3/) is to be used by `docker-compose`
- `borgmatic.yml` is to be used by [borgmatic](https://torsion.org/borgmatic/)

A `docker-compose.yml` file can also be used with `podman-compose`, but the shebang doesn't prevent `podman-compose` to use it, it just adds a new default way to run the conf.

## Args within shebang

There's an issue with shebang line though: it is not subject to argument splitting using shell syntax (i.e. interpreting spaces and quotes). Shebang considers everything up to the first space as the interpreter path, and everything after to be a single argument.

If you used this shebang:

	#!/bin/sh -e -u

this is what would actually be run (expressed in shell syntax):

	/bin/sh "-e -u" ./my-script

`env` comes to the rescue (at least on some environments)! [GNU env](https://manpages.debian.org/unstable/coreutils/env.1.en.html) and [FreeBSD env](https://www.freebsd.org/cgi/man.cgi?query=env&apropos=0&sektion=0&arch=default&format=html) support `-S` option which will split the argument similarly to shell rules.

	#!/bin/env -S sh -e -u

will run:

	/bin/env "-S sh -e -u"

and `env` itself interpret its arguments, and then run:

	sh -e -u

## Applying

### docker-compose

This is a shebang that could be used for `docker-compose.yml` files:

	#!/usr/bin/env -S docker-compose -f

then, one could do for instance:

	chmod +x ./someproject/docker-compose.yml
	./someproject/docker-compose.yml run -d

which would be equivalent to:

	docker-compose -f ./someproject/docker-compose.yml run -d

(Of course, the `chmod +x` only needs to be done once)

### borgmatic

A shebang for borgmatic configuration files:

	#!/usr/bin/env -S borgmatic -c

to use like this for example:

	chmod +x ./backup-external-hdd.borgmatic.yml
	./backup-external-hdd.borgmatic.yml create --stats --progress

instead of:

	borgmatic -c ./backup-external-hdd.borgmatic.yml create --stats --progress

