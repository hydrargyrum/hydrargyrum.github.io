---
layout: mine
title: Why I prefer zsh
last_modified_at: 2021-03-21T17:33:50+01:00
tags: shell zsh
accept_comments: true
---

# Features I use frequently that aren't elsewhere

## Global aliases

Global aliases are like aliases, except that they may be subsituted not only at the beginning of a command but anywhere.

For example:

```
alias -g PL='|less'
alias -g PG='|grep'
```

allows to simplify:

```
dmesg | grep error | less
```

into:

```
dmesg PG error PL
```

## `!$` tab expansion

Like `bash`, `zsh` has history expansion. For example, `!$` (an shortcut to `!!:$`) will expand into the previous command's last argument:

```
mkdir foo
cd !$
```

Or `!!` which refers to the last command:

```
  # oops, will return an error because user isn't root
apt install zsh
sudo !!
```

Where `zsh` shines over `bash`, is that those variables can be expanded with the `tab` key (by default) like any other expansion.
This allows to see the full command that will be run before you press enter, to make sure you don't submit a bad command, or simply to edit it furthermore.

`bash` doesn't allow to expand it, you will discover what was expanded when you run the command.

## Bare glob qualifiers

Globbing (like `*` wildcard expansion) has powerful filtering in zsh.
For example, in all shells, `*` expands to any name, it's possible in zsh to add a filter to select only regular files, not dirs or links with `*(.)`, or only dirs with `*(/)`.

	# remove symbolic links with extension .jpg
	rm *.jpg(@)

	# zip files modified more than 1 day ago
	tar cfz /tmp/backup.tgz *(md+1)

	# remove empty temporary files
	rm /tmp/*(L0)

# Nicer syntax for if/for/while

zsh supports the standard syntaxes:

	if something
	then
		true
	fi

	while something
	do
		true
	done

	for variable in some thing
	do
		true
	done

But also supports:

	if ( something ) {
		true
	}

	while ( something ) {
		true
	}

	# perl-like
	for variable (some thing) {
		true
	}

# Separate `man` pages for separate topics

The [`bash(1)`](https://manpages.debian.org/buster/bash/bash.1.en.html) manual is a 3000+ lines wall-of-text.

In contrast, the zsh manual is split in multiple manuals, for example [`zshexpn(1)`](https://manpages.debian.org/buster/zsh-common/zshexpn.1.en.html) which covers globbing and expansion features, [`zshzle(1)`](https://manpages.debian.org/buster/zsh-common/zshzle.1.en.html) for custom key binding, [`zshcompsys(1)`](https://manpages.debian.org/buster/zsh-common/zshcompsys.1.en.html) for the autocompletion system, etc.

Should you really have a single manpage, for example to do a global search, zsh combines all of it sub-manuals into the huge [`zshall(1)`](https://manpages.debian.org/buster/zsh-common/zshall.1.en.html) which reaches 17000+ lines.

# Other fancy stuff

See [Grml](https://grml.org/)'s (Live CD/USB distro) [zsh tips page](https://grml.org/zsh/zsh-lovers.html).

