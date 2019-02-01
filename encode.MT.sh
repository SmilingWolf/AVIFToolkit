if [ -z "$1" ]
	then
		quality=25
	else
		quality=$1
fi

if [ -z "$2" ]
	then
		format="AVIF"
	else
		format=$2
fi

if [ -z "$3" ]
	then
		lossy="lossy"
	else
		lossy=$3
fi

find images/ -type f -print0 | xargs -0 -n1 -P6 -I{} sh encode.ST.$format.$lossy.sh "{}" $quality

mkdir -p "./statistics/$lossy/$format/"
cat stats_* | sort -u > "./statistics/$lossy/$format/allstats.q$quality.txt"
rm stats_*

mkdir -p "./converted/$lossy/$format/$quality/"
mv -f ./contained/* "./converted/$lossy/$format/$quality/"
