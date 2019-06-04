<########################################################################################

Name		:	Enable-ADRecycleBin.ps1
Date		:	January 4th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Automate enabling the Active Directory Recycle Bin for AD Forests with functional level of Server 2008 R2 or higher.

Assumptions	:	Forest Functional Level is Server 2008 R2 or higher.
                

Known issues:	

Limitations	:	

Notes   	:   Once the Active Directory Recycle Bin has been enabled, it cannot be disabled.


Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 4 2013	:	Created script
 
########################################################################################>


#Get the current AD Forest
$ADForest = Get-ADForest

#Get the name of the forest
$Target = $ADForest.name

#Split the name of the forest for later use
$parts = @($Target.split("."))

#Set the start identity that is necessary to enable the AD Recycle Bin
$identity = "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration"

#Add each part of the AD forest name to the identity in a way that it can be used to enable the AD Recycle Bin
Foreach($part in $parts)
{
    $identity = $identity + ",DC=" + $part
}

#Enable the AD Recycle Bin Feature if it has not been enabled already.
#Beware, this is an irreversible action.

IF((Get-ADOptionalFeature -identity $identity | where {$_.name -eq "Recycle Bin Feature"}) -eq $NULL)
{
    Enable-ADOptionalFeature –Identity $identity –Scope ForestOrConfigurationSet –Target $target #-Confirm:$False
}