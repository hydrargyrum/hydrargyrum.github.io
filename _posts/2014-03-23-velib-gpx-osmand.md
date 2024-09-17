---
layout: mine
title: Velib map in OsmAnd
last_modified_at: 2024-09-17T16:55:58+02:00
---

# Display Velib stations position map in OsmAnd #

[OsmAnd](http://osmand.net/) is an Android app that can display maps using OpenStreetMap data while offline.

Here is how to display the positions of Velib stations (no bike availability status, it's offline) in OsmAnd. This article can also work with stations from other cities, but only if those cities are handled by the JCDecaux database.

## TL;DR ##

Download [velib.poi.gpx](velib.poi.gpx) and drop that file on the SD card in `/osmand/tracks/` (manually create the `tracks` folder if it doesn't exist).

## Explainations ##

The nearest format we can use with OsmAnd to display Velib positions is a GPX file.

First, we get the source positions data, Paris.json, from the [JCDecaux website](https://developer.jcdecaux.com/#/opendata/vls?page=static). Then, we can convert the stations info into a "Garmin POI database" (POI means Point Of Interest), because it's a simple format, roughly a 3-column CSV file. We need the [jq](http://stedolan.github.io/jq/) tool to do that.

```
jq -r '.[] | ("\(.longitude),\(.latitude),\(.name)")' < Paris.json > velib.poi.csv
```

This works as long as the station names don't contain any comma or quote character.

Then we convert it into GPX with the [GPSBabel](http://www.gpsbabel.org/) command-line tool:

```
gpsbabel -i garmin_poi -o gpx velib.poi.csv velib.poi.gpx
```

So we get our [velib.poi.gpx](velib.poi.gpx) file. Importing GPX is not possible through the OsmAnd app, the file must be placed on the SD card manually instead, in the the `/osmand/tracks/` folder.

![OsmAnd app screenshot showing a map with POIs being the Velib stations](velib-gpx.jpg)
