#  Scripts to run a group of iperf tests (beta version)

Here a set of scripts to run **iperf** 
The script has been verified successful with iperf3 on windows 2012 R2 and iperf 2.0.8 on CentOS.

- **hostPreSetup.ps1**: contains a set of powershell commands  to prepare the windows 2012R2 hosts, before running iperf and psping.
- **iperfClientLix.sh**:run in bash multiple iperf commands in sequence with the role of iperf client
- **iperfClientWin.ps1**: run in powershell multiple iperf commands in sequence with the role of iperf client
- **iperfServerLix.sh**: run in bash the iperf with the role of iperf server
- **iperfServerWin.ps1**: run in powershell the iperf with the role of iperf server
- **LogFileThreatment.ps1**: accept in input the log of iperf (Linix or windows) and write a new file containing only time and bandwidth in Mbps. the file generate in output can be easily imported in Excel to plot the graph (time, bandwidth). 


##### Note for Windows hosts
Before running the script you should store in the folder of both hosts (iperf client and iperf server):

- the executable of **iperf3**
- the **psping**
- install on the host **Tshark**


##### Note for CentOS hosts
Iperf can be installed from Extra Packages for Enterprise Linux (EPEL) repository:

``-`` Checking the package repositories:
**yum repolist**

``-``Check the list of repository:
**ls /etc/yum.repos.d**

``-``install the EPEL repository on the system: **sudo yum install epel-release**

``-`` install iperf on that system:
**sudo yum install iperf**


####  REFERENCE

**iperf**: https://iperf.fr/

**psping**: https://technet.microsoft.com/en-us/sysinternals/psping.aspx

**Tshark**: https://www.wireshark.org/



