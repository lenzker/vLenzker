### Input Parameter

$vCenter = ''
$VMName = ''

### Logic

Connect-VIServer $vCenter | Out-Null

$Datastores = Get-VM $VMName | Get-Datastore 

Write-Host 'Datastore Name , RuntimeName (L equals LunID)'
Write-Host ''

Foreach ($ds in $datastores){
   $lun = $ds | Get-ScsiLun | select -First 1
   Write-Host $ds.Name , $lun.runtimeName
}


Disconnect-VIServer * -confirm:$false