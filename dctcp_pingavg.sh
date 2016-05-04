#!/bin/bash

# Parameters
qsize=200
ks="8 12 15 20 30 40 60 100"
n=3
iperf_port=5001

# For-loop
for ((i=0; i<$n; i++)); do
    echo "Host: $i"
    for ((j=0; j<4; j++)); do
    	echo "TOS: $j"
        for k in $ks; do
        	dir1=dctcpbb-q$qsize-k$k
            dctcp_src=$dir1/k$k-h$i-tos$j-ping.txt
            echo $k, |tr "\n" " " 
            pingavg=`awk -F '/' 'END {print $5}' "$dctcp_src"`
            echo $pingavg, |tr "\n" " " 
            percentloss=`grep -oP '\d+(?=% packet loss)'  "$dctcp_src"`
            echo $percentloss
        done
    done
    echo ""
done
