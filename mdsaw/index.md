---
layout: mine
title: mdsaw - split or merge markdown files
last_modified_at: 2020-04-12T20:38:10+02:00
---

# mdsaw

Split or merge markdown files with multiple sections

# Merging

Multiple text files from the input directory will be merged into a singe big
output text file, with markdown sections for each of the original separate
files, and titles to split them ("# name of the file").

	mdsaw -c in_directory out_file.md

Or:

	mdsaw -c in_file1.md in_file2.md in_file3.md out_file.md

# Splitting

Conversely, if an input text file has markdown titles (for example lines like
"# the title"), it can be decomposed in multiple text files in the output
directory, each corresponding to one of the sections.
For example, one of the files could be "the-title.txt" and contain the text
from that section up to the next title.

	mdsaw -d in_file.md out_directory

# Example

A markdown file containing:

	# lorem

	lorem ipsum

	# dolor

	dolor sit amet

can be _decomposed_ in 2 files, `lorem.md` and `dolor.md`, each file
containing only the text from the corresponding section (and the heading).

Then, the 2 files `lorem.md` and `dolor.md` can be _composed_ together
to rebuild the original file.

# Download #

[Project repository](https://gitlab.com/hydrargyrum/mdsaw)
([GitHub mirror](https://github.com/hydrargyrum/mdsaw)).

mdsaw uses Python 3 and is licensed under the [Unlicense](https://unlicense.org/).
