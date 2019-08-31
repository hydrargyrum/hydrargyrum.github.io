---
layout: mine
title: vhd - Visual Hex Dump
last_modified_at: 2019-08-31T19:28:34+02:00
---

# vhd - Visual Hex Dump

`vhd` is tool for visualizing bytes, like `hd`, except it's designed for text files.
Instead of displaying bytes in fixed-length rows, one row will match a line.
This can be useful to see unexpected bytes in a text file.

# Example

Classical hexadecimal representation of bytes:

	% ( echo simple line; echo of text... ; echo non-ascii: résumé ) | vhd --hex
	73 69 6d 70 6c 65 20 6c 69 6e 65 0a
	6f 66 20 74 65 78 74 2e 2e 2e 0a
	6e 6f 6e 2d 61 73 63 69 69 3a 20 72 c3 a9 73 75 6d c3 a9 0a

Show ASCII characters when possible, the UTF-8 encoding of "`é`" is easy to spot:

	% ( echo simple line; echo of text... ; echo non-ascii: résumé ) | vhd
	 s   i   m   p   l   e   sp  l   i   n   e   \n
	 o   f   sp  t   e   x   t   .   .   .   \n
	 n   o   n   -   a   s   c   i   i   :   sp  r   c3  a9  s   u   m   c3  a9  \n

Display bytes addresses of line starts:

	% ( echo simple line; echo of text... ; echo non-ascii: résumé ) | vhd --line-addresses
	00000000  s   i   m   p   l   e   sp  l   i   n   e   \n
	0000000c  o   f   sp  t   e   x   t   .   .   .   \n
	00000017  n   o   n   -   a   s   c   i   i   :   sp  r   c3  a9  s   u   m   c3  a9  \n

# Requirements & Misc

`vhd` requires Python 3.

# Project repository

[Download](https://github.com/hydrargyrum/attic/tree/master/vhd)

