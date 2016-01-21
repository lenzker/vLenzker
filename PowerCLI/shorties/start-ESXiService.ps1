# PowerCLI SCript to start specific services on ESXi hosts

# The following service-keys can be used in the where part
<#Key                  Label                          Policy     Running  Requi
---                  -----                          ------     -------  -----
DCUI                 Direct Console UI              on         True     False
TSM                  ESXi Shell                     on         True     False
TSM-SSH              SSH                            on         True     False
lbtd                 Load-Based Teaming Daemon      on         True     False
lwsmd                Active Directory Service       off        True     False
ntpd                 NTP Daemon                     on         True     False
pcscd                PC/SC Smart Card Daemon        off        False    False
sfcbd-watchdog       CIM Server                     on         True     False
snmpd                SNMP Server                    on         False    False
vmsyslogd            Syslog Server                  on         True     True
vmware-fdm           vSphere High Availability A... off        False    False
vprobed              VProbe Daemon                  off        False    False
vpxa                 VMware vCenter Agent           on         True     False
xorg                 X.Org Server                   on         False    False
DCUI                 Direct Console UI              on         True     False
TSM                  ESXi Shell                     off        False    False
TSM-SSH              SSH                            on         True     False
lbtd                 Load-Based Teaming Daemon      on         True     False
lwsmd                Active Directory Service       off        False    False
ntpd                 NTP Daemon                     off        False    False
pcscd                PC/SC Smart Card Daemon        off        False    False
sfcbd-watchdog       CIM Server                     on         False    False
snmpd                SNMP Server                    on         False    False
vmsyslogd            Syslog Server                  on         True     True
vmware-fdm           vSphere High Availability A... off        False    False
vprobed              VProbe Daemon                  off        False    False
vpxa                 VMware vCenter Agent           on         True     False
xorg                 X.Org Server                   on         False    False
DCUI                 Direct Console UI              on         True     False
TSM                  ESXi Shell                     off        False    False
TSM-SSH              SSH                            on         True     False
lbtd                 Load-Based Teaming Daemon      on         True     False
lwsmd                Active Directory Service       off        False    False
ntpd                 NTP Daemon                     off        False    False
pcscd                PC/SC Smart Card Daemon        off        False    False
sfcbd-watchdog       CIM Server                     on         False    False
snmpd                SNMP Server                    on         False    False
vmsyslogd            Syslog Server                  on         True     True
vmware-fdm           vSphere High Availability A... off        False    False
vprobed              VProbe Daemon                  off        False    False
vpxa                 VMware vCenter Agent           on         True     False
xorg                 X.Org Server                   on         False    False
#>

Get-VMHost | Get-VMhostService | Where-Object {$_.Key -eq "TSM-SSH"} | Start-VMHostService
