---
layout: mine
---

# qr2unicode

qr2unicode is a program to display a QR Code on a terminal, using ANSI drawings.

# Features

* can output QR-Code unsing [Unicode block characters](https://en.wikipedia.org/wiki/Box-drawing_character#Unicode) in 2 sizes
* can output QR-Code using plain ASCII and [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code) for simpler terminals
* can invert colors for terminals with a dark background
* can add a border

# Example output

ANSI sequences in a term:

	qr2unicode -i -b 1 "hello world"

![Terminal screenshot](screenshot.png)

Unicode box-drawing characters:

	qr2unicode --method=unicode "foo bar"

```
  ██████████████    ██  ████  ██████████████  
  ██          ██  ████  ██    ██          ██  
  ██  ██████  ██  ████    ██  ██  ██████  ██  
  ██  ██████  ██    ██  ██    ██  ██████  ██  
  ██  ██████  ██  ██      ██  ██  ██████  ██  
  ██          ██  ██    ████  ██          ██  
  ██████████████  ██  ██  ██  ██████████████  
                  ██████████                  
  ████  ██    ████  ████      ██████  ████    
  ██  ██  ██        ██        ████    ██████  
    ██      ████      ██  ████      ██    ██  
    ██████        ██  ████      ██████  ██    
    ██  ████  ████    ██  ██  ██  ██    ████  
                  ████  ██            ██  ██  
  ██████████████  ██████    ██  ████    ██    
  ██          ██      ████████      ██    ██  
  ██  ██████  ██    ██████    ██          ██  
  ██  ██████  ██  ████  ██      ████    ████  
  ██  ██████  ██          ██    ████  ██  ██  
  ██          ██  ██  ██    ██████            
  ██████████████  ██  ██████      ████  ██    
```

Text encoded: "foo bar"

# Requirements & Misc ##

qr2unicode requires Python3, and python-qrcode.
qr2unicode is licensed under the [WTFPLv2](../wtfpl).

# Download

[Project repository](https://github.com/hydrargyrum/attic/tree/master/qr2unicode)
