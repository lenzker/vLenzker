#This requires PowerCLI 6.3 at minimum

#Check this values with Array vendor
$queuefullsamplesize =  0
$queuefullthreshold =  0
$Vendor = "3PARdata"
  
$Clusters = @("Cluster-9*")

foreach($cluster in $Clusters){
    Get-Cluster $cluster | Get-VMHost | ForEach-Object {  
  
  
        $esxcli = get-esxcli -VMHost $_ -V2  
        $arguments = $esxcli.storage.core.device.set.CreateArgs()  
        $arguments.queuefullsamplesize = $queuefullsamplesize   
        $arguments.queuefullthreshold = $queuefullthreshold  
      
        ($_ | Get-ScsiLun -LunType disk | where vendor -eq $Vendor).CanonicalName | ForEach-Object {  
		#Use this line if you only want to set on a single Disk
        #($_ | Get-ScsiLun -LunType disk | where CanonicalName -eq "naa.600xxxxxxxxxxxxx").CanonicalName | ForEach-Object {
            $arguments.device = $_  
            $esxcli.storage.core.device.set.Invoke($arguments)  
        }  
    }  
}