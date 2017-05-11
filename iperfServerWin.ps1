<#
Description:
   the script to run network benchmarks in iperf
   the script runs iperf as server in a powershell job
 
INPUT VARIABLES: the script do not accept input paramenters

NOTE:
To track the job use the powershell command: get-job
the powershell command get-job shows the job id.
to kill the job, get the  job Id and use the command: remove-job <Id>

#>

function Iperf 
{
    param(  [Parameter(Mandatory=$true)] [System.String]$pathExecFile,
            [Parameter(Mandatory=$true)] [System.String]$iperfCmd,
            [Parameter(Mandatory=$true)] [System.String]$logFile)
      
      $params = @()
      $params=$iperfCmd.split(' ')
      $p1=""; $p2="";$p3="";$p4="";$p5=""; $p6=""; $p7=""; $p8=""; $p9=""; $p10=""; $p11=""; $p12=""

      for($i=0; $i -lt $params.Count; $i++ ) 
      { 
         switch ($i)
         {
            0 {$p1 =$params[$i]}
            1 {$p2 =$params[$i]}
            2 {$p3 =$params[$i]}
            3 {$p4 =$params[$i]}
            4 {$p5 =$params[$i]}
            5 {$p6 =$params[$i]}
            6 {$p7 =$params[$i]}
            7 {$p8 =$params[$i]}
            8 {$p9 =$params[$i]}
            9 {$p10 =$params[$i]}
           10 {$p11 =$params[$i]}
           11 {$p12 =$params[$i]}
        }
      }  
      cmd /c  $pathExecFile$p1 $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10 $p11 $p12

          
          Start-Sleep -s 2
          # read the log file
          $f = Get-Content $logFile 
          # add to the beginning
          $b = "IPERF: $p1 $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10 $p11 $p12"
          Set-Content $logFile –value $b, $f

	  $a=Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet 2"
          $ipInterface=$a.IPAddress
          $hostName ="VM: "+$env:computername+" - IP: "+ $ipInterface
          $f = Get-Content $logFile
          Set-Content $logFile –value $hostName, $f  
}

###################################### MAIN program ######################################

$pathFiles = Split-Path -Parent $PSCommandPath 
while ($true)
{
  $time=(Get-Date -format yyyyMMddHHmmss).ToString()
  $rootPath  = $pathFiles+"\"
  New-Item -ItemType Directory -Force -Path $rootPath -Name $time


   #### INPUR PARAMETERS
   $labelFile=""
   ### =========================================
   Start-Sleep -s 5
   $labelFile=(Get-Date -format yyyyMMddHHmmss).ToString()
   $logFile = $rootPath + $time + "\" + $env:computername+ "_"+ "IPERF_SRV_"+ $labelFile + ".txt"
   $execFile = $rootPath + "iperf3.exe"
   write-host "Logfile--->" $logFile
   $pathExecFile = $rootPath

   $iperfCmd = "iperf3.exe -s -1 --logfile "+$logFile
   Iperf $pathExecFile $iperfCmd $logFile 
}
write-host "Exit from loop"
