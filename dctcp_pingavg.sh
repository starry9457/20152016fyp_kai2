#!/bin/bash

# Parameters
qsize=200
ks="1 2 3 5 8 15 20 30 40 60 80 100"
n=3
iperf_port=5001

# For-loop
for ((i=0; i<$n; i++)); do
	echo "Host: $i"
	for k in $ks; do
		dir1=dctcpbb-q$qsize-k$k
		dctcp_src=$dir1/k$k-h$i-ping.txt
		echo $k, |tr "\n" " " 
		pingavg=`awk -F '/' 'END {print $5}' "$dctcp_src"`
		echo $pingavg
    done
	echo ""
done
