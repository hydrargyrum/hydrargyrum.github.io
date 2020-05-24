---
layout: mine
title: Firefox config tweaks
last_modified_at: 2018-05-05T11:07:57+02:00
tags: firefox mozilla configuration
accept_comments: true
---

# Firefox regressions

Once, Mozilla had a good product, Firefox (and the Mozilla suite before it), which was different from other browsers, innovative. Once, Mozilla were leaders, not followers.

Then, Mozilla decided copying Google Chrome was the right thing to do. It was all downhill from there.

# How to revert some regressions

Fortunately, some of the changes can be reverted in the `about:config` page. To access it, type `about:config` in the address bar and press enter. The page contains a list of configuration keys and their values. The values can be changed from this page.

Alternatively, they can be changed by editing the `prefs.js` file in the Firefox profile folder.

## Address bar tweaks

To do like Chrome, Firefox reduces readability of the URL by dimming the font color on the URL path. To make it more readable, set `browser.urlbar.formatting.enabled = false`.

Firefox hides the `http://` scheme on URLs in the address bar, but not for `https://`. And the URL copied to clipboard is inconsistent because `http://` is copied, despite not being selected. To show the protocol as should be, set `browser.urlbar.trimURLs = false`.

## Preferences

~~In its attempt to build an uninteresting clone of Chrome, Mozilla dropped its better-organized preferences page and copied the messy, all-in-one preferences page from Chrome. To use the old preferences page, set `browser.preferences.useOldOrganization = true`.~~ (Can't do it anymore as of Firefox 57)

# Disable other useless stuff

## Context menu bloating

Despite many screenshoting apps do already exist, Mozilla has decided to bloat Firefox even more by adding its own app builtin into Firefox. It adds yet another entry in the context menu. To disable it, set `extensions.screenshots.disabled = true`, it will also disable the related toolbar button.

## Non-free Pocket service

To disable the use of the Pocket extension, which can only use the non-free and noninteroperable Pocket service, set `extensions.pocket.enabled = false`. This also disables the toolbar button. If the feature is really useful, open-source equivalents like [Wallabag](https://www.wallabag.org/) can be used.
