#!/bin/bash
#
# NOTE:
# Before running the script, replace the values in the variables:
#   USER_NAME  : need to be replaced with the username of the host/Virtual Machine
#   PASSWORD   : need to be replaced with the password of the host/Virtual Machine
#   targetIP   : it is the IP address of the target host/Virtual Machine
#   sourceFiles: it is an array with the full path to the files need to be copied to the target host/Virtual Machine
#   destinationFolder: it is the path to destination folder in the target host/Virtual Machine
#
# To suspend the script:
#   1) press Ctrl-Z to suspend the script
#   2) kill %%
#
USR='USER_NAME'
PWD='PASSWORD'
targetIP='10.0.1.5'

sourceFiles=('/datadrive/z/z01.pcap' '/datadrive/z/z02.pcap' '/datadrive/z/z03.pcap')
destinationFolder='/home/user/zdir/'
for i in ${sourceFiles[@]}; do
       echo "user    :$USR"
       echo "password:$PWD"
       echo "string  :$USR@$targetIP:$1"
       sourceFile="$i"
       START=$(date +%s)
       sshpass -p "$PWD" scp $sourceFile "$USR@$targetIP:$destinationFolder" &
       END=$(date +%s)
       DIFF=$(( $END - $START ))
       echo "Total number of seconds: $DIFF seconds"
       printf 'Running time: %dh:%dm:%ds\n' $(($DIFF/3600)) $(($DIFF%3600/60)) $(($DIFF%60))
done
wait
