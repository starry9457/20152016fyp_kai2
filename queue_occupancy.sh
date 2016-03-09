#!/bin/bash

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=12
bwnet=100
delay=0.25

# Red settings (for DCTCP)
dctcp_red_limit=1000000
#dctcp_red_min=30000
#dctcp_red_max=30001
#dctcp_red_avpkt=1500
dctcp_red_avpkt=1000
dctcp_red_burst=20
dctcp_red_prob=1
iperf_port=5001
iperf=~/iperf-patched/src/iperf
ks="3 5 9 15 20 30 40 60 80 100"
for qsize in 200; do
    #rm -rf dctcpgraphs-q$qsize
    mkdir dctcpgraphs-q$qsize
    #rm -rf dctcpbb-q$qsize
    #rm -rf tcpbb-q$qsize
    dirf=dctcpgraphs-q$qsize        # graph output
    for k in $ks; do
        dir1=dctcpbb-q$qsize-k$k            # txt output
        dctcp_red_min=`expr $k \\* $dctcp_red_avpkt`
        dctcp_red_max=`expr $dctcp_red_min + 1`
        python dctcp.py --delay $delay -b $bwnet -B $bwnet -d $dir1 --maxq $qsize -t $time \
        --red_limit $dctcp_red_limit \
        --red_min $dctcp_red_min \
        --red_max $dctcp_red_max \
        --red_avpkt $dctcp_red_avpkt \
        --red_burst $dctcp_red_burst \
        --red_prob $dctcp_red_prob \
        --dctcp 1 \
        --red 0 \
        --iperf $iperf -k $k -n 3
        #dir2=tcpbb-q$qsize
    done
    #python dctcp.py --delay $delay -b 100 -d $dir2 --maxq $qsize -t $time --dctcp 0 --red 0 --iperf $iperf -k 0 -n 3
    
    #cwnd_pathlist=""
    #q_pathlist=""
    #for k in $ks; do
    #    cwnd_pathlist=cwnd_pathlist + "dctcpbb-q" + $qsize + "-k" + $k + "/cwnd.txt" + " "
    #    q_pathlist=cwnd_pathlist + "dctcpbb-q" + $qsize + "-k" + $k + "/q.txt" + " "
    #done
    #python plot_tcpprobe.py -f cwnd_pathlist -o $dirf/cwnd-iperf.png -p $iperf_port
    #python plot_queue.py -f q_pathlist -o $dirf/dctcp_queue.png      # is it compined to look?
    
    for k in $ks; do
        dir2=dctcpbb-q$qsize-k$k
        python plot_queue.py -f $dir2/q.txt -o ＄dirf/dctcp_queue_k$k.png
    done

    #rm -rf $dir1 $dir2     # keep the files remained for analysis
    #python plot_ping.py -f $dir/ping.txt -o $dir/rtt.png
done