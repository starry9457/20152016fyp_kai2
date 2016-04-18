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
        python test_dctcp_iperf.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dctcpdir1 --maxq $qsize -t $time \
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


echo ""
echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment - TCP/ECN"
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
        python plot_queue.py -f $tcpecndir1/q1.txt -o $tcpecndirf/tcpecn_queue_k$k-q1.png
        python plot_queue.py -f $tcpecndir1/q2.txt -o $tcpecndirf/tcpecn_queue_k$k-q2.png
        python plot_queue.py -f $tcpecndir1/q3.txt -o $tcpecndirf/tcpecn_queue_k$k-q3.png
        python plot_queue.py -f $tcpecndir1/q4.txt -o $tcpecndirf/tcpecn_queue_k$k-q4.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $tcpecndir1/k1.txt >> $tcpecndirf/k1.txt
        cat $tcpecndir1/k2.txt >> $tcpecndirf/k2.txt
        cat $tcpecndir1/k3.txt >> $tcpecndirf/k3.txt
        cat $tcpecndir1/k4.txt >> $tcpecndirf/k4.txt
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "test_qb.sh: Generating graph of Throughput vs Marking Threshold (K) "
echo "------------------------------------------------------------------------"
python plot_k_sweep_qb.py -f $tcpecndirf/k1.txt -l Ksweep -o $tcpecndirf/k1_sweep.png
python plot_k_sweep_qb.py -f $tcpecndirf/k2.txt -l Ksweep -o $tcpecndirf/k2_sweep.png
python plot_k_sweep_qb.py -f $tcpecndirf/k3.txt -l Ksweep -o $tcpecndirf/k3_sweep.png
python plot_k_sweep_qb.py -f $tcpecndirf/k4.txt -l Ksweep -o $tcpecndirf/k4_sweep.png


echo ""
echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment - TCP"
echo "------------------------------------------------------------------------"
echo ""
for qsize in $qsizes; do
    mkdir qb-tcpgraphs-q$qsize
    tcpdirf=qb-tcpgraphs-q$qsize
    rm -rf qb-tcpbb-q$qsize
    for k in $ks; do
        mkdir qb-tcpbb-q$qsize-k$k
        tcpdir1=qb-tcpbb-q$qsize-k$k
        qbout=tcp-qb-k$k-qbs$qbsize-c$qbc.txt
        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python test_dctcp_iperf.py --delay $delay -b $bwnet -B $bwnet -k $k -d $tcpdir1 --maxq $qsize -t $time \
        --dctcp 0 \
        --red 0 \
        --ping $pingc \
        --interval $pinginterval \
        --ecn 0 \
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
        python plot_queue.py -f $tcpdir1/q1.txt -o $tcpdirf/tcp_queue_k$k-q1.png
        python plot_queue.py -f $tcpdir1/q2.txt -o $tcpdirf/tcp_queue_k$k-q2.png
        python plot_queue.py -f $tcpdir1/q3.txt -o $tcpdirf/tcp_queue_k$k-q3.png
        python plot_queue.py -f $tcpdir1/q4.txt -o $tcpdirf/tcp_queue_k$k-q4.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "test_qb.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $tcpdir1/k1.txt >> $tcpdirf/k1.txt
        cat $tcpdir1/k2.txt >> $tcpdirf/k2.txt
        cat $tcpdir1/k3.txt >> $tcpdirf/k3.txt
        cat $tcpdir1/k4.txt >> $tcpdirf/k4.txt
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "test_qb.sh: Generating graph of Throughput vs Marking Threshold (K) "
echo "------------------------------------------------------------------------"
python plot_k_sweep_qb.py -f $tcpdirf/k1.txt -l Ksweep -o $tcpdirf/k1_sweep.png
python plot_k_sweep_qb.py -f $tcpdirf/k2.txt -l Ksweep -o $tcpdirf/k2_sweep.png
python plot_k_sweep_qb.py -f $tcpdirf/k3.txt -l Ksweep -o $tcpdirf/k3_sweep.png
python plot_k_sweep_qb.py -f $tcpdirf/k4.txt -l Ksweep -o $tcpdirf/k4_sweep.png

dctcpf=qb-dctcpgraphs-q$qsize
tcpecnf=qb-tcpecngraphs-q$qsize
tcpf=qb-tcpgraphs-q$qsize
graphf=qb-graphs-q$qsize

echo ""
echo "------------------------------------------------------------------------"
echo "Processing data to get average ping in different tests, result will be"
echo "put inside $dctcpf and $tcpecnf"
echo "------------------------------------------------------------------------"
./tcpecn_pingavg_qb.sh | tee $tcpecnf/ping-avg.txt
./dctcp_pingavg_qb.sh | tee $dctcpf/ping-avg.txt
./tcp_pingavg_qb.sh | tee $tcpf/ping-avg.txt

echo ""
echo "------------------------------------------------------------------------"
echo "Generating the graph of cwnd size comparison between DCTCP and TCP/ECN and TCP"
echo "------------------------------------------------------------------------"
for k in $ks; do
    # cwnd graph. Actually not used in this experiment.
    dir1=qb-dctcpbb-q$qsize-k$k
    dir2=qb-tcpecnbb-q$qsize-k$k
    dir3=qb-tcpbb-q$qsize-k$k
    python plot_tcpprobe.py -f $dir1/cwnd.txt $dir2/cwnd.txt -o $graphf/cwnd-iperf-k$k.png -p $iperf_port
    python plot_tcpprobe.py -f $dir1/cwnd.txt $dir2/cwnd.txt $dir3/cwnd.txt -o $graphf/cwnd-iperf-k$k-full.png -p $iperf_port
done
echo ""
echo "------------------------------------------------------------------------"
echo "Generating the graph of queue occupancy comparison between DCTCP and TCP/ECN and TCP"
echo "------------------------------------------------------------------------"
for k in $ks; do
    dir1=qb-dctcpbb-q$qsize-k$k
    dir2=qb-tcpecnbb-q$qsize-k$k
    dir3=qb-tcpbb-q$qsize-k$k
    python plot_queue.py -f $dir1/q1.txt $dir2/q1.txt --legend dctcp tcpecn -o $graphf/dctcp-tcpecn-queue-k$k-q1.png
    python plot_queue.py -f $dir1/q2.txt $dir2/q2.txt --legend dctcp tcpecn -o $graphf/dctcp-tcpecn-queue-k$k-q2.png
    python plot_queue.py -f $dir1/q3.txt $dir2/q3.txt --legend dctcp tcpecn -o $graphf/dctcp-tcpecn-queue-k$k-q3.png
    python plot_queue.py -f $dir1/q4.txt $dir2/q4.txt --legend dctcp tcpecn -o $graphf/dctcp-tcpecn-queue-k$k-q4.png
    python plot_queue.py -f $dir1/q1.txt $dir2/q1.txt $dir3/q1.txt --legend dctcp tcpecn tcp -o $graphf/dctcp-tcpecn-tcp-queue-k$k-q1.png
    python plot_queue.py -f $dir1/q2.txt $dir2/q2.txt $dir3/q2.txt --legend dctcp tcpecn tcp -o $graphf/dctcp-tcpecn-tcp-queue-k$k-q2.png
    python plot_queue.py -f $dir1/q3.txt $dir2/q3.txt $dir3/q3.txt --legend dctcp tcpecn tcp -o $graphf/dctcp-tcpecn-tcp-queue-k$k-q3.png
    python plot_queue.py -f $dir1/q4.txt $dir2/q4.txt $dir3/q4.txt --legend dctcp tcpecn tcp -o $graphf/dctcp-tcpecn-tcp-queue-k$k-q4.png
done

echo ""
echo "------------------------------------------------------------------------"
echo "Generating graph of Throughput vs Marking Threshold (K) comparison"
echo "between DCTCP and TCP/ECN"
echo "------------------------------------------------------------------------"
python plot_k_sweep_qb.py -f $dctcpf/k1.txt $tcpecnf/k1.txt -l dctcp tcpecn -o $graphf/k1_sweep_comparison.png
python plot_k_sweep_qb.py -f $dctcpf/k2.txt $tcpecnf/k2.txt -l dctcp tcpecn -o $graphf/k2_sweep_comparison.png
python plot_k_sweep_qb.py -f $dctcpf/k3.txt $tcpecnf/k3.txt -l dctcp tcpecn -o $graphf/k3_sweep_comparison.png
python plot_k_sweep_qb.py -f $dctcpf/k4.txt $tcpecnf/k4.txt -l dctcp tcpecn -o $graphf/k4_sweep_comparison.png
python plot_k_sweep_qb.py -f $dctcpf/k1.txt $tcpecnf/k1.txt $tcpf/k1.txt -l dctcp tcpecn tcp -o $graphf/k1_sweep_comparison_full.png
python plot_k_sweep_qb.py -f $dctcpf/k2.txt $tcpecnf/k2.txt $tcpf/k2.txt -l dctcp tcpecn tcp -o $graphf/k2_sweep_comparison_full.png
python plot_k_sweep_qb.py -f $dctcpf/k3.txt $tcpecnf/k3.txt $tcpf/k3.txt -l dctcp tcpecn tcp -o $graphf/k3_sweep_comparison_full.png
python plot_k_sweep_qb.py -f $dctcpf/k4.txt $tcpecnf/k4.txt $tcpf/k4.txt -l dctcp tcpecn tcp -o $graphf/k4_sweep_comparison_full.png
