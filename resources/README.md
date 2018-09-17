for mng:

`convert -background Transparent -dispose Previous -resize 36x36 -filter Lanczos frame*.svg output.mng`

for sprite sheet:

`convert -background none -resize 1116x36 -filter Lanczos sprite_60fps.svg playpause.png`