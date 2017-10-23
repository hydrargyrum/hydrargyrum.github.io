---
layout: mine
---


Quick-reference of Semantic Versioning 2.0.0
============================================

This is a short reference of [Semantic Versioning](http://semver.org/).

 Releases
==========

  X.Y.Z       (Example: 1.23.4)

  * always 3 components, dot-separated
  * only digits, no leading zeroes

Core of semantic versioning:
  * X: Major version: for incompatible changes to "public API"
  * Y: Minor version: for backward-compatible new features to "public API"
  * Z: Patch version: for backward-compatible bugfixes (nothing in public API)
  * _Exception_: Major version 0 does not need to respect those rules

Ordering
  * compare numerically: 1.1.0 < 1.9.0 < 1.10.0
  * compare each component left-to-right, until components are unequal:
    0.3.1 < 0.4.0 < 1.3.0 < 2.0.0 < 2.0.1
  * if all components are equal, see next section

 Pre-releases
==============

  Examples: 1.23.4-rc1, 1.23.4-alpha.2

A pre-release is a hypen-suffix to an ordinary release, but is always
inferior to the related release.

  * unlimited number of components, dot-separated
  * alphanumeric and hyphen: [a-zA-Z0-9-]
  * no leading zeroes if a component is fully numeric

Ordering
  * always inferior to the release: 1.1.1-foo < 1.1.1
  * as with normal releases, compare left-to-right
  * compare numerically if two components are numbers: 1.1.1-2 < 1.1.1-10
  * compare in ASCII if two components are not numbers: 1.1.1-aa < 1.1.1-bb
  * if only one is a number, it is inferior: 1.1.1-42 < 1.1.1-aa
  * less components is inferior: 1.1.1-2 < 1.1.1-2.3

 Build metadata
================

  Examples: 1.23.4-alpha+foo, 1.23.4+foo

Build metadata is a plus-suffix to pre-release info (if present), or to
normal release info (else), and is ignored in version ordering.

  * unlimited number of components, dot-separated
  * alphanumeric and hyphen: [a-zA-Z0-9-]
