### Input Parameter

$vCenter = ''
$esxiName = '' # Use the same ESXi name as in the webclient OR keep the *
$input = 'C:\Temp\configBundle-esx01.lenzker.local.tgz'   # Configuration/Backup File, e.g.

###

Write-Host "Please make sure ESXi $($esxiName) is in maintenance mode"


Connect-VIServer $vCenter

$esx = get-VMHost $esxiName

$esx | Set-VMHostFirmware -Restore -Force -SourcePath $input

Disconnect-VIServer * -confirm:$false