<#
Description:
   The script use powershell jobs to copy the file from a source folder to destination folder.
   The copy operation runs through robocopy.

   The script use powershell jobs to run multiple copy operation in parallel.
#>

######################################################################
# define empty arrays
[System.Collections.ArrayList]$sourceFile=@()        ## List of source files need to be copied
[System.Collections.ArrayList]$destinationFile=@()   ## List of destination files

$totalNumParallelJobs = 3                            ## total number of parallel jobs
$trackInterval        = 3                            ## polling interval to track the status of the jobs
$sourceDir            = "C:\Users\test1\"            ## source folder
$destDir              = "C:\Users\test2\"            ## destination folder
$fileExe              = "robocopy.exe"               ## executable command; in this case Robocopy 

######################################################################
$pathFiles = Split-Path -Parent $PSCommandPath
$time=(Get-Date -format yyyyMMddHHmmss).ToString()
$logFile = "$pathFiles\"+$time+"-OutputLog.txt"

function writeLog
{
    param([Parameter(Mandatory=$true)] [System.String]$str)
    $time=(Get-Date -format yyyy-MM-dd:HH:mm:ss).ToString()
    $str=$time+$str
    write-host -foregroundcolor Cyan $str
    Out-File -FilePath $Global:logfile -Encoding  utf8 -Append -inputobject $str;
}

function logJobStart
{
      param([Parameter(Mandatory=$true)] [System.Collections.ArrayList]$sourceFile,
            [Parameter(Mandatory=$true)] [System.Collections.ArrayList]$destinationFile)

      $str = "**** START A NEW COPY  job: " + $singleJob.Name
      writeLog $str
      

      $str= "**** Source file     :" +$sourceFile
      writeLog $str

      $str= "**** Destination file:" +$destinationFile
      writeLog $str


      $str= " " 
      writeLog $str
}


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

function statusJobs
{
    param(  [Parameter(Mandatory=$true)] [System.Collections.ArrayList]$Jobs )

     $numRunningJob=0
     ForEach ($j in $Jobs)
     {
      try {
          if ($j.State -eq "Completed") 
          {             
             $str="-----JobID:"+[string]$j.Id +"¦" +"JobName:" +$j.Name +"¦" +"JobState: " +$j.State
             writeLog $str
          }
          if ($j.State -eq "Running") 
          {
             $numRunningJob++
             $str = "-----JobID:"+[string]$j.Id +"¦" +"JobName:"+ $j.Name +"¦" +"JobState: "+ $j.State
             writeLog $str
          }
          if ($j[0].State -eq "Failed") 
          {              
               $str=$j[0].ChildJobs[0].JobStateInfo.Reason
               writeLog $str
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
     $str="---->TOTAL NUMBER OF RUNNING JOBS:" +$numRunningJob.ToString()
     writeLog $str
     $str="----------------------------------------------------------"
     writeLog $str
     return $numRunningJob
}


function submitNewJob 
{
    param(  [Parameter(Mandatory=$true)] [System.String]$fileExe,
            [Parameter(Mandatory=$true)] [System.String]$sourceFile,
            [Parameter(Mandatory=$true)] [System.String]$destinationFile)
      
     $pathFiles = Split-Path -Parent $PSCommandPath 
     $time=(Get-Date -format yyyyMMddHHmmss).ToString()
     $journalFolder = $pathFiles+"\"+$time+"-job"+"\"

     $str=" "
     Write-host $str
            
     $str="================================== SUBMIT JOB =================================="
     Write-host $str

     $str="-----source file     :" + $sourceFile
     Write-host $str

     $str="-----destination file:" + $destinationFile
     Write-host $str

     $singleJob=Start-Job -ScriptBlock { 
          param (  $fileExe, $sourceFile, $destinationFile, $pathFiles )
          #   $list | % { $_ }
       
       $timeStart=Get-Date 
#######    $rnd=Get-Random -Minimum 30 -Maximum 60
#######    Start-Sleep -Seconds $rnd 
       
       $sourceFileName = Split-Path $sourceFile -leaf
       $sourcePath = Split-Path $sourceFile -Parent
       $destinationPath = Split-Path $destinationFile -Parent

       & $fileExe $sourcePath $destinationPath $sourceFileName /Z /W:5 /V
       $timeEnd=Get-Date
       $timeDiff=($timeEnd-$timeStart).Seconds
       
       ## write runtime to log file
       $timeStamp=$timeStart.ToString("yyyyMMddHHmmss")
       $logFile = "$pathFiles\"+$timeStamp+"-runtime.txt"
       $str1= "Startime      : "+$timeStart.ToString("yyyyMMddHHmmss")
       $str2= "Endtime       : "+$timeEnd.ToString("yyyyMMddHHmmss")
       $str3= "Total seconds : "+$timeDiff
       Out-File -FilePath $logfile -Encoding  utf8 -Append -inputobject $str1
       Out-File -FilePath $logfile -Encoding  utf8 -Append -inputobject $str2
       Out-File -FilePath $logfile -Encoding  utf8 -Append -inputobject $str3
       ##
     } -ArgumentList ( $fileExe, $sourceFile, $destinationFile, $Global:pathFiles) 
     return $singleJob
}



function GetListSourceFile
{
    param( [Parameter(Mandatory=$true)] [System.String]$sourcePath)

    $tmpList=Get-ChildItem -Path $sourcePath  –File |  Select-Object FullName
    $fileList=$tmpList.FullName
    foreach ($sFile in $fileList) {
      $global:sourceFile += ,@($sFile)
    }
}

function GetListDestFile
{
   param( [Parameter(Mandatory=$true)] [System.String]$destDir)

  foreach($sFile in $global:sourceFile){
    write-host $sFile
    $nameDestFile = Split-Path $sFile -leaf
    $fullDest = Join-Path $destDir $nameDestFile 
    $global:destinationFile += ,@($fullDest)
  }


}
function JobControl 
{
    param(  [Parameter(Mandatory=$true)] [System.String]$fileExe,
            [Parameter(Mandatory=$true)] [System.Collections.ArrayList]$sourceFile,
            [Parameter(Mandatory=$true)] [System.Collections.ArrayList]$destinationFile
            )


  [System.Collections.ArrayList]$Jobs = @()
  $numRunningJob=0
  
  
  While ($sourceFile.count -gt 0) 
  {
     if ($numRunningJob -lt $Global:totalNumParallelJobs)
     {
        # convert the Array element to string
        $sFile=[string]$sourceFile[0]
        $dFile=[string]$destinationFile[0]
        $singleJob= submitNewJob $fileExe $sFile $dFile  
       
        $Jobs += @($singleJob)      

        logJobStart $sourceFile[0] $destinationFile[0]
      
        $sourceFile.RemoveAt(0) 
        $destinationFile.RemoveAt(0)  
     }

     $numRunningJob= statusJobs $Jobs

     start-sleep -Seconds $Global:trackInterval
  }

  
 Do {
       $numRunningJob= statusJobs $Jobs
       start-sleep -Seconds $Global:trackInterval
    } while ($numRunningJob -ge 1)

  foreach($job in $Jobs){
    Receive-Job -Name $job.Name | Out-File $logFile -Encoding  utf8 -Append 
  }
#  start-sleep -Seconds 5
#  $Jobs | Remove-Job -Force
  return $Jobs
}

###################################### MAIN program ######################################


$checkSource=Test-Path $sourceDir
$checkDest=Test-Path $destDir
if (($checkSource -eq $true) -and ($checkDest -eq $true))
{  
   GetListSourceFile $sourceDir
   GetListDestFile $destDir
}


$str = "======================================================================================="
writeLog  $str

$Jobs = @()
$TimeStart = Get-Date -format HH:mm:ss
if (($sourceFile.count -gt 0) -and ($destinationFile.Count -gt 0))
{
   $Jobs = JobControl $fileExe $sourceFile $destinationFile
}

$str= " _____________________________________________________________________"
writeLog $str
$str= "|--------------------- Copy operation completed ----------------------|"
writeLog $str
$str= " _____________________________________________________________________"
writeLog $str


$TimeEnd = Get-Date -format HH:mm:ss
diffTime $TimeStart $TimeEnd
