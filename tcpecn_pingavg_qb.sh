#!/bin/bash

# Parameters
qsize=200
ks="3 5 8 15 20 30 40 60 80 100"
#ks="20"
n=4
iperf_port=5001

# For-loop
for ((i=0; i<$n; i++)); do
    echo "Host: $i"
    for ((j=0; j<4; j++)); do
    	echo "TOS: $j"
        for k in $ks; do
        	dir1=qb-tcpecnbb-q$qsize-k$k
            tcpecn_src=$dir1/k$k-h$i-tos$j-ping.txt
            echo $k, |tr "\n" " " 
            pingavg=`awk -F '/' 'END {print $5}' "$tcpecn_src"`
            echo $pingavg
        done
    done
    echo ""
done
