if [ -z "$2" ]
	then
		quality=96
	else
		quality=$2
fi

filename=$(echo "$1" | sed "s/images\///" | sed "s/\.jpg\|\.jpeg\|\.png\|\.bmp//")

echo "Begin $1"

./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=yuv444p -strict -1 "temp/orig_$filename.y4m"
./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=yuv444p -strict -1 "temp/orig_$filename.yuv"
width=$(head -1 "temp/orig_$filename.y4m" | grep -oE "\ W[0-9]{1,6}" | cut -b3-)
heigth=$(head -1 "temp/orig_$filename.y4m" | grep -oE "\ H[0-9]{1,6}" | cut -b3-)
totalPixels=$(( $width * $heigth ))

# Gotta play with the encoding parameters, this is pretty much an example
./bins/ffmpeg -r 1 -y -hide_banner -loglevel fatal -i "$1" -vf scale=in_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=bgr24 -strict -1 "temp/orig_$filename.png"
./bins/flif --overwrite -e -E 100 -Q $quality "temp/orig_$filename.png" "encoded/$filename.flif"
cp "encoded/$filename.flif" "contained/$filename.flif"
./bins/flif --overwrite -d "contained/$filename.flif" "temp/enc_$filename.png"

./bins/ffmpeg -y -hide_banner -loglevel fatal -i "temp/enc_$filename.png" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=yuv444p -strict -1 "temp/enc_$filename.y4m"
./bins/ffmpeg -y -hide_banner -loglevel fatal -i "temp/enc_$filename.png" -vf scale=out_color_matrix=bt709:flags=lanczos+accurate_rnd+bitexact+full_chroma_int+full_chroma_inp,format=yuv444p -strict -1 "temp/enc_$filename.yuv"

filesize=$(stat --printf="%s" "encoded/$filename.flif")
psnr=$(./bins/dump_psnr.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
ssim=$(./bins/dump_ssim.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
msssim=$(./bins/dump_msssim.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
psnrhvs=$(./bins/dump_psnrhvs.exe -s "temp/orig_$filename.y4m" "temp/enc_$filename.y4m" 2>/dev/null | cut -d" " -f2)
vmaf=$(./bins/vmafossexec.exe yuv444p $width $heigth "temp/orig_$filename.yuv" "temp/enc_$filename.yuv" ./bins/model/vmaf_v0.6.1.pkl | grep "score =" | cut -d" " -f4)
echo "$1: Size=$filesize Pixels=$totalPixels PSNR=$psnr SSIM=$ssim PSNR-HVS-M=$psnrhvs MS-SSIM=$msssim VMAF=$vmaf" > "stats_$filename.txt"

rm "temp/orig_$filename.png"
rm "temp/orig_$filename.y4m"
rm "temp/orig_$filename.yuv"
rm "temp/enc_$filename.png"
rm "temp/enc_$filename.y4m"
rm "temp/enc_$filename.yuv"

echo "End $1"
