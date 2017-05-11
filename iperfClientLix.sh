#!/bin/bash
#
# Run the script in background by the following command:
# $ nohup ./iperfClientLix.sh &
#
# Track the status of background process by command jobs -l; you should see the process in status "Running" or "Done".
# the process is removed when the execution of the script is completed.
#  $ jobs -l
#
# [1]+ 48429 Running     nohup ./iperfClientLix.sh &
#
# $ jobs -l
# [1]+ 48429 Done        nohup ./iperfClientLix.sh

declare -a commands=(
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
"iperf -P 1 -c 10.0.1.5 -t 600 -i 1 -f M"
);

for (( i = 0; i < ${#commands[@]} ; i++ )); do
    sys_time=$(date)
    nameFolder=`date --date="$sys_time" '+%Y%m%d%H%M%S'`
    startTimeHeader=`date --date="$sys_time" '+%Y_%m_%d-%H:%M:%S'`
    startTime=`date --date="$sys_time" '+%Y_%m_%d_%H%M%S'`
    fileName='iperf_'$startTime'.txt'
    # create a folder
    if [ ! -d ~/$nameFolder ]; then
       mkdir -p ~/$nameFolder;
    fi
    cwd=$(pwd)
    fileLog="$cwd/$nameFolder/$fileName"
    iperfCmd="${commands[$i]}"
    commands[$i]="${commands[$i]} > $fileLog"
    printf  "%s\n" "*** full CMD: ${commands[$i]} *****"
    eval "${commands[$i]}"
    wait
    sed -i "1 s/^/$startTimeHeader\\t$iperfCmd\n/" "$fileLog"
done
wait
exit 0
