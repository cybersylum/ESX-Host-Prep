<#
ESXHostPrep.ps1

DISCLAIMER - This runs in my lab and should run in most environments.  Please test thoroughly.  Feel free to change/modify/copy code as you see fit.

Written to run on a single host after it has been initially installed.  It was not designed to run against vCenter itself
  - use root credentials when prompted
  - Must create vSwitch before running (designed for virtual standard switches)  

Customizing for your environment
1. Change the VLAN definitions to match your environment - note a vlan of 131 is added as portgroup called vlan131 with a VLAN ID of 131.   If your environment uses different
conventions, you can adapt the script in a number of ways
2. If the portgroups should be added to vSwitch other than vSwitch1, you need to update that in the "#Add port groups" section below
3. update the $NTPserver variable to your preferred value
4. update the $SyslogServer variable to your preferred value. this script uses UDP.  Can change to TCP in #Syslog section below
#>

# Define VLANs for potential Clusters
$DC1VLANs = ("131","136","137","138","141","199","250","611","612","613","614","615","670","671","96")
$DC2VLANs = ("100","110","196","198","200","201","225","231","236","237","238","241","251","611","612","613","614","615","670","671")
$TESTVLANs = ("110","198","200","201","225","231","236","237","238","241")

$NTPserver = "pool.ntp.org"
$SyslogServer = "syslog.cybersylum.com"

#Prompt for host-specific info
$esxhost = Read-Host "Enter the Hostname or IP Address for the ESX server you wish to configure"
#connect to host
Connect-VIServer -Server $esxhost

$location = Read-Host "Enter the name of the cluster where this host will operate (DC1, DC2, TEST)"
$VLANs = "none"

#Prepare VLANs based on user input
Switch ($location) {
	"DC1" {$VLANs = $DC1VLANs}
	"DC2" {$VLANs = $DC2VLANs}
	"TEST" {$VLANs = $TESTVLANs}
	Default  {
		Write-Host -ForegroundColor Red Invalid VLAN selection.  No changes will be made
		exit
	}
}

#make changes

#Add port groups on vSwitch1
Write-Host -ForegroundColor Green Adding port groups to vSwitch1
$vs = Get-VirtualSwitch -vmhost $esxhost -name vSwitch1
foreach ($vlan in $VLANs) {
	$vs | new-virtualPortGroup -Name vlan$vlan -vlanid $vlan
}

#NTP settings
Get-VmHostService -vmhost $esxhost| Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "on"
Get-VmHostService -vmhost $esxhost| Where-Object {$_.key -eq "ntpd"} | Stop-VMHostService -Confirm:$false; Get-VMHost | Get-VmHostService | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "on"; Get-VMHost | Add-VMHostNtpServer -NtpServer $NTPserver; Get-VMHost | Get-VMHostFirewallException | Where-Object {$_.Name -eq "NTP client"} | Set-VMHostFirewallException -Enabled:$true; Get-VMHost | Get-VmHostService | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService

#Syslog
Get-VMHostFireWallException  -Name Syslog | Set-VMHostFirewallException -Enabled:$True
get-vmhost | Get-AdvancedSetting -Name Syslog.global.logHost | Set-AdvancedSetting -Value udp://$SyslogServer -Confirm:$false

#wrap up
Disconnect-VIServer -Server $esxhost -Confirm:$False