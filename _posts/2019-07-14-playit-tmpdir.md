---
layout: mine
title: "Tip: configuring ./play.it dirs"
last_modified_at: 2019-07-14T18:50:46+02:00
tags: play.it
accept_comments: true
---

# Tip: configuring `./play.it` dirs

When running low on space on the root partition, using `play.it` can be hard.
For example:

	./play-it-script basic-installer.sh

this will use `/tmp` to convert an installer script downloaded from (for example) GOG or Humble Store.
And after that, the generated distribution package will install files in `/usr` or `/usr/local`.

Those directories can be changed:

	TMPDIR=$HOME/tmp ./play-it-script --prefix=$HOME/games basic-installer.sh

This will use `~/tmp` as the temporary directory to extract the installer script.

And when installed, the game will be placed in `~/playit`, with dirs like `~/playit/lib`, `~/playit/games` etc. instead of `/usr`.
If preferred, one can choose `/opt` as the `--prefix`.
