---
layout: mine
title: Commands with subcommands and manuals
last_modified_at: 2021-09-20T22:08:38+02:00
tags: cli
accept_comments: true
---

# Tiny tip: manual of commands with subcommands

Many commands that have subcommands have dedicated manual pages for each subcommand.
The subcommands are taken as an argument of the main command, e.g. `cargo install`,
but the related manual pages are just separated with a dash, e.g. [`cargo-install`](https://manpages.debian.org/testing/cargo/cargo-install.1.en.html).

Examples of commands following this pattern:
- [`git`](https://git-scm.com/docs/git)
- [`borg`](https://borgbackup.readthedocs.io/en/stable/usage/init.html)
- [`docker`](https://docs.docker.com/engine/reference/commandline/cli/)
- [`cargo`](https://doc.rust-lang.org/cargo/commands/cargo.html)

## Trivia on man page sections
Not exactly `cargo-install`, the manpage is rather: `cargo-install(1)`.
The number designates the section of manuals.
1 is the section containing *Executable programs or shell commands*.
See [`man(1)`](https://manpages.debian.org/testing/man-db/man.1.en.html) for the list of sections.

A page can exist in different sections, for example `passwd` exist in 2 sections:
* [`passwd(1)`](https://manpages.debian.org/testing/passwd/passwd.1.en.html) for the command
* [`passwd(5)`](https://manpages.debian.org/testing/passwd/passwd.5.en.html) for the `/etc/passwd` file

## Reading manual pages online

There are many sites for reading manual pages but most of them are crippled with ads or trackers.
Fortunately, distributions and OSes provide them without clutter or selling your privacy:

- [Debian Manpages](https://manpages.debian.org/)
- [OpenBSD manual page server](https://man.openbsd.org/)
- [FreeBSD Manual Pages](https://www.freebsd.org/cgi/man.cgi)
- [Unofficial CentOS manual pages](http://man.linuxtool.net/)
