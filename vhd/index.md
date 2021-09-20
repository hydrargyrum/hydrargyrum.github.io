---
layout: mine
title: vhd - Visual Hex Dump
last_modified_at: 2021-09-20T22:09:36+02:00
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

See DOS end-of-lines:

	% ( echo simple line; echo of text... ; echo non-ascii: résumé ) | todos | vhd
	s  i  m  p  l  e  sp l  i  n  e  \r \n
	o  f  sp t  e  x  t  .  .  .  \r \n
	n  o  n  -  a  s  c  i  i  :  sp r  C3 A9 s  u  m  C3 A9 \r \n

Compared to VIm's `xxd` which makes it difficult to see lines:

	% ( echo simple line; echo of text... ; echo non-ascii: résumé ) | xxd
	00000000: 7369 6d70 6c65 206c 696e 650a 6f66 2074  simple line.of t
	00000010: 6578 742e 2e2e 0a6e 6f6e 2d61 7363 6969  ext....non-ascii
	00000020: 3a20 72c3 a973 756d c3a9 0a              : r..sum...

# Requirements & Misc

`vhd` requires Python 3.

# Project repository

[Download](https://github.com/hydrargyrum/attic/tree/master/vhd)

