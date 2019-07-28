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
	else
		FFpad="crop=iw:ih:0:0"
fi

filename=$(echo "$1" | sed "s/images\///" | sed "s/\.jpg\|\.jpeg\|\.png\|\.bmp//")

echo "Begin $1"

./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf $FFpad,scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=$chromaFmt -strict -1 "temp/orig_$filename.y4m"
./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf $FFpad,scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=$chromaFmt -strict -1 "temp/orig_$filename.yuv"
./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf $FFpad,format=bgr24 -strict -1 "temp/orig_$filename.png"
width=$(head -1 "temp/orig_$filename.y4m" | grep -oE "\ W[0-9]{1,6}" | cut -b3-)
heigth=$(head -1 "temp/orig_$filename.y4m" | grep -oE "\ H[0-9]{1,6}" | cut -b3-)
totalPixels=$(( $width * $heigth ))

# Gotta play with the encoding parameters, this is pretty much an example
./bins/cwebp -m 6 -q $quality -o "encoded/$filename.webp" "temp/orig_$filename.png" 2> /dev/null
cp "encoded/$filename.webp" "contained/$filename.webp"

./bins/ffmpeg -y -hide_banner -loglevel fatal -i "encoded/$filename.webp" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=$chromaFmt -strict -1 "temp/enc_$filename.y4m"
./bins/ffmpeg -y -hide_banner -loglevel fatal -i "encoded/$filename.webp" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=$chromaFmt -strict -1 "temp/enc_$filename.yuv"
./bins/ffmpeg -y -hide_banner -loglevel fatal -i "encoded/$filename.webp" -vf scale=flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=bgr24 -strict -1 "temp/enc_$filename.png"

filesize=$(stat --printf="%s" "encoded/$filename.webp")
psnr=$(./bins/dump_psnr.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
ssim=$(./bins/dump_ssim.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
msssim=$(./bins/dump_msssim.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
psnrhvs=$(./bins/dump_psnrhvs.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
vmaf=$(./bins/vmafossexec.exe $chromaFmt $width $heigth "temp/orig_$filename.yuv" "temp/enc_$filename.yuv" ./bins/model/vmaf_v0.6.1.pkl | grep "score =" | cut -d" " -f4)
dssim=$(./bins/dssim.exe "temp/orig_$filename.png" "temp/enc_$filename.png" | cut -d"	" -f1)
ssimulacra=$(ssimulacra.exe "temp/orig_$filename.png" "temp/enc_$filename.png" | cut -d"	" -f1)
echo "$1: Size=$filesize Pixels=$totalPixels PSNR=$psnr SSIM=$ssim PSNR-HVS-M=$psnrhvs MS-SSIM=$msssim VMAF=$vmaf DSSIM=$dssim SSIMULACRA=$ssimulacra" > "stats_$filename.txt"

rm "temp/orig_$filename.png"
rm "temp/orig_$filename.y4m"
rm "temp/orig_$filename.yuv"
rm "temp/enc_$filename.y4m"
rm "temp/enc_$filename.yuv"
rm "temp/enc_$filename.png"

echo "End $1"
