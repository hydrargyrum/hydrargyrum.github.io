---
layout: mine
title: qunpak
---

# qunpak

Extract and list Quake .pak archive files

# qunpak #

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

# Download #

[Project repository](https://github.com/hydrargyrum/attic/tree/master/qunpak)

qunpak uses Python 2 and is licensed under the [WTFPLv2](../wtfpl).
