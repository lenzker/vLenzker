#### PowerCLI Initialization. Put this in fron of all Powershell scripts to use PowerCLI CMDlets
### Taken from blogs.vmware.com


if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
. “C:\Program Files (x86)\VMware\Infrastructure\vSphere PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1″
}