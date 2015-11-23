$datacenter = Get-Datacenter -Name "LE01"
$refESXi = 'ESX01.lenzker.local' # vSwitch portgroups from this vSwitch will be used
$numUplinkPorts = 2 # Number of Uplinks
$vDSName = 'LE01vDS' # name of the new VDS

$vDS = New-VDSwitch -Name $vDSName -Location $datacenter -NumUplinkPorts $numUplinkPorts

$portgroups =  Get-VMHost $refESXi | Get-VirtualPortGroup



foreach ($pg in $portgroups){
	If($pg.vlanid -eq 4095){
		$vDS | New-VDPortgroup -Name $pg.name -VlanTrunkRange '0-4094'
	}
	else {
		$vDS | New-VDPortgroup -Name $pg.name -VlanID $pg.VlanID
	}
}

### Enable the health-check
Get-View -ViewType DistributedVirtualSwitch|?{($_.config.HealthCheckConfig|?{$_.enable -notmatch "true"})}|%{$_.UpdateDVSHealthCheckConfig(@((new-object Vmware.Vim.VMwareDVSVlanMtuHealthCheckConfig -property @{enable=1;interval="1"}),(new-object Vmware.Vim.VMwareDVSTeamingHealthCheckConfig -property @{enable=1;interval="1"})))}

