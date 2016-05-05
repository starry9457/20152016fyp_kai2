#!/bin/bash

# Parameters
qsize=200
ks="8 12 15 20 30 40 60 100"
n=3
iperf_port=5001
tos="0 2"

# For-loop
for i in $tos; do
    echo "TOS: $i"
    for k in $ks; do
        dir1=tcpecnbb-q$qsize-k$k
        tcpecn_src=$dir1/k$k-h1-tos$i-ping.txt
        echo $k, |tr "\n" " " 
        pingavg=`awk -F '/' 'END {print $5}' "$tcpecn_src"`
        echo $pingavg, |tr "\n" " " 
        percentloss=`grep -oP '\d+(?=% packet loss)'  "$tcpecn_src"`
        echo $percentloss
    done
done
