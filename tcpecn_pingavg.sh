#!/bin/bash

# Parameters
qsize=200
ks="3 5 8 15 20 30 40 60 80 100"
n=3
iperf_port=5001
for ((i=0; i<$n; i++)); do
	echo "Host: $i"
	for k in $ks; do
		dir1=tcpecnbb-q$qsize-k$k
		tcpecn_src=$dir1/k$k-h$i-ping.txt
		echo $k, |tr "\n" " " 
		pingavg=`awk -F '/' 'END {print $5}' "$tcpecn_src"`
		echo $pingavg
    done
	echo ""
done
