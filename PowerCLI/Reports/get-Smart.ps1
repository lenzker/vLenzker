# Change Parameter
$vCenter = 'vcsa01.lenzker.local'
$ClusterName ='CL01'
$outputfile = 'c:\temp\smart.csv'

### codeblock

Connect-VIServer -$vCenter 
$resultList = @()

$Cluster = Get-Cluster -Name $ClusterName
$ESXs = $Cluster | Get-VMHost | Where {$_.ConnectionState -eq 'Connected'}
Foreach ($ESX in $ESXs){
        $scsidevs = $ESX | Get-Scsilun | Where {$_.isLocal -eq $True -AND $_.canonicalName -notmatch 'mpx'}
	$esxcli = $ESX | Get-ESXCLI -v2
	$arguments = $esxcli.storage.core.device.smart.get.CreateArgs()
	
	foreach ($scsidev in $scsidevs){
		write-host "Gathering Smart-Data from $scsidev.canonicalName"
		$arguments.devicename = $scsidev.canonicalName
		$smart = $esxcli.storage.core.device.smart.get.Invoke($arguments)
		
		$healthstatus = ($smart | Where {$_.Parameter -contains 'Health Status'}).Value	
		$readerror = ($smart | Where {$_.Parameter -like'Read Error Count'}).Value	
		$writeerror = ($smart | Where {$_.Parameter -contains 'Write Error Count'}).Value
		$temperature = ($smart | Where {$_.Parameter -contains 'Drive Temperature'}).Value	
		
				
		$resultList += New-Object -TypeName PSCustomObject -Property @{
				esx = $ESX.Name
				devname = $arguments.devicename
				healthstatus = $healthstatus 
				readerror = $readerror
				writeerror = $writeerror
				temperature = $temperature
				} | Select esx, devname, healthstatus, readerror, writeerror, temperature
		}
	
}

$resultfile = $resultList | export-csv -Path $outputfile -notype

