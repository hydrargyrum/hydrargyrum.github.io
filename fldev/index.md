---
layout: mine
title: FLDev - expose partitions of a disk image in a virtual filesystem
---

# FLDev #

FLDev is a FUSE virtual filesystem that exposes the partitions of a disk image as individual files. FLDev shows these partitions like Linux shows virtual files `/dev/hda1`, `/dev/hda2`, `/dev/hda5` corresponding to partitions from a disk `/dev/hda`. FLDev means Fuse Linux-Devices.

As it uses FUSE, FLDev doesn't require root privileges.

## Example ##

If `image.bin` is a disk image with a primary partition and a logical one (inside an extended partition):

```
% mkdir partitions
% fldev image.bin partitions
% ls partitions
hda1  hda2  hda5
```

The partition files can be formatted, even mounted themselves if they contain a filesystem.

## Download ##

FLDev requires libgparted and libfuse to compile.

[Project repository](https://github.com/hydrargyrum/fldev)

## Warning ##

Modifying the partition table while FLDev is mounted won't change the shown partitions.
