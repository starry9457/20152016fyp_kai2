#!/bin/bash

#echo "------------------------------------------------------------------------"
#echo "post-processing.sh: This script is doing some post-experiment task."
#echo "------------------------------------------------------------------------"

# Parameters
qsize=200
ks="3 5 8 15 20 30 40 60 80 100"
n=3
iperf_port=5001

dctcpf=dctcpgraphs-q$qsize
tcpecnf=tcpecngraphs-q$qsize

echo ""
echo "------------------------------------------------------------------------"
echo "Processing data to get average ping in different tests, result will be"
echo "put inside $dctcpf and $tcpecnf"
echo "------------------------------------------------------------------------"
./tcpecn_pingavg.sh | tee $tcpecnf/ping-avg.txt
./dctcp_pingavg.sh | tee $dctcpf/ping-avg.txt

echo ""
echo "------------------------------------------------------------------------"
echo "Generating the graph of cwnd size comparison between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
for k in $ks; do
    # cwnd graph. Actually not used in this experiment.
    dir1=dctcpbb-q$qsize-k$k
    dir2=tcpecnbb-q$qsize-k$k
    python plot_tcpprobe.py -f $dir1/cwnd.txt $dir2/cwnd.txt -o $dctcpf/cwnd-iperf-k$k.png -p $iperf_port
done
echo ""
echo "------------------------------------------------------------------------"
echo "Generating the graph of queue occupancy comparison between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
for k in $ks; do
    # cwnd graph. Actually not used in this experiment.
    dir1=dctcpbb-q$qsize-k$k
    dir2=tcpecnbb-q$qsize-k$k
    python plot_queue.py -f $dir1/q.txt $dir2/q.txt --legend dctcp tcpecn -o $dctcpf/dctcp-tcpecn-queue-k$k.png
done
