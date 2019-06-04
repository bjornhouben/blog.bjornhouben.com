<########################################################################################

Name		:	Get-GroupMemberships
Date		:	February 20th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Determine GroupMemberShips of users.

                In this case, some users are member of multiple functional groups, while the design assumes a user can only be a member a single functional group.
                This script helps determine which users are members of how many functional groups and which ones.

Assumptions	:  

Known issues:	

Limitations	:	Requires Windows Server 2008 R2 with the ActiveDirectory PowerShell module

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


#Import the ActiveDirectory module
Import-Module ActiveDirectory

#Define the outputfile variables
$date = get-date
$filepath = "C:\"
$filename = $computername +"GroupMemberships_Report_"
$filedate = get-date -format "dd-MM-yyyy_HH.mm"
$filextension = ".csv"
$outputfile = $filepath + $filename + $filedate + $filextension

#Create a header line and write it to screen and the outputfile
$header = "ADuser;groupnamefilter;matchinggroupscount;matchinggroup"
$header | write-host
$header | out-file -filepath $outputfile -append


Function get-groupmemberships($ADuser,$groupnamefilter) #Create Function to get (specific) group memberships
{
    #To show all group memberships for an user:
    #get-groupmemberships "Administrator" ""

    #To show only group memberships for an user for groups that match "F_BAG_" :
    #get-groupmemberships "Administrator" "F_BAG_"
    

    #Reset the variables to ensure no old data is being presented
    $groups = $NULL
    $matchinggroups=@()
    $matchinggroupscount = 0

    #Get the group memberships for a user
    $groups = @($((Get-ADUser $ADuser -Properties *).MemberOf -split (",")  | Select-String -SimpleMatch "CN=") -replace "CN=","")

    
    Foreach($group in $groups) #Group memberships that match the groupnamefilter and are not "USERS"are added to $matchinggroups and $matchinggroupscount
    {
        IF($group -match $groupnamefilter)
        {
            $matchinggroups += $group
            $matchinggroupscount ++
        }   
    }

    Foreach($matchinggroup in $matchinggroups) #Output the desired info to screen and $outputfile for $matchinggroups
    {
        $output = "$ADuser;$groupnamefilter;$matchinggroupscount;$matchinggroup"
        $output | write-host
        $output | out-file -filepath $outputfile -append
    }
}

#Specify the users for which the group membership needs to be determined. Use "get-help get-aduser -full" to see filtering options.
$ADusers = (Get-ADUser -Filter * -SearchBase "OU=NL,OU=Demo Users,DC=Corp,DC=BjornHouben,DC=COM").SamAccountName


Foreach($ADuser in $ADusers) #Run the get-groupmemberships functions for each $ADuser and filter only groups matching "F_BAG_"
{
    get-groupmemberships $ADuser "F_BAG_"
}