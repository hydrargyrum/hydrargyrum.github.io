---
layout: mine
---

# tailsleep #

tailsleep is a program similar to "``tail -f``", except that it will quit if the followed file is not modified for a period of time. Also, it starts at the beginning of the file, not only the 10 last lines.
It's a sort of ``cat`` that continues to ``cat`` the file as the file is growing, and stops ``cat``-ing when the file is not growing since some time (5 seconds by default).

# Sample uses #

Extract a file that is being downloaded by a web browser:

```
tailsleep file-being-downloaded.tar.gz.part | tar -xzf -
```

As an extension, download Flash videos loading/loaded in your web browser (doesn't need to be playing them, they can be paused):

```
find /proc/*/fd -lname "*FlashXX*" | while read vid
do
	tailsleep $vid > "video-`basename $vid`.flv"
done
```

# Misc & download #

tailsleep requires Python 3 and is licensed under the [WTFPLv2](../wtfpl).

[Project repository](https://github.com/hydrargyrum/attic/tree/master/tailsleep)
