#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

echo "------------------------------------------------------------------------"
echo "TCP/ECN Experiment"
echo "------------------------------------------------------------------------"

time=60
bwnet=100
delay=1

# Red settings (for DCTCP)
#dctcp_red_limit=1000000
#dctcp_red_avpkt=1000
#dctcp_red_burst=100
#dctcp_red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
ks="1 2 3 5 8 15 20 30 40 60 80 100"
qsizes=200
n=3     # Number of hosts
for qsize in $qsizes; do
    mkdir tcpecngraphs-q$qsize
    dirf=tcpecngraphs-q$qsize
    rm -rf tcpecnbb-q$qsize
    for k in $ks; do
        mkdir tcpecnbb-q$qsize-k$k
        dir1=tcpecnbb-q$qsize-k$k
        echo ""
        echo "------------------------------------------------------------------------"
        echo "kai2_expt_tcpecn.sh: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
#        dctcp_red_min=`expr $k \\* $dctcp_red_avpkt`
#        dctcp_red_max=`expr $dctcp_red_min + 1`
        python dctcp.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dir1 --maxq $qsize -t $time \
        --dctcp 2 \
        --red 0\
        --iperf $iperf -n $n

        echo ""
        echo "------------------------------------------------------------------------"
        echo "kai2_expt_tcpecn.sh: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $dir1/q.txt -o $dirf/tcpecn_queue_k$k.png

        echo ""
        echo "------------------------------------------------------------------------"
        echo "kai2_expt_tcpecn.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $dir1/k.txt >> $dirf/k.txt

#        echo ""
#        echo "------------------------------------------------------------------------"
#        echo "kai2_expt_tcpecn.sh: Combining the average ping data of Marking Threshold (K)"
#        echo "with k: $k"
#        echo "------------------------------------------------------------------------"
#        for ((i=0; i<$n; i++)); do
#            echo "kai2_expt_tcpecn.sh: Combining with k: $k, h: $i"
#            echo $k, |tr "\n" " " >> $dirf/k$k_ping.txt
#            cat $dir1/k$k_h$i_ping_avg.txt >> $dirf/k$k_ping.txt
#        done

        # cwnd graph, not used.
        #python plot_tcpprobe.py -f $dir1/cwnd.txt $dir2/cwnd.txt -o $dirf/cwnd-iperf.png -p $iperf_port
    done
done

echo ""
echo "------------------------------------------------------------------------"
echo "kai2_expt_tcpecn.sh: Generating graph of Throughput vs Marking Threshold (K) "
echo "------------------------------------------------------------------------"
python plot_k_sweep.py -f $dirf/k.txt -l Ksweep -o $dirf/k_sweep.png

#rm -rf $dir1       # Keep the files remained for analysis
