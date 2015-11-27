#######################################################################
# Name: Scheduled_task_ressource-report.ps1
# Description: Retrieves basic capacity info for VMware clusters
# Created: 2015-09-01
# Author: Fabian Lenz/
# Version: 5.8.11
# Build: 4
# Modified: 2015-11-27
#######################################################################

<#
.SYNOPSIS
This script uses the cluster-evaluator mechanism to craete a ressource report. The output will be stored
in a csv file containing relevant metrics. 

.DESCRIPTION
Retrieves basic capacity info for VMware clusters

.PARAMETER  vcenterlistpath
A txt file with all vCenter that should be checked for. One vCenter FQDN per line
e.g

.EXAMPLE
PS C:\> .\ressource-report.ps1 C:\Path\To\vcenterlist.txt

.NOTES
Author: Fabian Lenz
Date: 13/01/2015
#>

param(
[Parameter(Mandatory=$true)]
[String]$vcenterlistpath
)


function Get-ClusterCapacityCheck {


[CmdletBinding()]
param(
[Parameter(Position=0,Mandatory=$true,HelpMessage="Name of the cluster to test",
ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$true)]
$Clusterlist
)

begin {	
$Finish = (Get-Date -Hour 0 -Minute 0 -Second 0)
$Start = $Finish.AddDays(-1).AddSeconds(1)

New-VIProperty -Name FreeSpaceGB -ObjectType Datastore -Value {
param($ds)
[Math]::Round($ds.FreeSpaceMb/1KB,0)
} -Force | out-null

}

process {
$statobjlist = @()
Foreach ($Clustername in $Clusterlist){

    $Cluster = Get-Cluster $Clustername
    $Datacenter = (Get-Datacenter -Cluster $cluster).Name

    $ClusterCPUCores = $Cluster.ExtensionData.Summary.NumCpuCores
    $ClusterEffectiveMemoryGB = [math]::round(($Cluster.ExtensionData.Summary.EffectiveMemory / 1KB),0)

    $ClusterVMs = $Cluster | Get-VM

    $ClusterVMsNumber = ($ClusterVMs | measure).Count	

    $ClusterAllocatedvCPUs = ($ClusterVMs | Measure-Object -Property NumCPu -Sum).Sum
    $ClusterAllocatedMemoryGB = [math]::round(($ClusterVMs | Measure-Object -Property MemoryMB -Sum).Sum / 1KB)

    $vCPUratio = 12
    #$CPUfree = [math]::round($ClusterCPUCores - ($ClusterAllocatedvCPUs/12.0),2)
    $CPUfree = $ClusterCPUCores*$vCPUratio - $ClusterAllocatedvCPUs
    $RAMfree = $ClusterEffectiveMemoryGB - $ClusterAllocatedMemoryGB 

    $VMHosts = $Cluster | Get-VMHost
    $VMHost = $VMHosts | Select-Object -Last 1
    $Datastore = $VMHost | Get-Datastore 

    $ClusterFreeDiskspaceGB = ($Datastore | Where-Object {$_.Extensiondata.Summary.MultipleHostAccess -eq $True} | Measure-Object -Property FreeSpaceGB -Sum).Sum
    $DISKCapacity =  ($Datastore| Where-Object {$_.Extensiondata.Summary.MultipleHostAccess -eq $True} | Measure-Object -Property CapacityGB -Sum).Sum
    $DiskConsumed = $DISKCapacity - $ClusterFreeDiskspaceGB 

    # Calculating VMs left based on the average consumption on each building block and the minmal number. THis number includes the failover capacity

    $numberOfHosts = ($VMHosts | Measure).Count
    $numberOfDatastore = ($Datastore | Measure).Count

    write-Host $Clustername 

    If($ClusterVMsNumber -ne 0){

        $CPUratio = [Math]::Round($ClusterAllocatedvCPUs / $ClusterVMsNumber,3)
        $VMvCPULeft = [Math]::Round((($ClusterCPUCores*$vCPUratio) * ($numberOfHosts - 1)/$numberOfHosts - $ClusterAllocatedvCPUs) / $CPUratio, 0)
        if($VMvCPULeft -le 0){
            $VMvCPULeft = 0
        }

        #SAMPLE 
        # CPUratio = 678 / 264 = 2,568
        # VMvCPULeft = (((96 * 12) * (9-1)/9 - 678) / 2,568 

        $RAMratio = [Math]::Round(($ClusterAllocatedMemoryGB / $ClusterVMsNumber),3)
        $VMRamLeft = [Math]::Round((($ClusterEffectiveMemoryGB) * ($numberOfHosts - 1)/$numberOfHosts - $ClusterAllocatedMemoryGB) / $RAMratio, 0)

        if($VMRamLeft -le 0){
            $VMRamLeft = 0
        }

        $DiskRatio = [Math]::Round($DiskConsumed / $ClusterVMsNumber,3)
        $CapacityLeft = [Math]::Round($DISKCapacity - (50*$numberOfDatastore),3) 
        $VMDiskLeft = [Math]::Round(($CapacityLeft - $DiskConsumed) / $DiskRatio,0)

        if($VMDiskLeft -le 0){
            $VMDiskLeft = 0
        }

        # DiskRatio = 23122 / 431
        # CapacityLeft = 28485 - (53,64*1,1*57)
        # VMDiskLeft = (25121  - 23122 ) / 53,64 = 37

        $VMleftArray = @()
        $VMleftArray += $VMvCPULeft
        $VMleftArray += $VMRamLeft
        $VMleftArray += $VMDiskLeft

        $VMleft = ($VMleftArray | Measure-Object -Minimum).Minimum

        switch($VMleft){

            $VMvCPULeft {$limittingRessource = 'CPU'}
            $VMRamLeft {$limittingRessource = 'RAM'}
            $VMDiskLeft {$limittingRessource = 'DISK'}
        }
    }

    else{
        $VMleft = ''
    }

    $dataobject = New-Object -TypeName PSObject -Property @{

    Datacenter = $Datacenter 
    Cluster = $Cluster.Name
    NUmberOfVDI = $ClusterVMsNumber 
    CPUCapacity = $ClusterCPUCores*$vCPUratio
    CPUConsumed = $ClusterAllocatedvCPUs
    CPUFree = $CPUfree 
    RAMCapacity = $ClusterEffectiveMemoryGB
    RAMConsumed = $ClusterAllocatedMemoryGB
    RAMFree = $RAMfree 
    DISKCapacity = $DISKCapacity 
    DISKConsumed = $DiskConsumed 
    DISKFree = $ClusterFreeDiskspaceGB
    VMLeft = $VMLeft
    limittingRessource = $limittingRessource
    }

    $statobjlist += $dataobject
    }
return $statobjlist 

}
}

#######################################################################
# Include VMware-PowerCLI SnapIn

if(!(Get-PSSnapin | Where {$_.name -eq "vmware.vimautomation.core"}))
{
	try
	{
		Write-Host "Adding PowerCLI snap in"
		Add-PSSnapin VMware.VimAutomation.Core -ea 0| out-null
	}
	catch
	{
		throw "Could not load PowerCLI snapin"
	}
}

$vcenterlist = get-content $vcenterlistpath

Connect-ViServer $vcenterlist

$clusterlist = @()
Foreach ($cluster in Get-Cluster){
	$clusterlist += $cluster.name
}

$stat = Get-ClusterCapacityCheck $clusterlist 
$timestamp = Get-Date -format "dd-MM-yyyy"
$file = 'C:\TEMP\'+$env:computername+'-'+$timestamp+'.csv'

If(test-path $file){
	'Old report is existing. Deleting it and Creating a new file.' | Write-host
	remove-item $file
}

$NewLine = 'Datacenter;Cluster;NUmberOfVDI;vCPUCapacity;RAMCapacity;DISKCapacity;vCPUConsumed;RAMConsumed;DISKConsumed;vCPULeft;RAMFree;DISKFree;estimatedRDHLeft;limittingRessource'
$NewLine | Add-Content $file

Foreach ($el in $stat){

	$NewLine = "{0};{1};{2};{3};{4};{5};{6};{7};{8};{9};{10};{11};{12};{13}" -f $el.Datacenter ,$el.Cluster ,$el.NUmberOfVDI ,$el.CPUCapacity ,$el.RAMCapacity ,$el.DISKCapacity ,$el.CPUConsumed,$el.RAMConsumed ,$el.DISKConsumed ,$el.CPUFree ,$el.RAMFree ,$el.DISKFree, $el.VMLeft, $el.limittingRessource
	$NewLine | Add-Content $file 
}

DisConnect-ViServer * -confirm:$false



