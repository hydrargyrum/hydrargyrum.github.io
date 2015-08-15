#!/bin/sh

n=1
for color in '#FF8B00' '#AD5F00' '#633700'
do
	for width in 5 10 20
	do
		height=$((width*2))
		convert -size "$width"x"$height" xc:"$color" base-"$n".png
		n=$((n+1))
	done
done


multiplerandom () {
	n=$1
	shift
	for i in $(seq $n)
        do
                for arg in $@
                do
                        echo $arg
                done
        done | shuf -n $n
}

xtiles=48
ytiles=14

montage -background black -geometry "40x80>+0+0" -tile "${xtiles}x" $(multiplerandom $((xtiles*ytiles)) base-*.png) nylights.png
