# ESX-Host-Prep
a basic powershell script using PowerCLI to set some basic configurations for ESXi hosts

Disclaimer
  * You are free to use or modify this code for your own purposes.
  * Warranty and/or support for this code is not provided or implied.  Use this at your own risk.  Testing is highly recommended.

If you have a small environment or do not use Enterprise Plus licensing (for Host Profiles), this script can help automate some basic configurations that may be the same across a number of hosts.  It can be easily extended to add other configuration items or adjusted to meet the needs in your environment

DISCLAIMER - This runs in my lab and should run in most environments.  Please test thoroughly.  Feel free to change/modify/copy code as you see fit.

Written to run on a single host after it has been initially installed.  It was not designed to run against vCenter itself
  - use root credentials when prompted
  - Must create vSwitch before running (designed for virtual standard switches)  

Customizing for your environment
1. Change the VLAN definitions to match your environment - note a vlan of 131 is added as portgroup called vlan131 with a VLAN ID of 131.   If your environment uses different conventions, you can adapt the script in a number of ways
2. If the portgroups should be added to vSwitch other than vSwitch1, you need to update that in the "#Add port groups" section below
3. update the $NTPserver variable to your preferred value
4. update the $SyslogServer variable to your preferred value. this script uses UDP.  Can change to TCP in #Syslog section below
