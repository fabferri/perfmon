<#
Description:
   the script to run network benchmarks in iperf.
   The script run iperf as client -c. 
   You can run in parallel to iperf the utility psping, Tshark and a collector to pickup the system counters.

   
INPUT VARIABLES:
   $arrayIperfCmd: array of iperf clients commands, to run in sequence
   $runPsping    : flag to run psping.
                   Possibile values:
                   $true: enable psping | $false: skip the psping

   $runTshark    : flag to run Tshark trace.
                   Possibile values:
                   $true: enable the capture in Tshark | $false: skip the capture 

   $runSysParams : flas to collect system paramenters. 
                   Possibile values:
                   $true: enable the collector | $false: skip the collection of system
NOTE:
  the script requires that you have start the iperf server in the other host.

REFERENCE:
  iperf: https://iperf.fr/
  psping: https://technet.microsoft.com/en-us/sysinternals/psping.aspx
  Tshark: https://www.wireshark.org/

#>
############################# INPUT PARAMS ##############################################
<#################################################################
$arrayIperfCmd =(
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10 -t 10",
"iperf3.exe -R -c 10.0.2.4 -P 1 -t 10 -t 10",               
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10 -w 64K",
"iperf3.exe -R -c 10.0.2.4 -P 1 -t 10 -w 64K",            
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10 -w 128K",
"iperf3.exe -R -c 10.0.2.4 -P 1 -t 10 -w 128K",
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10 -w 256K",
"iperf3.exe -R -c 10.0.2.4 -P 1 -t 10 -w 256K",
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10 -w 512K",
"iperf3.exe -R -c 10.0.2.4 -P 1 -t 10 -w 512K",
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10 -w 600K",
"iperf3.exe -R -c 10.0.2.4 -P 1 -t 10 -w 600K",
"iperf3.exe    -c 10.0.2.4 -P 2 -t 10",
"iperf3.exe -R -c 10.0.2.4 -P 2 -t 10",
"iperf3.exe    -c 10.0.2.4 -P 3 -t 10",
"iperf3.exe -R -c 10.0.2.4 -P 3 -t 10",
"iperf3.exe    -c 10.0.2.4 -P 4 -t 10",
"iperf3.exe -R -c 10.0.2.4 -P 4 -t 10"
)
#####################################################################>

$arrayIperfCmd =(
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10",
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10 -w 128K",
"iperf3.exe    -c 10.0.2.4 -P 1 -t 10 -w 256K"
)




$pspingCmd = "psping64.exe -4 -n 10s 10.0.2.4:80 -nobanner"
$TsharkCmd = "tshark.exe -i 1 -a duration:10 -p -f ""not port 3389"" -w "
$SysParamsDuration = "10"

$runPsping    = $true
$runTshark    = $true
$runSysParams = $true
##########################################################################################



$iperfCmd=@()
$pathFiles = Split-Path -Parent $PSCommandPath 
$rootPath  = $pathFiles+"\"

function diffTime
{
    param(  [Parameter(Mandatory=$true)] [System.DateTime]$Time1,
            [Parameter(Mandatory=$true)] [System.DateTime]$Time2 )

    $TimeDiff = New-TimeSpan $Time1 $Time2
    if ($TimeDiff.Seconds -lt 0)
    {
	    $Hrs = ($TimeDiff.Hours) + 23
	    $Mins = ($TimeDiff.Minutes) + 59
	    $Secs = ($TimeDiff.Seconds) + 59
    }
    else
    {
	    $Hrs = $TimeDiff.Hours
	    $Mins = $TimeDiff.Minutes
	    $Secs = $TimeDiff.Seconds
    }
    $Difference = '{0:00}:{1:00}:{2:00}' -f $Hrs,$Mins,$Secs
    write-host -ForegroundColor Green  "Start time          : " $Time1
    write-host -ForegroundColor Green  "End time            : " $Time2
    write-host -ForegroundColor Yellow "Total Execution Time: " $Difference
}



function submitIperf 
{
    param(  [Parameter(Mandatory=$true)] [System.String]$pathExecFile,
            [Parameter(Mandatory=$true)] [System.String]$iperfCmd,
            [Parameter(Mandatory=$true)] [System.String]$logFile)
            
      $singleJob=Start-Job -Name "iperf" -ScriptBlock { 
          param( $pathExecFile, $iperfCmd, $logFile)  
      
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
      $timeStart = (Get-Date -format yyy_MM_dd-HH:mm:ss).toString()
 
      cmd /c  $pathExecFile$p1 $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10 $p11 $p12

#####     cmd /c  echo "IPERF: $p1 $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10 $p11 $p12"  >> $logFile
#####     cmd /c  $execFile $p1 $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10 $p11 $p12 >> $logFile
 
          
          Start-Sleep -s 2
          # read the log file
          $f = Get-Content $logFile 
          # add to the beginning
          $b = "IPERF: $p1 $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10 $p11 $p12"
          Set-Content $logFile –value $b, $f

          $a=Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet 2"
          $ipInterface=$a.IPAddress
          $hostName ="VM: "+$env:computername+" -IP: "+ $ipInterface + " Startime: " + $timeStart
          $f = Get-Content $logFile
          Set-Content $logFile –value $hostName, $f

      } -ArgumentList ( $pathExecFile, $iperfCmd, $logFile) 
      return $singleJob
}

function submitJobPSPING 
{
    param(  [Parameter(Mandatory=$true)] [System.String]$pathExecFile,
            [Parameter(Mandatory=$true)] [System.String]$pspingCmd,
            [Parameter(Mandatory=$true)] [System.String]$logFile)
            
      $singleJob=Start-Job -Name "psping" -ScriptBlock { 
          param ( $pathExecFile, $pspingCmd, $logFile)  

      $params = @()
      $params=$pspingCmd.split(' ')
      $p1=""; $p2="";$p3="";$p4="";$p5=""; $p6=""; $p7=""; $p8=""; $p9=""; $p10=""

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
        }
      }  

      cmd /c  echo "PSPING: $pspingCmd" >> $logFile 
      cmd /c  $pathExecFile$p1 $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10 >> $logFile

      } -ArgumentList ( $pathExecFile, $pspingCmd, $logFile) 
      return $singleJob
}

function submitJobTshark 
{
    param(  [Parameter(Mandatory=$true)] [System.String]$pathExecFile,
            [Parameter(Mandatory=$true)] [System.String]$TsharkCmd,
            [Parameter(Mandatory=$true)] [System.String]$logFile)
            
      $singleJob=Start-Job -Name "tshark" -ScriptBlock { 
          param ( $pathExecFile, $TsharkCmd, $logFile)  

      # regular expression to split the command, avoiding fragmentation in case of presence of double quote in the string
      $params = @()
      $RegexOptions = [System.Text.RegularExpressions.RegexOptions]
      $csvSplit = '( )(?=(?:[^"]|"[^"]*")*$)'
      $params = [regex]::Split($TsharkCmd, $csvSplit, $RegexOptions::ExplicitCapture)

      $p1=""; $p2="";$p3="";$p4="";$p5=""; $p6=""; $p7=""; $p8=""; $p9=""; $p10=""
 
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
        }
      }  

       cmd /c  $p1 $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10
###      Invoke-Expression "& `"C:\Program Files\Wireshark\Tshark.exe`" $p2 $p3 $p4 $p5 $p6 $p7 $p8 $p9 $p10"
       
      } -ArgumentList ( $pathExecFile, $TsharkCmd, $logFile) 
      return $singleJob
}

function CollectPerf 
{            
  param(            
         [string]$hostName,            
         [string]$hostIPAddress,            
         [string]$logFolder ,
         [int]$sampleInterval,
         [int]$SysParamsDuration                   
       ) 

    write-host ">>> hostname            :" $hostName
    write-host ">>> IP Addr             :" $hostIPAddress
    write-host ">>> Folder              :" $logFolder
    write-host ">>> SamplingTime        :" $sampleInterval
    write-host ">>> Duration            :" $SysParamsDuration
    $singleJob=Start-Job -Name "counters" -ScriptBlock { 
          param ($hostName, $hostIPAddress, $logFolder, $sampleInterval, $SysParamsDuration) 

          $delimiter = "`t"     
          $params = @("\Processor(_total)\% Processor Time",
             "\Processor(_total)\% User Time",
             "\Processor(_total)\% Privileged Time",
             "\Processor(_total)\Interrupts/sec",
             "\Processor(_total)\% DPC Time",
             "\Processor(_total)\DPCs Queued/sec",
             "\Processor(_total)\% Idle Time",
             "\Processor(_total)\% Interrupt Time",
             "\Memory\Page Faults/sec",
             "\Memory\Available Bytes",
             "\Memory\Committed Bytes",
             "\Memory\Commit Limit",
             "\Memory\Pages/sec",
             "\Memory\Available MBytes",
             "\network interface(microsoft hyper-v network adapter _2)\Bytes Total/sec",
             "\network interface(microsoft hyper-v network adapter _2)\Bytes Received/sec",
             "\network interface(microsoft hyper-v network adapter _2)\Bytes Sent/sec",
             "\network interface(microsoft hyper-v network adapter _2)\Packets Received/sec"
             "\network interface(microsoft hyper-v network adapter _2)\Packets Sent/sec",
             "\network interface(microsoft hyper-v network adapter _2)\Packets Outbound Discarded",
             "\network interface(microsoft hyper-v network adapter _2)\Packets Outbound Errors",
             "\network interface(microsoft hyper-v network adapter _2)\Packets Received Discarded",
             "\network interface(microsoft hyper-v network adapter _2)\Packets Received Errors",
             "\PhysicalDisk(_total)\Current Disk Queue Length",
             "\PhysicalDisk(_total)\% Disk Time",
             "\PhysicalDisk(_total)\Avg. Disk Queue Length",
             "\PhysicalDisk(_total)\Avg. Disk Read Queue Length",
             "\PhysicalDisk(_total)\Avg. Disk Write Queue Length",
             "\PhysicalDisk(_total)\Avg. Disk sec/Transfer",
             "\PhysicalDisk(_total)\Avg. Disk sec/Read",
             "\PhysicalDisk(_total)\Avg. Disk sec/Write")

    # create a folder if it doesn't exist
    $b=test-path -path $logFolder -pathtype container
    if ($b -eq $false)
    {
       try
       {
           New-Item -ItemType Directory  -Path $logFolder -ErrorAction SilentlyContinue
        }
        catch
       {
           $ErrorMessage = $_.Exception.Message
           $FailedItem = $_.Exception.ItemName
           write-host "failure to create the folder $logFolder. The error message was $ErrorMessage"
       }
    }

       ## create an array of string with name of parameters to write the related filename
       $arrayParamName = @()
       foreach($p in $params)            
       {          
            $a=$p.substring($p.LastIndexOf("\"))
            $a=$a.replace("sec","Sec")
            $a=$a.replace("%","Perc")
            $a=$a.replace("\","")
            $a=$a.replace("/","")
            $a=$a.replace(".","")         
            $a=$a.replace(" ","")
            $arrayParamName += @($a)  
       }
       $NumSamples=[math]::floor($SysParamsDuration/$sampleInterval)
       $metrics =Get-Counter -ComputerName $hostIPAddress -Counter $params -SampleInterval $sampleInterval -MaxSamples $NumSamples  

       foreach($metric in $metrics)            
       {            
           $obj = $metric.CounterSamples | Select-Object -Property Timestamp, Path, CookedValue;            
           # add these columns as data                      
           $obj | Add-Member -MemberType NoteProperty -Name Computer -Value $hostIPAddress -Force;      
           for ($i=0; $i -lt $obj.Count; $i++)
           {
               $str=$obj[$i].Path
               [int] $pos = $str.LastIndexOf('\');
               $rightPart = ($str.Substring($pos + 1)).Split(':')
               $counterName = $rightPart[0].Trim();

               $value=$obj[$i].CookedValue
               $timestamp=$obj[$i].Timestamp
               $record=$timestamp.ToString("dd-MM-yyyy HH:mm:ss",[System.Globalization.CultureInfo]::InvariantCulture)+$delimiter+$counterName+$delimiter+$value

               # $arrayParamName
               $File=$logFolder+"\"+$hostName+"-"+$arrayParamName[$i]+".txt"
               out-file -Append -filepath $File  -inputobject $record -encoding ASCII
               # write-host -ForegroundColor Cyan $record 
               # if ($i -eq ($obj.Count-1))
               # { 
               #    $str="-------------------------------------------------------"
               #    write-host -ForegroundColor Yellow $str
               # }
           }
       }
     } -ArgumentList ($hostName, $hostIPAddress, $logFolder, $sampleInterval, $SysParamsDuration)
     return $singleJob
}
function statusJobs
{
    param(  [Parameter(Mandatory=$true)] [System.Collections.ArrayList]$Jobs )

     $str="----- JOB STATUS -----------------------------------------"
     write-host $str

     $numRunningJob=0
     ForEach ($j in $Jobs)
     {
      try {
          if ($j.State -eq "Completed") 
          {             
             $str="-----JobID:"+[string]$j.Id +"¦" +"JobName:" +$j.Name +"¦" +"JobState: " +$j.State
             write-host $str
          }
          if ($j.State -eq "Running") 
          {
             $numRunningJob++
             $str = "-----JobID:"+[string]$j.Id +"¦" +"JobName:"+ $j.Name +"¦" +"JobState: "+ $j.State
             write-host $str
          }
          if ($j[0].State -eq "Failed") 
          {              
               $str=$j[0].ChildJobs[0].JobStateInfo.Reason
               write-host $str
          }
          }
          catch {
               $ErrorMessage = $_.Exception.Message
               $FailedItem = $_.Exception.ItemName
               write-host "Error Message:" $ErrorMessage
               write-host "Failed Item  :" $FailedItem
               write-host "catch error-sleep 3 sec"
               Start-Sleep -Seconds 3
               Continue
               }
     }
     $str="----------------------------------------------------------"
     write-host $str
     return $numRunningJob
}

function RemoveJobs 
{
    param(  [Parameter(Mandatory=$true)] [System.Collections.ArrayList]$Jobs)

     $str="----- REMOVING JOBS -----------------------------------------"
     write-host $str

     
     ForEach ($j in $Jobs)
     {
      try {
          if ($j.State -eq "Completed") 
          {             
             $str="-----JobID:"+[string]$j.Id +"¦" +"JobName:" +$j.Name +"¦" +"JobState: " +$j.State
             write-host -ForegroundColor Cyan $str
             #### Remove-Job -Id $j.Id -Verbose 
             Remove-Job -Id $j.Id 
             $str="-----JobID:"+[string]$j.Id +"¦" +"JobName:" +$j.Name +"-> Removed" 
             write-host -ForegroundColor Cyan $str
          }
          if ($j.State -eq "Running") 
          {
             
             $str = "-----JobID:"+[string]$j.Id +"¦" +"JobName:"+ $j.Name +"¦" +"JobState: "+ $j.State
             write-host "the job should in status Completed, but it is still running"
          }
          if ($j[0].State -eq "Failed") 
          {              
               $str=$j[0].ChildJobs[0].JobStateInfo.Reason
               write-host $str
          }
          }
          catch {
               $ErrorMessage = $_.Exception.Message
               $FailedItem = $_.Exception.ItemName
               write-host "Error Message:" $ErrorMessage
               write-host "Failed Item  :" $FailedItem
               write-host "catch error-sleep 3 sec"
               Start-Sleep -Seconds 3
               Continue
               }
     }
}
###################################### MAIN program ######################################

foreach ($iperfCmd in $arrayIperfCmd)
{
  [System.Collections.ArrayList]$Jobs = @()
  $TimeStart = Get-Date -format HH:mm:ss
  $time=(Get-Date -format yyyyMMddHHmmss).ToString()
  
  New-Item -ItemType Directory -Force -Path $rootPath -Name $time
  write-host ""
  $labelFile=$iperfCmd.Replace("iperf3.exe","").Replace(" ","")
  ### =========================================
  if ( $runPsping)
  {
     $logFile = $rootPath+$time + "\" + $env:computername+ "_"+ "psping_"+ $labelFile + ".txt"
     $pathExecFile = $rootPath 
     write-host -foreground Green "PSPINGCMD: "$pspingCmd  
     $singleJob=submitJobPSPING $pathExecFile $pspingCmd $logFile  
     $Jobs += @($singleJob)   
  }
  ### =========================================  
  if ($runTshark)
  {
     $logFile = $rootPath + $time + "\" + $env:computername+ "_"+ "tshark_"+ $labelFile + ".cap"
     $pathExecFile ="C:\Program Files\Wireshark\"
   
     $TsharkCmdFinal = $TsharkCmd+$logFile
     write-host -foreground Cyan "TsharkCMD: "$TsharkCmd 
     $singleJob=submitJobTshark $pathExecFile $TsharkCmdFinal $logFile 
     $Jobs += @($singleJob)
  }
  ### =========================================
  if ($runSysParams)
  {
     ### Submit a job to collect system counters.
     $hostName = $env:computername
     $logFolder=$rootPath + $time +"\"+ $env:computername+ "_" + "syscounters"+"\"
     $hostIPAddress="127.0.0.1"
     $sampleInterval = 1
     write-host "hostname:" $hostName "- IPAddress:" $hostIPAddress "- logFolder" $logFolder
     $singleJob=CollectPerf $hostName $hostIPAddress $logFolder $sampleInterval $SysParamsDuration
     $Jobs += @($singleJob) 
  }  

  $logFile = $rootPath + $time + "\" + $env:computername+ "_"+ "iperf"+ $labelFile + ".txt"
  $execFile = $rootPath + "iperf3.exe"
  $pathExecFile = $rootPath
  $cmd=$iperfCmd -replace '\s+',  " "
  $iperfCmd = $cmd+" --logfile "+ $logFile
  write-host -foreground Yellow "IperfCMD: "$iperfCmd 
  $singleJob=submitIperf $pathExecFile $iperfCmd $logFile 
  $Jobs += @($singleJob)

  Do {      
       $numRunningJob= statusJobs $Jobs
       write-host "number of jobs running: "$numRunningJob
       start-sleep -Seconds 5
     } while ($numRunningJob -ge 1)
  
  ## margin delay to write the Tshark trace on the disk
  ### Start-Sleep -s 10  
  RemoveJobs $Jobs 

  $TimeEnd = Get-Date -format HH:mm:ss
  diffTime $TimeStart $TimeEnd
  write-host ""
}