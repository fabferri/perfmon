#  Scripts to run iperf in sequence (beta version)

Here a set of scripts to run **iperf** in sequence. 
The script has been verified successful with iperf3 on Windows 2012 R2 and iperf 2.0.8 on CentOS.

- **clientiperf.sh**: run in bash multiple iperf commands in sequence, with the role of iperf client
- **clientiperf.ps1**: run in powershell multiple iperf commands in sequence, with the role of iperf client
- **serveriperf.sh**: run in bash the iperf with the role of iperf server
- **serveriperf.ps1**: run in powershell the iperf with the role of iperf server
- **logFileThreatment.ps1**: accept in input the log of iperf (Linix or windows) and write a new file containing only time and bandwidth in Mbps. the file generate in output can be easily imported in Excel to plot the graph (time, bandwidth). 
- **winHostPreSetup.ps1**: contains a set of powershell commands  to prepare the windows 2012R2 hosts, before running iperf and psping.

###  Note for Windows hosts ###

Before running the script you should store in the folder of both hosts (iperf client and iperf server):

- the executable of **iperf3**
- the **psping**
- install on the host **Tshark**


#### Windows Firewall  ####

The script **winHostPreSetup.ps1** contains some powershell commands to presetup the host (i.e. open the port of firewall to allow iperf traffic).

To enable ping through the Windows firewall:

**Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -enabled True -Profile Any**

To enable iperf ports (TCP 5201, UDP 5201) through the windows firewall:

**New-NetFirewallRule -DisplayName "iperf-TCP" -Name "iperf-TCP" -Direction Inbound –Protocol TCP –LocalPort 5201 -Action Allow -Profile Any**

#### Wireshark ####
There is no silent installation of winPCap. Only the version Pro provides silent installation.
To capture with Tshark all traffic in non-promiscuous mode,  with exception of RDP for 300 seconds:

**tshark -i 1 -a duration:300 -p -f "not port 3389" -w capture%date:~10,4%%date:~4,2%%date:~7,2%.pcap.pcap**





###  <span style="color:darkblue">Note for CentOS hosts</span> ###

Iperf can be installed from Extra Packages for Enterprise Linux (EPEL) repository:

``-`` Checking the package repositories:
**yum repolist**

``-``Check the list of repository:
**ls /etc/yum.repos.d**

``-``install the EPEL repository on the system: **sudo yum install epel-release**

``-`` install iperf on that system:
**sudo yum install iperf**



On Linux you can use ping with specific options to achieve similar results to psping in windows:

**ping -U -q -c 300 -s 1200 <IP>**

The options are as follows:


**-U** display full user-to-user latency, not just network round trip time.

**-q** Print only the first line and the summary

**-c** The number requests to send at one second intervals (300 = 5 minutes worth)

**-s** The number of bytes sent for each ping



####  REFERENCE

**iperf**: https://iperf.fr/

**psping**: https://technet.microsoft.com/en-us/sysinternals/psping.aspx

**Tshark**: https://www.wireshark.org/



