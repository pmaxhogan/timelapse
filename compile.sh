#!/bin/bash
mkdir -p before timelapses

get_duration (){
    ffprobe -i "$1" -sexagesimal -show_entries format=duration -v quiet -of csv=p=0
}

speedup=360
fps=60

drawopts="drawbox=x=5:y=5:w=520:h=80:color=black@0.5:t=fill, drawtext=text='%{pts\\:hms}':fontcolor=white:fontsize=70:x=4:y=15"
vopts="setpts=PTS/$speedup"

encoder="libx264"
# encoder="h264_nvenc"
encoderopts="-preset fast -crf 23"
# encoderopts="-preset medium"

get_size () {
    num=$(stat -c%s "$1")
    echo $(numfmt --to=iec --suffix=B --padding=7 $num)
}

for infile in before/*.mkv; do
    file=$(basename "$infile" .mkv)
    tmpfile=$(mktemp --suffix=.mkv)
    outfile="timelapses/$file".mp4

    echo '⌛' $infile $(get_duration "$infile") '('$(get_size "$infile")')' '⏩' $outfile

    cp -v "$infile" "$tmpfile"

    ffmpeg -hide_banner -loglevel warning -stats -n\
	 -i "$tmpfile"\
	 -vf "$drawopts,$vopts"\
	 -an -r "$fps" -c:v "$encoder" \
	 $encoderopts "$outfile"

    rm -f "$tmpfile"

    echo '✅' $(get_duration "$infile") '('$(get_size "$infile")')' '⏩' $(get_duration "$outfile") '('$(get_size "$outfile")')'
    echo
done
