---
layout: mine
title: FLDev - expose partitions of a disk image in a virtual filesystem
last_modified_at: 2018-12-30T22:21:20+01:00
---

# FLDev #

FLDev is a FUSE virtual filesystem that exposes the partitions of a disk image as individual files. FLDev shows these partitions like Linux shows virtual files `/dev/hda1`, `/dev/hda2`, `/dev/hda5` corresponding to partitions from a disk `/dev/hda`. FLDev means Fuse Linux-Devices.

As it uses FUSE, FLDev doesn't require root privileges.

# Example

If `image.bin` is a disk image with a primary partition and a logical one (inside an extended partition):

```
% mkdir partitions
% fldev image.bin partitions
% ls partitions
hda1  hda2  hda5
```

The partition files can be formatted, even mounted themselves if they contain a filesystem.

# Features

* handles [many](https://www.gnu.org/software/parted/manual/html_node/mklabel.html#index-mklabel_002c-command-description) partition table formats by relying on [GNU libparted](https://www.gnu.org/software/parted/)
* can run as user (it uses [FUSE](https://en.wikipedia.org/wiki/Filesystem_in_Userspace))


# Download

FLDev requires libgparted and libfuse to compile.

[Project repository](https://gitlab.com/hydrargyrum/fldev)

# Warning

Modifying the partition table while FLDev is mounted won't change the shown partitions.
