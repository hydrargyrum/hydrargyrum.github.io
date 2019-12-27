---
layout: mine
title: pass and console pinentry
last_modified_at: 2019-12-27T11:32:52+01:00
tags: shell
---

# Force console pinentry for `pass` (and `gpg`)

If you use [`pass`](https://www.passwordstore.org/), you may use graphical pinentry, a dialog box prompting for the master password to unlock the storage, especially if `pass` is used by a graphical app.
But then, when accessing the machine from `ssh` for example, the command `pass show xxx` might wait forever.
Why? Probably a graphical pinentry has been started and displayed, but you can't fill it because you do not have access to the graphical session. So we need to force pinentry to console.

Some tips mention setting `export GPG_TTY=$(tty)` but it didn't work for me, even after stopping `gpg-agent` and `pinentry`.

After struggling some time, I found a solution:

    export PASSWORD_STORE_GPG_OPTS=--pinentry-mode=loopback

For it to work, make sure there is no pending pinentry prompt:

    killall pinentry
