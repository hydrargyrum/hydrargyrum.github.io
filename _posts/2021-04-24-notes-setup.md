---
layout: mine
title: My setup for taking notes
last_modified_at: 2021-04-24T10:25:50+02:00
tags: notes markdown
accept_comments: true
---

# Setup

A simple dir with Markdown files named `YYYY-MM-DD-NOTETITLE.md` files, for example `~/notes/Daily/2021-04-24-jekyll.md`.

# On a regular computer

### `dailynote.sh`

	#!/bin/sh -e

	dt=$(date +%Y-%m-%d)
	fn=$dt
	title=$dt
	if [ -n "$1" ]
	then
		fn="$fn-${*// /-}"
		title="$title $*"
	fi
	fn=${NOTESDIR:-~/notes/Daily}/$fn.md

	[ -f "$fn" ] || echo "# $title" >> "$fn"

	${EDITOR:-nano} "$fn"

This script creates a new note for the day with a title and spawns a text editor on it.
If the note already exists, it just opens it without overwriting it.

Usage:

- `dailynote` generates/edits `2021-04-24.md`
- `dailynote some topic` generates/edit `2021-04-24-some-topic.md`

# On an Android device

On Android, [Markor](https://f-droid.org/packages/net.gsantner.markor/) is enough for taking such notes.
When creating a note in Markor, select "Jekyll post" so the file name template is filled with the date.

# Recommandations

In your shell config, export shell variables `$NOTESDIR` and `$EDITOR`.

Preferably use multiple notes per day, by passing an argument to the `dailynote` script.

In every note, add a line with hashtags related to the note content, for example:

	tags: #jekyll #static-site #markdown

Use [object tags rather than topic tags](https://zettelkasten.de/posts/object-tags-vs-topic-tags/).

## Zettelkasten

I don't use [Zettelkasten](https://zettelkasten.de/introduction/) yet, though it has very good ideas for building a life-long thoughts database.

# Searching/editing previous notes

Searching and running an editor on result is as easy as:

	f=$(rgrep -l "your search string" "$NOTESDIR" | fzf --preview='cat {}' ) && $EDITOR "$f"

This command requires the ncurses menu app [`fzf`](https://github.com/junegunn/fzf).
Any `rgrep` drop-in alternative can be used ([ag](https://geoff.greer.fm/ag/), [rg](https://github.com/BurntSushi/ripgrep), you name it), they use the same options.

# Sharing between devices

Just use [Syncthing](https://packages.debian.org/stable/syncthing) for sharing between devices.
It has a simple UI to configure a folder to share and choose which devices to permit, then you can about forget it.
Of course, you need to start it at boot automatically (it's a run as a user, not as root/system app).

It has an [Android app](https://f-droid.org/packages/com.nutomic.syncthingandroid/).

# Keeping modifications history

Use git. No history gets lost with git. First, start with:

	cd "$NOTESDIR"
	git init
	git config user.name Me
	git config user.email me@example.com
	git add .
	git commit --allow-empty -qa -m "initial import"

Commit messages don't matter a lot here, so you don't need any imagination to use it, just run this periodically:

	cd "$NOTESDIR" && git add . && git commit -qa -m snapshot

# Backup

Versioning and synchronizing between devices don't replace backups!

Since your notes may contain very personal information, avoid pushing the notes git repository to SaaS instances like GitLab.com or GitHub.com, for privacy reasons.
Instead, push to some privately-hosted Git host.

Or simply backup the dir with regular backup tools, possibly along with your home directory, like with encrypted [borg-backup](https://www.borgbackup.org/).
