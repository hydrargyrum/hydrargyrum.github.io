#!/bin/sh

convert -size 16x16 xc:black -background white -rotate 45 +repage -crop 50%x50% +repage corner-%d.png
montage -geometry +0+0 corner-2.png corner-0.png corner-3.png corner-1.png cornerpattern.png
convert -size 1920x1080 tile:cornerpattern.png bw-tile.png
