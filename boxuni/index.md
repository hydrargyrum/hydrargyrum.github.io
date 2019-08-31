---
layout: mine
title: boxuni - convert ASCII diagrams into Unicode diagrams
last_modified_at: 2018-12-02T19:19:09+01:00
---

# boxuni

boxuni is a program to convert old-school ASCII diagrams into Unicode diagrams.

# Example output

It will convert this:

	+-----+-----+
	|     |     |
	+-----+-----+
	|     |     |
	+-----+-----+

into this:

	┌─────┬─────┐
	│     │     │
	├─────┼─────┤
	│     │     │
	└─────┴─────┘

# Conversions

Only `-`, `+` and `|` are converted for now. Diagonals, rounded corners, bold-width and double-lining will be handled in the future.

# Requirements & Misc

boxuni requires Python3. It is licensed under the [WTFPLv2](../wtfpl).

# Download

[Project repository](https://github.com/hydrargyrum/attic/tree/master/boxuni)
