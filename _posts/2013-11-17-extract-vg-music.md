---
layout: mine
title: Extract music from some video games
last_modified_at: 2017-08-04T22:35:36+02:00
tags: file_formats
accept_comments: true
---

# Extract music from some video games #

## VVVVVV ##

The music files are in OGG format inside a custom-format pack in data/vvvvvvmusic.vvv. The pack is not compressed, so an [easy solution](https://bitbucket.org/haypo/hachoir/wiki/hachoir-subfile) to extract is:

`cd <vvvvvv_folder>; hachoir-subfile --category=container data/vvvvvvmusic.vvv .`

This trick for extracting also works for other games such as Max Payne and Red Faction.

Filenames are:

```
0levelcomplete.ogg
1pushingonwards.ogg
2positiveforce.ogg
3potentialforanything.ogg
4passionforexploring.ogg
5intermission.ogg
6presentingvvvvvv.ogg
7gamecomplete.ogg
8predestinedfate.ogg
9positiveforcereversed.ogg
10popularpotpourri.ogg
11pipedream.ogg
12pressurecooker.ogg
13pacedenergy.ogg
14piercingthesky.ogg
```

### Quick analysis of the vvv format ###

- the vvvvvvmusic.vvv file contains a file table, giving info about the sub-files. After the file table, are the contents of all contained files concatenated
- the file table consists of 128 entries, each 60 bytes long
- each file table entry contains a 48 bytes file path, then 4 bytes whose role is unknown, then a 4 bytes integer (little-endian) representing the length of the file content, and finally 4 more unknown bytes

```
struct file_entry {
	char path[48];
	char reserved1[4];
	int32_t length;
	char reserved2[4];
};

typedef struct file_entry file_table[128];

const int first_file_data_offset = sizeof(file_table);
```

## Deus Ex ##

The music files are in .umx files in the "Music" folder. The music are [sound module files](https://en.wikipedia.org/wiki/Module_file), specifically Impulse Tracker format. Many programs, like VLC or [xmp](http://xmp.sourceforge.net/) can read them.
However, there are multiple tracks in each file.
The sound modules are divided in chunks (called "orders"), each chunk containing instructions for playing the music. There is a special type of instructions, which is "jump to this other order". This type of instruction makes it possible to make a music loop, by telling the music player to go to the beginning of the track again. With a trick, it's also possible to store several music tracks in the same file, by having carefully-made order arrangements.

For example, the file `BatteryPark_Music.umx` contains all music tracks that can be played in the Battery Park area of the game. This includes normal game music, combat music, and game over music.

At order 0, the normal game music starts. The last instruction from order 0 is a "jump" instruction that goes to order 6. The normal music then continues until end of order 17. The last instruction of order 17 is a "jump" to order 0, thus making a loop. Order 1 is not reached by the flow of instructions of normal game music. At order 1, starts the game over music, and goes in the same fashion as for the normal game music, with a loop (1, 45, 46, 47, 1, 45, etc.). At order 3, is the combat music, that is also a loop. This trick allows to have several loops that always start at fixed orders (always 0, 1, 3 and 4) in each file, and never overlap.

![Order graph](dex-battery.png)

To play them with xmp:

* `xmp -s 0 Music/BatteryPark_Music.umx`
* `xmp -s 1 Music/BatteryPark_Music.umx`
* `xmp -s 3 Music/BatteryPark_Music.umx`
* `xmp -s 4 Music/BatteryPark_Music.umx`

