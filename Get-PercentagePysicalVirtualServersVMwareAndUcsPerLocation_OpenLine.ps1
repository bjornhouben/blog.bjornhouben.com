<########################################################################################

Name		:	Get percentage physical and virtual servers in VMware vSphere and Cisco UCS per location
Date		:	December 18th 2012
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Script to automate determining for each location the number of physical and virtual servers in VMware vSphere and Cisco UCS.

Assumptions	:   -Cisco UCS PowerTool is installed
                -VMware PowerCLI is installed
                -A single account is used that has permissions on all Cisco UCS and VMware vShere environments to be accessed.
                -You are able to connect to all Cisco UCS and VMware vShere environments

Known issues:	

Limitations	:	Manual configuration of servers and their locations is required.

Notes   	:   -This script has been tested on PowerShell 3.0
                -By default, the script only shows totals and percentages for each location and writes it to the console.
                -You can easily remove commented lines to show more detailed information.
                -You can easily have information written to file as well using by example: $output | out-file -filepath $logfilefullpath -encoding ASCII -append 

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	December 18 2012	:	Created script
 
########################################################################################>


#Define the Virtual Infrastructure IPs to query and their location. DO not use spaces in location name.
$VIservers = @("10.239.200.100","10.239.200.200")

#Define $UCSservers and their location
$UCSservers = @("10.239.200.97","10.239.200.50")

#Define global variables for location Landgraaf
$global:Landgraaf = @("10.239.200.200","10.239.200.97") #Define servers that need to be included for location Beek
$global:LandgraafVirtualTotal = 0
$global:LandgraafPhysicalTotal = 0
$global:LandgraafVMhosts = @()

#Define global variables for location Beek
$global:Beek = @("10.239.200.100","10.239.200.50") #Define servers that need to be included for location Beek
$global:BeekVirtualTotal = 0
$global:BeekPhysicalTotal = 0
$global:BeekVMhosts = @()

#Load the VMware powerCLI snapin
Add-PSsnapin VMware.VimAutomation.Core

# Import the Cisco UCS PowerTool module
# Cisco UCS PowerTool download: http://developer.cisco.com/web/unifiedcomputing/pshell-download
Import-Module "C:\Program Files (x86)\Cisco\Cisco UCS PowerTool\Modules\CiscoUcsPS\CiscoUcsPS.psd1"

#Get credentials. Assumption is that the same credentials can be used for all vCenter environments you connect to. otherwise move this into the function so it will be requested everytime.
#Enter credentials in <domain>\<username> format
$credential = get-credential

#Define function to get vSphere Overview
Function Get-vCenterOverview($viserver)
{
    #Connect to the viServer using the stored credentials. Prevent connection info output using | out-null
    Connect-ViServer $viserver -credential $credential | out-null

    #Get the clusters on the viServer
	$clusters = (get-cluster).name

    #Set the number of hosts and VM's for this VIserver to 0
    $viServerHostsTotal = 0
    $viServerVMsTotal = 0

    #Define a header row
    $header = "VI server;vSphere Data Center;vSphere Cluster;# Of ESX hosts in cluster;# of VMs in cluster;% Physical in cluster;% Virtual in cluster"

    #Write output
    #$header | write-host -ForegroundColor Green

    #Foreach cluster get the hosts and VMs in the cluster and write the outpur
    Foreach($cluster in $clusters)
    {
            #Get the hosts in this cluster
            $hosts = get-vmhost | where{$_.parent -match $cluster}

            #Count the number of hosts in this cluster
            $hostcount = @($hosts).count

            #Add the Hostcount of this cluster to the total # of hosts on this VIserver 
            $viServerHostsTotal += $hostcount

            #Get the VM's that run on hosts in this cluster
            $vmsoncluster = Get-VM | where{$hosts.ID -contains $_.VMHostID}

            #Count the number of VMs on this cluster
            $vmsonclustercount = @($vmsoncluster).count

            #Add the VMcount of this cluster to the total # of Hosts on this VIserver 
            $viServerVMsTotal += $vmsonclustercount

            #Determine for one VM in this cluster in which datacenter it is running
            $datacenter = (Get-Datacenter -VM $vmsoncluster[0]).name

            #Determine the percentage of physical and virtual processors
            $percentagephysical = [Math]::Round(($hostcount/($hostcount+$vmsonclustercount))*100,0)
            $percentagevirtual = [Math]::Round(($vmsonclustercount/($hostcount+$vmsonclustercount))*100,0)

            #Define output
            $output = "$VIserver;$datacenter;$cluster;$hostcount;$vmsonclustercount;$percentagephysical;$percentagevirtual"

            #Write output
            #$output | write-host -ForegroundColor White
    } 

    #Calculate percentage totals
    $percentagephysicalTotal = [Math]::Round(($viServerHostsTotal/($viServerHostsTotal+$viServerVMsTotal))*100,0)
    $percentagevirtualTotal = [Math]::Round(($viServerVMsTotal/($viServerHostsTotal+$viServerVMsTotal))*100,0)

    #Define output for totals:
    $totalsheader = "VI Server;Total # of ESX hosts on VI server;Total # of VMs on VI server;% of ESX hosts on VI server;% of VMs hosts on VI server"
    $totalsoutput = "$VIserver;$viServerHostsTotal;$viServerVMsTotal;$percentagephysicalTotal;$percentagevirtualTotal"

    #Write output for totals:
    #write-host " "
    #$totalsheader | write-host -ForegroundColor Yellow
    #$totalsoutput | write-host -ForegroundColor White

    #Add the totals of the VIserver to the total for the correct location
    IF($global:landgraaf -contains $viserver)
    {
        $Global:LandgraafVirtualTotal += $viServerVMsTotal
        $Global:LandgraafPhysicalTotal += $viServerHostsTotal

        #The VM host names are stored so you can later check the UCS blades against this to prevent duplicates.
        #When you have more virtualcenters in one location, beware that this will be overwritten and will not return the correct values.
        $Global:LandgraafVMHosts = (get-vmhost).name
    }
    ELSEIF($global:Beek -contains $viserver)
    {
        $Global:BeekVirtualTotal += $viServerVMsTotal
        $Global:BeekPhysicalTotal += $viServerHostsTotal

        #The VM host names are stored so you can later check the UCS blades against this to prevent duplicates.
        #When you have more virtualcenters in one location, beware that this will be overwritten and will not return the correct values.
        $Global:BeekVMhostsHosts = (get-vmhost).name
    }

    #Disconnect the viServer
    Disconnect-VIServer $Viserver -Confirm:$false
}

#Run the function for each viServer as defined in $VIservers
Foreach($VIserver in $VIservers)
{
    Get-vcenterOverview $VIserver
}

Function get-NonDuplicateUcsBlades($UCS)
{
    #Connect to UCS and suppress connection output
    Connect-Ucs $UCS -credential $credential | out-null

    #Get the names of the UCS blades
    $UCSblades = (Get-UCSBlade).name
    
    #Define the suffix to be able to compare against the names used in virtual center $Global:LandgraafVMHosts or $Global:BeekVMHosts
    $suffix = ".virtualcenter.lan" 

    #For each blade check in what location it is AND whether it has already been counted in VMware. If this is not the case, add it to the totals.
    Foreach($UCSBlade in $UCSblades)
    {
        $UCSbladefqdn = $ucsblade + $suffix
        IF($global:landgraaf -contains $UCS)
        {
            IF($Global:LandgraafVMhostsHosts -contains $UCSbladefqdn)
            {
                #Duplicate, do not count
            }
            Else
            {
                $Global:LandgraafPhysicalTotal++
                #write-host "not in Vmware: $UCSbladefqdn"
            }
        }
        IF($global:Beek -contains $UCS)
        {
            IF($Global:BeekVMhostsHosts -contains $UCSbladefqdn)
            {
                #Write-already counted in VMware
                #Duplicate, do not count
            }
            Else
            {
                $Global:BeekPhysicalTotal++
                #write-host "not in Vmware: $UCSbladefqdn"
            }
        }

    }
    Disconnect-Ucs
}

#Run the function for each viServer as defined in $UCSservers
Foreach($UCS in $UCSservers)
{
    get-NonDuplicateUcsBlades $UCS
}

#Determine percentages
$percentagephysicalTotalLandgraaf = [Math]::Round(($Global:LandgraafPhysicalTotal/($Global:BeekPhysicalTotal+$global:LandgraafVirtualTotal))*100,0)
$percentagevirtualTotalLandgraaf = [Math]::Round(($global:LandgraafVirtualTotal/($Global:BeekPhysicalTotal+$global:LandgraafVirtualTotal))*100,0)
$percentagephysicalTotalBeek = [Math]::Round(($Global:BeekPhysicalTotal/($Global:BeekPhysicalTotal+$global:BeekVirtualTotal))*100,0)
$percentagevirtualTotalBeek = [Math]::Round(($global:BeekVirtualTotal/($Global:BeekPhysicalTotal+$global:BeekVirtualTotal))*100,0)


#Write output
write-host "Location;Physical hosts;VMs"
write-host "Landgraaf;$Global:LandgraafPhysicalTotal ($percentagephysicalTotalLandgraaf%);$Global:LandgraafVirtualTotal ($percentagevirtualTotalLandgraaf%)"
write-host "Beek;$Global:BeekPhysicalTotal ($percentagephysicalTotalBeek%);$Global:BeekVirtualTotal ($percentagevirtualTotalBeek%)"