$results = @()

$cluster = get-cluster | Sort-Object -Property Name
$dcName = (Get-Datacenter).Name
$networks = Get-View -viewtype Network

Foreach ($network in $networks){
    $pgname = $network.Name
    $pg = Get-VDPortgroup -Name $pgname
    $vlanid = $pg.vlanConfiguration.VlanID
    $connectedports = ($network.VM).count

    $details = @{
        PortgroupName = $pgname
        VLANID = $vlanId
        NumberOfConnectedPorts = $connectedports
        Datacenter = $dcName
    }

    $results += New-Object PSObject -Property $details
}

$results | export-csv -Append -Path c:\temp\newvDSnetworkConnected.csv -NoTypeInformation