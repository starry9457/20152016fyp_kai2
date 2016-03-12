#!/bin/bash

echo "------------------------------------------------------------------------"
echo "This is the experiment for HKUST 2015-2016 COMP4981/4988"
echo "Final Year Project KAI2 Team."
echo "------------------------------------------------------------------------"

echo "------------------------------------------------------------------------"
echo "Cleanup mininet first"
echo "------------------------------------------------------------------------"
mn -c

echo "------------------------------------------------------------------------"
echo "Running the DCTCP experiment"
echo "------------------------------------------------------------------------"
./kai2_expt_dctcp.sh

echo "------------------------------------------------------------------------"
echo "Running the TCP/ECN experiment"
echo "------------------------------------------------------------------------"
./kai2_expt_tcpecn.sh

echo "------------------------------------------------------------------------"
echo "Running the post-experiment script"
echo "------------------------------------------------------------------------"
./post_processing.sh
