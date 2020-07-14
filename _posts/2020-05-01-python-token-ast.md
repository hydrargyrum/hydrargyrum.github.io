---
layout: mine
title: Python AST and tokens
last_modified_at: 2020-07-14T22:49:20+02:00
tags: python,parsing
accept_comments: true
---

# Python AST and tokens

# Tokens

Tokens are atoms in the language syntax, like an operator, a delimiter, a keyword, a name or a literal.

- The [`tokenize` standard module](https://docs.python.org/3/library/tokenize.html) transforms source code text into a flat list of `TokenInfo` objects.
- The [`token` standard module](https://docs.python.org/3/library/token.html) holds the enum for describing the type of a token.
- Those modules are implemented in pure-python and the Python interpreter does not use them to parse programs

In addition of its `type` attribute, a `TokenInfo` object has a few more attributes, like its `start` and `end` (line and column numbers) and associated data.

For example, this piece of code:

	foo(1, 2)

consists in 7 tokens:

	NAME
	LPAR
	NUMBER
	COMMA
	NUMBER
	RPAR
	NEWLINE


## Small theory bit

Converting from source text to tokens list is called "lexical analysis" and is (mostly) based on regular expressions.


## Invalid syntax can still be tokenized

Tokenizing doesn't care about syntax, it is the step before grammar, it only splits in atomic tokens.
For example, the following source code is invalid regarding Python grammar, but tokenizing it will be fine:

	if if if : : : * ) (

Unrecognized tokens, like dollar (`$`) will emit an `ERRORTOKEN`.


## Operators

- for all operators, like `=`, `:`, `(`, `)`, `[`, `]`, `,` etc., token has `OP` type
- to know what operator it is, exame `exact_type` attribute: `EQUAL`, `COLON`, `LPAR`, `RPAR`, `LSQB`, `RSQB`, `COMMA` etc.
- or examine the `string` attribute


## Keywords

- keywords like `if`, `def`, `class` are not special tokens, they are just `NAME` tokens
- use the `string` attribute to get the name of a `NAME` token
- use the [`keyword` standard module](https://docs.python.org/3/library/keyword.html) to determine if it's a keyword
- even though keywords don't have a dedicated token, `ASYNC` and `AWAIT` tokens are an exception to this rule, though they have an history of being introduced and deprecated several times


## Line/column positions

For a `TokenInfo` object, there is the `start` attribute and the `end` representing the position of the token in physical source code.
Both are tuples `(line_number, column_number)`.

- line numbers are 1-based (though some tokens are [out of bounds](out-of-bounds-tokens))
- column numbers are 0-based
- end line numbers are inclusive
- end column number are exclusive

For example, if the first file line is just:

	foo

The `NAME` token will have:

- `start[0] == 1`
- `end[0] == 1`
- `start[1] == 0`
- `end[1] == 3`

About ending line position:

- for all tokens, the line `start` and `end` are the same, except for some `STRING` tokens
- `STRING` tokens are the only ones whose `start` and `end` can be on a different line
- this happens when the string either is a triple quoted string or contains a line-continuation (see [below](#line-continuations-with-backslash))
- `NEWLINE` and `NL` tokens finish on the same line they are started and are considered to take one column


## `NEWLINE` and `NL` tokens

- `NEWLINE` token appears if there's a newline in source code at the end of a logical line of code (for example: a statement)
- `NL` token appears if there's a newline in the source code in the middle of a statement

For example:

	foo = (
	    1
	)

will tokenize as:

	1,0-1,3:            NAME           'foo'          
	1,4-1,5:            EQUAL          '='            
	1,6-1,7:            LPAR           '('            
	1,7-1,8:            NL             '\n'           
	2,4-2,5:            NUMBER         '1'            
	2,5-2,6:            NL             '\n'           
	3,0-3,1:            RPAR           ')'            
	3,1-3,2:            NEWLINE        '\n'             

There's only one statement, so only one `NEWLINE`. The statement is split in multiple 3 physical lines, so there are 2 `NL`.

Also:
- there can be several statements between 2 `NEWLINE`, if using a semicolon (`;`) for example
- blank lines emit `NL` tokens, not `NEWLINE`, since they contain no statement, they are not considered logical lines.
- even if the file didn't end with a LF or CRLF, a `NEWLINE` will be emitted after the last statement (logical line) with width 1, but its `string` will be empty.


## Line-continuations with backslash

In source code, if there's a backslash (`\`) before a newline:

- there is no token for the backslash
- no `NL` or `NEWLINE` is emitted

A backslash before a newline makes the tokenizer react as if the physical source code line was not split.
However, the `start` and `end` attributes of the `TokenInfo` reflect the source numbers.

For example:

	a = \
	    1

will generate tokens:

	NAME   (start line = 1, start column = 0)
	EQUAL  (start line = 1, start column = 2)
	NUMBER (start line = 2, start column = 4)


## Indentation

- one `INDENT` is emitted at start of each logical indented block of code, but not for subsequently indented lines
- an `INDENT` has the width of its number of spaces
- one or more `DEDENT` are emitted at end of block of code
- `DEDENT` is emitted after `NEWLINE` and after blank lines `NL`, it's emitted just at the start of a significant line (not blanks or comments) with a lesser indentation

```
if foo:
    a = (  # INDENT at start of this line
        1  # no INDENT
    )      # no INDENT

pass       # DEDENT at start of line
```

tokenizes as (without the comments):

	1,0-1,2:            NAME           'if'           
	1,3-1,6:            NAME           'foo'          
	1,6-1,7:            COLON          ':'            
	1,7-1,8:            NEWLINE        '\n'           
	2,0-2,4:            INDENT         '    '         
	2,4-2,5:            NAME           'a'            
	2,6-2,7:            EQUAL          '='            
	2,8-2,9:            LPAR           '('            
	2,9-2,10:           NL             '\n'           
	3,8-3,9:            NUMBER         '1'            
	3,9-3,10:           NL             '\n'           
	4,4-4,5:            RPAR           ')'            
	4,5-4,6:            NEWLINE        '\n'           
	5,0-5,1:            NL             '\n'           
	6,0-6,0:            DEDENT         ''             
	6,0-6,4:            NAME           'pass'         
	6,4-6,5:            NEWLINE        '\n'             


## Out of bounds tokens

A source file containing just:

	pass

with no final newline, will tokenize as:

	0,0-0,0:            ENCODING       'utf-8'        
	1,0-1,4:            NAME           'pass'         
	1,4-1,5:            NEWLINE        ''             
	2,0-2,0:            ENDMARKER      ''             

- `ENCODING` starts and ends on line 0, column 0
- `ENDMARKER` start and ends on line after the last line, on column 0


## Test it yourself

Download [tokens-example.py](tokens-example.py) and run:

	python3 -m tokenize tokens-example.py

Add `-e` to print the `exact_type` attribute instead of `type` for `OP`.

# ASTs (Abstract Syntax Trees)

After converting the source text (stream of bytes) to a list of tokens (atoms of code), the tokens are assembled to form an abstract syntax tree (AST, for short).
It's a tree structure mapping the program's structure. For example, all instructions indented after an `if` are sub-nodes contained in an `If` node, not outside of it.

However, an AST only focuses on the program's flow, it discards comments and whitespace.
Grouping parentheses are used to know which token is assembled with which other, but they aren't present in final tree.
Comments and whitespace are ignored tokens in [Python's grammar](https://docs.python.org/3/reference/grammar.html).

- The [`ast` standard module](https://docs.python.org/3/library/ast.html) parses Python text in an AST node
- More documentation on nodes at [Green tree snakes](https://greentreesnakes.readthedocs.io/en/latest/nodes.html)
- The [`astroid` third-party module](https://pylint.pycqa.org/projects/astroid/en/latest/) also parses Python text in custom, more-detailed AST objects
- The [`asttokens` third-party module](https://asttokens.readthedocs.io/) maps AST nodes to syntax tokens

## Whitespace, comments

This source code:

	# foo
	# bar
	print( \
	    1 , 2,
	    3    ,
	)
	# baz

is represented by the same AST as if we used this source code instead:

	print(1,2,3)


## Binary operators

Binary operators take 2 operands, so this:

	1 + 2 + 3 + 4

is represented by the same AST as if we used this source code instead:

	(((1 + 2) + 3) + 4)

Groups are left-to-right because binary plus (`+`) operator is left-associative.

[Precedence](https://docs.python.org/3/reference/expressions.html#operator-precedence) of operators is taken into account:

	1 + 2 * a . b

is:

	(1 + (2 * (a.b)))

### booleans

In Python boolean operators `and` and `or` are a little different.
Arithmetic binary operators are represented by the [`ast.BinOp`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#BinOp) node type which holds exactly 2 operands (`left` and `right`),
but boolean are represented by [`ast.BoolOp`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#BoolOp) node type, which can hold more than 2 operands for a chained operation (as in `foo and bar and baz`).

### comparisons

Also in Python, comparisons can be chained, as in `foo < bar < baz`.
Thus comparisons are represented by the [`ast.Compare`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#Compare) node type which allows chaining.


## `if`/`elif`/`else`

Since an AST focuses on the program's flow, syntactic sugar may be eliminated to avoid different but equivalent ASTs.
Different token sequences might produce the same AST.

This source code:

	if ...:
		...
	elif ...:
		...
	else:
		...

is represented by the same AST as:

	if ...:
		...
	else:
		if ...:
			...
		else:
			...

An `If` node has an `orelse` attribute which is a list of nodes, and there is no `orelif` attribute.
The only way to represent an `elif` in AST terms (first example source)
is to nest the `elif` condition in a virtual `else` (second example source).


## tuples

This source code:

	a, *b = f()
	tup = 1, 2, 3

is represented by the same AST as:

	(a, *b) = f()
	tup = (1, 2, 3)

## dictionary unpacking

### in a dict literal

This snippet:

	{
		foo: bar,
		None: baz,
		**other,
	}

is represented by an [`ast.Dict()`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#Dict) node with 3 `keys`:

- [`ast.Name('foo')`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#Name)
- [`ast.Constant(None)`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#Constant)
- `None`, the value, not a node like `ast.Constant(None)`

and 3 `values`, the last one is `ast.Name('other')`.

In short, a "star-mapping" in a `ast.Dict()` is a regular pair but with a `None` key (and the mapping is the corresponding value).

### in a function call

Similarly to a dict literal ([`ast.Dict`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#Dict)),
a function call ([`ast.Call`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#Call)) can receive key-value pairs and dict unpacking.

Unlike `ast.Dict` which has `keys` and `values` fields, from which one would have to make pairs manually, `ast.Call` has the pairs already formed in `keywords` field. And similarly to `ast.Dict`, when the key part of the pair is `None`, it means there is dictionary unpacking:

	func(foo=1, bar=2, **c)

has 3 pairs in `keywords`, whose keys are:

- [`ast.Name('foo')`](https://greentreesnakes.readthedocs.io/en/latest/nodes.html#Name)
- `ast.Name('bar')`
- `None`
