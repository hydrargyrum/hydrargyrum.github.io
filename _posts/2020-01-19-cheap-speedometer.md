---
layout: mine
title: Cheap SSH speedometer
last_modified_at: 2020-01-19T19:10:46+01:00
tags: ssh
---

# Cheap SSH speedometer

Sometimes you need to measure (very) approximately the max network speed between 2 hosts (that happen to have an SSH link between them). It can be done with `ssh` and [`pv`](https://ivarch.com/programs/pv.shtml).

## Measure speed sending null bytes from local to `REMOTE`

	pv -abcrt -N $(hostname) /dev/zero | ssh -o Compression=no REMOTE pv -fabcrt -N REMOTE '>' /dev/null

## Measure speed receiving null bytes from `REMOTE` to local

	ssh -o Compression=no REMOTE pv -fabcrt -N REMOTE /dev/zero | pv -abcrt -N $(hostname) > /dev/null

## Approximate

Of course, it's very rough, it depends on many external factors, among which (non-exhaustive):

* system pipe overhead
* SSH overhead (cryptography included)
* QoS
* buffers of all of the aforementioned layers

## `pv` flags
* `-r` is for current speed
* `-a` is for average speed
* `-b` is for total size transferred
* `-t` is for time elapsed
* `-c` and `-N <label>` are for distinguishing both speedmeters
* `-f` tells the remote side `pv` to display stuff even though it's over `ssh`
* `'>' /dev/null` nullifies stdout directly on the remote side, avoiding null bytes to be echoed back from `ssh`

And for SSH:
* `-o Compression=no`: make sure compression isn't enabled, since we send only null bytes, which would be hugely compressed, the speed would seem much higher than what it really is.
