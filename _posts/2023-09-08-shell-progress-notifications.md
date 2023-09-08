---
title: Generic progress and notifications for commands in shell
last_modified_at: 2023-09-08T13:29:32+02:00
tags: shell notifications
accept_comments: true
---

# How to get progress info on command-line?

Many commands perform long tasks and report very little or even no progress info at all.
To name a few, even among the most standard tools:

- `tar`
- `cp`

## `pv`

When using piped commands or redirections, [`pv`](https://www.ivarch.com/programs/pv.shtml) can be put as a "command-in-the-middle", which will report speed and total data processed, and let data pass through.

For example, replace:

	tar xf foo.tar

with:

	pv -pret foo.tar | tar xf -

Example:

```
/tmp/foo % pv -pret foo.tar | tar xf -
0:01:29 [9.96MiB/s] [=======>                                  ] 21% ETA 0:05:27
```

For commands processing multiple files but not through a pipe, like:

	cp old/ new/

`pv` can monitor (with [`ptrace`](https://en.wikipedia.org/wiki/Ptrace), like a debugger) multiple file descriptors of a process, using `pv -d PID`:

	cp old/ new/ &
	pv -d $!

## `pvrun`

[`pvrun`](https://gitlab.com/hydrargyrum/attic/-/tree/master/pvrun) wraps it for easier usage:

	pvrun cp old/ new/

By the way, it's possible to tell `zsh`'s completion system that `pvrun` takes a command, so:

- `pvrun ` then `<tab>` will list commands
- `pvrun command ` then `<tab>` key will complete the same way `command` then `<tab>` would complete

This can be done with `compdef _precommand pvrun`.

# How to get notifications for background running tasks?

Sometimes, one starts a command running for a long time. For these situations, being notified when the command ends is useful. There are several solutions to this.

## Background with `&`

Running in the background with `&` seems an obvious solution.
The shell will notify inside the terminal when a background command ends.

```
/tmp/foo % tar xf archive.tar &
[1] 2605804
/tmp/foo % ls
file.txt    archive.tar    archive/
/tmp/foo % # do things while the archive is extracted
/tmp/foo % 
[1]  + done       tar xf archive.tar
/tmp/foo %
```

If the `&` was forgotten, it's still possible to send it to background while it's running with `<Ctrl+z>` then `bg`.
However, if the command outputs to stdout/stderr, it will either:
- garble the terminal
- suspend the app with `SIGTTOU` due to [`stty tostop`](https://pubs.opengroup.org/onlinepubs/009604599/basedefs/xbd_chap11.html#tag_11_01_04)

Also, if the terminal is not visible, the shell's notification will be missed.

## `notify-send`

Instead, one could add `; notify-send finished` to run [`notify-send`](https://manpages.debian.org/unstable/libnotify-bin/notify-send.1.en.html) for desktop notifications after the command finishes.
To add it afterwards, hit `<Ctrl+z>` and `fg ; notify-send finished`.

![screenshot of notify-send with a "finished" notification](2023-09-08-notify-send.png)

## Notifications to another device/medium

Remote notifications can be sent with [Gotify](https://gotify.net/) (for example [`gotify-send`](https://gitlab.com/hydrargyrum/attic/-/tree/master/gotify-tools) to send from command-line) or [Ntfy](https://ntfy.sh/) or [Apprise](https://github.com/caronc/apprise).

But for all those cases, it requires an extra step every time we want to be notified for a command completion.

## Automatically?

We could notify for each command running for more than X seconds but that would also notify the end for commands that run interactively, which is useless, because we know the command has finished: we are in front of the terminal and quit the app ourselves.

Instead, we could search for the terminal window running the shell and notify if the active window is not that terminal, when the command finishes.
If the shell is nested (for example, in [`screen`](https://www.gnu.org/software/screen/)), false positives may appear (for example, a shell may "change window"), so it's safer to just exclude them.

This is what could be done (for `zsh`, in `.zshrc`) for example:

```
_bgnotify () {
    local laststatus=$? lastcmd="${history[$#history]}" icon=dialog-error
    if [[ -z "${DISPLAY-}" ]] {
        # notify-send is only for graphical sessions
        return
    }
    if [[ $SHLVL -gt 1 ]] {
        # since we expect the shell's parent process to be the terminal,
        # nested shells break this assumption
        return
    }
    if [[ $laststatus -eq 0 ]] {
        icon=dialog-information
    }
    if [[ $(xdotool getwindowfocus getwindowpid) != $PPID ]] {
        notify-send -i $icon "command has exited with status ${laststatus}: $lastcmd"
    }
}

# execute _bgnotify before every prompt
add-zsh-hook precmd _bgnotify
# `add-zsh-hook precmd` is better than overriding `precmd` because it makes it possible to attach multiple hooks
```

![screenshot of notify-send with a failed ffmpeg notification](2023-09-08-notify-send-status.png)

Requires:

- [`notify-send`](https://manpages.debian.org/unstable/libnotify-bin/notify-send.1.en.html) for sending notifications
- [`xdotool`](https://github.com/jordansissel/xdotool) for checking the focused window and its PID

