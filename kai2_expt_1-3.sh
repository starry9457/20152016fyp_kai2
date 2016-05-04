#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

echo "------------------------------------------------------------------------"
echo "DCTCP / TCP/ECN Basic Experiment"
echo "------------------------------------------------------------------------"

time=30
bwnet=100
delay=1

# Red settings (originated for DCTCP)
red_limit=1000000
red_avpkt=1000
red_burst=100
red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
ks="8 12 15 20 30 40 60 100"
qsizes=200
n=3                # Number of hosts

# Ping
pingc=100           # counts
pinginterval=0.1    # interval

echo ""
echo "------------------------------------------------------------------------"
echo "DCTCP / TCP/ECN Experiment - DCTCP"
echo "------------------------------------------------------------------------"
echo ""

for qsize in $qsizes; do
    mkdir dctcpgraphs-q$qsize
    dctcpdirf=dctcpgraphs-q$qsize
    # rm -rf dctcpbb-q$qsize
    for k in $ks; do
        mkdir dctcpbb-q$qsize-k$k
        dctcpdir1=dctcpbb-q$qsize-k$k
        echo ""
        echo "------------------------------------------------------------------------"
        echo "DCTCP Experiment: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        dctcp_red_min=`expr $k \\* $red_avpkt`
        dctcp_red_max=`expr $dctcp_red_min + 1`
        python dctcp.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dctcpdir1 --maxq $qsize -t $time \
        --red_limit $red_limit \
        --red_min $dctcp_red_min \
        --red_max $dctcp_red_max \
        --red_avpkt $red_avpkt \
        --red_burst $red_burst \
        --red_prob $red_prob \
        --dctcp 1 \
        --red 1 \
        --ping $pingc \
        --interval $pinginterval \
        --ecn 1 \
        --iperf $iperf -n $n

        echo ""
        echo "------------------------------------------------------------------------"
        echo "tDCTCP Experiment: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $dctcpdir1/q.txt -o $dctcpdirf/dctcp_queue_k$k.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "DCTCP Experiment: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $dctcpdir1/k.txt >> $dctcpdirf/k.txt
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "DCTCP / TCP/ECN Experiment - TCP/ECN"
echo "------------------------------------------------------------------------"
echo ""
for qsize in $qsizes; do
    mkdir tcpecngraphs-q$qsize
    tcpecndirf=tcpecngraphs-q$qsize
    # rm -rf tcpecnbb-q$qsize
    for k in $ks; do
        mkdir tcpecnbb-q$qsize-k$k
        tcpecndir1=tcpecnbb-q$qsize-k$k
        echo ""
        echo "------------------------------------------------------------------------"
        echo "TCP/ECN Experiment: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        tcpecn_red_min=`expr $k \\* $red_avpkt`
        tcpecn_red_max=`expr $tcpecn_red_min + 1`
        python dctcp.py --delay $delay -b $bwnet -B $bwnet -k $k -d $tcpecndir1 --maxq $qsize -t $time \
        --red_limit $red_limit \
        --red_min $tcpecn_red_min \
        --red_max $tcpecn_red_max \
        --red_avpkt $red_avpkt \
        --red_burst $red_burst \
        --red_prob $red_prob \
        --dctcp 0 \
        --red 1 \
        --ping $pingc \
        --interval $pinginterval \
        --ecn 1 \
        --iperf $iperf -n $n

        echo ""
        echo "------------------------------------------------------------------------"
        echo "TCP/ECN Experiment: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $tcpecndir1/q.txt -o $tcpecndirf/tcpecn_queue_k$k.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "TCP/ECN Experiment: Combining the data of Marking Threshold (K), which "
        echo "will be used to generate the graph Throughput vs Marking Threshold (K) "
        echo "later with k: $k"
        echo "------------------------------------------------------------------------"
        cat $tcpecndir1/k.txt >> $tcpecndirf/k.txt
    done
done

dctcpf=dctcpgraphs-q$qsize
tcpecnf=tcpecngraphs-q$qsize
graphf=graphs-q$qsize
mkdir graphs-q$qsize

echo ""
echo "------------------------------------------------------------------------"
echo "Experiment 1"
echo "Generating the graph of queue occupancy comparison "
echo "between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
for k in $ks; do
    dir1=dctcpbb-q$qsize-k$k
    dir2=tcpecnbb-q$qsize-k$k
    python plot_queue.py -f $dir1/q.txt $dir2/q.txt --legend DCTCP 'TCP/ECN' -o $graphf/dctcp-tcpecn-queue-k$k.png
done

echo ""
echo "------------------------------------------------------------------------"
echo "Experiment 2"
echo "Generating graph of Throughput vs Marking Threshold (K) comparison"
echo "between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
python plot_k_sweep.py -f $dctcpf/k.txt $tcpecnf/k.txt -l DCTCP 'TCP/ECN' -o $graphf/k_sweep_comparison.png

echo ""
echo "------------------------------------------------------------------------"
echo "Experiment 3"
echo "Processing data to get average ping in different tests, result will be"
echo "put inside $dctcpf , $tcpecnf"
echo "------------------------------------------------------------------------"
./dctcp_pingavg.sh | tee $dctcpf/ping-avg.txt
./tcpecn_pingavg.sh | tee $tcpecnf/ping-avg.txt