---
layout: mine
title: Simulating HiDPI
last_modified_at: 2020-05-18T22:03:38+02:00
tags: hidpi
---

# HiDPI

As of 2020, HiDPI (High Dots Per Inch) screens are becoming more common, sporting higher resolutions (like 3840x2160) on desktop (or mobile) screen size.
With 4 times as much pixels on the same surface, those screens have a finer-grained display.

On the surface, it's a good thing, allowing much better display, but in practice, many apps are buggy and are not prepared for high-density displays.
The root cause is that most apps have hardcoded pixel sizes for its text and widgets. App developers chose pixel sizes that looked fine on a display from 15 inches to 24 inches, all having a 1920x1080 (or smaller) resolution, but are unfit for higher resolutions.
Why do they look bad? The screen physical dimensions remains the same, but considering 1920x1080 is only a quarter of a high-density screen, imagine an app packed in the lower-left quadrant of the screen, with every area in the app being 4 times smaller, because this is the pixel size the app chose.

When developing an app, one must of course be wary to avoid hardcoding pixel dimensions, or at least take into consideration the DPI.

# DPI

Since the physical screen size is the same for an old screen and a modern, 4K screen, the app's window and text physical size should be the same physically.
Since the pixel resolution is doubled, it means doubling each pixel dimension.

It's not just higher resolution, because the screen physical size isn't bigger, so the pixel density is higher too.
So we'll then let the app know the screen size to resolution ratio using DPI information.
For example, a 23 inches screen with a 1920x1080 resolution will have 96 DPI. The same screen but with a 3840x2160 resolution will have 192 DPI.

# Simulating HiDPI

When developing, we might not have a high-density monitor at hand, but fortunately we can test with Xephyr!

# Determining resolution and density

First, we can find what our physical monitor is and what our X server uses:

	% xdpyinfo | grep -B2 resolution
	screen #0:
	  dimensions:    1920x1080 pixels (508x286 millimeters)
	  resolution:    96x96 dots per inch

96 is a standard, non-high density, DPI value.
508x286 millimeters is a screen with a 22.9 inches diagonal.

# Running Xephyr

Here, we will use [`xephyr-run-cmd`](https://gitlab.com/hydrargyrum/attic/blob/master/xephyr-run-cmd/xephyr-run-cmd) which allows us to run a Xephyr server, run a command in it and take care of shutting down Xephyr at the end.

## Xephyr server with the same dimensions as the main X server

	xephyr-run-cmd -screen 1920x1080 -dpi 96 -- xterm

## Xephyr server with "misconfigured" DPI

Bigger resolution, but as if it were a bigger screen (1 meter wide!):

	xephyr-run-cmd -screen 3840x2160 -dpi 96 -- xterm

On our physical screen we can only see the Xephyr window is much bigger.
The windows and text in Xephyr will have the same pixel size as outside Xephyr, but the screen estate is much bigger.
On a HiDPI screen, the content would be unreadable because everything would be packed on a small screen instead of the big Xephyr window.

## Xephyr server with screen dimensions

Xephyr is informed of the screen size (508x286mm) and the high resolution (3840x2160).

	xephyr-run-cmd -screen 3840/508x2160/286 -- xterm

The Xephyr window will still be much bigger than our screen. But given the emulated screen dimensions, Xephyr will compute the appropriate DPI: 192.
`xterm` doesn't care about the DPI, but it's a bug. Most Qt or GTK apps will resize their text accordingly to the high DPI, because the underlying framework interprets it, if the app doesn't force the text size.

However, there might still be glitches as apps might hardcode pixel size which isn't appropriate for a 3840x2160 resolution with 192 DPI.

# Running useful stuff in Xephyr

## Window manager
In the previous commands, we just run `xterm`. We don't even have a window manager, which may be hard to run our app.
Rather than running a full-fledged desktop for this testing session, using a window manager like `openbox` or `fluxbox` would be best, or `xfwm4`.

## Preview on real screen size

Within the Xephyr session, run:

	import -window root -resize 1920x1080 screenshot.png

This will save `screenshot.png` showing the 3840x2160 resolution shrunk to fit on your classical monitor using 1920x1080. Apps not supporting HiDPI (like `xterm`!) will be unreadable.

Let's test with X messages:

	hd /dev/urandom | head -20 > sample.txt
	xephyr-run-cmd -screen 3840/508x2160/286 -- bash -c "openbox & sleep 1 ; xmessage -file sample.txt & sleep 5 ; import -window root -resize 1920x1080 screenshot-xmessage.png"
	xephyr-run-cmd -screen 3840/508x2160/286 -- bash -c "openbox & sleep 1 ; zenity --text-info --filename sample.txt & sleep 5 ; import -window root -resize 1920x1080 screenshot-zenity.png"
	GDK_SCALE=2 xephyr-run-cmd -screen 3840/508x2160/286 -- bash -c "openbox & sleep 1 ; zenity --text-info --filename sample.txt & sleep 5 ; import -window root -resize 1920x1080 screenshot-zenity2.png"

* `xmessage` ignores density and is unreadable.
* unless passing `GDK_SCALE=2` to double the size, `zenity` is also unreadable

`scite`:

	xephyr-run-cmd -screen 3840/508x2160/286 -- bash -c "openbox & scite sample.txt & sleep 5 ; import -window root -resize 1920x1080 screenshot-scite.png"
	GDK_SCALE=2 xephyr-run-cmd -screen 3840/508x2160/286 -- bash -c "openbox & scite sample.txt & sleep 5 ; import -window root -resize 1920x1080 screenshot-scite2.png"

* as a GTK app, `scite` also is affected by `GDK_SCALE=2`.

Qt:

	xephyr-run-cmd -screen 3840/508x2160/286 -- bash -c "openbox & qterminal -e more sample.txt sample.txt & sleep 5 ; import -window root -resize 1920x1080 screenshot-qterminal.png"

* Qt apps like `qterminal` react well to density and do not need additional configuration

