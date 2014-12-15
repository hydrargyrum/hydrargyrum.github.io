---
layout: mine
title: Variables and quoting in shell
---

# Quoting vars with spaces in shell

## Why? (without quoting)

In shell, expanding a variable `$var` can expand to multiple arguments if the variable contains spaces. If the variable is empty, it will even not count as an argument at all.
The shell will split the variable content at spaces and produce one argument for each word resulting of the split. This is regardless of how the variable was declared or where it comes from.

Let's introduce a function that will be useful to demonstrate the splitting:

```
print_args () {
	n=1
	for arg; do
		echo "$n: $arg"
		n=$((n+1))
	done
}
```


```
var="foo bar"
print_args before $var after
```


will yield

```
1: before
2: foo
3: bar
4: after
```

print_args received 4 arguments, but it looked like we passed 3. This is because `$var` expands to as many arguments as `$var` contains words. To understand this behavior, one can think of it as "`$var` contains 2 arguments". Now, if `$var` is empty:

```
var=
print_args before $var after
```

we get:

```
1: before
2: after
```

print_args received only 2 arguments! `$var` is empty, this is interpreted as "`$var` contains no arguments". Imagine the disaster if the `$archive` variable was empty when running this line:

```
tar cf $archive file1.c file2.c
```

`$archive` would expand to 0 arguments, file1.c would be the first argument after "cf", thus file1.c would be overwritten by a tar file containing only file2.c!

## Testing the quotes

To force packing as an argument in all cases, quotes are needed.

```
var="foo bar"
print_args before "$var" after
```

```
1: before
2: foo bar
3: after
```

The 2 words are in one argument only, and

```
var=
print_args before "$var" after
```

yields

```
1: before
2: 
3: after
```

so we get an argument containing `$var`, which is empty.

Quotes are really interpreted by the shell to disable argument-splitting when encountering spaces. It's not even needed to have a quote at the beginning of an argument

```
var="foo bar"
print_args "before $var" after
```

yields

```
1: before foo bar
2: after
```


Now, consider:

```
print_args "before "$var after
```

It will yield:

```
1: before foo
2: bar
3: after
```


This because `$var` isn't within quotes, so it's split in 2 arguments. Also, the first word contained in `$var` is stuck to the argument before, because the space is quoted, so `before` and `foo` are one only arg, with a space in between.
It would be the same output if we did:

```
print_args before" "$var after
```

Or even:

```
print_args "before"" "$var after
```

But

```
print_args "before"" ""$var" after
```

will yield

```
1: before foo bar
2: after
```

## An exception: `$@`

The only exception to this quoting is the magic variable `$@`, which represents all the arguments that were passed to current function or script. `$@` and `$*` are 2 magic variables containing the arguments passed to current function/script.

While `$*` retains the ordinary behavior regarding argument-merging when used inside quotes, `$@` has a unique behavior that keeps the arguments as-are when used within quotes. If `$@` is passed in quotes, the arguments are not merged into only one argument, but are kept as as many arguments as were passed.

```
verify () {
	print_args "$*"
}

verify before "foo bar" after
```

yields:

```
1: before foo bar after
```

All arguments are in `$*`, and are merged together due to the quoting.
Now, with:

```
verify () {
	print_args "$@"
}

verify before "foo bar" after
```

yields

```
1: before
2: foo bar
3: after
```

This behavior does not follow the rules of quoting we've previously seen, this is due to the use of "$@", which kept the original arguments of `verify` untouched.

## Reminder

| shell syntax | real arguments passed |
|----|----|
| before $var after | before/foo/bar/after |
| before "$var" after | before/foo bar/after |
| "before $var after" | before foo bar after |
| before" $var "after | before foo bar after |
| before" "$var" "after | before foo/bar after |
