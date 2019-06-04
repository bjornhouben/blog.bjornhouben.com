<########################################################################################

Name		:	Get-AdObjectProtectedFromAccidentalDeletion
Date		:	January 9th 2013
Author		:	Bjorn Houben
Blog        :   http://blog.bjornhouben.com
Website		:	http://www.bjornhouben.com
Linkedin	:	http://nl.linkedin.com/in/bjornhouben

Purpose		:   Determine AD objects that are protected from accidental deletion by checking their ACL. If everyone is denied access, it is protected from accidental deletion.

Assumptions	:	
                

Known issues:	

Limitations	:	

Notes   	:   For more information about protection from accidental deletion, read this blog post: 
                http://blogs.technet.com/b/industry_insiders/archive/2007/10/31/windows-server-2008-protection-from-accidental-deletion.aspx


Disclaimer	:	This script is provided AS IS without warranty of any kind. I disclaim all implied warranties including, without limitation,
			    any implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of the use or
			    performance of the sample scripts and documentation remains with you. In no event shall I be liable for any damages whatsoever
			    (including, without limitation, damages for loss of business profits, business interruption, loss of business information,
			    or other pecuniary loss) arising out of the use of or inability to use the script or documentation. 

To improve  :	

Copyright   :   I believe in sharing knowledge, so this script and its use is subject to : http://creativecommons.org/licenses/by-sa/3.0/

History     :	Januari 9 2013	:	Created script
 
########################################################################################>

$ADobjects = Get-ADobject -filter *
Foreach($ADobject in $ADobjects)
{
    $ADObjectName = $ADobject.Name
    $ADobjectDN = $ADobject.DistinguishedName
    IF(@((Get-Acl $ADobjectDN).access | where{($_.IdentityReference -eq "Everyone") -and ($_.AccessControlType -eq "Deny")}).count -lt 1)
    {
        write-host "IsNotProtectedFromAccidentalDeletion;$ADObjectName;$ADobjectDN"
    }
    ELSE
    {
        write-host "IsProtectedFromAccidentalDeletion;$ADObjectName;$ADobjectDN"
    }
}