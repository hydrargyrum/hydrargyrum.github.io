---
title: Python source rewriting with libCST
last_modified_at: 2023-04-22T08:25:03+02:00
tags: python libcst
accept_comments: true
---

# Python source rewriting with libCST

In this article, we'll cover what is AST/CST, and how to use libCST to rewrite Python source files.

## A bit of theory

### AST
An Abstract Syntax Tree (or AST for short) is a compiler/interpreter's view of a program source code.

#### step 1: tokenization

Usually, source code is first tokenized using a lexical analyzer (lexer for short): the stream of characters is converted into an unstructured stream of atomic tokens. For example, the following line:

```
print(lambda: 3)
```

is tokenized into the following sequence:

```
1,0-1,5:            NAME           'print'        
1,5-1,6:            OP             '('            
1,6-1,12:           NAME           'lambda'       
1,12-1,13:          OP             ':'            
1,14-1,15:          NUMBER         '3'            
1,15-1,16:          OP             ')'            
1,16-1,17:          NEWLINE        '\n'           
```

(The above output can be reproduced with this command: `echo 'print(lambda: 3)' | python3 -m tokenize`)

You can see at this stage even the `lambda` keyword is considered a mere name just like `print`.
In some languages, comments are eliminated when tokenizing since they will not change the outcome of the program, but they are kept in Python.

It's a very low-level form and it's not very convenient to work with it.

For reference, Python's lexical analysis is detailed here: <https://docs.python.org/3/reference/lexical_analysis.html>

#### step 2: parsing

Then, the token stream is parsed using a grammar: it's converted into a tree making sense of the relations between the tokens and mapping the language structures:

```
Module(
   body=[
      Expr(
         value=Call(
            func=Name(id='print', ctx=Load()),
            args=[
               Lambda(
                  args=arguments(
                     posonlyargs=[],
                     args=[],
                     kwonlyargs=[],
                     kw_defaults=[],
                     defaults=[]),
                  body=Constant(value=3))],
            keywords=[]))],
   type_ignores=[])
```

(The above output can be reproduced with this command: `echo 'print(lambda: 3)' | python3 -m ast`)

However, it does not map stuff like variables scopes which could have been done at "compile"-time.

It's sufficiently high-level to be able to easily do structural modifications, then another tool can generate source code back from the AST, but we'd lose comments and whitespace.

For reference, Python's grammar is available here: <https://docs.python.org/3/reference/grammar.html>

### Nodes in an AST

There are a lot of node types, they are divided in 2 main categories plus a few more. The 2 main ones are statement nodes and expression nodes.
The simplest statements generally represent one line of code, and can't be nested, examples:

- `return`
- `pass`
- `from..import`
- assignment (`x=y`)

More complex statements are group of lines and contain other statements, examples:

- `if..elif..else`
- `for..else`
- function definition

Expressions typically represent a value. They are part of statements and can be nested, examples:

- `foo`, `foo.bar`
- `True`, `[42]`, `"a string"`
- `func(param)`
- `foo + 1`

Each of these node types has a dedicated class (for [ast](https://docs.python.org/3/library/ast.html) and [libCST](https://libcst.readthedocs.io/en/latest/nodes.html))

To implement a code rewriter, being aware of every node type is important.

### CST

In short, Concrete Syntax Trees (CST for short) are like ASTs except they keep concrete source data like whitespace and comments.

## Using libCST

### Visitors

Whether we want to simply analyze source code or want to replace parts of the code, when the structured of the source code we want to work with is not completely known in advance, we have to go through the whole tree and search for what we want. It's possible to manually browse the tree with recursive functions.
Most AST/CST libs provide [visitor](https://en.wikipedia.org/wiki/Visitor_pattern) helpers to help with that.
The framework will take care of recursively browsing the syntax tree, and call our code for specific node types.

Let's implement a linter that checks for code which uses the unidiomatic `== None` instead of `is None`. So we're interested by expressions (`x == y` is an expression, not a statement) that are comparisons. There's a dedicated node type for it: [`Comparison`](https://libcst.readthedocs.io/en/latest/nodes.html#libcst.Comparison).

#### Mandatory administrivia

Imports:

```python
#!/usr/bin/env python3
import sys

import libcst
import libcst.matchers as M
from libcst.metadata import PositionProvider, MetadataWrapper
```

#### Subclass CSTVisitor
Now, we subclass `CSTVisitor` (and add some boilerplate if we want to use position info like line numbers):

```python
class NoneLinter(libcst.CSTVisitor):
    METADATA_DEPENDENCIES = (PositionProvider,)
```

#### Override node method

We only need to override method `visit_Comparison` (there's a method `visit_<NodeType>` for each node type).
It will be called automatically when a comparison is encountered during tree traversal by the framework.

```python
    def visit_Comparison(self, node: libcst.Comparison):
```

#### Verifying the tree using simple attributes
But this could be any comparison, so we need to discard those we don't care about:

```python
        if (
            # only accept == and !=
            not isinstance(
                node.comparisons[0].operator, (libcst.Equal, libcst.NotEqual)
            )
            # ignore chained-comparisons like `... == ... == ...`
            or len(node.comparisons) > 1
        ):
            return True
```

We can browse the syntax tree using the attributes documented for [`Comparison`](https://libcst.readthedocs.io/en/latest/nodes.html#libcst.Comparison) and related [`ComparisonTarget`](https://libcst.readthedocs.io/en/latest/nodes.html#libcst.ComparisonTarget).

If we want to discard it, we can return early `True` (`True` meaning to continue to visit the tree recursively).

At this stage, we know it's an equality comparison, but not yet if it's about `None`. Let's check it:

```python
        def is_none(node):
            return isinstance(node, libcst.Name) and node.value == "None"

        if not (
            # ... == None
            is_none(node.comparisons[0].comparator)
            # yoda-style: None == ...
            or is_none(node.left)
        ):
            return True
```

`None` is a simple name like any variable. We check both sides of the comparison operator.

After this, we have found a match! The comparison is an `== None` or a `!= None` (or in the other direction for people preferring [Yoda conditions](https://en.wikipedia.org/wiki/Yoda_conditions)).
We get the line number and print our linter warning message.
And `return True` so the visitor continues to check more nodes recursively.

```python
        pos = self.get_metadata(PositionProvider, node).start
        print(f"{pos.line}: you should use `is None` or `is not None`")
        return True
```

Our visitor class is finished!

#### Running the whole thing

```python
src_text = open(sys.argv[1]).read()
src_tree = MetadataWrapper(libcst.parse_module(src_text))
visitor = NoneLinter()
src_tree.visit(visitor)
```

That's all! We start the tree recursive traversal by calling `visit()` and it will call our overridden methods (`visit_Comparison`) when needed.

Then we can run it:

```shell
% cat file_to_check.py
assert any(
    el == None
    for el in [
        range != None,
        range is None,
        None == range,
    ]
)
% ./none_linter.py file_to_check.py
2: you should use `is None` or `is not None`
4: you should use `is None` or `is not None`
6: you should use `is None` or `is not None`
```

#### Alternate way of verifying the tree: matchers

LibCST has an alternate way of verifying the content of the tree, that can be more convenient sometimes.
The idea is to replace chains of `isinstance(xxx, NodeType) and xxx...` by a comparison between the node and a wildcard object, named "matcher".
A matcher is a node type, where we set some attributes to match exact values, and the unset attributes will match anything.

For example, we can replace first matching part

```python
        if (
            # only accept == and !=
            not isinstance(
                node.comparisons[0].operator, (libcst.Equal, libcst.NotEqual)
            )
            # ignore chained-comparisons like `... == ... == ...`
            or len(node.comparisons) > 1
        ):
            return True
```


… with this:

```python
        # only accept == and != and no chained-comparisons
        if not M.matches(
            node,
            M.Comparison(
                comparisons=[
                    M.ComparisonTarget(operator=M.OneOf(M.Equal(), M.NotEqual()))
                ],
            ),
        ):
            return True
```

`M` is an alias to `libcst.matchers` module. It roughly contains:

- a set of node type classes (named "matchers"), similar to those in the `libcst` module, e.g. `libcst.matchers.Name` is a matcher for node `libcst.Name`
- a few special matchers like `OneOf` or `DoesNotMatch`
- the `matches` function that compares a node to a matcher

We know for sure `node` is a `libcst.Comparison`, we want to check some of its attributes (`comparisons` only in the first part, not `left`), so we instanciate a `libcst.matchers.Comparison` matcher with only the `comparisons` attribute set.
Here, it will match only if there's a single element, and its `operator` sub-node is either `libcst.Equal` or `libcst.NotEqual`.

The second part becomes:

```python
        if not (
            M.matches(
                node,
                M.Comparison(
                    comparisons=[M.ComparisonTarget(comparator=M.Name("None"))],
                ),
            )
            # yoda-style: None == ...
            or M.matches(node, M.Comparison(left=M.Name("None")))
        ):
            return True
```

#### Concluding visitors

The same thing could have been done using standard lib `ast`-module with similar code.
But libCST really shines when it's about rewriting code, not merely analyzing it.

### Transformers

Let's try to transform our linter into a rewriter that replaces `== None` with `is None` instead of simply warning about it.

#### Few things change

A tree transformer is very similar to a tree visitor, the code structure is mostly the same and few things change.
The first difference is that we subclass `CSTTransformer`:

```python
class NoneRewriter(libcst.CSTTransformer):
```

Rewriting takes places when visiting a node but after visiting its children (see [traversal order](https://libcst.readthedocs.io/en/latest/visitors.html#traversal-order)).
And this time we override `leave_Comparison` method which takes 2 parameters, but [only one is really useful](https://libcst.readthedocs.io/en/latest/best_practices.html#prefer-updated-node-when-modifying-trees).

```python
    def leave_Comparison(self, _: libcst.Comparison, node: libcst.Comparison):
```

Most of the checks don't change, except we don't `return True` when we don't want to touch anything, we have to return the node:

```python
        # only accept == and != and no chained-comparisons
        if not M.matches(
            node,
            M.Comparison(
                comparisons=[
                    M.ComparisonTarget(operator=M.OneOf(M.Equal(), M.NotEqual()))
                ],
            ),
        ):
            return node

        if not (
            M.matches(
                node,
                M.Comparison(
                    comparisons=[M.ComparisonTarget(comparator=M.Name("None"))],
                ),
            )
            # yoda-style: None == ...
            or M.matches(node, M.Comparison(left=M.Name("None")))
        ):
            return node
```

#### Generating new content

Now, the interesting part, we will generate a new comparison node:

- using `is` if it was a `==` or `is not` if it was a `!=`
- with the exact same operands as before

Since this is a light change, we can use the `with_changes`/`with_deep_changes` methods which are more convenient.

```python
            TRANSFORMED = {
                libcst.Equal: libcst.Is,
                libcst.NotEqual: libcst.IsNot,
            }

            new_op_type = TRANSFORMED[type(node.comparisons[0].operator)]
            return node.with_deep_changes(node.comparisons[0], operator=new_op_type())
```


#### Writing back code

Still very similar to the linter, and `.code` magically generates source code from the new AST.

```python
with open(sys.argv[1]) as fp:
    src_text = fp.read()
src_tree = MetadataWrapper(libcst.parse_module(src_text))
visitor = NoneRewriter()
new_code = src_tree.visit(visitor).code
with open(sys.argv[1], "w") as fp:
    fp.write(new_code)
```

## Appendix

- [linter source](libcst-linter.py)
- [rewriter source](libcst-rewriter.py)
- [sample file to analyze/rewrite](libcst-file-to-check.py)

