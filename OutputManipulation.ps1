<#
Description:
   the script get the outcome of iperf log and reduce the date to two columns: time, bandwidth
   the file can be easly imported in excel to plot the graph.
   Before running the script adjust the name of file "HOSTFILE_*.txt" (see below)
#>

$pathFiles = Split-Path -Parent $PSCommandPath 
$rootPath  = $pathFiles+"\"

$dirList=Get-ChildItem -dir
foreach ($singledir in $dirList)
{
  write-host -foregroundcolor Green "FolderName: "$singledir
  $pathIn=$rootPath+$singledir
  $Namefile=Get-ChildItem $pathIn -name -Filter HOSTFILE_*.txt  -Exclude PSPING*
  write-host -foregroundcolor Yellow "FileName  : "$Namefile
  $fileIn= $pathIn+ "\"+ $Namefile
  write-host $fileIn

  $pathOut=$pathIn
  $fileOut= $fileIn + "_CLEANUP.txt"
  write-host $fileOut

  $ins = New-Object System.IO.StreamReader  $fileIn
  $outs = New-Object System.IO.StreamWriter $fileOut

[int]$count=0
while( !$ins.EndOfStream ) 
{
   $line = $ins.ReadLine();
   if ($line.Contains("[SUM"))
   {
     $multipleStreams=$true
     $count = $count+1
   }
}

Write-host -foreground Yellow "count multistream- num records: "$count

$ins.BaseStream.Seek(0,[System.IO.SeekOrigin]::Begin)
$ins.DiscardBufferedData();

$global:b
$global:interval


while( !$ins.EndOfStream ) 
{
     $line = $ins.ReadLine(); 
     if ($count -eq 0)  ###################### MANIPULATION SINGLE STREAM
     {
        $status=(($line -Match "\W*(byte)\W*") -and ( $i -ne 0 ) -and ($line -NotMatch "sender") -and ($line -NotMatch "receiver"))
     }
     else   ###################### MANIPULATION MULITPLE STREAM
     {
       $status=(($line -Match "\[SUM") -and ( $i -ne 0 ) -and ($line -NotMatch "sender") -and ($line -NotMatch "receiver"))
     }
     if ($status)
     { 
            $option = [System.StringSplitOptions]::RemoveEmptyEntries
            $a=$line.split(" ", $option)

            for ($i=0; $i -lt $a.length; $i++) 
            {
                   if ($a[$i] -Match "\W*-\W*")
                   {
                      $interval=$a[$i]
                   }
	               if ($a[$i] -Contains "Gbits/sec")
                   {
                      $b=1000*[decimal]($a[$i-1])
                      write-host -ForegroundColor Cyan  "bandwidth:"$b
                   }
                   if  ($a[$i] -Contains "Mbits/sec")
                   {
                      $b =[decimal]($a[$i-1])
                      write-host -ForegroundColor Cyan  "bandwidth:"$b
                   }
                   if  ($a[$i] -Contains "Kbits/sec")
                   {
                      $b= ([decimal]($a[$i-1]) /1000) 
                      write-host -ForegroundColor Cyan  "bandwidth:"$b
                   }
                   if  ($a[$i] -Contains "bits/sec")
                   {
                      $b=( ([decimal]($a[$i-1]) /1000)/1000)
                      write-host -ForegroundColor Cyan  "bandwidth"$b
                   }

            } 
             
            $record= $interval+ "`t"+$b
            write-host -ForegroundColor Green $record
            $outs.WriteLine($record);
     }
     $i = $i+1;
}

$outs.Close();
$ins.Close();
$ins.Dispose();
$outs.Dispose();

}