---
layout: mine
---

# rest2web plugins

2 rest2web plugins

## rest2web ##

[rest2web](http://www.voidspace.org.uk/python/rest2web/) is a tool to write a website with a simple markup language ([reStructuredText](http://docutils.sourceforge.net/rst.html)). The tool takes text files and generates HTML files. rest2web's features can be extended thanks to plugins.

## RSS ##

RSS is a plugin to output [RSS](http://en.wikipedia.org/wiki/RSS) files describing changes in your pages.
With minimal configuration, it just produce a new RSS file when your page changes, without describing changes. A changelog can be written in the restindex, and this RSS plugin will use it (if present) to generate more more complete RSS files.
It can update multiple RSS files per page (for example, a RSS file describing changes of only one page, and a RSS aggregating changes of multiple pages)

More documentation can be found in rss.py.

### Minimal config ###

In the [restindex](http://www.voidspace.org.uk/python/rest2web/restindex.html):

```
  uservalues
  	rss: yes
  	rss_index: RELATIVE_PATH_TO_DESTINATION_RSS_FILES
  /uservalues
```

In r2w.ini:

```
[uservalues]
rss_link=Absolute URL of the root where everything will be uploaded (RSS needs this)
rss_title=Title to put in the RSS feeds
rss_description: Description to put in the RSS feeds
```

### With a changelog ###

In the restindex:

```
  uservalues
  	rss: yes
  	rss_index: index.rss, ../anotherfile.rss
  	rss_changelog:
  		2008-08-31 Any text you want describing the change with this date
  		2008-08-30T23:59:59 You can set the time too, respect this format though
  /uservalues
```



## AutoCopier ##

AutoCopier is a plugin that auto-detects all the files linked to in the page, and copies them in the destination directory. It avoids having to declare manually (and possibly forget) every file to copy in the restindex header.

Before:

```
  restindex
    file: myfile.zip
  /restindex
  
  `Download <myfile.zip>`_
```

After:

```
  restindex
    plugins: autocopier
  /restindex
  
  `Download <myfile.zip>`_

```

More documentation can be found in autocopier.py.

