---
title: Clipboard data
last_modified_at: 2021-12-21T23:00:33+01:00
tags: clipboard
accept_comments: true
---

# Clipboard data

The clipboard is used to hold data copied (typically with Ctrl-C) in an app, so it can be pasted anywhere (the same app or another).

When something is copied, the source app puts data in the clipboard, converted in multiple formats (using MIME types) that are relevant to the data copied.
Thus, at a given time, the clipboard holds multiple pieces of data, each assigned to a MIME type.

The destination app where stuff is pasted can process all these data pieces by only examining the MIME types it's capable of handling.

We'll be using [`all-clipboard`](https://gitlab.com/hydrargyrum/attic/-/tree/master/all-clipboard) to peek at the clipboard and debug it.

## Example: text copied from a text editor

```
TIMESTAMP: b'j\xd6~`'
TARGETS: b'O\x01\x00\x00M\x01\x00\x00N\x01\x00\x00P\x01\x00\x00\x8f\x01\x00\x00\x1f\x00\x00\x00'
MULTIPLE: b''
SAVE_TARGETS: b''
text/plain: We'll be using [`all-clipboard`](https://gitlab.com/hydrargyrum/attic/-/tree/master/all-clipboard) to peek at the clipboard and debug it.

```

We can see that the basic `text/plain` MIME type is filled, along with some other metadata.

## Example: 1x1 image copied from GIMP

```
TIMESTAMP: b'\xaef\x83`'
TARGETS: b'O\x01\x00...'
MULTIPLE: b''
image/png: b'\x89PNG...'
image/bmp: b'BM:\x00\x00...'
image/x-bmp: b'BM:\x00\x00...'
image/x-MS-bmp: b'BM:\x00\x00...'
image/x-icon: b'\x00\x00...'
image/x-ico: b'\x00\x00...'
image/x-win-bitmap: b'\x00\x00...'
image/vnd.microsoft.icon: b'\x00\x00...'
application/ico: b'\x00\x00...'
image/ico: b'\x00\x00...'
image/icon: b'\x00\x00...'
text/ico: b'\x00\x00...'
image/tiff: b'II*\x00\x18...'
image/jpeg: b'\xff\xd8\xff\xe0\x00\x10JFIF...'
application/x-qt-image: b'\x89PNG\r\n\x1a...'
```

For brevity, the output was truncated.
But we can see that when copying, GIMP exports in many formats for maximum compatibility with other apps where to paste.

## Example: copied 2 files in Thunar

Files too can be sent to clipboard! Let's see how:

```
TIMESTAMP: b'\xae\x0b\x8f\x0c'
TARGETS: b'M\x01\x00\x00K\x01\x00\x00L\x01\x00\x00q\x02\x00\x00z\x03\x00\x00\x8d\x01\x00\x00'
MULTIPLE: b''
text/uri-list: file:///tmp/plop-2335880/m.mp3
file:///tmp/plop-2335880/r.png

x-special/gnome-copied-files: b'copy\nfile:///tmp/plop-2335880/m.mp3\nfile:///tmp/plop-2335880/r.png'
text/plain: /tmp/plop-2335880/m.mp3
/tmp/plop-2335880/r.png
```

### MIME: `text/uri-list`

The `text/uri-list` MIME type is used in file managers when starting a copy/cut operation for a later paste.

It consists of full URLs with a newline (consisting of carriage return + line feed) after each URL (even after the last URL).

By the way, it's also used when dragging files from a file manager to drop somewhere else.
Drag-and-drops work similarly by attaching multiple pieces of data with various MIME types, to the drag operation.

### MIME: `x-special/gnome-copied-files`

The `x-special/gnome-copied-files` is used in file managers when starting a copy/cut operation for a later paste.

The first line indicates the type of operation (`copy` or `cut`) and will be interpreted by the target app where the paste will occur.
Next lines are full URLs but there is no final newline.

It's not used in drag-and-drops though.
