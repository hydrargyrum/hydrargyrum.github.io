---
layout: mine
title: Extract music from some video games
last_modified_at: 2021-01-29T09:02:18+01:00
tags: file_formats
accept_comments: true
---

# Extract music from some video games (redux)

## DUSK

[DUSK](https://en.wikipedia.org/wiki/DUSK_(video_game)) is a 2018 fast-FPS.
Its [OST](https://andrewhulshult.bandcamp.com/album/dusk-original-game-soundtrack) is available but listening from there is a poor choice:
- some tracks are outright missing!
	- `E1M2_Amb` for example
- some tracks are combined together in a single one, which is nothing but disrespect to the music, and it prevents from looping the tracks...
	- for example, "Ashes to Ashes, Dusk to Dusk" concatenates 2 different tracks with very different style
- if you own the game, you already own the music contained in it, it the form meant to be listened

DUSK is a [Unity](https://en.wikipedia.org/wiki/Unity_(game_engine)) game, whose data can be extracted with various tools, for example with [united-ost](https://gitlab.com/hydrargyrum/united-ost) (based on the [UnityPy](https://pypi.org/project/UnityPy/) library)

## Other Unity games

Many games use Unity and their music can be extracted in the same way, [Tetrobot](https://www.mobygames.com/game/tetrobot-and-co), [Construct](https://www.mobygames.com/game/construct-escape-the-system), you name them.

