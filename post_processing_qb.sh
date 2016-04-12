#!/bin/bash

#echo "------------------------------------------------------------------------"
#echo "post-processing_qb.sh: This script is doing some post-experiment task  for Queue Buildup."
#echo "------------------------------------------------------------------------"

# Parameters
qsize=200
ks="3 5 8 15 20 30 40 60 80 100"
n=3
iperf_port=5001

dctcpf=qb-dctcpgraphs-q$qsize
tcpecnf=qb-tcpecngraphs-q$qsize

echo ""
echo "------------------------------------------------------------------------"
echo "Processing data to get average ping in different tests, result will be"
echo "put inside $dctcpf and $tcpecnf"
echo "------------------------------------------------------------------------"
./tcpecn_pingavg_qb.sh | tee $tcpecnf/ping-avg.txt
./dctcp_pingavg_qb.sh | tee $dctcpf/ping-avg.txt

echo ""
echo "------------------------------------------------------------------------"
echo "Generating the graph of cwnd size comparison between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
for k in $ks; do
    # cwnd graph. Actually not used in this experiment.
    dir1=qb-dctcpbb-q$qsize-k$k
    dir2=qb-tcpecnbb-q$qsize-k$k
    python plot_tcpprobe.py -f $dir1/cwnd.txt $dir2/cwnd.txt -o $dctcpf/cwnd-iperf-k$k.png -p $iperf_port
done
echo ""
echo "------------------------------------------------------------------------"
echo "Generating the graph of queue occupancy comparison between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
for k in $ks; do
    # cwnd graph. Actually not used in this experiment.
    dir1=qb-dctcpbb-q$qsize-k$k
    dir2=qb-tcpecnbb-q$qsize-k$k
    python plot_queue.py -f $dir1/q1.txt $dir2/q1.txt --legend dctcp tcpecn -o $dctcpf/dctcp-tcpecn-queue-k$k-q1.png
    python plot_queue.py -f $dir1/q2.txt $dir2/q2.txt --legend dctcp tcpecn -o $dctcpf/dctcp-tcpecn-queue-k$k-q2.png
    python plot_queue.py -f $dir1/q3.txt $dir2/q3.txt --legend dctcp tcpecn -o $dctcpf/dctcp-tcpecn-queue-k$k-q3.png
    python plot_queue.py -f $dir1/q4.txt $dir2/q4.txt --legend dctcp tcpecn -o $dctcpf/dctcp-tcpecn-queue-k$k-q4.png
done

echo ""
echo "------------------------------------------------------------------------"
echo "Generating graph of Throughput vs Marking Threshold (K) comparison"
echo "between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
python plot_k_sweep_qb.py -f $dctcpf/k1.txt $tcpecnf/k1.txt -l dctcp tcpecn -o $dctcpf/k1_sweep_comparison.png
python plot_k_sweep_qb.py -f $dctcpf/k2.txt $tcpecnf/k2.txt -l dctcp tcpecn -o $dctcpf/k2_sweep_comparison.png
python plot_k_sweep_qb.py -f $dctcpf/k3.txt $tcpecnf/k3.txt -l dctcp tcpecn -o $dctcpf/k3_sweep_comparison.png
python plot_k_sweep_qb.py -f $dctcpf/k4.txt $tcpecnf/k4.txt -l dctcp tcpecn -o $dctcpf/k4_sweep_comparison.png
