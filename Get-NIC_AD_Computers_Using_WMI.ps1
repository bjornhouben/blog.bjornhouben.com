<########################################################################################

Name		:	Get-NIC_AD_Computers_Using_WMI
Date		:	Februari 19th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   A new Wireless network infrastructure was being introduced, but an inventory had to be made of all NICs in the clients
                to make sure they are compatible or not. This script connects to Active Directory and then queries WMI of all the clients for
                their NIC information. In this case the Wi-Fi adapters were all Broadcom adapters.

Assumptions	:	
                

Known issues:	

Limitations	:	If possible, use PowerShell remoting instead because it is better, faster and only requires 1 port to be allowed through the firewall.

Notes   	:   -Remote registry service needs to be enabled on the remote servers.
                -Requirements for remote WMI need to be met. Think of by example DCOM, WMI and RPC. Also the client must be on ofcourse.
                -The account used, needs to have sufficient permissions on the remote computers.
                -For servers in the same subnet and Active Directory domain this is often the case. 

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	Create a single logfile that only contains unique values and that gets updated every run of the script.

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	February 19 2013	:	Created script
 
########################################################################################>

#Explore all options using: Get-WmiObject -Class Win32_NetworkAdapter | Get-Member

#Define logfile location
$logfile = "C:\Wifiadapterinventory.txt"

#Request credentials with permissions on remote computer
#Enter credentials in format : domain\username
$credential = get-credential

#Run script on Server 2008 R2 Active Directory Domain Controller or later because the AD module needs to be imported.
Import-module ActiveDirectory

#Get all computers from AD in a specific OU, matching a specific filter. Modify where necessary
$computers = Get-ADComputer -LDAPFilter "(name=*)" -SearchBase "OU=Clients,DC=BJORNHOUBEN,DC=LOCAL"

#Define $NICnamefilter
$NICnamefilter = "Broadcom"

Foreach($computer in $computers)
{
    $computername = $computer.DNSHostName

    #Define wifiadapters in array for each server
    $wifiadapters = Get-WmiObject -Class Win32_NetworkAdapter -ComputerName $computername -credential $credential | where {$_.name -match $NICnamefilter}

    #Write output for each wifi adapter matching the filter
    Foreach($wifiadapter in $wifiadapters)
    {
        $wifiadaptername = $wifiadapter.name
        #Even if a computer is not reachable, an entry will be made in the logfile containing just the computername. Filter empty results in by example Excel.
        $output = "$computername;$wifiadaptername"

        #Write output to console
        $output | write-host

        #Write output to logfile
        $output | out-file -filepath $logfile -append
    }
}