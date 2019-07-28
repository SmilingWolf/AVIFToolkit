BJONTEGAARD="./bins/bjontegaard.exe"

IFS=' ' read -r VALUES <<< "$(head -n 1 $1)"
VALUES=($VALUES)
NUM_VALUES_1=${#VALUES[@]}
IFS=' ' read -r VALUES <<< "$(head -n 1 $2)"
VALUES=($VALUES)
NUM_VALUES_2=${#VALUES[@]}

N1=$(cat $1 | wc -l)
N2=$(cat $2 | wc -l)
AREA1=$(cut -d\  -f 2 $1 | xargs | sed 's/ /,/g')
AREA2=$(cut -d\  -f 2 $2 | xargs | sed 's/ /,/g')
SIZE1=$(cut -d\  -f 3 $1 | xargs | sed 's/ /,/g')
SIZE2=$(cut -d\  -f 3 $2 | xargs | sed 's/ /,/g')
PSNR1=$(cut -d\  -f 4 $1 | xargs | sed 's/ /,/g')
PSNR2=$(cut -d\  -f 4 $2 | xargs | sed 's/ /,/g')
SSIM1=$(cut -d\  -f 5 $1 | xargs | sed 's/ /,/g')
SSIM2=$(cut -d\  -f 5 $2 | xargs | sed 's/ /,/g')
PSNRHVS1=$(cut -d\  -f 6 $1 | xargs | sed 's/ /,/g')
PSNRHVS2=$(cut -d\  -f 6 $2 | xargs | sed 's/ /,/g')
MSSSIM1=$(cut -d\  -f 7 $1 | xargs | sed 's/ /,/g')
MSSSIM2=$(cut -d\  -f 7 $2 | xargs | sed 's/ /,/g')
VMAF1=$(cut -d\  -f 8 $1 | xargs | sed 's/ /,/g')
VMAF2=$(cut -d\  -f 8 $2 | xargs | sed 's/ /,/g')
DSSIM1=$(cut -d\  -f 9 $1 | xargs | sed 's/ /,/g')
DSSIM2=$(cut -d\  -f 9 $2 | xargs | sed 's/ /,/g')
SSIMULACRA1=$(cut -d\  -f 10 $1 | xargs | sed 's/ /,/g')
SSIMULACRA2=$(cut -d\  -f 10 $2 | xargs | sed 's/ /,/g')

SSIM_RATE=$($BJONTEGAARD 0 $N1 $AREA1 $SIZE1 $SSIM1 $N2 $AREA2 $SIZE2 $SSIM2)
SSIM_DSNR=$($BJONTEGAARD 1 $N1 $AREA1 $SIZE1 $SSIM1 $N2 $AREA2 $SIZE2 $SSIM2)
PSNR_RATE=$($BJONTEGAARD 0 $N1 $AREA1 $SIZE1 $PSNR1 $N2 $AREA2 $SIZE2 $PSNR2)
PSNR_DSNR=$($BJONTEGAARD 1 $N1 $AREA1 $SIZE1 $PSNR1 $N2 $AREA2 $SIZE2 $PSNR2)
MSSSIM_RATE=$($BJONTEGAARD 0 $N1 $AREA1 $SIZE1 $MSSSIM1 $N2 $AREA2 $SIZE2 $MSSSIM2)
MSSSIM_DSNR=$($BJONTEGAARD 1 $N1 $AREA1 $SIZE1 $MSSSIM1 $N2 $AREA2 $SIZE2 $MSSSIM2)
PSNRHVS_RATE=$($BJONTEGAARD 0 $N1 $AREA1 $SIZE1 $PSNRHVS1 $N2 $AREA2 $SIZE2 $PSNRHVS2)
PSNRHVS_DSNR=$($BJONTEGAARD 1 $N1 $AREA1 $SIZE1 $PSNRHVS1 $N2 $AREA2 $SIZE2 $PSNRHVS2)
VMAF_RATE=$($BJONTEGAARD 0 $N1 $AREA1 $SIZE1 $VMAF1 $N2 $AREA2 $SIZE2 $VMAF2)
VMAF_DSNR=$($BJONTEGAARD 1 $N1 $AREA1 $SIZE1 $VMAF1 $N2 $AREA2 $SIZE2 $VMAF2)
DSSIM_RATE=$($BJONTEGAARD 0 $N1 $AREA1 $SIZE1 $DSSIM1 $N2 $AREA2 $SIZE2 $DSSIM2)
DSSIM_DSNR=$($BJONTEGAARD 1 $N1 $AREA1 $SIZE1 $DSSIM1 $N2 $AREA2 $SIZE2 $DSSIM2)
SSIMULACRA_RATE=$($BJONTEGAARD 0 $N1 $AREA1 $SIZE1 $SSIMULACRA1 $N2 $AREA2 $SIZE2 $SSIMULACRA2)
SSIMULACRA_DSNR=$($BJONTEGAARD 1 $N1 $AREA1 $SIZE1 $SSIMULACRA1 $N2 $AREA2 $SIZE2 $SSIMULACRA2)

echo "        RATE (%) DSNR (dB)"
echo "   PSNR" $(echo $PSNR_RATE   | cut -d\  -f 3) $(echo $PSNR_DSNR   | cut -d\  -f 3)
echo "   SSIM" $(echo $SSIM_RATE   | cut -d\  -f 3) $(echo $SSIM_DSNR   | cut -d\  -f 3)
echo "PSNRHVS" $(echo $PSNRHVS_RATE  | cut -d\  -f 3) $(echo $PSNRHVS_DSNR  | cut -d\  -f 3)
echo " MSSSIM" $(echo $MSSSIM_RATE   | cut -d\  -f 3) $(echo $MSSSIM_DSNR   | cut -d\  -f 3)
echo "   VMAF" $(echo $VMAF_RATE    | cut -d\  -f 3) $(echo $VMAF_DSNR    | cut -d\  -f 3)
echo "  DSSIM" $(echo $DSSIM_RATE    | cut -d\  -f 3) $(echo $DSSIM_DSNR    | cut -d\  -f 3)
echo "SSIMUL." $(echo $SSIMULACRA_RATE    | cut -d\  -f 3) $(echo $SSIMULACRA_DSNR    | cut -d\  -f 3)
