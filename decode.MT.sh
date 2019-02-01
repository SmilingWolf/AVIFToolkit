find contained/ -type f -print0 | xargs -0 -n1 -P6 -I{} sh decode.ST.sh "{}"
