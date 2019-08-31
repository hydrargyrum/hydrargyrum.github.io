---
layout: mine
title: hexgen - generate data from an hex dump
last_modified_at: 2018-12-02T19:19:09+01:00
---

# hexgen

A tool to generate bytes from ASCII hex dump

# hexgen #

hexgen just takes hex on stdin and produces the corresponding bytes.

```
% echo "4865 6c6c 6f20 776f 726c 64 21 0a" | hexgen
Hello world!
```

It ignores whitespace and will error if a non-hex digit is found.

# Download #

[Project repository](https://github.com/hydrargyrum/attic/tree/master/hexgen)

hexgen uses Python 3 and is licensed under the [WTFPLv2](../wtfpl).
