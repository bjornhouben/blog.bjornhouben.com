<########################################################################################

Name		:	Get percentage physical and virtual servers in VMware vSphere
Date		:	Januari 13th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Script to automate determining for each VMware Virtual Center number of physical and virtual servers.

Assumptions	:   -VMware PowerCLI is installed
                -A single account is used that has permissions on all Vmware Virtual Infrastructure server to be accessed.
                -You are able to connect to all Vmware Virtual Infrastructure servers.

Known issues:	

Limitations	:	Manual configuration of Vmware Virtual Infrastructure servers is required.

Notes   	:   -This script has been tested on PowerShell 3.0
                -By default, the script only shows totals and percentages for each location and writes it to the console.
                -You can easily have information written to file as well using by example: $output | out-file -filepath $logfilefullpath -encoding ASCII -append 

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 13th 2013	:	Created script
 
########################################################################################>



#Define the Virtual Infrastructure server to query and their location. DO not use spaces in location name.
$VIservers = @("VirtualCenter1.corp.bjornhouben.com","VirtualCenter2.corp.bjornhouben.com")

#Load the VMware powerCLI snapin
Add-PSsnapin VMware.VimAutomation.Core

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

    $viServerHostsTotal = 0
    $viServerVMsTotal = 0

    #Define a header row
    $header = "VI server;vSphere Data Center;vSphere Cluster;# Of ESX hosts in cluster;# of VMs in cluster;% Physical in cluster;% Virtual in cluster"

    #Write output
    $header | write-host -ForegroundColor Green

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

            #Determine for one VM in this cluster in which datacenter it is running. Does not need to be determined for each and saves time/processing.
            $datacenter = (Get-Datacenter -VM $vmsoncluster[0]).name

            #Determine the percentage of physical and virtual processors
            $percentagephysical = [Math]::Round(($hostcount/($hostcount+$vmsonclustercount))*100,0)
            $percentagevirtual = [Math]::Round(($vmsonclustercount/($hostcount+$vmsonclustercount))*100,0)

            #Define output
            $output = "$VIserver;$datacenter;$cluster;$hostcount;$vmsonclustercount;$percentagephysical;$percentagevirtual"

            #Write output
            $output | write-host -ForegroundColor White
    } 

    #Calculate percentage totals
    $percentagephysicalTotal = [Math]::Round(($viServerHostsTotal/($viServerHostsTotal+$viServerVMsTotal))*100,0)
    $percentagevirtualTotal = [Math]::Round(($viServerVMsTotal/($viServerHostsTotal+$viServerVMsTotal))*100,0)

    #Define output for totals:
    $totalsheader = "VI Server;Total # of ESX hosts on VI server;Total # of VMs on VI server;% of ESX hosts on VI server;% of VMs hosts on VI server"
    $totalsoutput = "$VIserver;$viServerHostsTotal;$viServerVMsTotal;$percentagephysicalTotal;$percentagevirtualTotal"

    #Write output for totals:
    write-host " "
    $totalsheader | write-host -ForegroundColor Yellow
    $totalsoutput | write-host -ForegroundColor White

    #Disconnect the viServer
    Disconnect-VIServer $Viserver -Confirm:$false
}

#Run the function for each viServer as defined in $VIservers
Foreach($VIserver in $VIservers)
{
    Get-vcenterOverview $VIserver
    write-host " "
    write-host " "
    write-host " "
}