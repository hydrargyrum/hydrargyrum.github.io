---
layout: mine
title: Why HAR format is clumsy
last_modified_at: 2020-07-14T22:49:20+02:00
tags: har json
accept_comments: true
---

# Why HAR format is clumsy

[HTTP Archive format](https://en.wikipedia.org/wiki/HAR_(file_format)), or HAR is a JSON-backed format for saving HTTP requests and responses.
It can be produced by web browsers or scrapers, and be parsed by browsers, analysers, tools.

Unfortunately, the format is not well-defined. A [draft](https://w3c.github.io/web-performance/specs/HAR/Overview.html) was started on the W3C in 2012 but was abandoned. So, any tool can do whatever they want, it may or may not work with other tools.

## Binary data response

Since it can record any request or response, it also has to be able to handle binary data.
For example, a response can be a PNG file, so contain arbitrary bytes.

HAR is backed by [JSON](https://www.json.org), but JSON is not meant for holding binary data, only text.
JSON considers Unicode strings, not byte strings, so it's not directly possible to store verbatim byte-per-byte response.
HAR addressed this problem by supporting the content to be expressed as [base-64](https://en.wikipedia.org/wiki/Base64), so a byte-string can be encoded with it, and the decoder will know it gets the original byte-string when seeing `"encoding": "base64"`.

## No binary data request support

HTTP supports binary data in requests too, for example for uploading a binary file.
However, for some reason, HAR designers did not bother to handle that at all.

HAR has a `postData` object, with a `text` field, which is a Unicode string (HAR is backed by JSON).

If a client POSTed this *single byte*:

	E9

... the HAR should logically contain:

	...
	"text": "\u00e9",
	...

What if the client POSTs this *text*:

	é

... encoded as UTF-8, this translates to those hex bytes:

	C3 A9

With previous logic, the HAR would likely contain:

	...
	"text": "\u00c3\u00a9",
	...

... but that defeats the use of name `text`, and most HAR readers will misinterpret it.
Instead of seeing 2 bytes to decode as UTF-8, they will see 2 Unicode code points, thus:

	Ã©

For example, when POSTing that *`é`* text, Firefox would save the following HAR (excerpt):

	...
	"text": "\u00e9",
	...

... which is then ambiguous with the first example.

HAR gives no solution for this, because there is no way to encode as base-64, or to distinguish "this is a Unicode string" vs "these are actually bytes of a byte string (to encode as [Latin-1](https://en.wikipedia.org/wiki/ISO/IEC_8859-1))".

## Ill-implementations

The HAR standard draft defines many fields to be optional. However, Firefox and Chromium can't load an HAR that only defines the mandatory fields.

For example:
- the `pages` object is marked optional, but it won't be imported by a browser if it's effectively missing, or does not contain `id`, `pageTimings` or `startedDateTime` keys
- `request` and `response` objects must have a `bodySize` and a `headersSize` even if they're `-1` (though deemed optional, the keys are mandatory by some readers)
- `timings` isn't optional as mentioned, and it should contain `send`, `wait` and `receive` but they can be `-1`

## Patch-up incremental logging

JSON serializes objects, lists, strings, numbers, booleans, and `null`. Lists and objects have an opening delimiter (`[` and `{`) and a closing delimiter (`]` and `}`). This makes it hard to serialize data into a byte stream, and then later insert new elements in the data without having to re-serialize the entire stuff, because one would have to know where in the stream should the new data be located.

Being backed by JSON, HAR has the same limitation, even though it would be useful for an HTTP client to append new requests/responses into the HAR as HTTP requests are made.


```
{"log": {"entries": [...], "version": {...}, "creator": {...}, ...}}
                       ↑└─────────────────────┬────────────────────┘
                       └──────────┐           │
                                  │           │
                                  │           │
new entry should be inserted here ╵           │
                                              │
                   all that must be "shifted" ╵
```

Appending a new entry would require to find the end of the `entries` array in the byte stream, save all bytes after it, write the new entry, and then write the overwritten bytes, which is both tedious and inefficient.
Rewriting the whole object is not tedious but plain inefficient as it is an illustration of [Schlemiel the painter's algorithm](https://en.wikipedia.org/wiki/Joel_Spolsky#Schlemiel_the_Painter's_algorithm).

It's however possible to achieve, if using JSON compact representation (no spaces or newlines outside of string contents), by making sure the `entries` list is the last key of the last object.
That way, appending a new entry requires rewinding before the stream end, write just the new entry, and write the overwritten bytes, which, luckily, are known and fixed: `]}}`

```
{"log":{"version":{...},"creator":{...},...,"entries":[...]}}
                                                         ↑└┬┘
new entry should be inserted here ───────────────────────┘ │
                                                           │
                               only that must be "shifted" ╵
```
