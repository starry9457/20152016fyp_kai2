#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment (Experiment 4)"
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
n=4                # Number of hosts

# Queue buildup experiment parameters
qbport=50001        # Port
qbsize=20           # Size for each request
qbc=1000            # counts
qbinterval=0        # interval

echo ""
echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment - DCTCP"
echo "------------------------------------------------------------------------"
echo ""

for qsize in $qsizes; do
    # mkdir qb-dctcpgraphs-q$qsize
    # dctcpdirf=qb-dctcpgraphs-q$qsize
    # rm -rf qb-dctcpbb-q$qsize
    for k in $ks; do
        mkdir qb-dctcpbb-q$qsize-k$k
        dctcpdir1=qb-dctcpbb-q$qsize-k$k
        qbout=dctcp-qb-k$k-qbs$qbsize-c$qbc.txt
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Queue Buildup Experiment - DCTCP: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        dctcp_red_min=`expr $k \\* $red_avpkt`
        dctcp_red_max=`expr $dctcp_red_min + 1`
        python dctcp_qb.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dctcpdir1 --maxq $qsize -t $time \
        --red_limit $red_limit \
        --red_min $dctcp_red_min \
        --red_max $dctcp_red_max \
        --red_avpkt $red_avpkt \
        --red_burst $red_burst \
        --red_prob $red_prob \
        --dctcp 1 \
        --red 1 \
        --ecn 1 \
        --qbport $qbport \
        --qbsize $qbsize \
        --qbcount $qbc \
        --qbinterval $qbinterval \
        --qbout $qbout \
        -qb 1 \
        --iperf $iperf -n $n
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment - TCP/ECN"
echo "------------------------------------------------------------------------"
echo ""
for qsize in $qsizes; do
    # mkdir qb-tcpecngraphs-q$qsize
    # tcpecndirf=qb-tcpecngraphs-q$qsize
    # rm -rf qb-tcpecnbb-q$qsize
    for k in $ks; do
        mkdir qb-tcpecnbb-q$qsize-k$k
        tcpecndir1=qb-tcpecnbb-q$qsize-k$k
        qbout=tcpecn-qb-k$k-qbs$qbsize-c$qbc.txt
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Queue Buildup Experiment - TCP/ECN: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        tcpecn_red_min=`expr $k \\* $red_avpkt`
        tcpecn_red_max=`expr $tcpecn_red_min + 1`
        python dctcp_qb.py --delay $delay -b $bwnet -B $bwnet -k $k -d $tcpecndir1 --maxq $qsize -t $time \
        --red_limit $red_limit \
        --red_min $tcpecn_red_min \
        --red_max $tcpecn_red_max \
        --red_avpkt $red_avpkt \
        --red_burst $red_burst \
        --red_prob $red_prob \
        --dctcp 0 \
        --red 1 \
        --ecn 1 \
        --qbport $qbport \
        --qbsize $qbsize \
        --qbcount $qbc \
        --qbinterval $qbinterval \
        --qbout $qbout \
        -qb 1 \
        --iperf $iperf -n $n
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment - TCP"
echo "------------------------------------------------------------------------"
echo ""
for qsize in $qsizes; do
    # mkdir qb-tcpgraphs-q$qsize
    # tcpdirf=qb-tcpgraphs-q$qsize
    # rm -rf qb-tcpbb-q$qsize
    for k in $ks; do
        mkdir qb-tcpbb-q$qsize-k$k
        tcpdir1=qb-tcpbb-q$qsize-k$k
        qbout=tcp-qb-k$k-qbs$qbsize-c$qbc.txt
        echo ""
        echo "------------------------------------------------------------------------"
        echo "Queue Buildup Experiment - TCP: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        tcp_red_min=`expr $k \\* $red_avpkt`
        tcp_red_max=`expr $tcp_red_min + 1`
        python dctcp_qb.py --delay $delay -b $bwnet -B $bwnet -k $k -d $tcpdir1 --maxq $qsize -t $time \
        --dctcp 0 \
        --red 0 \
        --ecn 0 \
        --qbport $qbport \
        --qbsize $qbsize \
        --qbcount $qbc \
        --qbinterval $qbinterval \
        --qbout $qbout \
        -qb 1 \
        --iperf $iperf -n $n
    done
done

graphf=qb-graphs-q$qsize
mkdir qb-graphs-q$qsize

echo ""
echo "------------------------------------------------------------------------"
echo "Queue Buildup Experiment - Generate graph"
echo "------------------------------------------------------------------------"
echo ""
for k in $ks; do
    dctcpf=qb-dctcpbb-q$qsize-k$k
    tcpecnf=qb-tcpecnbb-q$qsize-k$k
    tcpf=qb-tcpbb-q$qsize-k$k
    dctcpqbout=dctcp-qb-k$k-qbs$qbsize-c$qbc.txt
    tcpecnqbout=tcpecn-qb-k$k-qbs$qbsize-c$qbc.txt
    tcpqbout=tcp-qb-k$k-qbs$qbsize-c$qbc.txt
    python plot_qb.py -f $dctcpf/$dctcpqbout $tcpecnf/$tcpecnqbout $tcpf/$tcpqbout --count $qbc --size $qbsize -l DCTCP 'TCP/ECN' TCP -o $graphf/qb-comparison-k$k-qbs$qbsize-c$qbc.png
done
