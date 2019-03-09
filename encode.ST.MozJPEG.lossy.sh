if [ -z "$2" ]
	then
		quality=96
	else
		quality=$2
fi

chromaFmt="yuv420p"
if [ "$chromaFmt" = "yuv420p" ]
	then
		FFpad="crop=trunc(iw/2)*2:trunc(ih/2)*2:0:0"
		sampleSize="-sample 2x2"
	else
		FFpad="crop=iw:ih:0:0"
		sampleSize="-sample 1x1"
fi

filename=$(echo "$1" | sed "s/images\///" | sed "s/\.jpg\|\.jpeg\|\.png\|\.bmp//")

echo "Begin $1"

./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf $FFpad,scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=$chromaFmt -strict -1 "temp/orig_$filename.y4m"
./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf $FFpad,scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=$chromaFmt -strict -1 "temp/orig_$filename.yuv"
width=$(head -1 "temp/orig_$filename.y4m" | grep -oE "\ W[0-9]{1,6}" | cut -b3-)
heigth=$(head -1 "temp/orig_$filename.y4m" | grep -oE "\ H[0-9]{1,6}" | cut -b3-)
totalPixels=$(( $width * $heigth ))

# Gotta play with the encoding parameters, this is pretty much an example
./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf $FFpad,scale=in_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=bgr24 -strict -1 "temp/orig_$filename.png"
./bins/cjpeg -quality $quality $sampleSize -outfile "encoded/$filename.jpeg" "temp/orig_$filename.png"
cp "encoded/$filename.jpeg" "contained/$filename.jpeg"

./bins/ffmpeg -y -hide_banner -loglevel fatal -i "encoded/$filename.jpeg" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=$chromaFmt -strict -1 "temp/enc_$filename.y4m"
./bins/ffmpeg -y -hide_banner -loglevel fatal -i "encoded/$filename.jpeg" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=$chromaFmt -strict -1 "temp/enc_$filename.yuv"

filesize=$(stat --printf="%s" "encoded/$filename.jpeg")
psnr=$(./bins/dump_psnr.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
ssim=$(./bins/dump_ssim.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
msssim=$(./bins/dump_msssim.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
psnrhvs=$(./bins/dump_psnrhvs.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
vmaf=$(./bins/vmafossexec.exe $chromaFmt $width $heigth "temp/orig_$filename.yuv" "temp/enc_$filename.yuv" ./bins/model/vmaf_v0.6.1.pkl | grep "score =" | cut -d" " -f4)
echo "$1: Size=$filesize Pixels=$totalPixels PSNR=$psnr SSIM=$ssim PSNR-HVS-M=$psnrhvs MS-SSIM=$msssim VMAF=$vmaf" > "stats_$filename.txt"

rm "temp/orig_$filename.png"
rm "temp/orig_$filename.y4m"
rm "temp/orig_$filename.yuv"
rm "temp/enc_$filename.y4m"
rm "temp/enc_$filename.yuv"

echo "End $1"
