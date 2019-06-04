﻿#Specify desired DNS forwarders for public DNS resolving

#Add a PTR record for this computer to the reverse lookup zone.  
Add-DnsServerResourceRecordPtr -ZoneName $reversezonename -Name $IPAddresssplit[3] -PtrDomainName $fqdn
#Requires ForestMode of Windows 2008 R2 or higher

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
    Enable-ADOptionalFeature –Identity $identity –Scope ForestOrConfigurationSet –Target $target -Confirm:$False
}