---
layout: mine
title: SIT-Tagger
---

# SIT-Tagger #

SIT-Tagger is an image browser/viewer where folders full of images can be browsed, and tags be set to pictures (and saves those tags in a database file). Then, SIT-Tagger can browse all pictures that were associated to particular tags, instead of only browsing by path.

## Screenshots ##



## Command-line options ##

The database to use can be changed with "-d". The prefix to images can be set with "-p". This allows to have a relocatable dir of pictures, and not have the tags become associated with dangling image paths.

Here's a sample with pictures stored on an external drive (and the database also stored there):

`imagetagger -d /media/sdb1/pictures/tags.db -p /media/sdb1/pictures`

## Known issues ##

The tag database is a Python dict serialized with the basic [pickle](http://docs.python.org/2/library/pickle.html) format, which is not very efficient nor a proper abstraction. It's planned to change to another database format, like SQLite.

## Download ##

Tagger requires Python, and either PyQt4 or PySide4.

[Project repository](https://github.com/hydrargyrum/sit-tagger)
