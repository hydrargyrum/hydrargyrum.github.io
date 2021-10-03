---
layout: mine
title: hibp - Have-I-Been-Pwned? tester
last_modified_at: 2020-01-05T10:49:06+01:00
---

# `hibp` - Have-I-Been-Pwned? tester

`hibp` is a command to check passwords against the [haveibeenpwned password database](https://haveibeenpwned.com/Passwords).

> Pwned Passwords are 555,278,657 real world passwords previously exposed in data breaches. This exposure makes them unsuitable for ongoing use as they're at much greater risk of being used to take over other accounts.

# Example

	% hibp
	Password to check on HIBP:            <-- password input is hidden but "hello" was typed in this example
	Password has been found 253581 times on HIBP :(

# Security

`hibp` tool does **NOT** send the checked passwords to haveibeenpwned site so you do not leak your passwords when using `hibp`.
Details on how this achieved can be found on [haveibeenpwned author blog](https://www.troyhunt.com/ive-just-launched-pwned-passwords-version-2/#cloudflareprivacyandkanonymity) and in `hibp` tool [source code](https://gitlab.com/hydrargyrum/attic/blob/master/hibp/hibp).

Basically, `hibp` fetches password hashes from haveibeenpwned site and checks locally if the password is there, so the password isn't sent.

# Download

[Project repository](https://gitlab.com/hydrargyrum/attic/tree/master/hibp)
