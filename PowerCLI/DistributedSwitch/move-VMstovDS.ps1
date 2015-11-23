# Migrate VM from old to the new corresponding vDS portgroup

$esxHosts = Get-VMHost 'esx01*','esx02*','esx03*' # VMs will be migrated from these hosts
$vDSName = 'LE01vDS'

### Logic

$vDS = Get-Virtualswitch -Name $vDSName

foreach ($esx in $esxHosts){
    $VMs = $esx | Get-VM
    foreach ($VM in $VMs){
        $oldPGs = $VM  | Get-VirtualPortGroup
        foreach ($oldPG in $oldPGs){
            $newPG = $vDS | Get-VirtualPortGroup | Where {$_.Name -eq $oldPG.name}
            $VM | Get-NetworkAdapter | Where {$_.Networkname -eq $newPG.Name} | Set-NetworkAdapter -NetworkName $newPG -confirm:$false
        }   
    }
}
