### Gather NAA of RDM  $rdm = get-vm hv-fileserv1 | Get-HardDisk -DiskType "RawPhysical"
### $rdm.ScsiCanonicalName

$naa = "naa.60050768018a86bf10000000000000f2"
$esxs = get-vmhost

foreach($esx in $esxs){
    $esxcli = get-esxcli -VMhost $esx
    $esxcli.storage.core.device.setConfig($false,$naa,$true)
    $esxcli.storage.core.device.list($naa)
}