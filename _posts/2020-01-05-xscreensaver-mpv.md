---
layout: mine
title: "Tip: play videos as a screensaver thanks to mpv"
last_modified_at: 2020-01-05T11:19:32+01:00
tags: xscreensaver mpv
accept_comments: true
---

# Tip: play videos as screensaver thanks to mpv

[XScreensaver](https://www.jwz.org/xscreensaver/) can run any command as screensaver and will put its locker over it (if password-locking is enabled).
But it requires to edit some config files.

# `~/.xscreensaver`

Look for a line consisting only of the text `programs:` (it's a config section), and add these lines:

	"MPV" 	mpv --really-quiet --no-stop-screensaver      \
		  --fs --wid=$XSCREENSAVER_WINDOW	      \
		  --no-audio --loop=inf --shuffle	      \
		  --ytdl-format="bestvideo[height<=1080]"     \
		  $HOME/.config/screensaver.m3u             \n\

For [reference](https://mpv.io/manual/master/#options), here's what these options do:

* `--really-quiet`: don't write to stdout, we won't see it anyway
* `--no-stop-screensaver`: mpv usually prevents the screensaver from being triggered while a video is playing, but now we are the screensaver itself!
* `--fs`: fullscreen, covers other apps
* `--wid=$XSCREENSAVER_WINDOW`: display in the xscreensaver dedicated window
* `--no-audio`: don't play sound
* `--loop=inf`: restart playlist when the end is reached, forever
* `--shuffle`: playlist in random order
* `--ytdl-format="bestvideo[height<=1080]"`: no need to select useless resolutions, and ignore sound if possible at all (youtube has formats with video only for 1080p onwards), adapt if you have a larger resolution
* `$HOME/.config/screensaver.m3u`: this will be our playlist

# `~/.config/screensaver.m3u`

This file is the playlist. It should start with a line containing only `#EXTM3U`. Then every line should be a local path or a URL to a video to play.
It can even be remote URLs, as long as `youtube-dl` is installed and it can handle those URLs.

### Example file

	#EXTM3U

	/path/to/some_video.mp4
	/path/to/dir_with_many_videos/

	# any youtube video or other sites supported by `youtube-dl`
	https://www.youtube.com/watch?v=Xjs6fnpPWy4

