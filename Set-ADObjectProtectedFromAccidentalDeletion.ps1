<########################################################################################

Name		:	Set-ProtectedFromAccidentalDeletion.ps1
Date		:	January 8th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Automate protecting Active Directory objects from accidental deletion.

Assumptions	:	
                

Known issues:	

Limitations	:	

Notes   	:   -Inside the script, there are multiple commands you can use to protect only those AD objects you want to protect.
                -Even though you can enable the Active Directory recycle bin and restore objects from it, it is better to prevent the accidental deletion in the first place.
                -For more information about protection from accidental deletion, read this blog post: 
                http://blogs.technet.com/b/industry_insiders/archive/2007/10/31/windows-server-2008-protection-from-accidental-deletion.aspx


Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 8 2013	:	Created script
 
########################################################################################>


#Get-ADobject class names
#get-adobject -filter * | select objectclass | group objectclass

#Protect specific AD object classes from accidental deletion
#get-adobject -filter * | where{($_.ObjectClass -eq "container") -or ($_.ObjectClass -eq "organizationalunit") -or ($_.ObjectClass -eq "user") -or ($_.ObjectClass -eq "group") -or ($_.ObjectClass -eq "computer")} | Set-ADObject -ProtectedFromAccidentalDeletion $true

#Protect all AD organizational units from accidental deletion
#Get-ADOrganizationalUnit -filter * | Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion $true

#Protect all AD objects from accidental deletion
#Get-ADobject -filter * | Set-ADObject -ProtectedFromAccidentalDeletion $true