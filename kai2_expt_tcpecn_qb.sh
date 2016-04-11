#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

echo "------------------------------------------------------------------------"
echo "TCP/ECN Test Experiment for Queue Buildup"
echo "------------------------------------------------------------------------"

time=30
bwnet=1000
delay=1

# Red settings (originated for DCTCP)
dctcp_red_limit=1000000
dctcp_red_avpkt=1000
dctcp_red_burst=100
dctcp_red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
ks="3 5 8 15 20 30 40 60 80 100"
qsizes=200

# Reproducing Queue buildup
qbport=50001
qbsize=20
qbc=1000
qbinterval=0

n=4     # Number of hosts
for qsize in $qsizes; do
    mkdir qb-tcpecngraphs-q$qsize
    dirf=qb-tcpecngraphs-q$qsize
    rm -rf qb-tcpecnbb-q$qsize
    for k in $ks; do
        mkdir qb-tcpecnbb-q$qsize-k$k
        dir1=qb-tcpecnbb-q$qsize-k$k
        qbout=tcpecn-qb-k$k-qbs$qbsize-c$qbc.txt
        echo ""
        echo "------------------------------------------------------------------------"
        echo "kai2_expt_tcpecn_qb.sh: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        dctcp_red_min=`expr $k \\* $dctcp_red_avpkt`
        dctcp_red_max=`expr $dctcp_red_min + 1`
        python dctcp_iperf.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dir1 --maxq $qsize -t $time \
        --red_limit $dctcp_red_limit \
        --red_min $dctcp_red_min \
        --red_max $dctcp_red_max \
        --red_avpkt $dctcp_red_avpkt \
        --red_burst $dctcp_red_burst \
        --red_prob $dctcp_red_prob \
        --dctcp 0 \
        --red 1 \
        --ping 100 \
        --interval 0.3 \
        --ecn 1 \
        --qbport $qbport \
        --qbsize $qbsize \
        --qbcount $qbc \
        --qbinterval $qbinterval \
        --qbout $qbout \
        -qb 1 \
        --iperf $iperf -n $n

        echo ""
        echo "------------------------------------------------------------------------"
        echo "kai2_expt_tcpecn_qb.sh: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $dir1/q.txt -o $dirf/tcpecn_queue_k$k.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "kai2_expt_tcpecn_qb.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $dir1/k.txt >> $dirf/k.txt
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "kai2_expt_tcpecn_qb.sh: Generating graph of Throughput vs Marking Threshold (K) "
echo "------------------------------------------------------------------------"
python plot_k_sweep_qb.py -f $dirf/k.txt -l Ksweep -o $dirf/k_sweep.png

#rm -rf $dir1       # Keep the files remained for analysis
