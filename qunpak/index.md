---
layout: mine
title: qunpak - extract Quake I and II .pak files
last_modified_at: 2020-03-29T00:08:49+01:00
---

# qunpak

Extract and list Quake .pak archive files

# Examples

With qunpak it is easy to extract a .pak file:

```
qunpak PAK0.PAK
```

It's also possible to simply list it:

```
qunpak -l PAK0.PAK
```

Only some files can be extracted by specifying a glob-pattern ("*" will match slashes and dots):

```
qunpak PAK0.PAK "*.wav"
```

By default, files are extracted in current directory, but another directory can be used:

```
qunpak -O /other/dir/where/to/extract PAK0.PAK
```

# Features

* list contents of a PAK archive
* extract all content or only some files from a PAK archive

# Download

[Project repository](https://github.com/hydrargyrum/attic/tree/master/qunpak)

qunpak uses Python 3 and is licensed under the [WTFPLv2](../wtfpl).
