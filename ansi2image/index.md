---
layout: mine
title: ansi2image
---

# ansi2image

ansi2image is a program that converts ANSI-art to image or HTML

## Usage ##

``ansi2image file.ans --truetype=file.ttf -o out.png``

``ansi2image file.ans -o out.html``

## Example output ##

``ansi2image file.ans --font=vga.pcf -o out.png``

## Fonts ##

The dosemu font ``vga.pcf`` is the recommended font. TrueType fonts can also be used, but the render has too large margin between characters. The render code can be tweaked but depends on the font and is not straigthforward.

## Requirements & Misc ##

ansi2image requires Python2, and [PIL (Python Imaging Library)](http://www.pythonware.com/library/pil/handbook/image.htm) for image output.
ansi2image is licensed under the [WTFPLv2](../wtfpl). 

## Similar programs ##

[Ansilove](http://ansilove.sourceforge.net/) is a program to convert ANSI files to images.
Ansilove was written by [Cleaner](http://cleaner.untergrund.net/), a great ANSI-artist.

## Download ##

