#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=30
bwnet=100
delay=1

# Red settings (for DCTCP)
dctcp_red_limit=1000000
dctcp_red_avpkt=1000
dctcp_red_burst=100
dctcp_red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
ks="1 2 3 5 8 15 20 30 40 60 80 100"
qsizes=200
n=3     # hosts
for qsize in $qsizes; do
    mkdir dctcpgraphs-q$qsize
    dirf=dctcpgraphs-q$qsize
    rm -rf dctcpbb-q$qsize
    for k in $ks; do
        mkdir dctcpbb-q$qsize-k$k
        dir1=dctcpbb-q$qsize-k$k
        echo "------------------------------------------------------------------------"
        echo "kai2_expt.sh: Testing with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        dctcp_red_min=`expr $k \\* $dctcp_red_avpkt`
        dctcp_red_max=`expr $dctcp_red_min + 1`
        python dctcp.py --delay $delay -b $bwnet -B $bwnet -k $k -d $dir1 --maxq $qsize -t $time \
        --red_limit $dctcp_red_limit \
        --red_min $dctcp_red_min \
        --red_max $dctcp_red_max \
        --red_avpkt $dctcp_red_avpkt \
        --red_burst $dctcp_red_burst \
        --red_prob $dctcp_red_prob \
        --dctcp 1 \
    --red 0\
        --iperf $iperf -n $n

        echo "------------------------------------------------------------------------"
        echo "kai2_expt.sh: Generating graph of Queue Occupancy vs "
        echo "Marking Threshold (K) "
        echo "with k: $k, Queue Size: $qsize"
        echo "------------------------------------------------------------------------"
        python plot_queue.py -f $dir1/q.txt -o $dirf/dctcp_queue_k$k.png

        echo "------------------------------------------------------------------------"
        echo "kai2_expt.sh: Combining the data of Marking Threshold (K), which will"
        echo "be used to generate the graph Throughput vs Marking Threshold (K) later"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        cat $dir1/k.txt >> $dirf/k.txt

        echo "------------------------------------------------------------------------"
        echo "kai2_expt.sh: Combining the average ping data of Marking Threshold (K)"
        echo "with k: $k"
        echo "------------------------------------------------------------------------"
        for ((i=0; i<=$n; i++)); do
            echo $k, |tr "\n" " " >> $dirf/k$k_ping.txt
            cat $dir1/k$k_h$i_ping_avg.txt >> $dirf/k$k_ping.txt
        done

        # cwnd graph, not used.
        #python plot_tcpprobe.py -f $dir1/cwnd.txt $dir2/cwnd.txt -o $dirf/cwnd-iperf.png -p $iperf_port
    done
done

echo "------------------------------------------------------------------------"
echo "kai2_expt.sh: Generating graph of Throughput vs Marking Threshold (K) "
echo "------------------------------------------------------------------------"
python plot_k_sweep.py -f $dirf/k.txt -l Ksweep -o $dirf/k_sweep.png

#rm -rf $dir1       # Keep the files remained for analysis
