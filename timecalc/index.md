---
layout: mine
title: timecalc - calculator of dates and durations
last_modified_at: 2018-12-30T22:21:20+01:00
---

# timecalc

A calculator of dates and durations.

`timecalc` can make various calculations like adding durations to dates and times, computing the duration difference between two dates and times, etc. It takes textual expressions.

```
% timecalc "2015/01/01 + 1 day, 2 hours"
2015/01/02 02:00
```

Expressions can be given either on the command-line or in a Read-Eval-Print-Loop, if no argument is given.

# Features

* add/subtract durations together to get new durations
* multiply/divide durations by numbers to get new durations
* add/subtract durations to a datetime to get a new datetime
* subtract 2 datetimes to get a duration
* combine all of the above

## Limitations

* does not handle yet timezones
* does not handle leap seconds

# Download #

[Project repository](https://github.com/hydrargyrum/timecalc)

timecalc uses Python 3 and is licensed under the [WTFPLv2](../wtfpl).

It depends optionally on [dateutil](https://labix.org/python-dateutil).
