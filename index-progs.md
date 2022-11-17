---
layout: mine
title: The Attic - Programs
last_modified_at: 2022-11-17T21:51:37+01:00
---

Most of the site and programs from the site are licensed under the [WTFPLv2 license](wtfpl).

# GUI apps #

- [SIT-Tagger](sit-tagger): a simple image browser/viewer with tagging
- [EYE](https://gitlab.com/hydrargyrum/eye): extensible text editor, scriptable in Python, beta version
- [Lierre](https://gitlab.com/hydrargyrum/lierre): tag-based mail client (leveraging [notmuch](https://notmuchmail.org/)), with plugins, alpha version
- [Epistolaire](epistolaire): Android app to backup SMSes *and* MMSes to JSON
- [KelpMark](https://gitlab.com/hydrargyrum/kelpmark): GUI for watermarking images or PDFs


# Command-line tools #

- [redmine2ical](redmine2ical): convert Redmine's timesheet to iCalendar format
- [timecalc](timecalc): calculator of dates and durations
- [morse](morse): text from/to Morse code converter, and optional beep player
- [hibp](hibp): check if a password is leaked on "Have I Been Pwned?" (without sending it)
- [headset-bluez](https://gitlab.com/hydrargyrum/attic/-/tree/master/headset-bluez): enable a bluetooth headset and out or in/out mode
- [asciinario](https://gitlab.com/hydrargyrum/asciinario): app for automatic terminal recording with asciinema based on scenario scripts


## Network tools

- [puppetsocket](https://gitlab.com/hydrargyrum/gopuppetsocket): fake server and fake client to help traverse firewalls by using a reverse connection server -> client
- [wakeonwan](wakeonwan): wake remote machines with Wake-on-WAN
- [httpshare](https://gitlab.com/hydrargyrum/attic/-/tree/master/httpshare): share a directory via HTTP, like `python -m http.server` but supports "Range" headers (useful if you share a media directory)
- [httpmedia](https://gitlab.com/hydrargyrum/httpmedia): share a directory via HTTP, like `httpshare`, but adds thumbnails for images and videos
- [gotify-push.py, gotify-read.py](https://gitlab.com/hydrargyrum/attic/-/tree/master/gotify-tools): tools for sending/reading [Gotify](https://gotify.net/) notifications


## File formats ##

- [FLDev](fldev): expose partitions of a disk image in a virtual filesystem
- [hexgen](hexgen): generate data from an hex dump
- [iqontool](iqontool): pack multiple images into a .ico or .icns
- [qunpak](qunpak): extract Quake I and II .pak files
- [keepassxprint](keepassxprint): dump info and passwords from a KeePassX database
- [mdsaw](mdsaw): compose/decompose text files with multiple markdown sections
- [pdf-watermark](https://gitlab.com/hydrargyrum/attic/-/tree/master/pdf-watermark): watermark a chosen message on a PDF


## Video/Audio ##

- [ffmcut](https://gitlab.com/hydrargyrum/attic/-/tree/master/ffmcut): ffmpeg wrapper to cut a video between 2 timestamps
- [radiodump](https://gitlab.com/hydrargyrum/attic/-/tree/master/radiodump): circular buffer and dump to file (useful for radio streams)
- [united-ost](https://gitlab.com/hydrargyrum/united-ost): extract sound files from Unity games


## JSON and CSV

- [pjy](https://pypi.org/project/pjy/): process JSON data like [jq](https://stedolan.github.io/jq/), but with a reasonable Python syntax
- [json2sqlite](jsontools/json2sqlite.html): insert JSON data in SQLite
- [flatten-json](https://gitlab.com/hydrargyrum/attic/-/tree/master/flatten-json): flatten a deep JSON tree in a single object (or reverse operation)
- [json2table](jsontools/json2table.html): pretty-print JSON data (list of objects) in an ASCII-art table
- [csv2table](https://gitlab.com/hydrargyrum/attic/-/tree/master/csv2table): pretty-print CSV data in an ASCII-art table
- [json2csv](jsontools/json2csv.html): convert JSON data (a list of objects) to CSV
- [csv2json](https://gitlab.com/hydrargyrum/attic/-/tree/master/csv2json): convert CSV to JSON


## Unicode stuff ##

- [univisible](univisible): tweak Unicode combinations and visualize them
- [boxuni](boxuni): convert ASCII diagrams into Unicode diagrams
- [qr2unicode](qr2unicode): display QR-codes on console using Unicode box-drawing characters
- [vhd](vhd): visual hex dump, splitting at newlines, instead of classical hex dump fixed-width lines
- [realign-text-table](https://gitlab.com/hydrargyrum/attic/-/tree/master/realign-text-table): tool to rebuild plain-text table


## Filters and process management ##

- [tailsleep](tailsleep): like tail -f but quits when I/O activity stops
- [random-line](https://gitlab.com/hydrargyrum/attic/-/blob/master/random-line/random-line): take a random line from stdin
- [cheapthrottle](https://gitlab.com/hydrargyrum/attic/-/blob/master/cheapthrottle/cheapthrottle): throttle a command by repeatedly sending SIGSTOP and SIGCONT
- [xephyr-run-cmd](https://gitlab.com/hydrargyrum/attic/-/tree/master/xephyr-run-cmd): run a Xephyr server and run a command in it (like xvfb-run)
- [log-snippet](https://gitlab.com/hydrargyrum/attic/-/tree/master/log-snippet): parse compilation-log and show snippets of files with context
- [log-ts-diff](https://gitlab.com/hydrargyrum/attic/-/tree/master/log-ts-diff): parse log and replace timestamps with diff to previous timestamp
- [pvrun](https://gitlab.com/hydrargyrum/attic/-/tree/master/pvrun): run a command and show its I/O progress with [pv](http://www.ivarch.com/programs/pv.shtml)
- [sort-with-numbers](https://gitlab.com/hydrargyrum/attic/-/tree/master/sort-with-numbers): sort stdin like sort(1) but sorts numbers
- [uniq-unsorted](https://gitlab.com/hydrargyrum/attic/-/tree/master/uniq-unsorted): like uniq(1) but does not require lines to be sorted
- [altlines](https://gitlab.com/hydrargyrum/attic/-/tree/master/altlines): mark every 2 lines with color
- [catsponge](https://gitlab.com/hydrargyrum/attic/-/tree/master/catsponge): like cat(1) but soaks stdin and waits that stdin reaches EOF
- [group-lines](https://gitlab.com/hydrargyrum/attic/-/tree/master/group-lines): group stdin lines by a regular expression pattern


## Directory/file tools ##

- [gen-indexhtml](https://gitlab.com/hydrargyrum/attic/-/tree/master/gen-indexhtml): create an `index.html` listing all files in dir
- [group-files-by-mtime](https://gitlab.com/hydrargyrum/attic/-/tree/master/group-files-by-mtime): take files in a dir and move them to folders for each last modification time
- [name2mtime](https://gitlab.com/hydrargyrum/name2mtime): change the last-modification time of files basing on the dates contained in their filenames
- [xattrs-csv, xattrs-filter, xattrs-set](https://gitlab.com/hydrargyrum/attic/-/tree/master/xattr-tools): tools for manipulating/viewing xattrs (file system extended attributes)
- [hardlinks-to-csv](https://gitlab.com/hydrargyrum/attic/-/tree/master/hardlinks-to-csv): list files (and inodes) with more than 1 hardlink as CSV


## zsh

- [ZLE widgets](https://gitlab.com/hydrargyrum/zsh-stuff): several widgets for making command-line editing easier
- [junkyard/zsh](https://gitlab.com/hydrargyrum/junkyard/-/tree/main/zsh): a few zsh examples


# Tiny graphical apps #

- [qr-shot](qr-shot): decode a QR code image from part of the screen
- [coordapp](coordapp): always-on-top window that shows the mouse cursor coordinates
- [qruler](qruler): tool window that measures width and height in pixels
- [qgifview](https://gitlab.com/hydrargyrum/attic/-/tree/master/qgifview): basic GIF viewer
- [stickimage](stickimage): display an image always-on-top like a sticky note
- [lch-color-chooser](https://gitlab.com/hydrargyrum/attic/-/tree/master/lch-color-chooser): CIE LCh color chooser and RGB converter
- [exiforientergui](https://gitlab.com/hydrargyrum/attic/-/tree/master/exiforientergui): GUI to losslessly modify EXIF orientation of an image


# Web apps
- [WebP3](https://gitlab.com/hydrargyrum/webp3): raw web app for browsing music collection
- see [httpmedia](https://gitlab.com/hydrargyrum/httpmedia) above


# Web extensions
- [Cookie shelf](https://gitlab.com/hydrargyrum/cookie-shelf): [Firefox web-extension](https://addons.mozilla.org/en-US/firefox/addon/cookie-shelf/) to use with builtin [multi-account containers](https://addons.mozilla.org/en-US/firefox/addon/multi-account-containers/), to reject unwanted cookies depending on the container


# Fun with graphics #

- [ImageMagick stuff](magick): (including "how to read a CAPTCHA on console with ImageMagick")
- [image2xterm](image2xterm): display an image on console using terminal RGB24 mode or 256 colors
- [fonts2png](fonts2png): render TTF fonts samples to image files
- [svg-to-dia](https://gitlab.com/hydrargyrum/svg-to-dia): import arbitrary SVG files into [Dia](https://wiki.gnome.org/Apps/Dia/)
- [qr2unicode](qr2unicode): display QR-codes on console using Unicode box-drawing characters
- [Some images](gfx)


# Libraries #

- [vignette](https://pypi.org/project/vignette/): a Python library for generating thumbnails following the FreeDesktop specification [[documentation](https://vignette.readthedocs.io)]
- [qorbeille](https://gitlab.com/hydrargyrum/qorbeille): a Qt library to trash files to recycle bin
- [qvariantjson](https://gitlab.com/hydrargyrum/qvariantjson): yet another Qt4 JSON library
- a patch for upgrading [pycairo to cairo 0.12](py2cairo)


# Various plugins #

- [autocopier](r2w_plugins): rest2web plugin: automatically marks referenced images and files for inclusion at deployment
- [rss](r2w_plugins): rest2web plugin: generate RSS feeds along with your pages
- [supybot-shell](https://gitlab.com/hydrargyrum/attic/-/tree/master/supybot-shell/Shell): Supybot plugin: execute shell commands and see their output


# Training #

- [git exercises](https://framagit.org/git-exercises/index): exercise yourself on some git advanced topics
- [python exercises](https://gitlab.com/hydrargyrum/python-exercises): mildly advanced Python exercises
- [docker exercises](): getting hands on Docker with beginner exercises


# Various snippets

See the [junkyard repository](https://gitlab.com/hydrargyrum/junkyard).

