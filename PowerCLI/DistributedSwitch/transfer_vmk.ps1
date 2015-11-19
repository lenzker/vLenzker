#Migrate vNIC and VMkernelAdapter to vDS
#Assumptions: Portgroup names on vDS are identical to those on the vSS

$esxHosts = Get-VMHost 'esx01*','esx02*','esx03*'

foreach ($esx in $esxHosts){
	$VMhostAdapters = $esx | Get-VMHostNetworkadapter | Where {$_.Name -match 'vmk'}
    foreach ($VMhostAdapter in $VMhostAdapters){

	    $currentPortgroup = $VMhostAdapter.PortgroupName
	    $newPortgroupname = Get-VDPortgroup -Name $currentPortgroup 

	    Set-VMHostNetworkAdapter -PortGroup $newPortgroupname -VirtualNic $VMhostAdapter -confirm:$false
    } 
}
