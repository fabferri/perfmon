#!/bin/bash
#
# run the server component by command:
# $ nohup ./serveriperf.sh &
#
# Track the status of background process by command:
# $ jobs -l
# Store the PID in a file:
# $ PROC_ID=$!
# $ echo "----procID: $PROC_ID"
# $ echo $PROC_ID > $filepid
#
# if you disconnect from terminal check the status of the process by command ps-ef
#
# To terminate the process:
# kill -9 <PID>
#
cmd="iperf -s"
eval "$cmd"
wait
exit 0
