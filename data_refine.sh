#!/bin/bash

echo "------------------------------------------------------------------------"
echo "This script is some post-experiment task."
echo "------------------------------------------------------------------------"

# Parameters
qsize=200
ks="3 5 8 15 20 30 40 60 80 100"
n=3

dctcpf=dctcpgraph-q$qsize
tcpecnf=dctcpgraph-q$qsize

echo ""
echo "------------------------------------------------------------------------"
echo "Finding the average ping in each test, combine them in to one file."
echo "------------------------------------------------------------------------"

for k in $ks; do
    dir1=dctcpbb-q$qsize-k$k
    dir2=tcpecnbb-q$qsize-k$k
    for ((i=0; i<$n; i++)); do
        echo "data_refine.sh: Combining with k: $k, h: $i"
        #echo "kai2_expt_dctcp.sh: Combining with k: $k, h: $i"
        echo $k, |tr "\n" " " >> $dctcpf/k$k_ping.txt
        awk -F '/' 'END {print $5}' dir1/k$k_h$i_ping.txt >> $dctcpf/k$k_h$i_ping_avg.txt
	    
        echo $k, |tr "\n" " " >> $tcpecnf/k$k_ping.txt
        awk -F '/' 'END {print $5}' dir1/k$k_h$i_ping.txt >> $tcpecnf/k$k_h$i_ping_avg.txt
    done

    # cwnd graph, not used.
    python plot_tcpprobe.py -f $dir1/cwnd.txt $dir2/cwnd.txt -o $dctcpf/cwnd-iperf-k$k.png -p $iperf_port
done


