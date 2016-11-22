#For specific Clusters
#$Clusters = @("ClusterName1,ClusterName2")

#For all Cluster connected to a vCenter
$Clusters = Get-Cluster

$Communities = ""
$Syscontact = ""
$Syslocation = ""
#Comma seperated List of Targets/Community
$Targets = "tar.get.net/TrapCommunity"

foreach($cluster in $Clusters){

	foreach($esx in Get-Cluster $cluster | Get-VMHost){
		$esxcli = Get-EsxCli -VMHost $esx
		$result = $esxcli.system.snmp.set($null,$Communities,$true,$null,"indications",$true,"info","1.3.6.1.4.1.6876.4.90.0.401",161,$null,$null,$true,$Syscontact,$Syslocation,$Targets,$null,$null)

		#$esxcli.system.snmp.set(string authentication, string communities, boolean enable, string engineid, string hwsrc, string loglevel, string notraps, long port, string privacy, string remoteusers, boolean reset, string syscontact, string syslocation, string targets, string users, string v3targets)

		Write-Host "Host:", $esx.Name, "Result", $result
	}
}