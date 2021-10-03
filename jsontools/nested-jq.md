---
layout: mine
---

# nested-jq

A tool to make [`jq`](https://stedolan.github.io/jq/) parse nested JSON data.

Sometimes, you encounter extremely stupid JSON files, because they contain strings, themselves containing JSON encoded data, like this:

```
{
  "foo": "{\"bar\": \"baz\"}"
}
```

Of course, good JSON would have been:

```
{
  "foo": {
    "bar": "baz"
  }
}
```

But you can't always get good data. Sometimes, there are even multiple levels of such encoding.

By default, `jq` will interpret the `foo` value as a string. `nested-jq` is used to pipe the data to `jq` again so you can pass another filter.

For example:

```
nested-jq .foo .bar badfile.json
```

will get the value of the `bar` key nested in the JSON data contained in the `foo` key in the outer JSON.

# Download #

[Project repository](https://gitlab.com/hydrargyrum/attic/tree/master/nested-jq)

It is licensed under the [WTFPLv2](../wtfpl).
