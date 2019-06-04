<########################################################################################

Name		:	Add AD groups to AD group using Quest AD snapin.ps1
Date		:	November 11th 2012
Author		:	Bjorn Houben
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Add multiple Active Directory groups (matching a filter) to another Active Directory group using powershell on a Server 2003 Domain Controller
                (by using the Quest AD snapin).

Assumptions	:	I assume you have some knowledge of PowerShell.

Known issues:	

Limitations	:	

Notes   	:	-Edit the variables $targetgroupname and $groupstoaddtotargetgroup to match your purpose.
                -When using Server 2008 R2 or later consider using the built-in Active Directory module and its cmdlets.

Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	November 11 2012	:	Created script
 
########################################################################################>


#Need to have Quest Snap-in installed: http://www.quest.com/powershell/activeroles-server.aspx

#Add the powershell snap-in
Add-PSSnapin Quest.ActiveRoles.ADManagement

#Specify target group name
$targetgroupname = "group3"

#Specify group name filter to get groups you want to add to target group. group* for example will match group1, group2, group for admins.
$groupstoaddtotargetgroup = "group*"


#Get the distinguished name for your target group
$targetgroupdn = (get-qadgroup -identity $targetgroupname).dn

#Get all the groups you want to add to the targetgroup. Use filtering to get the groups you want.
$groups = get-qadgroup -identity $groupstoaddtotargetgroup

#Loop to add each group to the target group
Foreach($group in $groups)
{
    #Get the distinguished name for the group you want to add to your target group
    $groupdn = $group.dn

    IF($groupdn –eq $targetgroupdn)    {        write-host "Group $group is the same as the target group and was therefore not added." -BackgroundColor Red    }        ELSE	{        add-QADGroupMember -identity $targetgroupdn -member $groupdn    }
}