#Set Advanced Settings für ESXi Hosts

$OnOff = 0    # 1 = Enabled,0= Disabled

#If you want specific Cluster
#$Clusters = @("Cluster,Cluster2")

$Clusters = Get-Cluster

foreach($cluster in $Clusters)
{
	foreach($esx in Get-Cluster $cluster | Get-VMHost)
	{
		Get-AdvancedSetting -Entity $esx -Name VMFS3.UseATSForHBOnVMFS5 | Set-AdvancedSetting -Value $OnOff -Confirm:$false 
		#Get-AdvancedSetting -Entity $esx -Name VMFS3.HardwareAcceleratedLocking | Set-AdvancedSetting -Value $OnOff -Confirm:$false 
	}
}