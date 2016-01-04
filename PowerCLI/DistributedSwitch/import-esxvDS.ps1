### Add a list of ESXi Hosts to the specified datacenter and restores the vDS


$datacenter = 'LE01'
$esxList = @('esx01.lenzker.local', 'esx02.lenzker.local', 'esx03.lenzker.local')
$user = 'root'
$password = 'VMare1!'
$vDSLocation = 'C:\Users\Administrator\Desktop\vds_backup.zip'

foreach ($esx in $esxList){
    Add-VMHost -Location $datacenter -Name $esx -Force:$true -User $user -Password $password
}

New-VDSwitch -BackupPath  $vDSLocation  -Location (Get-Datacenter $datacenter) -KeepIdentifiers:$true


