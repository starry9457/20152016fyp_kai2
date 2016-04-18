#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

echo "------------------------------------------------------------------------"
echo "DCTCP Test Experiment for Queue Buildup"
echo "------------------------------------------------------------------------"

time=10
bwnet=100
delay=1

# Red settings (originated for DCTCP)
dctcp_red_limit=1000000
dctcp_red_avpkt=1000
dctcp_red_burst=100
dctcp_red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
ks="20"
qsizes=200

# Reproducing Queue buildup
qbport=50001
qbsize=10
qbc=1000
qbinterval=0.1

n=4     # Number of hosts
for qsize in $qsizes; do
    mkdir qb-dctcpgraphs-q$qsize
    dirf=qb-dctcpgraphs-q$qsize
    rm -rf qb-dctcpbb-q$qsize
    for k in $ks; do
        mkdir qb-dctcpbb-q$qsize-k$k
        dir1=qb-dctcpbb-q$qsize-k$k
        qbout=dctcp-qb-k$k-qbs$qbsize-c$qbc.txt
        echo ""
        echo "------------------------------------------------------------------------"
        echo "kai2_expt_dctcp_qb.sh: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        dctcp_red_min=`expr $k \\* $dctcp_red_avpkt`
        dctcp_red_max=`expr $dctcp_red_min + 1`
        python test_dctcp_iperf.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dir1 --maxq $qsize -t $time \
        --red_limit $dctcp_red_limit \
        --red_min $dctcp_red_min \
        --red_max $dctcp_red_max \
        --red_avpkt $dctcp_red_avpkt \
        --red_burst $dctcp_red_burst \
        --red_prob $dctcp_red_prob \
        --dctcp 1 \
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
        echo "kai2_expt_dctcp_qb.sh: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $dir1/q1.txt -o $dirf/dctcp_queue_k$k-q1.png
        python plot_queue.py -f $dir1/q2.txt -o $dirf/dctcp_queue_k$k-q2.png
        python plot_queue.py -f $dir1/q3.txt -o $dirf/dctcp_queue_k$k-q3.png
        python plot_queue.py -f $dir1/q4.txt -o $dirf/dctcp_queue_k$k-q4.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "kai2_expt_dctcp_qb.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $dir1/k1.txt >> $dirf/k1.txt
        cat $dir1/k2.txt >> $dirf/k2.txt
        cat $dir1/k3.txt >> $dirf/k3.txt
        cat $dir1/k4.txt >> $dirf/k4.txt
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "kai2_expt_dctcp_qb.sh: Generating graph of Throughput vs Marking Threshold (K) "
echo "------------------------------------------------------------------------"
python plot_k_sweep.py -f $dirf/k1.txt -l Ksweep -o $dirf/k1_sweep.png
python plot_k_sweep.py -f $dirf/k2.txt -l Ksweep -o $dirf/k2_sweep.png
python plot_k_sweep.py -f $dirf/k3.txt -l Ksweep -o $dirf/k3_sweep.png
python plot_k_sweep.py -f $dirf/k4.txt -l Ksweep -o $dirf/k4_sweep.png

#rm -rf $dir1       # Keep the files remained for analysis
