#  Scripts to run iperf, psping and Tshark in parallel (alpha version)

Here a set of script to run **iperf** 
The script has been tested successful with iperf3 on windows 2012 R2.

- **ClientIperf.ps1**: run the iperf with the role of client
- **ServIperf.ps1**: run the iperf with the role of server
- **OutputManipulation.ps1**: accept in input the log of iperf and write a new file containing time and bandwidth in Mbps.
- **PreSetup.ps1**: contains a set of powershell commmand need to be run to prepare the hosts before running iperf and psping.

Before running the script you should store in the folder of both hosts (iperf client and iperf server):

- the executable of **iperf3**
- the **psping**
- install on the host **Tshark**


##  REFERENCE

**iperf**: https://iperf.fr/

**psping**: https://technet.microsoft.com/en-us/sysinternals/psping.aspx

**Tshark**: https://www.wireshark.org/



