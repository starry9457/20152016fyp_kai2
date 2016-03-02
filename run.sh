#!/bin/bash
mn -c
apt-get install mutt
echo ""
echo "The test takes some time to run (approx 30 minutes), give us your email id
and we will mail you the results :) (Example : \"gmail@rajnikanth.com\"  without
the quotes)"
echo "IMPORTANT : Take the much needed break before the finals, this is going to
take some time : "
read email
echo "Thanks, we will mail you at $email"
echo "------------------------------------------------------------------------"
echo "NOTE : We will try our best to email you and shut the instance down, if
we run into issues, we will not be able to send out the email or shut the 
instance down, so please do check to see if the instance is shut down, the
tests take around 30 minutes to complete at max"
echo "------------------------------------------------------------------------"
echo "Do you want us to shut down once the runs are over ? Enter 1 for yes, 0
for no :"
read shutdown
echo "Executing the script dctcp_tcp_comparison.sh"
./dctcp_tcp_comparison.sh
echo "Executing the script k_sweep.sh"
./k_sweep.sh
echo "Executing the script cdf_flows_queue.sh"
./cdf_flows_queue.sh
echo "Sending the attachment to $email"
cd dctcpgraphs-q200/
echo "Please find the attachment, thank you for your patience" | \
mutt -s "PA3 graphs" -a dctcp_tcp_queue.png k_sweep.png cdf_flows.png \
-- $email
sleep 30
if [ "$shutdown" -eq 1 ]; then
    shutdown -P now
fi
