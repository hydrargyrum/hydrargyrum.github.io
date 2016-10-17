---
layout: mine
---

# morse

A tool to convert text from/to Morse code

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

`morse` is compatible with Python 2 and Python 3.
It is licensed under the [WTFPLv2](../wtfpl).