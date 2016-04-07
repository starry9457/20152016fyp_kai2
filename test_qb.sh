#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment"
echo "------------------------------------------------------------------------"

time=15
bwnet=1000
delay=1

# Red settings (originated for DCTCP)
red_limit=1000000
red_avpkt=1000
red_burst=100
red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
ks="20"
qsizes=200
n=50     # Number of hosts

# Reproducing Queue buildup
qbport=50001
qbsize=10
qbc=1000
qbinterval=0.1

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
        python test_dctcp_iperf.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dctcpdir1 --maxq $qsize -t $time \
        --red_limit $red_limit \
        --red_min $dctcp_red_min \
        --red_max $dctcp_red_max \
        --red_avpkt $red_avpkt \
        --red_burst $red_burst \
        --red_prob $red_prob \
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
        echo "test_qb.sh: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $dctcpdir1/q.txt -o $dctcpdirf/dctcp_queue_k$k.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $dctcpdir1/k.txt >> $dctcpdirf/k.txt
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "test_qb.sh: Generating graph of Throughput vs Marking Threshold (K) "
echo "------------------------------------------------------------------------"
python plot_k_sweep_qb.py -f $dctcpdirf/k.txt -l Ksweep -o $dctcpdirf/k_sweep.png

echo ""
echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment - TCPECN"
echo "------------------------------------------------------------------------"
echo ""
for qsize in $qsizes; do
    mkdir qb-tcpecngraphs-q$qsize
    tcpecndirf=qb-tcpecngraphs-q$qsize
    rm -rf qb-tcpecnbb-q$qsize
    for k in $ks; do
        mkdir qb-tcpecnbb-q$qsize-k$k
        tcpecndir1=qb-tcpecnbb-q$qsize-k$k
        qbout=tcpecn-qb-k$k-qbs$qbsize-c$qbc.txt
        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        tcpecn_red_min=`expr $k \\* $red_avpkt`
        tcpecn_red_max=`expr $tcpecn_red_min + 1`
        python test_dctcp_iperf.py --delay $delay -b $bwnet -B $bwnet -k $k -d $tcpecndir1 --maxq $qsize -t $time \
        --red_limit $red_limit \
        --red_min $tcpecn_red_min \
        --red_max $tcpecn_red_max \
        --red_avpkt $red_avpkt \
        --red_burst $red_burst \
        --red_prob $red_prob \
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
        echo "test_qb.sh: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $tcpecndir1/q.txt -o $tcpecndirf/tcpecn_queue_k$k.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $tcpecndir1/k.txt >> $tcpecndirf/k.txt
    done
done

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
    python plot_queue.py -f $dir1/q.txt $dir2/q.txt --legend dctcp tcpecn -o $dctcpf/dctcp-tcpecn-queue-k$k.png
done

echo ""
echo "------------------------------------------------------------------------"
echo "Generating graph of Throughput vs Marking Threshold (K) comparison"
echo "between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
python plot_k_sweep_qb.py -f $dctcpf/k.txt $tcpecnf/k.txt -l dctcp tcpecn -o $dctcpf/k_sweep_comparison.png
