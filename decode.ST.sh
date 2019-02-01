filename=$(echo "$1" | sed "s/contained\///" | sed "s/\.avif//")

echo "Begin $1"

./bins/MP4Box.exe -dump-item 1:path="temp/$filename.obu" "$1" 2> /dev/null
./bins/aomdec.exe -o "temp/$filename.y4m" "temp/$filename.obu" 2> /dev/null
./bins/ffmpeg.exe -y -hide_banner -loglevel fatal -i "temp/$filename.y4m" -vf scale=in_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=rgb24 "decoded/$filename.png"

rm "temp/$filename.obu"
rm "temp/$filename.y4m"

echo "End $1"
