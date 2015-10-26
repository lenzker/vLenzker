### Input Parameter

$vCenter = ''
$esxiName = '' # Use the same ESXi name as in the webclient OR keep the *
$output = 'C:\Temp'

###

Connect-VIServer $vCenter

get-VMHost $esxiName | Get-VMHostFirmware -BackupConfiguration -DestinationPath $output

Disconnect-VIServer * -confirm:$false