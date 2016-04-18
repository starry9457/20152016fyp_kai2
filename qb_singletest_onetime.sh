#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment"
echo "------------------------------------------------------------------------"

time=80
bwnet=1000
delay=1

# Red settings (originated for DCTCP)
red_limit=1000000
red_avpkt=1000
red_burst=100
red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
#ks="3 5 8 15 20 30 40 60 80 100"
ks="20"
qsizes=200
n=4                # Number of hosts

# Reproducing Queue buildup
qbport=50001        # Port
qbsize=20           # Size for each request
qbc=1000            # counts
qbinterval=0        # interval

# Ping
pingc=100           # counts
pinginterval=0.3    # interval

echo ""
echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment - DCTCP"
echo "------------------------------------------------------------------------"
echo ""

for qsize in $qsizes; do
    mkdir qb-dctcpgraphs-q$qsize
    dctcpdirf=qb-dctcpgraphs-q$qsize
    rm -rf qb-dctcpbb-q$qsize
    for k in $ks; do
        mkdir qb-dctcpbb-q$qsize-k$k
        dctcpdir1=qb-dctcpbb-q$qsize-k$k
        qbout=dctcp-qb-k$k-qbs$qbsize-c$qbc.txt
        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        dctcp_red_min=`expr $k \\* $red_avpkt`
        dctcp_red_max=`expr $dctcp_red_min + 1`
        python test_dctcp_onetime.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dctcpdir1 --maxq $qsize -t $time \
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
        --qbport $qbport \
        --qbsize $qbsize \
        --qbcount $qbc \
        --qbinterval $qbinterval \
        --qbout $qbout \
        -qb 1 \
        --iperf $iperf -n $n

        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $dctcpdir1/q1.txt -o $dctcpdirf/dctcp_queue_k$k-q1.png
        python plot_queue.py -f $dctcpdir1/q2.txt -o $dctcpdirf/dctcp_queue_k$k-q2.png
        python plot_queue.py -f $dctcpdir1/q3.txt -o $dctcpdirf/dctcp_queue_k$k-q3.png
        python plot_queue.py -f $dctcpdir1/q4.txt -o $dctcpdirf/dctcp_queue_k$k-q4.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $dctcpdir1/k1.txt >> $dctcpdirf/k1.txt
        cat $dctcpdir1/k2.txt >> $dctcpdirf/k2.txt
        cat $dctcpdir1/k3.txt >> $dctcpdirf/k3.txt
        cat $dctcpdir1/k4.txt >> $dctcpdirf/k4.txt
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "test_qb.sh: Generating graph of Throughput vs Marking Threshold (K) "
echo "------------------------------------------------------------------------"
python plot_k_sweep_qb.py -f $dctcpdirf/k1.txt -l Ksweep -o $dctcpdirf/k1_sweep.png
python plot_k_sweep_qb.py -f $dctcpdirf/k2.txt -l Ksweep -o $dctcpdirf/k2_sweep.png
python plot_k_sweep_qb.py -f $dctcpdirf/k3.txt -l Ksweep -o $dctcpdirf/k3_sweep.png
python plot_k_sweep_qb.py -f $dctcpdirf/k4.txt -l Ksweep -o $dctcpdirf/k4_sweep.png
