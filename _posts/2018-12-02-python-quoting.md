---
layout: mine
title: String escaping in Python
tags: python string regex
#original_date: 2018-01-20
---

# String escaping in Python

String escaping is a common feature of many languages. It follows some basic rules but it can quickly get confusing when a user does not understand them properly.

## Using `input`/`raw_input`, `print` and `repr` as an aid

The [`input`](https://docs.python.org/3/library/functions.html#input) function (`raw_input` in Python 2) reads some text verbatim from standard input and returns it as a string.
The [`print`](https://docs.python.org/3/library/functions.html#print) function is the converse function, it takes a string and displays it verbatim to standard output.

Let's see in a Python interpreter (in Python 2, replace `input` with `raw_input`):

	>>> s = input('enter a string: ')
	enter a string: foo bar
	>>> print(s)
	foo bar

Since `input` uses the text verbatim, backslashes and quotes are not interpreted:

	>>> s = input('enter a string: ')
	enter a string: backslash \ quote ' double-quote "
	>>> print(s)
	backslash \ quote ' double-quote "

Thus, `print` is the converse function.

When given a string, the [`repr`](https://docs.python.org/3/library/functions.html#repr) function will convert it to a form that could be put in a Python source file to build the given string. Let's use `print` to see the ouput string:

	>>> s = input('enter a string: ')
	enter a string: foo bar
	>>> use_in_source = repr(s)
	>>> print(use_in_source)
	'foo bar'

A side effect is that it will escape some characters if needed. This can be a convenient way to make sure we do not make mistakes:

	>>> s = input('enter a string: ')
	enter a string: backslash \ quote ' double-quote "
	>>> use_in_source = repr(s)
	>>> print(use_in_source)
	'backslash \\ quote \' double-quote "'
	>>> s == 'backslash \\ quote \' double-quote "'
	True

We literally copied-pasted the content of `repr(s)` in the interactive interpreter and checked the string was indeed equal to `s`.
We could have pasted the content of `repr(s)` in a Python source file and be sure it's interpreted as we intended.

## Raw string literal

In Python, prefixing a string literal's quote with an `r` will make a "raw string literal" instead of a "string literal". The difference is that Python will not interpret backslashes as escapes.

	>>> print('foo\nbar')
	foo
	bar
	>>> print(r'foo\nbar')
	foo\nbar

Note that it only changes parsing of the literal itself. Once the literal is parsed, it becomes a regular string and it can't be told apart from strings parsed from non-raw string literals.
 
	>>> r'foo\nbar' == 'foo\\nbar'
	True

The `r` prefix is typically used when the string literal contains _another_ language, for example HTML, TeX or... regular expressions.

# Regular expressions

The regular expressions [are a separate language](https://en.wikipedia.org/wiki/Regular_expression#Formal_language_theory), with a distinct syntax from the Python language.
This language has [its own escape-codes](https://docs.python.org/3/library/re.html#regular-expression-syntax), different from the [Python interpreter's escape-codes](https://docs.python.org/3/reference/lexical_analysis.html#string-and-bytes-literals).
For example, in regular expressions, `*` is a modifier indicating "0 or more occurences" and `\*` is an escape-code to match a single, literal `*` character.
Some of them are shared though, like `\n` for a newline character.

To use regular expressions in Python, they must be expressed in the form of Python strings.
Since they are Python strings, the escape-codes are interpreted by the Python interpreter first, then the regular expression module (the `re` module) will interpret the string content with its own escape-codes.

**It's better to add the `r` prefix in front of each string literal used as a regular expression.**

## It's a string before being a regex

When writing:

	r = re.compile('foo\nbar')

the Python interpreter reads `'foo\nbar'`, which is interpreted as a string literal. It sees the characters `f`, `o`, `o`, `\`, `n`, `b`, `a`, `r`.
Python transforms consecutive `\` and `n` into a single linefeed character.
The result of `'foo\nbar'` is a string containing `f`, `o`, `o`, a linefeed character (U+000A), `b`, `a`, `r`.

Then, the `re.compile` function is called with that string as a parameter. So, the `re.compile` will not get the `\n` escape-code (2 characters), but a single linefeed character.

When writing:

	r = re.compile('foo\?')

The Python interpreter reads the characters `f`, `o`, `o`, `\`, `?`. Since consecutive `\` and `?` aren't known to the Python interpreter, it will silently let them untouched.
`re.compile` will thus receive `f`, `o`, `o`, `\`, `?` and interpret itself `\` and `?` as an escape to `?`, which translates to a literal `?` instead of a quantifier for 0 or 1 occurence.
But this is still an error, and other languages compilers would be less forgiving about this.

You can make Python be loud about escapes it doesn't recognize:

	% python3 -Wdefault
	>>> 'foo\?'
	<string>:1: DeprecationWarning: invalid escape sequence \?
	'foo\\?'

## Conflicts

`\b` is an escape-code that both exists in Python literals and regex syntax, but has a very different meaning between the two:

	re.compile('\b')

matches a backspace character (U+0008). This is is very different from:

	re.compile('\\b')

which matches a word boundary (not a character). And it's easy to make a mistake.
Since most Python standard escape-codes have similar meanings for regex syntax (i.e. `r'\n'` will match a newline in regexes too), it's better to always prefix regex strings with `r`:

	re.compile(r'\b')

## Think in terms of regex first, then think how to convert as Python string

As an example, try to think how to match this text: `\n`, not the newline, but really the two characters: `\` and `n`.

First, try to imagine the regex. The `\n` regex will match a newline, not `\` then `n`. The backslash must be escaped, so the regex should be `\\n`.

Once the regex is found, we will need to express it (`\\n`) as a Python string, in Python syntax.
If we just write `'\\n'`, the Python interpreter will create a string containing 2 characters: `\` and `n` (because the `\\` was interpreted as an escape-code by Python).
Then, the `re` module will get a string containing `\n`, not `\\n` as we wanted. The correct way is to escape each backslash: `'\\\\n'`.

## Using the `repr` aid (and `re.escape`)

If we have the regex `She says: "Python's (.*)"`, and want to put in a Python file:

	>>> regex = input('enter regex: ')
	She says: "Python's (.*)"
	>>> use_in_source = repr(regex)
	>>> print(use_in_source)
	'She says: "Python\'s (.*)"'

The correct Python string is `'She says: "Python\'s (.*)"'`.

And if we want to match the literal text `\n` (2 characters), we should combine `repr` with `re.escape`, which converts a literal string into a regex matching the input string:

	>>> literal = input('enter a string: ')
	enter a string: \n
	>>> regex = re.escape(literal)
	>>> print(regex)
	\\n
	>>> use_in_source = repr(regex)
	>>> print(use_in_source)
	'\\\\n'

Note that `re.escape` is overzealous and will needlessly escape some characters. For example:

	>>> re.escape(',')
	'\\,'

is useless because `,` (comma) is not a metacharacter in the regex language, it will only match a single comma.

# Reference

* [Python 3, String and Bytes literals](https://docs.python.org/3/reference/lexical_analysis.html#string-and-bytes-literals)
* [Python 3, An Informal Introduction to Python, Strings](https://docs.python.org/3/tutorial/introduction.html#strings)
