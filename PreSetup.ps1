<#
set of powershell commands to pre-setup the Windows 2012R2 hosts/VMs to run iperf, psping, tshark.
the script 
  -install IIS to run psping on port 80
  -disable Internet Explorer Enhanced Security Configuration 
  -setup the firewall to accept UDP and TCP iperf connection on port 80
  - accept the emula license of psping  

#>
### powershell to disable IE Enhanced Security Configuration
function Disable-InternetExplorerESC {
    $AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
    $UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
    Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
    Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
    Stop-Process -Name Explorer
    Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Green
}


### Instal IIS on windows Server 2012R2 inclusive of Management tools
Install-WindowsFeature -name Web-Server -IncludeManagementTools -Restart

### Enable the ICMP for ping IPV4
Set-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)" -enabled True -Profile Any

### Enable incoming connection to receive incoming iperf traffic through the windows firewall
New-NetFirewallRule -DisplayName "iperf-TCP" -Name "iperf-TCP" -Direction Inbound –Protocol TCP –LocalPort 5201 -Action Allow -Profile Any

### Enable incoming connection to receive incoming iperf traffic through the windows firewall
New-NetFirewallRule -DisplayName "iperf-UDP" -Name "iperf-UDP" -Direction Inbound –Protocol UDP –LocalPort 5201 -Action Allow -Profile Any

### Enable IE ESC
Disable-InternetExplorerESC

### Add wrireshark path
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Wireshark\", [EnvironmentVariableTarget]::Machine)


### Set Emula in psping
# cmd reg.exe ADD HKCU\Software\Sysinternals\PsPing /v EulaAccepted /t REG_DWORD /d 1 /f