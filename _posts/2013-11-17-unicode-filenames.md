---
layout: mine
title: Filenames and Unicode in various OSes
tags: unicode
---

## A brief reminder about Unicode and encodings ##

In the beginning, there was ASCII, 128 characters containing the latin alphabet (A-Z), arabic numbers (0-9), a few symbols (period, plus, hash, etc.), some whitespace (space, tab, newline, etc.), a few control characters (like the bell character) and a null character. It was convenient as every character was contained in one byte, so there was a direct mapping between its code and the byte value.

But soon, the rest of the world wanted to use their own alphabets, which needed far more than 128 or even 256 characters. A number of country-local standards were created, to use their own characters, but each of those "standards" still did not care about the rest of the world. A stream of bytes would produce different characters depending on with which country-standard it was decoded, and often nothing could tell which standard to use, leading to confusion and lot of unreadable text (called [Mojibake](https://en.wikipedia.org/wiki/Mojibake)).

Thus Unicode was invented, which had thousands of characters and symbols, containing every language in the world. Each of these glyphs was called a codepoint (a number associated to a particular glyph). The original ASCII characters also had the same codepoint number they had in ASCII. For example, codepoint number 65 corresponds to uppercase letter A, and is noted U+0041 (where 0041 is hex for 65).

However, the number of glyphs made it impossible to fit everything in one byte. A few encodings were created, an encoding maps virtual entities (codepoints) to low-level bytes. The most common encoding is UTF-8. In this encoding, some characters would take one byte, some would take more (2 to 4) but no byte would be null, which made it easy to use with C's infamous null-terminated strings. Also, in UTF-8, the former ASCII characters are represented with only one byte, which made it compatible with old ASCII text data.

## Unicode's combining glyphs ##

Among Unicode's features, are the "combining glyphs", like accents, that are used to be associated with another glyph in order to build a third glyph. For example, an acute accent is a combining glyph, which can be combined with the "e" letter, to make this glyph: "é". Multiple combining glyphs can be used at the same time with a normal glyph. A combining glyph has also a codepoint, and it's put before the normal glyph it is combined with. So "é" is made of codepoints U+0301 U+0065. However, Unicode also contains the codepoint U+00E9 which represents an already combined glyph "é". So the "é" glyph has several representations in Unicode, one consisting of one codepoint and one involving composition of 2 glyphs.

While the representations are equivalent, they are not equal, and a program that would just compare the codepoints (or the bytes resulting from UTF-8 encoding) will see them as being different. For that reason, Unicode defines 2 "normalizations" to transform equivalent representations into one canonical representation, to compare it easierly. The first is NFKD (Normalization Form Compatibility Decomposition), which will convert each glyph into decomposed form if it exists. U+00E9 will be converted to U+0301 U+0065 by NFKD for example. The second is NFKC which does the reverse, transform combined glyphs into one single glyph, if there is such a combination.

## A reminder about C strings ##

In C, strings are contiguous arrays of characters. As it is impossible in C to know the length of an array, the convention is to put a null character (a character that shouldn't be encountered inside a string in normal conditions) to indicate it is the end of the string and there is nothing anymore after that null character. By just writing `"foo"`, an array of 4 characters is made, equivalent to `{'f', 'o', 'o', '\0'}`, where each character is one byte. By writing `L"foo"`, an array of 4 characters will be made, but each character will be bigger than one byte (`char`), using the `wchar_t` type (equivalent to `{L'f', L'o', L'o', L'\0'}`). If wchar_t were 2 bytes-wide (as on Windows), the bytes would be (assuming little-endian): `{0x66, 0x00, 0x6F, 0x00, 0x6F, 0x00, 0x00, 0x00}`. Notice there are null-bytes in the middle of the array, but the string does not end at this point, it ends when encountering a null character.

## Filenames and encodings ##

Each operating systems has its set of rules for its APIs and filesystem support and nothing should be assumed prior to reading the rules.

### Reserved characters and names ###

On Unix and MacOSX, null characters and slashes are forbidden in a filename. MacOSX Finder will display ":" as a "/" though.

On Windows, null characters are forbidden, plus theses ones: slash (`/`), colon (`:`), backslash (`\`),  pipe (`|`), star (`*`), question mark (`?`), double quote (`"`), angle brackets (`<>`), tabs and carriage returns and line feeds. Additionnaly, a few names are reserved, like "con" or "nul" ("nul" is a sort of equivalent to /dev/null).

Also, on Windows, file names should not end with a space or a dot (.). While it is possible to create them with some means (see below), many API functions will not be able to manipulate them, and in particular the Windows explorer cannot manipulate them, not even remove them.

[Reference for Windows' naming rules](http://msdn.microsoft.com/en-us/library/windows/desktop/aa365247%28v=vs.85%29.aspx)

### Path lengths ###



### Case sensitivity ###

On case-insensitive filesystems, like FAT32, API calls made with 2 different cases will operate on the same file.

On MacOSX, the filesytem can be made case-sensitive, but the OS default is to be case-insensitive.

On Windows, the filesystem is generally case-insensitive, but the OS "personalities" (like the POSIX one) could change rules. This article will not cover these details.

On other Unices, the filesystems are usually case-sensitive.

### Path encodings ###

On MacOSX, filenames created by most APIs are encoded in UTF-8, and the OS enforces NFKD form, meaning using 2 names with equivalent unicode representations will refer to the same file.

On other Unices, the filenames are just bytes sequences (restricted by the previous rules on reserved chars and further rules on length) with no encoding even recommended, even if UTF-8 seems the most promising, and is chosen by default on most popular Linux distributions. Of course, no normalization is even suggested. The user locale (through `$LANG` environment variable and others) is just an indication and is nowhere enforced.

On Windows, the filenames are handled as UTF-16, without Unicode normalization. The filenames can be returned in UTF-16 or in a non-Unicode encoding. The latter encoding should be discouraged as it cannot encode all possible characters.

http://msdn.microsoft.com/en-us/library/windows/desktop/dd317748%28v=vs.85%29.aspx

### APIs ###

On Unices (including MacOSX), API are generally for C language, and take filenames as C null-terminated strings of "`char*`". See above for path encoding.

On Windows, the situation is much more complicated.

Because of legacy, Windows API functions have generally two variants: the ANSI variant and the Unicode variant.
For exemple, the CreateFile function (equivalent to POSIX' open(2) function) is in fact a macro that will call CreateFileA (ANSI variant) or CreateFileW (Unicode variant) which are actual functions.
The ANSI variants take `char*` parameters for strings, while the Unicode variants do take `wchar_t*` parameters. Obviously, the ANSI functions are not for using Unicode names, as they use a local codepage encoding, which can't handle all characters.
The ANSI variants are subject to some path length limitations: paths passed to them must be shorter than `MAX_PATH` (260, so 260 bytes because of `char*`).

On Windows, to use a path longer than 260 bytes, the Unicode variant must be used, and the path must be transformed in a special form.
This special form can only take an absolute path. In this special form, `C:\some\path` becomes `\\?\C:\some\path`, and `\\remote\share\some\path` becomes `\\UNC\remote\share\some\path`. To translate in C, `L"C:\\some\\path"` becomes `L"\\\\?\\C:\\some\\path"`, `L"string"` denotes a `wchar_t[]` string instead of a `char[]` string.
When the special form is used with the Unicode variant, the path length limitation is raised to ~32k characters (characters, not bytes).


## Other links of interest ##

[http://www.utf8everywhere.org/](http://www.utf8everywhere.org/)
