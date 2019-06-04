<########################################################################################

Name		:	New-DomainGPOReport
Date		:	January 13th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   

Assumptions	:  

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

History     :	January 13 2013	:	Created script
 
########################################################################################>


#Define variables
$ReportType = "HTML"
$ReportSaveLocation = "C:\" #If you specify a directory, you have to make sure it exists already.
$ReportDestination = "_GPOReports_All_"
$timestamp = get-date -format dd-M-yyyy-HH.MM

#Get the current AD Forest and DC
$domain = (Get-ADDomain).DNSroot
$server = (Get-ADDomain).PDCEmulator

#Construct the Reportfile
$ReportFile = $ReportSaveLocation + $domain + $ReportDestination + $timestamp + "." +$ReportType

#Create-Report
Get-GPOReport -All -Domain $domain -Server $server -ReportType $ReportType -Path $ReportFile

#Outputfile example: C:\corp.bjornhouben.com_GPOReports_All_06-1-2013-10.01.HTML