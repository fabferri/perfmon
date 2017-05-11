$pathFiles = Split-Path -Parent $PSCommandPath 
$rootPath  = $pathFiles+"\"


$dirList=Get-ChildItem -dir $rootPath
foreach ($singledir in $dirList)
{
  write-host -foregroundcolor Green "FolderName: "$singledir
  $pathIn=$rootPath+$singledir
  $Namefile=Get-ChildItem $pathIn -name -Filter *.txt  -Exclude "*psping*"
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
        $status=(($line -Match "\W*(byte)\W*") -and ($line -Match "sec") -and ( $i -ne 0 ) -and ($line -NotMatch "sender") -and ($line -NotMatch "receiver"))
     }
     else   ###################### MANIPULATION MULITPLE STREAM
     {
       $status=(($line -Match "\[SUM") -and ( $i -ne 0 ) -and ($line -NotMatch "sender") -and ($line -NotMatch "receiver"))
     }
     if ($status)
     { 
            # remove all before the "]"
            $pos = $line.IndexOf("]")
            $line = $line.Substring($pos+1)
            
            # remove the presence of space of time interval
            $pos = $line.IndexOf("sec")
            $left = $line.Substring(0,$pos)
            $left=$left.replace(' ','')

            $right =$line.Substring($pos+("sec".Length))

            $pos=$right.IndexOf("Bytes")

            $right=$right.Substring($pos+("Bytes".Length))
            $right=$right -replace '\s+', ' '
            $line=$left+$right

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
            # $sampleTimeEnd =$interval.Substring($interval.IndexOf('-')+1)
            # $sampleTime = $sampleTimeEnd.Substring(0, $sampleTimeEnd.IndexOf("."))
            # $record= $sampleTime+ "`t"+$b
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