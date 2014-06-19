---
layout: mine
title: C++ ASCII tree
---

# C++ ASCII tree

An example of how to hardcode a tree strucure and to have the source code looking like the actual tree to be more readable

# Example #

To demonstrate what "tree-looking source code" means:

```
Node n =
	Node("1")
	* Node("11")
	* Node("12")
	* * Node("121")
	* * * Node("1211")
	* Node("13");
```

It's real C++ code that builds a tree with a few nodes, each one with a string value, by abusing C++ operators. The structure of the tree is apparent here.

This is only useful for hardcoding trees in source code though, and that can be useful when unit testing a program or library that manipulates trees.
Take for example a library generating a tree of strings from listing the filesystem. The unit test could create a temp dir and drop some files and folders inside it, use that ASCII tree to build an "expected" tree, call the library to build an "actual" tree. Finally compare the expected to the actual, and succeed only if the 2 trees are equal. With the ASCII tree, the test source code becomes much more readable.

Another proposal for tree building:

```
Node2 n2 =
	Node2("1")
	/ Node2("11")
	/ (Node2("12")
	   / (Node2("121")
	      / Node2("1211")))
	/ Node2("13");
```

# Download #

[Project repository](https://github.com/hydrargyrum/attic/tree/master/cppasciitree)

hexgen uses Python 2 and is licensed under the [WTFPLv2](../wtfpl).
