---
layout: mine
title: morse - text from/to Morse code converter, and optional beep player
last_modified_at: 2020-03-29T00:08:49+01:00
---

# morse

A tool to convert text from/to Morse code

# Features

* convert text to printable Morse code
* convert printable Morse code to text
* convert text to wav file playing Morse sound (or using `beep` command)

# Examples

Convert text to Morse:

```
% echo hello world | morse
.... . .-.. .-.. --- / .-- --- .-. .-.. -..
```

Convert Morse to text:

```
% echo ".... . .-.. .-.. --- / .-- --- .-. .-.. -.." | morse --parse
HELLO WORLD
```

If the [`beep` command](http://johnath.com/beep/) is available, ``morse`` can use it to play the Morse beeps using the PC speaker:

```
% echo hello world | morse --beep
[speaker beeps]
```

Otherwise, a [wave output](output.wav) can be generated, with optional frequency:

```
% echo hello world | morse --wave output.wav --frequency 700
```

# Download #

[Project repository](https://github.com/hydrargyrum/attic/tree/master/morse)

`morse` uses Python 3.
It is licensed under the [WTFPLv2](../wtfpl).

# See also

[Screen-blinking Morse](blink.html) at [repository](https://github.com/hydrargyrum/attic/tree/master/morsehtml).

