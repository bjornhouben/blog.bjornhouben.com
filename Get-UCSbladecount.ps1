<########################################################################################

Name		:	Get-UCSbladecount
Date		:	January 13th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Script to automate determining the number of blades in a Cisco UCS chassis.

Assumptions	:   -Cisco UCS PowerTool is installed : http://developer.cisco.com/web/unifiedcomputing/pshell-download
                -A single account is used that has permissions on all Cisco UCS environments to be accessed.
                -You are able to connect to all Cisco UCS environments

Known issues:	

Limitations	:	

Notes   	:   

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 13 2013	: Created script
 
########################################################################################>


# Import the Cisco UCS PowerTool module                             #
Import-Module "C:\Program Files (x86)\Cisco\Cisco UCS PowerTool\Modules\CiscoUcsPS\CiscoUcsPS.psd1"

#Define $UCSservers and their location
$UCSservers = @(("UCS1.corp.bjornhouben.com","Location1"),("UCS2.corp.bjornhouben.com","Location2"))

#Have user specify credentials. Assumption is that the same credentials can be used for all UCS servers.
$credential = get-credential

#Define header
$UCSheader = "Location;UCS server;# of blades"

#Write header
write-host $UCSheader

#Get bladecount for each server in $UCSservers
Foreach($UCSserver in $UCSservers)
{
    $Connection = $UCSServer[0]
    $Location = $UCSServer[1]
    
    #Connect to UCS and suppress connection output
    Connect-Ucs $UCSConnectionID -credential $credential | out-null 
    $bladecount = (Get-UCSblade).count
    $output = "$location;$connection;$bladecount"
    write-host $output
    Disconnect-UCS
}