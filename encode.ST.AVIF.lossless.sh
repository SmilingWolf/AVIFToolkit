filename=$(echo "$1" | sed "s/images\///" | sed "s/\.jpg\|\.jpeg\|\.png\|\.bmp//")

echo "Begin $1"

./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=yuv444p -strict -1 "temp/orig_$filename.y4m"
./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -f rawvideo -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=yuv444p -strict -1 "temp/orig_$filename.yuv"
width=$(head -1 "temp/orig_$filename.y4m" | grep -oE "\ W[0-9]{1,6}" | cut -b3-)
heigth=$(head -1 "temp/orig_$filename.y4m" | grep -oE "\ H[0-9]{1,6}" | cut -b3-)
totalPixels=$(( $width * $heigth ))

# Gotta play with the encoding parameters, this is pretty much an example
./bins/aomenc -v --cpu-used=0 --end-usage=q --lossless=1 --full-still-picture-hdr --color-primaries=bt709 --transfer-characteristics=bt709 --matrix-coefficients=bt709 --ivf -o "encoded/$filename.ivf" "temp/orig_$filename.y4m" 2> /dev/null
./bins/MP4Box -add-image "encoded/$filename.ivf:primary" -ab avif -ab miaf -new "contained/$filename.avif" 2> /dev/null

./bins/ffmpeg -y -hide_banner -loglevel fatal -i "encoded/$filename.ivf" -strict -1 "temp/enc_$filename.y4m"
./bins/ffmpeg -y -hide_banner -loglevel fatal -i "encoded/$filename.ivf" -f rawvideo -strict -1  "temp/enc_$filename.yuv"

filesize=$(stat --printf="%s" "encoded/$filename.ivf")
echo "$1: Size=$filesize Pixels=$totalPixels" > "stats_$filename.txt"

rm "temp/orig_$filename.y4m"
rm "temp/orig_$filename.yuv"
rm "temp/enc_$filename.y4m"
rm "temp/enc_$filename.yuv"

echo "End $1"
