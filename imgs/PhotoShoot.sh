#!/bin/bash

HEIGHT=885
WIDTH=1760
X=15
Y=172

mkdir new

for file in "/Applications/World of Warcraft/_retail_/Screenshots/"*.{png,jpg}; do
	[ -f "$file" ] || continue
	outfile="MogShare_"$(basename "$file")

	sips --cropToHeightWidth $HEIGHT $WIDTH \
	     --cropOffset $Y $X \
	     "$file" \
	     --out ./new/"$outfile"
done